from .taco import search_food


SYSTEM_PROMPT = """Você é um agente especializado em calcular porções ideais de alimentos baseado no perfil de saúde de uma pessoa.
Sua tarefa é analisar um cardápio de restaurante e recomendar a melhor combinação de alimentos 
para uma pessoa em déficit calórico.

REGRAS IMPORTANTES:
1. Sempre priorize proteínas magras para preservar massa muscular
2. Inclua vegetais e fibras para saciedade, se estiver no cardápio.
3. Evite frituras, molhos cremosos e carboidratos refinados
4. Considere o equilíbrio entre os macronutrientes
5. Seja realista com as porções - pessoas comem em restaurantes, não em laboratórios
6. Justifique cada escolha de forma educativa mas concisa

FORMATO DE RESPOSTA:
Responda SEMPRE em JSON válido com a seguinte estrutura:
{
    "escolhas": [
        {
            "alimento": "nome do alimento",
            "gramas": quantidade em gramas,
            "calorias_estimadas": número,
            "proteina_g": número,
            "carboidrato_g": número,
            "gordura_g": número,
            "justificativa": "breve explicação"
        }
    ],
    "total": {
        "calorias": número,
        "proteina_g": número,
        "carboidrato_g": número,
        "gordura_g": número
    },
    "dica": "Uma dica prática sobre a refeição"
}"""


def _build_food_reference(menu_text: str) -> str:
    """Busca dados nutricionais da TBCA para os alimentos do cardápio."""
    from .agent import extract_foods  # lazy import para evitar ciclo
    items = extract_foods(menu_text)
    
    references = []
    for item in items:
        results = search_food(item, limit=1)
        if results:
            food = results[0]
            n = food["por_100g"]
            references.append(
                f"- {item}: {n['calorias']:.0f} kcal, "
                f"{n['proteina_g']:.1f}g prot, "
                f"{n['carboidrato_g']:.1f}g carb, "
                f"{n['gordura_g']:.1f}g gord (por 100g)"
            )
    
    if not references:
        return ""
    
    return "DADOS NUTRICIONAIS DE REFERÊNCIA (TBCA - por 100g):\n" + "\n".join(references)


def build_user_prompt(profile: dict, menu_text: str, meal_type: str = "almoco") -> str:
    macros = profile["macros"]
    meals = profile["meals"]
    target_calories = profile["target_calories"]
    
    # Calcula percentuais reais dos macros
    protein_percent = int((macros['protein_calories'] / target_calories) * 100)
    carbs_percent = int((macros['carbs_calories'] / target_calories) * 100)
    fat_percent = int((macros['fat_calories'] / target_calories) * 100)
    
    # Monta a distribuição de refeições do dia
    meals_info = "\n".join([
        f"  - {m['nome']}: {m['percentual']}% ({m['calorias']} kcal)"
        for m in meals.values()
    ])
    
    # Pega informações da refeição atual
    current_meal = meals.get(meal_type, meals.get("almoco"))
    
    # Busca dados nutricionais da TBCA
    food_reference = _build_food_reference(menu_text)
    
    prompt = f"""PERFIL DO USUÁRIO:
- Meta calórica diária: {target_calories} kcal (déficit de {int(profile['deficit_percent'] * 100)}%)
- Macros alvo por dia:
  - Proteína: {macros['protein_g']}g ({protein_percent}% do VET)
  - Carboidratos: {macros['carbs_g']}g ({carbs_percent}% do VET)
  - Gordura: {macros['fat_g']}g ({fat_percent}% do VET)

DISTRIBUIÇÃO DAS {profile['meals_per_day']} REFEIÇÕES DO DIA:
{meals_info}

REFEIÇÃO ATUAL: {current_meal['nome']} ({current_meal['percentual']}% do dia)
Meta para esta refeição:
- {current_meal['calorias']} kcal
- {current_meal['proteina_g']}g de proteína
- {current_meal['carboidrato_g']}g de carboidratos
- {current_meal['gordura_g']}g de gordura

CARDÁPIO DO RESTAURANTE:
{menu_text}

{food_reference}

Analise o cardápio e escolha os melhores alimentos para esta refeição ({current_meal['nome']}), 
indicando a quantidade em gramas de cada um. USE OS DADOS NUTRICIONAIS DE REFERÊNCIA acima para 
calcular as porções. A pessoa está em déficit calórico e quer emagrecer de forma saudável, 
preservando massa muscular."""

    return prompt
