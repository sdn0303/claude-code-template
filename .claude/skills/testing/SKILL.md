---
name: testing
description: Testing strategies, patterns, and best practices across languages. Use when writing or improving tests.
---

# Testing Skill

Comprehensive testing patterns for reliable software.

## Testing Pyramid

```
         ┌───────┐
         │  E2E  │  Few, slow, brittle
         ├───────┤
         │ Integ │  Some, medium speed
         ├───────┴───────┐
         │     Unit      │  Many, fast, stable
         └───────────────┘

Ratio: Unit 70% | Integration 20% | E2E 10%
```

## Coverage Targets

```
Minimum:   70%  (acceptable)
Target:    80%  (good)
Critical:  90%+ (auth, payments, security)

Focus on:
- Business logic
- Error handling paths
- Edge cases

Avoid testing:
- Getters/setters
- Framework code
- Third-party libraries
```

## Test Structure

### Arrange-Act-Assert (AAA)
```go
func TestCreateUser(t *testing.T) {
    // Arrange
    repo := NewMockUserRepository()
    service := NewUserService(repo)
    input := CreateUserInput{Name: "Alice", Email: "alice@example.com"}
    
    // Act
    user, err := service.CreateUser(ctx, input)
    
    // Assert
    assert.NoError(t, err)
    assert.Equal(t, "Alice", user.Name)
    assert.NotEmpty(t, user.ID)
}
```

### Given-When-Then (BDD)
```typescript
describe('UserService', () => {
  describe('createUser', () => {
    it('should create user with valid input', async () => {
      // Given
      const input = { name: 'Alice', email: 'alice@example.com' };
      
      // When
      const user = await userService.createUser(input);
      
      // Then
      expect(user.name).toBe('Alice');
      expect(user.id).toBeDefined();
    });
  });
});
```

## Table-Driven Tests

### Go
```go
func TestValidateEmail(t *testing.T) {
    tests := []struct {
        name    string
        email   string
        wantErr bool
    }{
        {"valid email", "user@example.com", false},
        {"missing @", "userexample.com", true},
        {"missing domain", "user@", true},
        {"empty string", "", true},
        {"with subdomain", "user@mail.example.com", false},
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            err := ValidateEmail(tt.email)
            if (err != nil) != tt.wantErr {
                t.Errorf("ValidateEmail(%q) error = %v, wantErr %v", 
                    tt.email, err, tt.wantErr)
            }
        })
    }
}
```

### Python (pytest)
```python
import pytest

@pytest.mark.parametrize("email,expected_valid", [
    ("user@example.com", True),
    ("userexample.com", False),
    ("user@", False),
    ("", False),
    ("user@mail.example.com", True),
])
def test_validate_email(email: str, expected_valid: bool):
    result = validate_email(email)
    assert result == expected_valid
```

### TypeScript (Jest)
```typescript
describe('validateEmail', () => {
  const testCases = [
    { email: 'user@example.com', expected: true },
    { email: 'userexample.com', expected: false },
    { email: 'user@', expected: false },
    { email: '', expected: false },
    { email: 'user@mail.example.com', expected: true },
  ];

  test.each(testCases)('$email should be $expected', ({ email, expected }) => {
    expect(validateEmail(email)).toBe(expected);
  });
});
```

## Mocking Patterns

### Interface-Based Mocking (Go)
```go
// Define interface in consumer package
type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// Mock implementation
type MockUserRepository struct {
    FindByIDFunc func(ctx context.Context, id string) (*User, error)
    SaveFunc     func(ctx context.Context, user *User) error
}

func (m *MockUserRepository) FindByID(ctx context.Context, id string) (*User, error) {
    return m.FindByIDFunc(ctx, id)
}

// Usage in test
func TestGetUser(t *testing.T) {
    mock := &MockUserRepository{
        FindByIDFunc: func(ctx context.Context, id string) (*User, error) {
            return &User{ID: id, Name: "Alice"}, nil
        },
    }
    service := NewUserService(mock)
    // ...
}
```

### Jest Mocking (TypeScript)
```typescript
// Auto-mock module
jest.mock('./userRepository');

// Manual mock
const mockUserRepository = {
  findById: jest.fn(),
  save: jest.fn(),
};

beforeEach(() => {
  jest.clearAllMocks();
});

test('getUser returns user', async () => {
  mockUserRepository.findById.mockResolvedValue({ id: '1', name: 'Alice' });
  
  const user = await userService.getUser('1');
  
  expect(user.name).toBe('Alice');
  expect(mockUserRepository.findById).toHaveBeenCalledWith('1');
});
```

