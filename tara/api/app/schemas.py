from typing import List, Literal

from pydantic import BaseModel, Field

from .calculator import ActivityLevel, Sex


class GoogleAuthRequest(BaseModel):
    id_token: str


class AuthTokensResponse(BaseModel):
    access_token: str
    refresh_token: str
    token_type: str = "bearer"


class RefreshRequest(BaseModel):
    refresh_token: str


class ProfilePayload(BaseModel):
    weight_kg: float = Field(gt=0)
    height_cm: float = Field(gt=0)
    age: int = Field(gt=0)
    sex: Sex
    activity_level: ActivityLevel
    deficit_percent: float = Field(default=0.20, gt=0, le=1)
    meals_per_day: int = Field(default=3, ge=1, le=12)
    body_fat_percent: float | None = Field(default=None, gt=0, le=100)
    lean_mass_kg: float | None = Field(default=None, gt=0)


class TrainingPreferencesPayload(BaseModel):
    days_available: List[str] = Field(min_length=1)
    session_minutes: int = Field(ge=10, le=300)
    muscle_priorities: List[str] = Field(min_length=1, max_length=3)
    experience_level: Literal["iniciante", "intermediario", "avancado"]
    equipment: Literal["academia_completa", "academia_predio", "casa"]


class ProfileUpdateRequest(BaseModel):
    profile: ProfilePayload
    training_preferences: TrainingPreferencesPayload


class ProfileResponse(BaseModel):
    profile: ProfilePayload
    training_preferences: TrainingPreferencesPayload
