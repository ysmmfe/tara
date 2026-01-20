import time

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.mark.integration
def test_api_profile_and_analyze(monkeypatch):
    from tests.support.g4f.client import Client as StubClient
    import app.agent as agent_module

    monkeypatch.setattr(agent_module, "_create_client", lambda: StubClient())
    client = TestClient(app)

    profile_payload = {
        "weight_kg": 70,
        "height_cm": 170,
        "age": 30,
        "sex": "male",
        "activity_level": "moderate",
        "deficit_percent": 0.2,
        "meals_per_day": 4,
    }

    profile_response = client.post("/api/v1/profile", json=profile_payload)
    assert profile_response.status_code == 200
    profile = profile_response.json()
    assert "macros" in profile

    analyze_payload = {
        "profile": profile_payload,
        "menu_text": "Frango grelhado\nArroz branco",
        "meal_type": "almoco",
    }

    analyze_response = client.post("/api/v1/analyze", json=analyze_payload)
    assert analyze_response.status_code == 200
    job_id = analyze_response.json()["job_id"]

    result = None
    deadline = time.monotonic() + 5.0
    last_payload = None
    while time.monotonic() < deadline:
        status_response = client.get(f"/api/v1/analyze/{job_id}")
        assert status_response.status_code == 200
        payload = status_response.json()
        last_payload = payload
        if payload["status"] == "done":
            result = payload["result"]
            break
        if payload["status"] == "error":
            pytest.fail(payload["error"] or "Job falhou")
        time.sleep(0.1)

    assert result is not None, f"Job nao finalizou: {last_payload}"
    assert "recommendation" in result