### pytest Mocking (Python)
```python
from unittest.mock import Mock, patch, AsyncMock

def test_get_user(mocker):
    # Using pytest-mock
    mock_repo = mocker.Mock()
    mock_repo.find_by_id.return_value = User(id="1", name="Alice")
    
    service = UserService(mock_repo)
    user = service.get_user("1")
    
    assert user.name == "Alice"
    mock_repo.find_by_id.assert_called_once_with("1")

@patch('myapp.services.user_repository')
def test_with_patch(mock_repo):
    mock_repo.find_by_id.return_value = User(id="1", name="Alice")
    # ...
```

## Integration Testing

### Database Integration (Go)
```go
func TestUserRepository_Integration(t *testing.T) {
    if testing.Short() {
        t.Skip("skipping integration test")
    }
    
    // Setup test database
    db := setupTestDB(t)
    t.Cleanup(func() { cleanupTestDB(db) })
    
    repo := NewPostgresUserRepository(db)
    
    t.Run("Save and FindByID", func(t *testing.T) {
        user := &User{Name: "Alice", Email: "alice@example.com"}
        
        err := repo.Save(ctx, user)
        require.NoError(t, err)
        require.NotEmpty(t, user.ID)
        
        found, err := repo.FindByID(ctx, user.ID)
        require.NoError(t, err)
        assert.Equal(t, user.Name, found.Name)
    })
}

func setupTestDB(t *testing.T) *sql.DB {
    t.Helper()
    db, err := sql.Open("postgres", os.Getenv("TEST_DATABASE_URL"))
    require.NoError(t, err)
    
    // Run migrations
    migrate.Up(db)
    return db
}
```

### HTTP Integration (TypeScript)
```typescript
import request from 'supertest';
import { app } from '../app';

describe('User API', () => {
  beforeEach(async () => {
    await db.migrate.latest();
    await db.seed.run();
  });

  afterEach(async () => {
    await db.migrate.rollback();
  });

  describe('GET /api/users/:id', () => {
    it('returns user when exists', async () => {
      const response = await request(app)
        .get('/api/users/1')
        .expect(200);

      expect(response.body).toMatchObject({
        id: '1',
        name: expect.any(String),
      });
    });

    it('returns 404 when not found', async () => {
      await request(app)
        .get('/api/users/nonexistent')
        .expect(404);
    });
  });
});
```

## E2E Testing

### Playwright (TypeScript)
```typescript
import { test, expect } from '@playwright/test';

test.describe('User Registration', () => {
  test('completes registration flow', async ({ page }) => {
    await page.goto('/register');
    
    await page.fill('[data-testid="name-input"]', 'Alice');
    await page.fill('[data-testid="email-input"]', 'alice@example.com');
    await page.fill('[data-testid="password-input"]', 'SecurePass123!');
    await page.click('[data-testid="submit-button"]');
    
    await expect(page).toHaveURL('/dashboard');
    await expect(page.locator('[data-testid="welcome-message"]'))
      .toContainText('Welcome, Alice');
  });

  test('shows validation errors', async ({ page }) => {
    await page.goto('/register');
    await page.click('[data-testid="submit-button"]');
    
    await expect(page.locator('[data-testid="email-error"]'))
      .toBeVisible();
  });
});
```

## Test Fixtures

### Go
```go
// testdata/users.json - loaded automatically
func TestParseUsers(t *testing.T) {
    data, err := os.ReadFile("testdata/users.json")
    require.NoError(t, err)
    // ...
}

// Factory pattern
func NewTestUser(overrides ...func(*User)) *User {
    user := &User{
        ID:    uuid.New().String(),
        Name:  "Test User",
        Email: "test@example.com",
    }
    for _, override := range overrides {
        override(user)
    }
    return user
}

// Usage
user := NewTestUser(func(u *User) { u.Name = "Alice" })
```

