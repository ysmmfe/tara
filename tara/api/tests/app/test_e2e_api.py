import os
import httpx
import pytest


@pytest.mark.e2e
def test_e2e_profile_and_analyze():
    if not os.getenv("DATABASE_URL"):
        pytest.skip("DATABASE_URL não configurado para testes e2e.")
    google_id_token = os.getenv("GOOGLE_ID_TOKEN")
    if not google_id_token:
        pytest.skip("GOOGLE_ID_TOKEN não configurado para testes e2e.")
    base_url = "http://127.0.0.1:8001"
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

    with httpx.Client(base_url=base_url, timeout=10) as client:
        login_response = client.post(
            "/api/v1/auth/google",
            json={"id_token": google_id_token},
        )
        assert login_response.status_code == 200
        access_token = login_response.json()["access_token"]
        headers = {"Authorization": f"Bearer {access_token}"}

        profile_response = client.put(
            "/api/v1/me/profile",
            json={
                "profile": profile_payload,
                "training_preferences": preferences_payload,
            },
            headers=headers,
        )
        assert profile_response.status_code == 200

        analyze_payload = {
            "menu_text": "Frango grelhado\nArroz branco",
            "meal_type": "almoco",
        }
        analyze_response = client.post(
            "/api/v1/analyze", json=analyze_payload, headers=headers
        )
        assert analyze_response.status_code == 200
