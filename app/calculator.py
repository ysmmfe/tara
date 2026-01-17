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


def calculate_macros(
    target_calories: float,
    weight_kg: float,
    activity_level: ActivityLevel,
) -> dict:
    """
    Calcula distribuição de macronutrientes para perda de gordura.
    
    Proteínas baseadas em faixas ISSN (2017), aplicadas por nível de atividade:
    - Sedentário: 1.4 g/kg/dia
    - Leve: 1.5 g/kg/dia
    - Moderado: 1.6 g/kg/dia
    - Ativo: 1.8 g/kg/dia
    - Muito Ativo: 2.0 g/kg/dia

    Gordura fixa em 25% do VET e carboidratos completam o restante.
    
    Conversão: Proteína/Carb = 4 kcal/g, Gordura = 9 kcal/g
    """
    protein_factors = {
        ActivityLevel.SEDENTARY: 1.4,
        ActivityLevel.LIGHT: 1.5,
        ActivityLevel.MODERATE: 1.6,
        ActivityLevel.ACTIVE: 1.8,
        ActivityLevel.VERY_ACTIVE: 2.0,
    }

    protein_g = weight_kg * protein_factors[activity_level]
    protein_g_rounded = round(protein_g)
    protein_calories_rounded = protein_g_rounded * 4

    fat_calories = min(target_calories * 0.25, max(0, target_calories - protein_calories_rounded))
    fat_calories_rounded = round(fat_calories)
    fat_g = fat_calories / 9

    carb_calories = max(0, target_calories - protein_calories_rounded - fat_calories_rounded)
    carb_g = carb_calories / 4

    return {
        "protein_g": protein_g_rounded,
        "fat_g": round(fat_g),
        "carbs_g": round(max(0, carb_g)),
        "protein_calories": protein_calories_rounded,
        "fat_calories": fat_calories_rounded,
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
    macros = calculate_macros(target_calories, weight_kg, activity_level)
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
            "macros": "ISSN 2017 (Proteina g/kg) + Gordura 25% VET",
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
