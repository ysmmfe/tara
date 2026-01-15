from enum import Enum


class Sex(str, Enum):
    MALE = "male"
    FEMALE = "female"


class ActivityLevel(str, Enum):
    """
    Níveis de atividade física conforme FAO/OMS.
    """
    SEDENTARY = "sedentary"  # Pouco ou nenhum exercício
    LIGHT = "light"  # Exercício leve 1-3x/semana
    MODERATE = "moderate"  # Exercício moderado 3-5x/semana
    ACTIVE = "active"  # Exercício intenso 6-7x/semana
    VERY_ACTIVE = "very_active"  # Exercício muito intenso + trabalho físico


# Fatores de atividade física - Fonte: FAO/OMS
ACTIVITY_MULTIPLIERS = {
    ActivityLevel.SEDENTARY: 1.2,
    ActivityLevel.LIGHT: 1.375,
    ActivityLevel.MODERATE: 1.55,
    ActivityLevel.ACTIVE: 1.725,
    ActivityLevel.VERY_ACTIVE: 1.9,
}

# Distribuição calórica por refeição - Fonte: Guia Alimentar para a População Brasileira
MEAL_DISTRIBUTION = {
    3: {
        "cafe_da_manha": 0.25,
        "almoco": 0.40,
        "jantar": 0.35,
    },
    4: {
        "cafe_da_manha": 0.20,
        "almoco": 0.35,
        "lanche_tarde": 0.15,
        "jantar": 0.30,
    },
    5: {
        "cafe_da_manha": 0.20,
        "lanche_manha": 0.05,
        "almoco": 0.35,
        "lanche_tarde": 0.10,
        "jantar": 0.30,
    },
    6: {
        "cafe_da_manha": 0.20,
        "lanche_manha": 0.05,
        "almoco": 0.30,
        "lanche_tarde": 0.10,
        "jantar": 0.30,
        "ceia": 0.05,
    },
}

MEAL_NAMES = {
    "cafe_da_manha": "Café da Manhã",
    "lanche_manha": "Lanche da Manhã",
    "almoco": "Almoço",
    "lanche_tarde": "Lanche da Tarde",
    "jantar": "Jantar",
    "ceia": "Ceia",
}


def calculate_bmr(weight_kg: float, height_cm: float, age: int, sex: Sex) -> float:
    """
    Calcula Taxa Metabólica Basal usando equação de Mifflin-St Jeor (1990).
    
    Homens: (10 × peso) + (6,25 × altura) - (5 × idade) + 5
    Mulheres: (10 × peso) + (6,25 × altura) - (5 × idade) - 161
    
    Fonte: Mifflin MD, St Jeor ST, et al. (1990)
    American Journal of Clinical Nutrition, 51(2), 241-247.
    """
    if sex == Sex.MALE:
        return (10 * weight_kg) + (6.25 * height_cm) - (5 * age) + 5
    else:
        return (10 * weight_kg) + (6.25 * height_cm) - (5 * age) - 161


def calculate_tdee(bmr: float, activity_level: ActivityLevel) -> float:
    """
    Calcula Gasto Energético Total Diário (TDEE).
    
    TDEE = TMB × Fator de Atividade
    
    Fatores de atividade conforme FAO/OMS:
        - Sedentário: 1,2
        - Leve: 1,375
        - Moderado: 1,55
        - Ativo: 1,725
        - Muito Ativo: 1,9
    """
    return bmr * ACTIVITY_MULTIPLIERS[activity_level]


def calculate_deficit_calories(tdee: float, deficit_percent: float = 0.20) -> float:
    """
    Calcula calorias alvo com déficit.
    
    Déficit recomendado: 20-25% do TDEE (~0,5-1kg por semana)
    
    Fonte: ABESO + ACSM (500-1000 kcal/dia)
    """
    return tdee * (1 - deficit_percent)


