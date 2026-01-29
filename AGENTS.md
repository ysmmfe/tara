# Instruções para Agentes

## Objetivo
Garantir revisões de código objetivas que mantenham a precisão dos cálculos nutricionais, a usabilidade do app e a confiabilidade das integrações com LLM.

## Comportamento
- Seja direto e objetivo. Evite rodeios.
- Escreva em português brasileiro.
- Cite arquivos/linhas afetadas (`agent.py:42`) para ação imediata.
- Pergunte quando faltar contexto, não suponha.

## Prioridades da Revisão
1. **Bloqueadores**: erros em cálculos nutricionais (TMB, macros, porções), falhas de LLM sem fallback, bugs que quebram a experiência do usuário.
2. **Qualidade**: inconsistências entre API e app mobile, testes ausentes para lógica de cálculo, violações das fontes científicas (ISSN, Mifflin-St Jeor).
3. **Manutenção**: código duplicado entre endpoints, complexidade desnecessária no agente, legibilidade prejudicada.
4. **Polimento**: nits de formatação ou estilo que não afetam funcionamento.

## Como Estruturar Comentários
- Indique impacto: **Bloqueador**, **Ajuste sugerido**, **Nit**.
- Descreva o problema em até duas frases.
- Proponha correção ou peça confirmação.

### Exemplos
> **Bloqueador** — `calculator.py:35` usa 0.12 fixo para proteína, ignorando peso corporal. Isso resulta em valores abaixo do mínimo recomendado para pessoas mais pesadas. Ref: issue #8.

> **Ajuste sugerido** — `agent.py:87` não trata timeout do provider. Se g4f travar, a requisição fica pendurada. Considerar `asyncio.wait_for`.

> **Nit** — `main.py:12` import não usado.

## Checklist Antes de Aprovar

### Backend (API)
- [ ] Cálculos nutricionais estão corretos conforme fontes (Mifflin-St Jeor, ISSN, FAO/OMS)
- [ ] Chamadas LLM têm timeout e fallback de providers
- [ ] Endpoints versionados (`/api/v1/`)
- [ ] Testes cobrem casos críticos (cálculos, parsing de resposta do LLM)

### Mobile (Flutter)
- [ ] Estado persiste corretamente (SharedPreferences)
- [ ] UI funciona em light/dark mode
- [ ] Integração com API usa endpoints corretos

### Geral
- [ ] Sem secrets ou credenciais hardcoded
- [ ] Type hints em funções Python
- [ ] Mensagens ao usuário em português

## Cuidados Especiais

### Cálculos Nutricionais
Os cálculos são a base do produto. Qualquer mudança em `calculator.py` deve:
- Citar a fonte científica da fórmula
- Manter compatibilidade com valores existentes ou justificar a mudança
- Ter testes que validem os valores esperados

### Integração LLM
O agente usa g4f com múltiplos providers. Mudanças em `agent.py` devem:
- Manter fallback entre providers
- Usar async com timeout (ref: PR #20, #30, #31)
- Logar erros para debug sem expor prompts completos

### Precisão de Porções
A saída do LLM deve ser validada. Valores absurdos (2g de ovo = 156 kcal) devem ser detectados. Ref: issue #21.

## Dinâmica com Autores
- Reconheça contribuições bem feitas, especialmente de novos contribuidores.
- Em desacordos, sustente com dados ou referência às fontes científicas.
- Quando resolvido, sinalize com "Resolvido".

## Comandos Úteis

# Setup
uv sync

# Rodar backend
PYTHONPATH=tara/api uv run uvicorn app.main:app --reload

# Testes
PYTHONPATH=tara/api uv run pytest

# Flutter
cd tara/mobile && flutter run


