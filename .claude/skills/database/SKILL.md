---
name: database
description: Database best practices for PostgreSQL, MySQL, and MongoDB. Use when designing schemas, writing queries, or optimizing database performance.
---

# Database Development Skill

Best practices for database design and operations.

## PostgreSQL

### Schema Design
```sql
-- Use appropriate data types
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE,
    name VARCHAR(100) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'active',
    metadata JSONB DEFAULT '{}',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW(),
    updated_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

-- Indexes for common queries
CREATE INDEX idx_users_email ON users(email);
CREATE INDEX idx_users_status ON users(status) WHERE status = 'active';
CREATE INDEX idx_users_metadata ON users USING GIN(metadata);

-- Updated at trigger
CREATE OR REPLACE FUNCTION update_updated_at()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER users_updated_at
    BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at();
```

### Relationships
```sql
-- One-to-Many
CREATE TABLE orders (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    user_id UUID NOT NULL REFERENCES users(id) ON DELETE CASCADE,
    total_amount DECIMAL(10, 2) NOT NULL,
    status VARCHAR(20) NOT NULL DEFAULT 'pending',
    created_at TIMESTAMPTZ NOT NULL DEFAULT NOW()
);

CREATE INDEX idx_orders_user_id ON orders(user_id);

-- Many-to-Many
CREATE TABLE order_items (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    order_id UUID NOT NULL REFERENCES orders(id) ON DELETE CASCADE,
    product_id UUID NOT NULL REFERENCES products(id),
    quantity INTEGER NOT NULL CHECK (quantity > 0),
    unit_price DECIMAL(10, 2) NOT NULL,
    UNIQUE(order_id, product_id)
);
```

### Query Patterns
```sql
-- Pagination (offset)
SELECT * FROM users
ORDER BY created_at DESC
LIMIT 20 OFFSET 40;

-- Pagination (cursor-based, better for large datasets)
SELECT * FROM users
WHERE created_at < '2024-01-01T00:00:00Z'
ORDER BY created_at DESC
LIMIT 20;

-- Aggregations
SELECT 
    DATE_TRUNC('day', created_at) as day,
    COUNT(*) as order_count,
    SUM(total_amount) as revenue
FROM orders
WHERE created_at >= NOW() - INTERVAL '30 days'
GROUP BY DATE_TRUNC('day', created_at)
ORDER BY day DESC;

-- CTEs for complex queries
WITH active_users AS (
    SELECT id, email FROM users WHERE status = 'active'
),
recent_orders AS (
    SELECT user_id, COUNT(*) as order_count
    FROM orders
    WHERE created_at >= NOW() - INTERVAL '30 days'
    GROUP BY user_id
)
SELECT u.email, COALESCE(o.order_count, 0) as orders
FROM active_users u
LEFT JOIN recent_orders o ON u.id = o.user_id;
```

## MySQL

### Schema Design
```sql
CREATE TABLE users (
    id CHAR(36) PRIMARY KEY,
    email VARCHAR(255) NOT NULL,
    name VARCHAR(100) NOT NULL,
    status ENUM('active', 'inactive', 'suspended') NOT NULL DEFAULT 'active',
    metadata JSON,
    created_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP,
    updated_at TIMESTAMP NOT NULL DEFAULT CURRENT_TIMESTAMP ON UPDATE CURRENT_TIMESTAMP,
    UNIQUE INDEX idx_email (email),
    INDEX idx_status (status)
) ENGINE=InnoDB DEFAULT CHARSET=utf8mb4 COLLATE=utf8mb4_unicode_ci;
```

### Query Optimization
```sql
-- Use EXPLAIN ANALYZE
EXPLAIN ANALYZE SELECT * FROM users WHERE email = 'test@example.com';

-- Avoid SELECT *
SELECT id, email, name FROM users WHERE status = 'active';

-- Use covering indexes
CREATE INDEX idx_users_status_email ON users(status, email, name);

-- Batch inserts
INSERT INTO users (id, email, name) VALUES
    (UUID(), 'user1@example.com', 'User 1'),
    (UUID(), 'user2@example.com', 'User 2'),
    (UUID(), 'user3@example.com', 'User 3');
```

## MongoDB

### Schema Design
```javascript
// User document
{
  _id: ObjectId("..."),
  email: "user@example.com",
  name: "User Name",
  status: "active",
  profile: {
    avatar: "https://...",
    bio: "..."
  },
  preferences: {
    notifications: true,
    theme: "dark"
  },
  createdAt: ISODate("2024-01-01T00:00:00Z"),
  updatedAt: ISODate("2024-01-01T00:00:00Z")
}

// Create indexes
db.users.createIndex({ email: 1 }, { unique: true });
db.users.createIndex({ status: 1 });
db.users.createIndex({ "profile.avatar": 1 }, { sparse: true });
```

### Query Patterns
```javascript
// Find with projection
db.users.find(
  { status: "active" },
  { email: 1, name: 1, _id: 0 }
);

// Aggregation pipeline
db.orders.aggregate([
  { $match: { createdAt: { $gte: ISODate("2024-01-01") } } },
  { $group: {
      _id: "$userId",
      totalOrders: { $sum: 1 },
      totalAmount: { $sum: "$amount" }
    }
  },
  { $sort: { totalAmount: -1 } },
  { $limit: 10 }
]);

// Lookup (join)
db.orders.aggregate([
  { $lookup: {
      from: "users",
      localField: "userId",
      foreignField: "_id",
      as: "user"
    }
  },
  { $unwind: "$user" }
]);
```

### Schema Validation
```javascript
db.createCollection("users", {
  validator: {
    $jsonSchema: {
      bsonType: "object",
      required: ["email", "name", "status"],
      properties: {
        email: {
          bsonType: "string",
          pattern: "^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\\.[a-zA-Z]{2,}$"
        },
        status: {
          enum: ["active", "inactive", "suspended"]
        }
      }
    }
  }
});
```

## Migration Best Practices

### Principles
1. Migrations are versioned and immutable
2. Each migration is atomic
3. Support both up and down migrations
4. Test migrations on staging first

### Migration Example (Go)
```go
// migrations/001_create_users.sql
-- +goose Up
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT gen_random_uuid(),
    email VARCHAR(255) NOT NULL UNIQUE
);

-- +goose Down
DROP TABLE users;
```

### Zero-Downtime Migrations
```sql
-- Step 1: Add new column (nullable)
ALTER TABLE users ADD COLUMN phone VARCHAR(20);

-- Step 2: Backfill data
UPDATE users SET phone = '' WHERE phone IS NULL;

-- Step 3: Add constraint (after backfill)
ALTER TABLE users ALTER COLUMN phone SET NOT NULL;
```

## Performance Tips

### Indexing Strategy
- Index columns used in WHERE, JOIN, ORDER BY
- Use composite indexes for multi-column queries
- Consider partial indexes for filtered queries
- Monitor and remove unused indexes

### Query Optimization
- Use EXPLAIN/ANALYZE to understand query plans
- Avoid N+1 queries (use JOINs or batch loading)
- Implement proper pagination
- Use connection pooling

### Connection Management
```go
// Go example with pgx
config, _ := pgxpool.ParseConfig(connString)
config.MaxConns = 25
config.MinConns = 5
config.MaxConnLifetime = time.Hour
config.MaxConnIdleTime = 30 * time.Minute

pool, _ := pgxpool.NewWithConfig(ctx, config)
```
