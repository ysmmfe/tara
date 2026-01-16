# Contributing to Tara

Obrigado por querer contribuir! Este guia vai te ajudar a começar.

## Setup do Ambiente

### Pré-requisitos

- Python 3.11+
- [uv](https://docs.astral.sh/uv/) (gerenciador de pacotes)

### Instalação

```bash
# Clone o repositório
git clone https://github.com/seu-usuario/tara.git
cd tara

# Instale as dependências
uv sync

# Rode o servidor
uv run uvicorn app.main:app --reload
```

O servidor vai rodar em `http://localhost:8000`.

## Estrutura do Projeto

```
tara/
├── app/
│   ├── main.py        # FastAPI app e rotas
│   ├── agent.py       # Lógica do agente
│   ├── calculator.py  # Cálculos de TMB, TDEE, macros
│   ├── prompts.py     # Prompts para o LLM
│   └── food_api.py    # API de alimentos
├── static/            # Frontend (HTML, CSS, JS)
└── pyproject.toml     # Dependências
```

## Como Contribuir

### 1. Escolha uma issue

- Veja as [issues abertas](../../issues)
- Issues com label `good first issue` são ideais para começar
- Comente na issue que você vai trabalhar nela

### 2. Crie uma branch

```bash
git checkout -b feature/nome-da-feature
# ou
git checkout -b fix/nome-do-bug
```

### 3. Faça suas alterações

- Mantenha o código simples e legível
- Siga o estilo do código existente

### 4. Teste localmente

```bash
uv run uvicorn app.main:app --reload
```

### 5. Commit e Push

```bash
git add .
git commit -m "Descrição clara do que foi feito"
git push origin sua-branch
```

### 6. Abra um Pull Request

- Descreva o que foi alterado
- Referencie a issue relacionada (ex: `Closes #123`)

## Padrões

- **Commits**: Mensagens claras e em português ou inglês
- **Branches**: Use prefixos `feature/`, `fix/`, `docs/`
- **Código**: Python com type hints quando possível

## Dúvidas?

Abra uma issue com a label `question`.
