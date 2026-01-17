import pytest

from app.agent import analyze_menu, extract_foods
from app.calculator import ActivityLevel, Sex, calculate_profile


@pytest.mark.unit
def test_extract_foods_stub_client(monkeypatch):
    from tests.support.g4f.client import Client as StubClient
    import app.agent as agent_module

    monkeypatch.setattr(agent_module, "Client", StubClient)
    items = extract_foods("Frango grelhado\nArroz branco")
    assert items == ["Frango grelhado", "Arroz branco"]


@pytest.mark.unit
def test_analyze_menu_stub_client(monkeypatch):
    from tests.support.g4f.client import Client as StubClient
    import app.agent as agent_module

    monkeypatch.setattr(agent_module, "Client", StubClient)
    profile = calculate_profile(
        weight_kg=70,
        height_cm=170,
        age=30,
        sex=Sex.MALE,
        activity_level=ActivityLevel.MODERATE,
        deficit_percent=0.2,
        meals_per_day=4,
    )

    result = analyze_menu(profile, "Frango grelhado\nArroz branco", "almoco")

    assert result["escolhas"][0]["alimento"] == "stub"
