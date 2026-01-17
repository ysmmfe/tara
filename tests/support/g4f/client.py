import json


class _Message:
    def __init__(self, content: str):
        self.content = content


class _Choice:
    def __init__(self, content: str):
        self.message = _Message(content)


class _Response:
    def __init__(self, content: str):
        self.choices = [_Choice(content)]


class _ChatCompletions:
    @staticmethod
    def create(model: str, messages: list[dict]):
        prompt = "\n".join(m.get("content", "") for m in messages)

        if "Extraia do texto abaixo uma lista" in prompt:
            items = ["Frango grelhado", "Arroz branco"]
            return _Response(json.dumps(items))

        payload = {
            "escolhas": [
                {
                    "alimento": "stub",
                    "gramas": 100,
                    "calorias_estimadas": 0,
                    "proteina_g": 0,
                    "carboidrato_g": 0,
                    "gordura_g": 0,
                    "justificativa": "Resposta stub para testes.",
                }
            ],
            "total": {
                "calorias": 0,
                "proteina_g": 0,
                "carboidrato_g": 0,
                "gordura_g": 0,
            },
            "dica": "Stub local para testes.",
        }
        return _Response(json.dumps(payload))


class _Chat:
    completions = _ChatCompletions()


class Client:
    def __init__(self):
        self.chat = _Chat()