def calculate_macros(target_calories: float, weight_kg: float) -> dict:
    """
    Calcula distribuição de macronutrientes para perda de gordura.
    
    Distribuição baseada em recomendações da SBAN (Sociedade Brasileira de Alimentação e Nutrição):
    - Carboidratos: 65% do VET (SBAN: 60-70%)
    - Proteínas: 12% do VET (SBAN: 10-12%)
    - Lipídios: 23% do VET (SBAN: 20-25%)
    
    Conversão: Proteína/Carb = 4 kcal/g, Gordura = 9 kcal/g
    """
    carb_calories = target_calories * 0.65
    carb_g = carb_calories / 4

    protein_calories = target_calories * 0.12
    protein_g = protein_calories / 4

    fat_calories = target_calories * 0.23
    fat_g = fat_calories / 9

    return {
        "protein_g": round(protein_g),
        "fat_g": round(fat_g),
        "carbs_g": round(max(0, carb_g)),
        "protein_calories": round(protein_calories),
        "fat_calories": round(fat_calories),
        "carbs_calories": round(max(0, carb_calories)),
    }


def calculate_meals_distribution(target_calories: float, macros: dict, meals_per_day: int) -> dict:
    """
    Calcula a distribuição de calorias e macros por refeição.
    
    Fonte: Guia Alimentar para a População Brasileira
    """
    distribution = MEAL_DISTRIBUTION.get(meals_per_day, MEAL_DISTRIBUTION[4])
    
    meals = {}
    for meal_key, percentage in distribution.items():
        meals[meal_key] = {
            "nome": MEAL_NAMES[meal_key],
            "percentual": int(percentage * 100),
            "calorias": round(target_calories * percentage),
            "proteina_g": round(macros["protein_g"] * percentage),
            "carboidrato_g": round(macros["carbs_g"] * percentage),
            "gordura_g": round(macros["fat_g"] * percentage),
        }
    
    return meals


def calculate_profile(
    weight_kg: float,
    height_cm: float,
    age: int,
    sex: Sex,
    activity_level: ActivityLevel,
    deficit_percent: float = 0.20,
    meals_per_day: int = 4,
    body_fat_percent: float | None = None,
    lean_mass_kg: float | None = None,
) -> dict:
    """
    Calcula perfil nutricional completo.
    """
    bmr = calculate_bmr(weight_kg, height_cm, age, sex)
    tdee = calculate_tdee(bmr, activity_level)
    target_calories = calculate_deficit_calories(tdee, deficit_percent)
    macros = calculate_macros(target_calories, weight_kg)
    meals = calculate_meals_distribution(target_calories, macros, meals_per_day)

    result = {
        "bmr": round(bmr),
        "tdee": round(tdee),
        "deficit_percent": deficit_percent,
        "target_calories": round(target_calories),
        "macros": macros,
        "meals_per_day": meals_per_day,
        "meals": meals,
        "sources": {
            "bmr": "Mifflin-St Jeor (1990)",
            "activity_factors": "FAO/OMS",
            "deficit": "ABESO / ACSM",
            "macros": "SBAN (Carb 65%, Prot 12%, Gord 23%)",
            "meals": "Guia Alimentar para a População Brasileira",
        },
    }

    if body_fat_percent is not None:
        fat_mass = weight_kg * (body_fat_percent / 100)
        lean_mass = weight_kg - fat_mass
        result["body_composition"] = {
            "body_fat_percent": body_fat_percent,
            "fat_mass_kg": round(fat_mass, 1),
            "lean_mass_kg": round(lean_mass, 1),
        }
    elif lean_mass_kg is not None:
        fat_mass = weight_kg - lean_mass_kg
        body_fat_percent = (fat_mass / weight_kg) * 100
        result["body_composition"] = {
            "body_fat_percent": round(body_fat_percent, 1),
            "fat_mass_kg": round(fat_mass, 1),
            "lean_mass_kg": lean_mass_kg,
        }

    return result
