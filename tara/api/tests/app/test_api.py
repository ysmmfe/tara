import os
import time

import pytest
from fastapi.testclient import TestClient

from app.main import app


@pytest.mark.integration
def test_api_profile_and_analyze(monkeypatch):
    if not os.getenv("DATABASE_URL"):
        pytest.skip("DATABASE_URL não configurado para testes de integração.")
    from tests.support.g4f.client import Client as StubClient
    import app.agent as agent_module
    import app.jobs as jobs_module
    import app.main as main_module

    monkeypatch.setattr(agent_module, "_create_client", lambda: StubClient())

    async def _run_immediately(runner, timeout_seconds: int) -> str:
        job_id = "test-job"
        result = await runner()
        now = time.time()
        jobs_module._jobs[job_id] = jobs_module.Job(
            job_id=job_id,
            status=jobs_module.JobStatus.done,
            created_at=now,
            updated_at=now,
            result=result,
        )
        return job_id

    monkeypatch.setattr(main_module, "create_job", _run_immediately)
    client = TestClient(app)

    unique_email = f"teste-{int(time.time())}@example.com"
    import app.google_auth as google_auth_module

    def _fake_verify(_: str):
        return {
            "sub": "google-sub-123",
            "email": unique_email,
            "name": "Teste",
            "email_verified": True,
        }

    monkeypatch.setattr(google_auth_module, "verify_google_id_token", _fake_verify)

    login_response = client.post(
        "/api/v1/auth/google",
        json={"id_token": "fake-token"},
    )
    assert login_response.status_code == 200
    tokens = login_response.json()
    access_token = tokens["access_token"]
    refresh_token = tokens["refresh_token"]

    refresh_response = client.post(
        "/api/v1/auth/refresh", json={"refresh_token": refresh_token}
    )
    assert refresh_response.status_code == 200
    access_token = refresh_response.json()["access_token"]
    headers = {"Authorization": f"Bearer {access_token}"}

    profile_payload = {
        "weight_kg": 70,
        "height_cm": 170,
        "age": 30,
        "sex": "male",
        "activity_level": "moderate",
        "deficit_percent": 0.2,
        "meals_per_day": 4,
    }
    preferences_payload = {
        "days_available": ["seg", "qua", "sex"],
        "session_minutes": 60,
        "muscle_priorities": ["peito", "costas"],
    }

    upsert_response = client.put(
        "/api/v1/me/profile",
        json={
            "profile": profile_payload,
            "training_preferences": preferences_payload,
        },
        headers=headers,
    )
    assert upsert_response.status_code == 200

    analyze_payload = {
        "menu_text": "Frango grelhado\nArroz branco",
        "meal_type": "almoco",
    }

    analyze_response = client.post(
        "/api/v1/analyze", json=analyze_payload, headers=headers
    )
    assert analyze_response.status_code == 200
    job_id = analyze_response.json()["job_id"]

    status_response = client.get(f"/api/v1/analyze/{job_id}", headers=headers)
    assert status_response.status_code == 200
    payload = status_response.json()
    assert payload["status"] == "done"
    assert "recommendation" in payload["result"]
