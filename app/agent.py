import json

from g4f.client import Client

from .prompts import SYSTEM_PROMPT, build_user_prompt


_EXTRACT_PROMPT = """Extraia do texto abaixo uma lista com cada alimento individual.
Separe itens compostos como "arroz e feijão" em ["arroz", "feijão"].
Mantenha itens que são naturalmente juntos como "pão de queijo" ou "arroz de leite".

Responda APENAS com um array JSON de strings, sem explicações.

Texto:
{menu_text}"""


def extract_foods(menu_text: str) -> list[str]:
    """Extrai lista de alimentos individuais do texto do cardápio."""
    client = Client()
    
    response = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "user", "content": _EXTRACT_PROMPT.format(menu_text=menu_text)},
        ],
    )
    
    return json.loads(response.choices[0].message.content)


def analyze_menu(profile: dict, menu_text: str, meal_type: str = "almoco") -> dict:
    """Analisa cardápio e retorna recomendações baseadas no perfil do usuário."""
    client = Client()
    user_prompt = build_user_prompt(profile, menu_text, meal_type)
    
    response = client.chat.completions.create(
        model="gpt-5.2",
        messages=[
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt},
        ],
    )
    
    return json.loads(response.choices[0].message.content)
