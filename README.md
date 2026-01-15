---
title: Tara
emoji: 🔥
colorFrom: green
colorTo: emerald
sdk: docker
pinned: false
license: mit
short_description: Agente que calcula porções ideais de alimentos baseado no seu perfil de saúde
---

#  Tara <img src="static/logo.png" alt="Tara" width="35" height="35">

Agente que recebe um cardápio e calcula a quantidade de gramas de cada alimento para sua refeição, baseado no seu perfil de saúde.

## O que faz

1. **Calcula suas metas**: TMB, TDEE e macros baseados no seu perfil
2. **Distribui calorias por refeição**: Calcula automaticamente a quantidade ideal para cada refeição do dia
3. **Analisa cardápios**: Cole o texto do cardápio do restaurante
4. **Recomenda alimentos**: Escolhe os melhores pratos com quantidades em gramas

## Fontes dos Cálculos

| Cálculo | Fonte |
|---------|-------|
| TMB | Mifflin-St Jeor (1990) |
| Fatores de Atividade | FAO/OMS |
| Déficit 20% | ABESO / ACSM |
| Macros (Carb 65%, Prot 12%, Gord 23%) | SBAN |
| Distribuição de Refeições | Guia Alimentar para a População Brasileira |
