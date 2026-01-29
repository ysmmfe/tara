from typing import Any

import jwt
from jwt import PyJWKClient

from .settings import settings

GOOGLE_JWKS_URL = "https://www.googleapis.com/oauth2/v3/certs"
GOOGLE_ISSUERS = {"accounts.google.com", "https://accounts.google.com"}


class GoogleAuthError(ValueError):
    pass


def verify_google_id_token(id_token: str) -> dict[str, Any]:
    if not settings.google_client_ids:
        raise GoogleAuthError("GOOGLE_CLIENT_IDS não configurado.")

    jwks_client = PyJWKClient(GOOGLE_JWKS_URL)
    try:
        signing_key = jwks_client.get_signing_key_from_jwt(id_token).key
        payload = jwt.decode(
            id_token,
            signing_key,
            algorithms=["RS256"],
            audience=settings.google_client_ids,
            issuer=GOOGLE_ISSUERS,
        )
    except jwt.InvalidTokenError as exc:
        raise GoogleAuthError("ID token inválido.") from exc

    return payload
