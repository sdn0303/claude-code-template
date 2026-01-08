---
name: architecture
description: Software architecture patterns including Clean Architecture, Hexagonal, DDD, and microservices. Use when designing system structure or reviewing architectural decisions.
---

# Software Architecture Skill

Comprehensive architecture patterns and design principles.

## Clean Architecture

### Layer Hierarchy
```
┌────────────────────────────────────────────┐
│              Frameworks & Drivers           │
│  (Web, DB, UI, External Services)          │
├────────────────────────────────────────────┤
│           Interface Adapters                │
│  (Controllers, Gateways, Presenters)       │
├────────────────────────────────────────────┤
│           Application Business Rules        │
│  (Use Cases)                               │
├────────────────────────────────────────────┤
│           Enterprise Business Rules         │
│  (Entities)                                │
└────────────────────────────────────────────┘
         Dependencies point INWARD ↑
```

### Directory Structure
```
src/
├── domain/                # Enterprise Business Rules
│   ├── entities/          # Business objects
│   ├── valueobjects/      # Immutable value types
│   ├── repositories/      # Repository interfaces
│   ├── services/          # Domain services
│   └── errors/            # Domain-specific errors
├── usecase/               # Application Business Rules
│   ├── user/
│   │   ├── create_user.go
│   │   └── get_user.go
│   └── order/
├── adapter/               # Interface Adapters
│   ├── controller/        # HTTP handlers
│   ├── presenter/         # Response formatters
│   └── gateway/           # External service clients
└── infrastructure/        # Frameworks & Drivers
    ├── persistence/       # Database implementations
    ├── web/              # HTTP server setup
    └── config/           # Configuration
```

### Dependency Rule
```go
// ✓ Domain: No external dependencies
package domain

type User struct {
    ID    string
    Email string
    Name  string
}

type UserRepository interface {
    FindByID(ctx context.Context, id string) (*User, error)
    Save(ctx context.Context, user *User) error
}

// ✓ UseCase: Depends only on Domain
package usecase

type CreateUser struct {
    repo   domain.UserRepository  // Interface from domain
    hasher PasswordHasher         // Interface defined in usecase
}

func (uc *CreateUser) Execute(ctx context.Context, input CreateUserInput) (*User, error) {
    // Business logic here
}

// ✓ Adapter: Implements Domain interfaces
package adapter

type PostgresUserRepository struct {
    db *sql.DB
}

func (r *PostgresUserRepository) FindByID(ctx context.Context, id string) (*domain.User, error) {
    // SQL implementation
}
```

## Hexagonal Architecture (Ports & Adapters)

### Core Concept
```
              ┌───────────────────────────┐
              │                           │
   Driving    │         Application       │    Driven
   Adapters   │           Core            │    Adapters
              │                           │
   ┌──────┐   │  ┌─────┐      ┌─────┐    │   ┌──────┐
   │ REST │◀──┼──│Port │      │Port │────┼──▶│ DB   │
   │ API  │   │  │(in) │      │(out)│    │   │      │
   └──────┘   │  └─────┘      └─────┘    │   └──────┘
              │                           │
   ┌──────┐   │  ┌─────┐      ┌─────┐    │   ┌──────┐
   │ CLI  │◀──┼──│Port │      │Port │────┼──▶│Queue │
   │      │   │  │(in) │      │(out)│    │   │      │
   └──────┘   │  └─────┘      └─────┘    │   └──────┘
              │                           │
              └───────────────────────────┘
```