### TypeScript
```typescript
// Factory with faker
import { faker } from '@faker-js/faker';

export const createUser = (overrides?: Partial<User>): User => ({
  id: faker.string.uuid(),
  name: faker.person.fullName(),
  email: faker.internet.email(),
  createdAt: faker.date.past(),
  ...overrides,
});

// Usage
const user = createUser({ name: 'Alice' });
```

## Testing Async Code

### Go
```go
func TestAsyncOperation(t *testing.T) {
    ctx, cancel := context.WithTimeout(context.Background(), 5*time.Second)
    defer cancel()
    
    resultChan := make(chan Result)
    go func() {
        result, _ := asyncOperation(ctx)
        resultChan <- result
    }()
    
    select {
    case result := <-resultChan:
        assert.Equal(t, expected, result)
    case <-ctx.Done():
        t.Fatal("test timed out")
    }
}
```

### TypeScript
```typescript
test('async operation completes', async () => {
  const result = await asyncOperation();
  expect(result).toBe(expected);
});

test('async operation with timeout', async () => {
  jest.useFakeTimers();
  
  const promise = asyncOperationWithRetry();
  jest.advanceTimersByTime(5000);
  
  await expect(promise).resolves.toBe(expected);
  jest.useRealTimers();
});
```

## Error Testing

### Testing Error Cases
```go
func TestCreateUser_ValidationError(t *testing.T) {
    tests := []struct {
        name    string
        input   CreateUserInput
        wantErr error
    }{
        {
            name:    "empty name",
            input:   CreateUserInput{Name: "", Email: "a@b.com"},
            wantErr: ErrNameRequired,
        },
        {
            name:    "invalid email",
            input:   CreateUserInput{Name: "A", Email: "invalid"},
            wantErr: ErrInvalidEmail,
        },
    }
    
    for _, tt := range tests {
        t.Run(tt.name, func(t *testing.T) {
            _, err := service.CreateUser(ctx, tt.input)
            assert.ErrorIs(t, err, tt.wantErr)
        })
    }
}
```

### Testing Panics (Go)
```go
func TestPanicsOnNil(t *testing.T) {
    assert.Panics(t, func() {
        processNilUnsafe(nil)
    })
}
```

## Snapshot Testing

### Jest
```typescript
test('renders user profile', () => {
  const component = render(<UserProfile user={mockUser} />);
  expect(component).toMatchSnapshot();
});

// Update snapshots: jest --updateSnapshot
```

## Test Organization

### Directory Structure
```
project/
├── internal/
│   └── user/
│       ├── service.go
│       ├── service_test.go      # Unit tests (same package)
│       └── repository.go
├── test/
│   ├── integration/
│   │   └── user_test.go         # Integration tests
│   ├── e2e/
│   │   └── user_flow_test.go    # E2E tests
│   └── testutil/
│       └── fixtures.go          # Shared test utilities
```

### Test Naming
```go
// Function_Scenario_ExpectedResult
func TestCreateUser_ValidInput_ReturnsUser(t *testing.T)
func TestCreateUser_DuplicateEmail_ReturnsError(t *testing.T)
func TestCreateUser_EmptyName_ReturnsValidationError(t *testing.T)
```

## CI/CD Integration

### GitHub Actions
```yaml
name: Tests
on: [push, pull_request]

jobs:
  test:
    runs-on: ubuntu-latest
    services:
      postgres:
        image: postgres:15
        env:
          POSTGRES_PASSWORD: test
        ports:
          - 5432:5432
    steps:
      - uses: actions/checkout@v4
      - uses: actions/setup-go@v5
        with:
          go-version: '1.23'
      - name: Unit Tests
        run: go test -short -race -coverprofile=coverage.out ./...
      - name: Integration Tests
        run: go test -race ./test/integration/...
        env:
          TEST_DATABASE_URL: postgres://postgres:test@localhost:5432/test
      - name: Upload Coverage
        uses: codecov/codecov-action@v4
```

## Flaky Test Prevention

### Guidelines
```
1. No shared state between tests
2. No reliance on test execution order
3. Explicit waits instead of sleeps
4. Deterministic data generation
5. Isolated test databases
6. Mock external services
7. Retry flaky external calls in SUT, not tests
```

### Quarantine Flaky Tests
```go
func TestFlakyOperation(t *testing.T) {
    if os.Getenv("RUN_FLAKY_TESTS") != "true" {
        t.Skip("skipping flaky test")
    }
    // ...
}
```
