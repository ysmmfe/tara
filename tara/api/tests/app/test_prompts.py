import pytest

from app.calculator import ActivityLevel, Sex, calculate_profile
from app.prompts import build_user_prompt


@pytest.mark.unit
def test_build_user_prompt_contains_macros_and_meal():
    profile = calculate_profile(
        weight_kg=70,
        height_cm=170,
        age=30,
        sex=Sex.MALE,
        activity_level=ActivityLevel.MODERATE,
        deficit_percent=0.2,
        meals_per_day=4,
    )

    prompt = build_user_prompt(profile, "Frango grelhado\nArroz branco", "almoco")

    assert "Meta calórica diária" in prompt
    assert "Proteína" in prompt
    assert "REFEIÇÃO ATUAL" in prompt
