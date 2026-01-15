import json

from g4f.client import Client

from .prompts import SYSTEM_PROMPT, build_user_prompt


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
