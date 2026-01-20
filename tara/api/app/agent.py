import json
import multiprocessing as mp
import queue

from g4f.client import Client as G4FClient
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

class _Message:
    def __init__(self, content: str):
        self.content = content


class _Choice:
    def __init__(self, content: str):
        self.message = _Message(content)


class _Response:
    def __init__(self, content: str):
        self.choices = [_Choice(content)]


def _build_provider():
    return IterListProvider(list(_FALLBACK_PROVIDERS), shuffle=False)

def _default_create_client():
    return G4FClient()


def _create_client():
    return _default_create_client()


def _call_chat_completion(messages: list[dict], model: str, provider):
    client = _create_client()
    return client.chat.completions.create(
        model=model,
        messages=messages,
        provider=provider,
    )


def _call_in_subprocess(result_queue, messages: list[dict], model: str):
    try:
        response = _call_chat_completion(messages, model, _build_provider())
        content = response.choices[0].message.content
        result_queue.put(("ok", content))
    except Exception as exc:
        result_queue.put(("err", exc.__class__.__name__, str(exc)))


def _build_response_from_content(content: str):
    return _Response(content)


def _call_with_timeout(messages: list[dict], model: str):
    if _create_client is not _default_create_client:
        return _call_chat_completion(messages, model, _build_provider())

    ctx = mp.get_context("spawn")
    result_queue = ctx.Queue(maxsize=1)
    process = ctx.Process(
        target=_call_in_subprocess,
        args=(result_queue, messages, model),
        daemon=True,
    )
    process.start()
    process.join(_LLM_TIMEOUT_SECONDS)

    if process.is_alive():
        process.terminate()
        process.join()
        logger.warning("LLM timeout com model=%s apos %ss", model, _LLM_TIMEOUT_SECONDS)
        raise TimeoutError("Timeout ao chamar LLM")

    try:
        result = result_queue.get_nowait()
    except queue.Empty as exc:
        raise RuntimeError("LLM subprocess terminou sem resposta.") from exc

    if result[0] == "ok":
        return _build_response_from_content(result[1])

    error_type = result[1]
    error_message = result[2]
    if error_type == "MissingAuthError":
        raise MissingAuthError(error_message)
    if error_type == "NoValidHarFileError":
        raise NoValidHarFileError(error_message)
    raise RuntimeError(f"Falha ao chamar LLM: {error_type}: {error_message}")


def get_chat_with_fallback(messages: list[dict]):
    last_error: Exception | None = None

    for model in _FALLBACK_MODELS:
        try:
            response = _call_with_timeout(messages, model)
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
