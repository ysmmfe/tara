import json
from concurrent.futures import ThreadPoolExecutor, TimeoutError as FutureTimeoutError

from g4f.client import Client
from g4f import Provider
from g4f.errors import MissingAuthError, NoValidHarFileError
from g4f.providers.retry_provider import IterListProvider

from .logger import get_logger

from .prompts import SYSTEM_PROMPT, build_user_prompt


_EXTRACT_PROMPT = """Extraia do texto abaixo uma lista com cada alimento individual.
Separe itens compostos como "arroz e feijão" em ["arroz", "feijão"].
Mantenha itens que são naturalmente juntos como "pão de queijo" ou "arroz de leite".

Responda APENAS com um array JSON de strings, sem explicações.

Texto:
{menu_text}"""

_FALLBACK_MODELS = (
    "gpt-5.2",
    "gpt-5-mini",
    "gpt-4o",
)

_LLM_TIMEOUT_SECONDS = 25

_FALLBACK_PROVIDERS = (
    Provider.Chatai,
    Provider.OIVSCodeSer2,
    Provider.OIVSCodeSer0501,
    Provider.Startnest,
    Provider.OperaAria,
    Provider.PollinationsAI,
    Provider.Qwen,
    Provider.WeWordle,
)

logger = get_logger("tara.agent")


def _call_chat_completion(client: Client, messages: list[dict], model: str, provider):
    return client.chat.completions.create(
        model=model,
        messages=messages,
        provider=provider,
    )


def _call_with_timeout(client: Client, messages: list[dict], model: str, provider):
    executor = ThreadPoolExecutor(max_workers=1)
    future = executor.submit(_call_chat_completion, client, messages, model, provider)
    try:
        return future.result(timeout=_LLM_TIMEOUT_SECONDS)
    except FutureTimeoutError as exc:
        logger.warning("LLM timeout com model=%s apos %ss", model, _LLM_TIMEOUT_SECONDS)
        raise TimeoutError("Timeout ao chamar LLM") from exc
    finally:
        executor.shutdown(wait=False, cancel_futures=True)


def get_chat_with_fallback(messages: list[dict]):
    client = Client()
    last_error: Exception | None = None

    for model in _FALLBACK_MODELS:
        try:
            provider = IterListProvider(list(_FALLBACK_PROVIDERS), shuffle=False)
            response = _call_with_timeout(client, messages, model, provider)
            logger.info("LLM sucesso com model=%s", model)
            return response
        except (MissingAuthError, NoValidHarFileError) as exc:
            logger.warning("LLM falhou por auth/har com model=%s: %s", model, exc)
            last_error = exc
        except TimeoutError as exc:
            logger.warning("LLM timeout com model=%s: %s", model, exc)
            last_error = exc
        except Exception as exc:
            logger.warning("LLM falhou com model=%s: %s", model, exc)
            last_error = exc

    if last_error is not None:
        raise last_error
    raise RuntimeError("Nenhum modelo disponível para completar a requisicao.")


def extract_foods(menu_text: str) -> list[str]:
    """Extrai lista de alimentos individuais do texto do cardápio."""
    logger.info("extract_foods prompt: %s", _EXTRACT_PROMPT.format(menu_text=menu_text))
    response = get_chat_with_fallback(
        [
            {"role": "user", "content": _EXTRACT_PROMPT.format(menu_text=menu_text)},
        ]
    )

    content = response.choices[0].message.content
    logger.info("extract_foods raw response: %s", content)
    cleaned = content.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        if cleaned.lower().startswith("json"):
            cleaned = cleaned[4:].lstrip()
    try:
        items = json.loads(cleaned)
        logger.info("extract_foods items: %s", items)
        return items
    except ValueError as exc:
        logger.warning("Falha ao decodificar JSON em extract_foods: %s", content)
        raise ValueError("Resposta invalida do modelo em extract_foods.") from exc


def analyze_menu(profile: dict, menu_text: str, meal_type: str = "almoco") -> dict:
    """Analisa cardápio e retorna recomendações baseadas no perfil do usuário."""
    user_prompt = build_user_prompt(profile, menu_text, meal_type)
    logger.info("system prompt: %s", SYSTEM_PROMPT)
    logger.info("user prompt: %s", user_prompt)
    
    response = get_chat_with_fallback(
        [
            {"role": "system", "content": SYSTEM_PROMPT},
            {"role": "user", "content": user_prompt},
        ]
    )
    
    content = response.choices[0].message.content
    logger.info("analyze_menu raw response: %s", content)
    cleaned = content.strip()
    if cleaned.startswith("```"):
        cleaned = cleaned.strip("`")
        if cleaned.lower().startswith("json"):
            cleaned = cleaned[4:].lstrip()
    try:
        return json.loads(cleaned)
    except ValueError as exc:
        logger.warning("Falha ao decodificar JSON em analyze_menu: %s", content)
        raise ValueError("Resposta invalida do modelo em analyze_menu.") from exc
