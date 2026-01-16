import json
import unicodedata
from pathlib import Path
from difflib import SequenceMatcher

DATA_PATH = Path(__file__).parent / "data" / "taco.json"


def _normalize(text: str) -> str:
    """Remove acentos e normaliza texto para busca."""
    nfkd = unicodedata.normalize("NFKD", text)
    return "".join(c for c in nfkd if not unicodedata.combining(c)).lower()

_foods_cache: list[dict] | None = None


def _load_foods() -> list[dict]:
    """Carrega os alimentos do JSONL em cache."""
    global _foods_cache
    
    if _foods_cache is not None:
        return _foods_cache
    
    _foods_cache = []
    with open(DATA_PATH, "r", encoding="utf-8") as f:
        for line in f:
            line = line.strip()
            if not line:
                continue
            item = json.loads(line)
            food = _parse_food(item)
            if food:
                _foods_cache.append(food)
    
    return _foods_cache


def _parse_food(item: dict) -> dict | None:
    """Converte item raw da TBCA para formato simplificado."""
    nutrientes = {n["Componente"]: n["Valor por 100g"] for n in item.get("nutrientes", [])}
    
    def get_float(key: str) -> float:
        val = nutrientes.get(key, "0")
        if val in ("NA", "Tr", "-", ""):
            return 0.0
        try:
            return float(val.replace(",", "."))
        except ValueError:
            return 0.0
    
    return {
        "codigo": item.get("codigo", ""),
        "nome": item.get("descricao", ""),
        "classe": item.get("classe", ""),
        "por_100g": {
            "calorias": get_float("Energia"),
            "proteina_g": get_float("Proteína"),
            "carboidrato_g": get_float("Carboidrato total"),
            "gordura_g": get_float("Lipídios"),
            "fibra_g": get_float("Fibra alimentar"),
        },
    }


def _similarity(a: str, b: str) -> float:
    """Calcula similaridade entre duas strings (já normalizadas)."""
    return SequenceMatcher(None, a, b).ratio()


def search_food(term: str, limit: int = 5) -> list[dict]:
    """
    Busca alimentos por termo com matching fuzzy.
    
    Args:
        term: Termo de busca (ex: "arroz", "feijão")
        limit: Número máximo de resultados
    
    Returns:
        Lista de alimentos ordenados por relevância
    """
    foods = _load_foods()
    term_norm = _normalize(term)
    
    results = []
    for food in foods:
        nome_norm = _normalize(food["nome"])
        
        # Match exato no início
        if nome_norm.startswith(term_norm):
            score = 1.0
        # Contém o termo
        elif term_norm in nome_norm:
            score = 0.8
        # Similaridade fuzzy
        else:
            score = _similarity(term_norm, nome_norm)
            if score < 0.3:
                continue
        
        results.append((score, food))
    
    # Ordena por score decrescente
    results.sort(key=lambda x: x[0], reverse=True)
    
    return [food for _, food in results[:limit]]


def get_food_by_code(code: str) -> dict | None:
    """Busca alimento por código TBCA."""
    foods = _load_foods()
    for food in foods:
        if food["codigo"] == code:
            return food
    return None


def list_classes() -> list[str]:
    """Lista todas as classes/categorias de alimentos."""
    foods = _load_foods()
    classes = set(f["classe"] for f in foods)
    return sorted(classes)


def search_by_class(classe: str, limit: int = 20) -> list[dict]:
    """Busca alimentos por classe/categoria."""
    foods = _load_foods()
    classe_lower = classe.lower()
    
    results = [f for f in foods if classe_lower in f["classe"].lower()]
    return results[:limit]
