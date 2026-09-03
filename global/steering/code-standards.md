---
inclusion: auto
---

# Code Standards

## Python
- Formatter: ruff format
- Linter: ruff check
- Type hints: always on public functions
- Docstrings: Google style
- Min Python version: 3.10
- Testing: pytest
- Async: prefer asyncio patterns
- Imports: sorted by ruff (isort compatible)

## General
- Commits: conventional commits (feat/fix/chore/docs)
- Branch naming: feature/{ticket}-{short-desc}, fix/{ticket}-{short-desc}
- No console.log/print in production code
- Error handling: explicit, no silent catches
- Prefer composition over inheritance
- Keep functions small and focused
