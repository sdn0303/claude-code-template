---
name: python
description: Python best practices for backend development. Use when writing FastAPI, Django, or general Python code.
---

# Python Development Skill

Best practices for modern Python development (3.11+).

## Project Structure

```
project/
├── src/
│   └── project_name/
│       ├── __init__.py
│       ├── main.py
│       ├── domain/           # Business entities
│       │   └── user/
│       │       ├── entity.py
│       │       └── repository.py
│       ├── application/      # Use cases
│       │   └── user/
│       │       └── create.py
│       ├── infrastructure/   # External
│       │   ├── database/
│       │   └── api/
│       └── presentation/     # API layer
│           └── api/
├── tests/
│   ├── unit/
│   ├── integration/
│   └── conftest.py
├── pyproject.toml
└── uv.lock
```

## Type Hints

### Basic Types
```python
from typing import Optional, Union
from collections.abc import Sequence

def greet(name: str) -> str:
    return f"Hello, {name}"

def process(items: list[str]) -> dict[str, int]:
    return {item: len(item) for item in items}

def find_user(user_id: str) -> Optional[User]:
    # Returns User or None
    pass

def get_value(key: str) -> str | None:  # Python 3.10+
    pass
```

### Generic Types
```python
from typing import TypeVar, Generic

T = TypeVar('T')

class Repository(Generic[T]):
    def find_by_id(self, id: str) -> T | None: ...
    def save(self, entity: T) -> T: ...
```

### Dataclasses
```python
from dataclasses import dataclass, field
from datetime import datetime

@dataclass
class User:
    id: str
    email: str
    name: str
    created_at: datetime = field(default_factory=datetime.utcnow)
    
    def __post_init__(self):
        if not self.email:
            raise ValueError("Email required")
```

### Pydantic Models
```python
from pydantic import BaseModel, EmailStr, Field

class UserCreate(BaseModel):
    email: EmailStr
    name: str = Field(min_length=1, max_length=100)

class UserResponse(BaseModel):
    id: str
    email: str
    name: str
    
    model_config = {"from_attributes": True}
```

## Error Handling

### Custom Exceptions
```python
class DomainError(Exception):
    """Base domain exception"""
    pass

class NotFoundError(DomainError):
    def __init__(self, entity: str, id: str):
        self.entity = entity
        self.id = id
        super().__init__(f"{entity} not found: {id}")

class ValidationError(DomainError):
    def __init__(self, field: str, message: str):
        self.field = field
        self.message = message
        super().__init__(f"{field}: {message}")
```

### Context Managers
```python
from contextlib import contextmanager

@contextmanager
def transaction(session):
    try:
        yield session
        session.commit()
    except Exception:
        session.rollback()
        raise
```

## Async Programming

### Async Functions
```python
import asyncio
from typing import AsyncIterator

async def fetch_user(user_id: str) -> User:
    async with httpx.AsyncClient() as client:
        response = await client.get(f"/users/{user_id}")
        return User(**response.json())

async def process_users(user_ids: list[str]) -> list[User]:
    tasks = [fetch_user(uid) for uid in user_ids]
    return await asyncio.gather(*tasks)
```

### Async Generators
```python
async def stream_data() -> AsyncIterator[dict]:
    async with aiofiles.open('data.jsonl') as f:
        async for line in f:
            yield json.loads(line)
```

## FastAPI Patterns

### Router Structure
```python
from fastapi import APIRouter, Depends, HTTPException, status

router = APIRouter(prefix="/users", tags=["users"])

@router.get("/{user_id}", response_model=UserResponse)
async def get_user(
    user_id: str,
    service: UserService = Depends(get_user_service),
) -> UserResponse:
    user = await service.get_by_id(user_id)
    if not user:
        raise HTTPException(
            status_code=status.HTTP_404_NOT_FOUND,
            detail="User not found",
        )
    return UserResponse.model_validate(user)
```

### Dependency Injection
```python
from functools import lru_cache

@lru_cache
def get_settings() -> Settings:
    return Settings()

def get_database(
    settings: Settings = Depends(get_settings),
) -> Database:
    return Database(settings.database_url)

def get_user_repository(
    db: Database = Depends(get_database),
) -> UserRepository:
    return UserRepository(db)
```

## Testing

### Pytest Fixtures
```python
import pytest
from unittest.mock import AsyncMock, Mock

@pytest.fixture
def mock_repository():
    repo = Mock(spec=UserRepository)
    repo.find_by_id = AsyncMock(return_value=User(id="1", name="Test"))
    return repo

@pytest.fixture
def user_service(mock_repository):
    return UserService(repository=mock_repository)
```

### Parametrized Tests
```python
@pytest.mark.parametrize(
    "input_value,expected",
    [
        ("valid@email.com", True),
        ("invalid-email", False),
        ("", False),
    ],
)
def test_validate_email(input_value: str, expected: bool):
    assert validate_email(input_value) == expected
```

### Async Tests
```python
import pytest

@pytest.mark.asyncio
async def test_fetch_user(user_service, mock_repository):
    result = await user_service.get_by_id("1")
    
    assert result.id == "1"
    mock_repository.find_by_id.assert_called_once_with("1")
```

## Package Management (uv)

```bash
# Create project
uv init project-name
cd project-name

# Add dependencies
uv add fastapi uvicorn
uv add --dev pytest pytest-asyncio

# Run
uv run python -m project_name.main

# Test
uv run pytest

# Sync
uv sync
```

## Code Quality

```bash
# Format
uv run ruff format .

# Lint
uv run ruff check . --fix

# Type check
uv run mypy src/
```

## pyproject.toml

```toml
[project]
name = "project-name"
version = "0.1.0"
requires-python = ">=3.11"
dependencies = [
    "fastapi>=0.100",
    "uvicorn>=0.23",
    "pydantic>=2.0",
]

[project.optional-dependencies]
dev = [
    "pytest>=7.0",
    "pytest-asyncio>=0.21",
    "ruff>=0.1",
    "mypy>=1.0",
]

[tool.ruff]
line-length = 100
target-version = "py311"

[tool.mypy]
python_version = "3.11"
strict = true
```
