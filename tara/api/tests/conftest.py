from __future__ import annotations

import sys
from pathlib import Path


ROOT = Path(__file__).resolve().parents[1]
SUPPORT = ROOT / "tests" / "support"

if str(ROOT) not in sys.path:
    sys.path.insert(0, str(ROOT))

if SUPPORT.exists() and str(SUPPORT) not in sys.path:
    sys.path.insert(0, str(SUPPORT))
