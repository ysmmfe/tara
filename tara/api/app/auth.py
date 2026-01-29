from datetime import datetime, timezone

from fastapi import APIRouter, HTTPException

from .db import db
from .google_auth import GoogleAuthError, verify_google_id_token
from .schemas import AuthTokensResponse, GoogleAuthRequest, RefreshRequest
from .security import (
    create_access_token,
    create_refresh_expires_at,
    generate_token,
    hash_token,
)

router = APIRouter(prefix="/auth", tags=["auth"])


@router.post("/google", response_model=AuthTokensResponse)
async def google_login(request: GoogleAuthRequest):
    try:
        payload = verify_google_id_token(request.id_token)
    except GoogleAuthError as exc:
        raise HTTPException(status_code=401, detail=str(exc))

    google_sub = payload.get("sub")
    email = payload.get("email")
    name = payload.get("name") or "Usuário"
    email_verified = bool(payload.get("email_verified", True))

    if not google_sub or not email:
        raise HTTPException(status_code=400, detail="Token do Google incompleto")

    user = await db.user.find_unique(where={"google_sub": google_sub})
    if user is None:
        existing_by_email = await db.user.find_unique(where={"email": email})
        if existing_by_email and existing_by_email.google_sub:
            raise HTTPException(
                status_code=409, detail="Conta já vinculada a outro Google"
            )
        if existing_by_email:
            user = await db.user.update(
                where={"id": existing_by_email.id},
                data={
                    "google_sub": google_sub,
                    "name": name,
                    "email_verified": email_verified,
                },
            )
        else:
            user = await db.user.create(
                data={
                    "name": name,
                    "email": email,
                    "google_sub": google_sub,
                    "email_verified": email_verified,
                }
            )
    else:
        if user.email != email or user.name != name:
            user = await db.user.update(
                where={"id": user.id},
                data={"email": email, "name": name, "email_verified": email_verified},
            )

    access_token = create_access_token(user.id, user.email)
    refresh_token = generate_token()
    refresh_hash = hash_token(refresh_token)
    await db.refreshtoken.create(
        data={
            "user_id": user.id,
            "token_hash": refresh_hash,
            "expires_at": create_refresh_expires_at(),
        }
    )
    return AuthTokensResponse(
        access_token=access_token,
        refresh_token=refresh_token,
    )

@router.post("/refresh", response_model=AuthTokensResponse)
async def refresh(request: RefreshRequest):
    now = datetime.now(timezone.utc)
    token_hash = hash_token(request.refresh_token)
    token = await db.refreshtoken.find_first(
        where={
            "token_hash": token_hash,
            "revoked_at": None,
            "expires_at": {"gt": now},
        }
    )
    if token is None:
        raise HTTPException(status_code=401, detail="Refresh token inválido")

    user = await db.user.find_unique(where={"id": token.user_id})
    if user is None:
        raise HTTPException(status_code=401, detail="Usuário não encontrado")

    access_token = create_access_token(user.id, user.email)
    new_refresh_token = generate_token()
    new_refresh_hash = hash_token(new_refresh_token)
    new_token = await db.refreshtoken.create(
        data={
            "user_id": user.id,
            "token_hash": new_refresh_hash,
            "expires_at": create_refresh_expires_at(),
        }
    )
    await db.refreshtoken.update(
        where={"id": token.id},
        data={"revoked_at": now, "replaced_by": new_token.id},
    )
    return AuthTokensResponse(
        access_token=access_token,
        refresh_token=new_refresh_token,
    )
