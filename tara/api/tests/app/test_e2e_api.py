import pytest
import httpx


@pytest.mark.e2e
def test_e2e_profile_and_analyze():
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

    with httpx.Client(base_url=base_url, timeout=10) as client:
        profile_response = client.post("/api/v1/profile", json=profile_payload)
        assert profile_response.status_code == 200

        analyze_payload = {
            "profile": profile_payload,
            "menu_text": "Frango grelhado\nArroz branco",
            "meal_type": "almoco",
        }
        analyze_response = client.post("/api/v1/analyze", json=analyze_payload)
        assert analyze_response.status_code == 200