### Implementation Pattern
```go
// Primary Port (Driving/Inbound)
package port

type UserService interface {
    CreateUser(ctx context.Context, cmd CreateUserCommand) (*User, error)
    GetUser(ctx context.Context, id string) (*User, error)
}

// Secondary Port (Driven/Outbound)
type UserRepository interface {
    Save(ctx context.Context, user *User) error
    FindByID(ctx context.Context, id string) (*User, error)
}

type EventPublisher interface {
    Publish(ctx context.Context, event Event) error
}

// Application Core
package application

type UserServiceImpl struct {
    repo      port.UserRepository
    publisher port.EventPublisher
}

func (s *UserServiceImpl) CreateUser(ctx context.Context, cmd CreateUserCommand) (*User, error) {
    user := NewUser(cmd.Email, cmd.Name)
    if err := s.repo.Save(ctx, user); err != nil {
        return nil, err
    }
    s.publisher.Publish(ctx, UserCreatedEvent{UserID: user.ID})
    return user, nil
}

// Driving Adapter (HTTP)
package http

type UserHandler struct {
    service port.UserService
}

func (h *UserHandler) Create(w http.ResponseWriter, r *http.Request) {
    var req CreateUserRequest
    // ... decode request
    user, err := h.service.CreateUser(r.Context(), CreateUserCommand{...})
    // ... encode response
}

// Driven Adapter (PostgreSQL)
package postgres

type UserRepositoryImpl struct {
    db *pgxpool.Pool
}

func (r *UserRepositoryImpl) Save(ctx context.Context, user *port.User) error {
    _, err := r.db.Exec(ctx, `INSERT INTO users ...`, user.ID, user.Email)
    return err
}
```

## Domain-Driven Design (DDD)

### Strategic Patterns

#### Bounded Context
```
┌─────────────────────┐    ┌─────────────────────┐
│   Order Context     │    │   Inventory Context │
│                     │    │                     │
│  Order              │    │  Product            │
│  OrderItem          │    │  Stock              │
│  OrderService       │    │  Warehouse          │
│                     │    │                     │
└─────────────────────┘    └─────────────────────┘
         │                          │
         └──────────┬───────────────┘
                    │
              Context Map
              (Integration)
```

#### Context Map Integration Patterns
- **Shared Kernel**: Shared subset of domain model
- **Customer-Supplier**: Upstream-downstream relationship
- **Conformist**: Downstream conforms to upstream model
- **Anti-Corruption Layer**: Translate between models
- **Open Host Service**: Public API for integration
- **Published Language**: Standard interchange format

### Tactical Patterns

#### Entity
```go
// Entity: Identity-based, mutable
type Order struct {
    id        OrderID           // Identity
    customer  CustomerID
    items     []OrderItem
    status    OrderStatus
    createdAt time.Time
    version   int               // Optimistic locking
}

// Entities are equal by identity
func (o *Order) Equals(other *Order) bool {
    return o.id == other.id
}

// Behavior encapsulated
func (o *Order) AddItem(product ProductID, quantity int, price Money) error {
    if o.status != OrderStatusDraft {
        return ErrOrderNotModifiable
    }
    o.items = append(o.items, NewOrderItem(product, quantity, price))
    return nil
}
```

#### Value Object
```go
// Value Object: Immutable, equality by attributes
type Money struct {
    amount   decimal.Decimal
    currency Currency
}

func NewMoney(amount decimal.Decimal, currency Currency) Money {
    return Money{amount: amount, currency: currency}
}

func (m Money) Add(other Money) (Money, error) {
    if m.currency != other.currency {
        return Money{}, ErrCurrencyMismatch
    }
    return NewMoney(m.amount.Add(other.amount), m.currency), nil
}

// Value Objects are equal by attributes
func (m Money) Equals(other Money) bool {
    return m.amount.Equal(other.amount) && m.currency == other.currency
}

// Value Object: Address
type Address struct {
    street     string
    city       string
    postalCode string
    country    string
}
```

#### Aggregate
```go
// Aggregate Root: Consistency boundary
type Order struct {
    // ... fields ...
}

// Only Aggregate Root is accessed from outside
// Internal entities accessed through root
func (o *Order) CalculateTotal() Money {
    total := NewMoney(decimal.Zero, o.currency)
    for _, item := range o.items {
        total = total.Add(item.Subtotal())
    }
    return total
}

// Repository per Aggregate
type OrderRepository interface {
    FindByID(ctx context.Context, id OrderID) (*Order, error)
    Save(ctx context.Context, order *Order) error
    // No FindOrderItem - access through Order
}
```

