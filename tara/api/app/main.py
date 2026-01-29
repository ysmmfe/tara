import asyncio
import traceback

from fastapi import APIRouter, Depends, FastAPI, HTTPException
from pydantic import BaseModel
from dotenv import load_dotenv

from .calculator import Sex, ActivityLevel, calculate_profile
from .agent import analyze_menu
from .auth import router as auth_router
from .db import db
from .deps import get_current_user, require_complete_profile
from .jobs import JobStatus, create_job, get_job
from .logger import get_logger
from .profile import router as profile_router
from .schemas import ProfilePayload

load_dotenv()

app = FastAPI(
    title="Tara",
    description="Agente que calcula porções ideais de alimentos baseado no seu perfil de saúde",
)
api_v1_router = APIRouter(prefix="/api/v1")
logger = get_logger()


@app.get("/")
def root():
    return {"status": "ok", "service": "tara-api"}


@app.get("/health")
def health_check():
    return {"status": "healthy"}


class AnalyzeRequest(BaseModel):
    menu_text: str
    meal_type: str = "almoco"


@api_v1_router.post("/profile")
async def calculate_user_profile(
    request: ProfilePayload, user=Depends(get_current_user)
):
    """Calcula metas nutricionais baseadas no perfil do usuário."""
    try:
        profile = await asyncio.to_thread(
            calculate_profile,
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


@api_v1_router.post("/analyze")
async def analyze_menu_endpoint(
    request: AnalyzeRequest, user=Depends(require_complete_profile)
):
    """Analisa cardápio e retorna recomendações."""
    try:
        profile = await db.userprofile.find_unique(where={"user_id": user.id})
        if profile is None:
            raise HTTPException(status_code=403, detail="Perfil incompleto")
        profile = await asyncio.to_thread(
            calculate_profile,
            weight_kg=profile.weight_kg,
            height_cm=profile.height_cm,
            age=profile.age,
            sex=Sex(profile.sex),
            activity_level=ActivityLevel(profile.activity_level),
            deficit_percent=profile.deficit_percent,
            meals_per_day=profile.meals_per_day,
            body_fat_percent=profile.body_fat_percent,
            lean_mass_kg=profile.lean_mass_kg,
        )

        async def _runner() -> dict:
            recommendation = await analyze_menu(
                profile,
                request.menu_text,
                request.meal_type,
            )
            return {"profile": profile, "recommendation": recommendation}

        job_id = await create_job(_runner, timeout_seconds=180)
        return {"job_id": job_id}
    except ValueError as e:
        logger.warning("Erro de validacao no analyze: %s", e)
        raise HTTPException(status_code=400, detail=str(e))
    except Exception as e:
        logger.exception("Erro inesperado no analyze: %s", e)
        traceback.print_exc()
        raise HTTPException(status_code=500, detail=str(e))


@api_v1_router.get("/analyze/{job_id}")
async def analyze_menu_status(job_id: str, user=Depends(get_current_user)):
    job = await get_job(job_id)
    if job is None:
        raise HTTPException(status_code=404, detail="Job não encontrado")
    return {
        "status": job.status,
        "result": job.result,
        "error": job.error,
    }


api_v1_router.include_router(auth_router)
api_v1_router.include_router(profile_router)
app.include_router(api_v1_router)


@app.on_event("startup")
async def _startup() -> None:
    await db.connect()


@app.on_event("shutdown")
async def _shutdown() -> None:
    await db.disconnect()



