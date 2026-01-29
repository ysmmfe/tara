from fastapi import APIRouter, Depends, HTTPException
from prisma import Json

from .db import db
from .deps import get_current_user
from .schemas import ProfileResponse, ProfileUpdateRequest

router = APIRouter(prefix="/me", tags=["profile"])


@router.get("/profile", response_model=ProfileResponse)
async def get_profile(user=Depends(get_current_user)):
    profile = await db.userprofile.find_unique(where={"user_id": user.id})
    preferences = await db.trainingpreferences.find_unique(where={"user_id": user.id})
    if profile is None or preferences is None:
        raise HTTPException(status_code=404, detail="Perfil não encontrado")

    return ProfileResponse(
        profile={
            "weight_kg": profile.weight_kg,
            "height_cm": profile.height_cm,
            "age": profile.age,
            "sex": profile.sex,
            "activity_level": profile.activity_level,
            "deficit_percent": profile.deficit_percent,
            "meals_per_day": profile.meals_per_day,
            "body_fat_percent": profile.body_fat_percent,
            "lean_mass_kg": profile.lean_mass_kg,
        },
        training_preferences={
            "days_available": preferences.days_available,
            "session_minutes": preferences.session_minutes,
            "muscle_priorities": preferences.muscle_priorities,
            "experience_level": preferences.experience_level,
            "equipment": preferences.equipment,
        },
    )


@router.put("/profile", response_model=ProfileResponse)
async def upsert_profile(
    payload: ProfileUpdateRequest, user=Depends(get_current_user)
):
    profile_data = payload.profile.model_dump(mode="json")
    preferences_data = payload.training_preferences.model_dump(mode="json")
    preferences_data["days_available"] = Json(preferences_data["days_available"])
    preferences_data["muscle_priorities"] = Json(
        preferences_data["muscle_priorities"]
    )

    profile = await db.userprofile.upsert(
        where={"user_id": user.id},
        data={
            "create": {"user": {"connect": {"id": user.id}}, **profile_data},
            "update": profile_data,
        },
    )
    preferences = await db.trainingpreferences.upsert(
        where={"user_id": user.id},
        data={
            "create": {"user": {"connect": {"id": user.id}}, **preferences_data},
            "update": preferences_data,
        },
    )

    return ProfileResponse(
        profile={
            "weight_kg": profile.weight_kg,
            "height_cm": profile.height_cm,
            "age": profile.age,
            "sex": profile.sex,
            "activity_level": profile.activity_level,
            "deficit_percent": profile.deficit_percent,
            "meals_per_day": profile.meals_per_day,
            "body_fat_percent": profile.body_fat_percent,
            "lean_mass_kg": profile.lean_mass_kg,
        },
        training_preferences={
            "days_available": preferences.days_available,
            "session_minutes": preferences.session_minutes,
            "muscle_priorities": preferences.muscle_priorities,
            "experience_level": preferences.experience_level,
            "equipment": preferences.equipment,
        },
    )