#### Domain Event
```go
// Domain Event: Something that happened
type OrderPlaced struct {
    OrderID    OrderID
    CustomerID CustomerID
    TotalAmount Money
    OccurredAt time.Time
}

// Aggregate raises events
func (o *Order) Place() error {
    if len(o.items) == 0 {
        return ErrEmptyOrder
    }
    o.status = OrderStatusPlaced
    o.Raise(OrderPlaced{
        OrderID:    o.id,
        CustomerID: o.customer,
        TotalAmount: o.CalculateTotal(),
        OccurredAt: time.Now(),
    })
    return nil
}
```

#### Domain Service
```go
// Domain Service: Logic that doesn't belong to single entity
type PricingService struct {
    discountPolicy DiscountPolicy
    taxCalculator  TaxCalculator
}

func (s *PricingService) CalculateOrderPrice(order *Order, customer *Customer) (Money, error) {
    subtotal := order.CalculateTotal()
    discount := s.discountPolicy.Apply(subtotal, customer.Tier())
    tax := s.taxCalculator.Calculate(subtotal.Subtract(discount), customer.Address())
    return subtotal.Subtract(discount).Add(tax), nil
}
```

## Microservices Patterns

### Service Decomposition
```
┌─────────────┐  ┌─────────────┐  ┌─────────────┐
│   User      │  │   Order     │  │  Inventory  │
│   Service   │  │   Service   │  │   Service   │
└──────┬──────┘  └──────┬──────┘  └──────┬──────┘
       │                │                │
       └────────────────┼────────────────┘
                        │
              ┌─────────▼─────────┐
              │   API Gateway     │
              │   (BFF Pattern)   │
              └───────────────────┘
```

### Communication Patterns

#### Synchronous (REST/gRPC)
```go
// gRPC Service Definition
service UserService {
    rpc GetUser(GetUserRequest) returns (User);
    rpc CreateUser(CreateUserRequest) returns (User);
}

// Client with Circuit Breaker
type UserClient struct {
    conn    *grpc.ClientConn
    breaker *gobreaker.CircuitBreaker
}

func (c *UserClient) GetUser(ctx context.Context, id string) (*User, error) {
    result, err := c.breaker.Execute(func() (interface{}, error) {
        return c.client.GetUser(ctx, &GetUserRequest{Id: id})
    })
    if err != nil {
        return nil, err
    }
    return result.(*User), nil
}
```

#### Asynchronous (Event-Driven)
```go
// Event Publisher
type OrderEventPublisher struct {
    producer *kafka.Producer
}

func (p *OrderEventPublisher) PublishOrderPlaced(ctx context.Context, event OrderPlaced) error {
    data, _ := json.Marshal(event)
    return p.producer.Produce(&kafka.Message{
        TopicPartition: kafka.TopicPartition{Topic: &orderTopic},
        Key:           []byte(event.OrderID),
        Value:         data,
        Headers: []kafka.Header{
            {Key: "event_type", Value: []byte("OrderPlaced")},
            {Key: "correlation_id", Value: []byte(ctx.Value("correlationID").(string))},
        },
    }, nil)
}

// Event Consumer
func (c *InventoryConsumer) HandleOrderPlaced(ctx context.Context, event OrderPlaced) error {
    for _, item := range event.Items {
        if err := c.stockService.Reserve(ctx, item.ProductID, item.Quantity); err != nil {
            return err
        }
    }
    return nil
}
```

### Saga Pattern
```go
// Orchestration Saga
type CreateOrderSaga struct {
    orderService     OrderService
    paymentService   PaymentService
    inventoryService InventoryService
}

func (s *CreateOrderSaga) Execute(ctx context.Context, cmd CreateOrderCommand) error {
    // Step 1: Create Order
    order, err := s.orderService.Create(ctx, cmd)
    if err != nil {
        return err
    }

    // Step 2: Reserve Inventory
    if err := s.inventoryService.Reserve(ctx, order.Items); err != nil {
        // Compensate: Cancel Order
        s.orderService.Cancel(ctx, order.ID)
        return err
    }

    // Step 3: Process Payment
    if err := s.paymentService.Charge(ctx, order.Total); err != nil {
        // Compensate: Release Inventory, Cancel Order
        s.inventoryService.Release(ctx, order.Items)
        s.orderService.Cancel(ctx, order.ID)
        return err
    }

    return nil
}
```

