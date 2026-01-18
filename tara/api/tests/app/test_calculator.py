import pytest

from app.calculator import ActivityLevel, calculate_macros


@pytest.mark.unit
def test_calculate_macros_protein_by_activity():
    target_calories = 2000
    weight_kg = 88

    macros = calculate_macros(target_calories, weight_kg, ActivityLevel.MODERATE)
    expected_protein_g = round(1.6 * weight_kg)

    assert macros["protein_g"] == expected_protein_g
    assert macros["fat_calories"] == round(target_calories * 0.25)
    assert macros["carbs_calories"] == round(
        target_calories - (expected_protein_g * 4) - macros["fat_calories"]
    )


@pytest.mark.unit
def test_calculate_macros_caps_carbs_when_protein_is_high():
    target_calories = 1000
    weight_kg = 100

    macros = calculate_macros(target_calories, weight_kg, ActivityLevel.VERY_ACTIVE)

    assert macros["carbs_calories"] == 0
