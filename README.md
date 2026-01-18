# Tara <img src="tara/web/logo.png" alt="Tara" width="35" height="35">

[![License: MIT](https://img.shields.io/badge/License-MIT-yellow.svg)](https://opensource.org/licenses/MIT)
[![Python 3.11+](https://img.shields.io/badge/python-3.11+-blue.svg)](https://www.python.org/downloads/)

Agente que recebe um cardápio e calcula a quantidade de gramas de cada alimento para sua refeição, baseado no seu perfil de saúde.

## O que faz

1. **Calcula suas metas**: TMB, TDEE e macros baseados no seu perfil
2. **Distribui calorias por refeição**: Calcula automaticamente a quantidade ideal para cada refeição do dia
3. **Analisa cardápios**: Cole o texto do cardápio do restaurante
4. **Recomenda alimentos**: Escolhe os melhores pratos com quantidades em gramas

## Instalação

### Pré-requisitos

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) (gerenciador de pacotes)

### Setup

```bash
# Clone o repositório
git clone https://github.com/ysmmfe/tara.git
cd tara

# Instale as dependências
uv sync

# Rode o servidor
PYTHONPATH=tara/api uv run uvicorn app.main:app --reload
```

O servidor vai rodar em `http://localhost:8000`.

## Uso

### Landing Page

Os arquivos da landing page ficam em `tara/web`. Sirva separadamente ou abra `tara/web/index.html`.

### Via API

**1. Calcular perfil nutricional:**

```bash
curl -X POST http://localhost:8000/api/v1/profile \
  -H "Content-Type: application/json" \
  -d '{
    "weight_kg": 70,
    "height_cm": 170,
    "age": 30,
    "sex": "male",
    "activity_level": "moderate",
    "deficit_percent": 0.20,
    "meals_per_day": 4
  }'
```

**2. Analisar cardápio:**

```bash
curl -X POST http://localhost:8000/api/v1/analyze \
  -H "Content-Type: application/json" \
  -d '{
    "profile": {
      "weight_kg": 70,
      "height_cm": 170,
      "age": 30,
      "sex": "male",
      "activity_level": "moderate",
      "deficit_percent": 0.20,
      "meals_per_day": 4
    },
    "menu_text": "Frango grelhado\nArroz branco\nFeijão\nSalada",
    "meal_type": "almoco"
  }'
```

## Roadmap

Veja o [GitHub Projects](https://github.com/ysmmfe/tara/projects) para acompanhar o que está sendo desenvolvido.

## Contributing

Quer contribuir? Veja o [CONTRIBUTING.md](CONTRIBUTING.md) para instruções de como rodar o projeto e abrir PRs.

Issues com label `good first issue` são ideais para começar.

## Fontes dos Cálculos

| Cálculo | Fonte |
|---------|-------|
| TMB | Mifflin-St Jeor (1990) |
| Fatores de Atividade | FAO/OMS |
| Déficit 20% | ABESO / ACSM |
| Macros (Proteína g/kg + Gordura 25% VET) | ISSN (2017) |
| Distribuição de Refeições | Guia Alimentar para a População Brasileira |

## Licença

Este projeto está sob a licença MIT. Veja o arquivo [LICENSE](LICENSE) para mais detalhes.
