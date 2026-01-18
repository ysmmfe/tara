import traceback

from fastapi import FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

from .calculator import Sex, ActivityLevel, calculate_profile
from .agent import analyze_menu
from .logger import get_logger

load_dotenv()

app = FastAPI(title="Tara", description="Agente que calcula porções ideais de alimentos baseado no seu perfil de saúde")
logger = get_logger()


class ProfileRequest(BaseModel):
    weight_kg: float
    height_cm: float
    age: int
    sex: Sex
    activity_level: ActivityLevel
    deficit_percent: float = 0.20
    meals_per_day: int = 4
    body_fat_percent: float | None = None
    lean_mass_kg: float | None = None


class AnalyzeRequest(BaseModel):
    profile: ProfileRequest
    menu_text: str
    meal_type: str = "almoco"


@app.post("/api/profile")
def calculate_user_profile(request: ProfileRequest):
    """Calcula metas nutricionais baseadas no perfil do usuário."""
    try:
        profile = calculate_profile(
            weight_kg=request.weight_kg,
            height_cm=request.height_cm,
            age=request.age,
            sex=request.sex,
            activity_level=request.activity_level,
            deficit_percent=request.deficit_percent,
            meals_per_day=request.meals_per_day,
            body_fat_percent=request.body_fat_percent,
            lean_mass_kg=request.lean_mass_kg,
        )
        return profile
    except Exception as e:
        logger.exception("Erro ao calcular perfil: %s", e)
        raise HTTPException(status_code=400, detail=str(e))


@app.post("/api/analyze")
def analyze_menu_endpoint(request: AnalyzeRequest):
    """Analisa cardápio e retorna recomendações."""
    try:
        profile = calculate_profile(
            weight_kg=request.profile.weight_kg,
            height_cm=request.profile.height_cm,
            age=request.profile.age,
            sex=request.profile.sex,
            activity_level=request.profile.activity_level,
            deficit_percent=request.profile.deficit_percent,
            meals_per_day=request.profile.meals_per_day,
            body_fat_percent=request.profile.body_fat_percent,
            lean_mass_kg=request.profile.lean_mass_kg,
        )
        
        result = analyze_menu(profile, request.menu_text, request.meal_type)
        return {"profile": profile, "recommendation": result}
    except ValueError as e:
        logger.warning("Erro de validacao no analyze: %s", e)
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.exception("Erro inesperado no analyze: %s", e)
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))