## CQRS (Command Query Responsibility Segregation)

### Architecture
```
              ┌──────────────┐
              │   Commands   │
              │  (Write API) │
              └──────┬───────┘
                     │
              ┌──────▼───────┐
              │   Command    │
              │   Handler    │
              └──────┬───────┘
                     │
              ┌──────▼───────┐        ┌────────────┐
              │    Write     │───────▶│   Event    │
              │    Model     │        │   Store    │
              └──────────────┘        └─────┬──────┘
                                            │
                                     ┌──────▼──────┐
                                     │  Projection │
                                     └──────┬──────┘
                                            │
              ┌──────────────┐        ┌─────▼──────┐
              │   Queries    │◀───────│   Read     │
              │  (Read API)  │        │   Model    │
              └──────────────┘        └────────────┘
```

### Implementation
```go
// Command
type CreateOrderCommand struct {
    CustomerID string
    Items      []OrderItemDTO
}

// Command Handler
type CreateOrderHandler struct {
    repo      OrderRepository
    publisher EventPublisher
}

func (h *CreateOrderHandler) Handle(ctx context.Context, cmd CreateOrderCommand) error {
    order := domain.NewOrder(cmd.CustomerID, cmd.Items)
    if err := h.repo.Save(ctx, order); err != nil {
        return err
    }
    return h.publisher.Publish(ctx, order.Events()...)
}

// Query
type GetOrderQuery struct {
    OrderID string
}

// Query Handler (uses read model)
type GetOrderHandler struct {
    readDB *sql.DB  // Denormalized read database
}

func (h *GetOrderHandler) Handle(ctx context.Context, q GetOrderQuery) (*OrderReadModel, error) {
    var order OrderReadModel
    err := h.readDB.QueryRow(ctx, `
        SELECT id, customer_name, total, status, item_count
        FROM order_read_model WHERE id = $1
    `, q.OrderID).Scan(&order.ID, &order.CustomerName, &order.Total, &order.Status, &order.ItemCount)
    return &order, err
}

// Projection (Event → Read Model)
type OrderProjection struct {
    readDB *sql.DB
}

func (p *OrderProjection) Apply(ctx context.Context, event Event) error {
    switch e := event.(type) {
    case OrderPlaced:
        _, err := p.readDB.Exec(ctx, `
            INSERT INTO order_read_model (id, customer_name, total, status)
            VALUES ($1, $2, $3, 'placed')
        `, e.OrderID, e.CustomerName, e.Total)
        return err
    }
    return nil
}
```

## Architecture Decision Records (ADR)

### Template
```markdown
# ADR-001: Use PostgreSQL as Primary Database

## Status
Accepted

## Context
We need to choose a primary database for storing application data.
Requirements include: ACID compliance, JSON support, full-text search.

## Decision
We will use PostgreSQL 15+ as the primary database.

## Consequences

### Positive
- Strong ACID guarantees
- JSONB for semi-structured data
- Full-text search capabilities
- Mature ecosystem

### Negative
- Operational complexity vs managed NoSQL
- Horizontal scaling requires additional tools

### Neutral
- Team has PostgreSQL experience
```

## Architecture Review Checklist

### Design Quality
- [ ] Single Responsibility at component level
- [ ] Loose coupling between modules
- [ ] High cohesion within modules
- [ ] Dependency Injection used
- [ ] Interfaces at boundaries

### Scalability
- [ ] Stateless services where possible
- [ ] Horizontal scaling strategy defined
- [ ] Database sharding/partitioning plan
- [ ] Caching strategy documented
- [ ] Async processing for long operations

### Resilience
- [ ] Circuit breakers for external calls
- [ ] Retry with exponential backoff
- [ ] Graceful degradation strategy
- [ ] Health checks implemented
- [ ] Timeout policies defined

### Observability
- [ ] Structured logging
- [ ] Distributed tracing
- [ ] Metrics collection
- [ ] Alerting thresholds defined
- [ ] Dashboards available

### Security
- [ ] Authentication/Authorization designed
- [ ] Secrets management
- [ ] Data encryption (at rest, in transit)
- [ ] Input validation at boundaries
- [ ] Security audit logging
