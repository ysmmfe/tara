import asyncio
import pytest

from app.agent import analyze_menu, extract_foods, get_chat_with_fallback
from app.calculator import ActivityLevel, Sex, calculate_profile


@pytest.mark.unit
def test_extract_foods_stub_client(monkeypatch):
    from tests.support.g4f.client import Client as StubClient
    import app.agent as agent_module

    monkeypatch.setattr(agent_module, "_create_client", lambda: StubClient())
    items = asyncio.run(extract_foods("Frango grelhado\nArroz branco"))
    assert items == ["Frango grelhado", "Arroz branco"]


@pytest.mark.unit
def test_analyze_menu_stub_client(monkeypatch):
    from tests.support.g4f.client import Client as StubClient
    import app.agent as agent_module

    monkeypatch.setattr(agent_module, "_create_client", lambda: StubClient())
    profile = calculate_profile(
        weight_kg=70,
        height_cm=170,
        age=30,
        sex=Sex.MALE,
        activity_level=ActivityLevel.MODERATE,
        deficit_percent=0.2,
        meals_per_day=4,
    )

    result = asyncio.run(
        analyze_menu(profile, "Frango grelhado\nArroz branco", "almoco")
    )

    assert result["escolhas"][0]["alimento"] == "stub"


@pytest.mark.unit
def test_fallback_tries_next_model(monkeypatch):
    import json
    import app.agent as agent_module

    class _Message:
        def __init__(self, content: str):
            self.content = content

    class _Choice:
        def __init__(self, content: str):
            self.message = _Message(content)

    class _Response:
        def __init__(self, content: str):
            self.choices = [_Choice(content)]

    class FailingClient:
        def __init__(self):
            self.chat = self
            self.completions = self

        async def create(self, model: str, messages: list[dict], **kwargs):
            if model == "gpt-5.2":
                raise RuntimeError("model down")
            return _Response(json.dumps(["arroz"]))

    monkeypatch.setattr(agent_module, "_create_client", lambda: FailingClient())
    foods = asyncio.run(extract_foods("Arroz"))
    assert foods == ["arroz"]


@pytest.mark.unit
def test_get_chat_with_fallback_returns_response(monkeypatch):
    import json
    import app.agent as agent_module

    class _Message:
        def __init__(self, content: str):
            self.content = content

    class _Choice:
        def __init__(self, content: str):
            self.message = _Message(content)

    class _Response:
        def __init__(self, content: str):
            self.choices = [_Choice(content)]

    class StubClient:
        def __init__(self):
            self.chat = self
            self.completions = self

        async def create(self, model: str, messages: list[dict], **kwargs):
            return _Response(json.dumps(["feijao"]))

    monkeypatch.setattr(agent_module, "_create_client", lambda: StubClient())
    response = asyncio.run(get_chat_with_fallback([{"role": "user", "content": "x"}]))
    assert response.choices[0].message.content == "[\"feijao\"]"
