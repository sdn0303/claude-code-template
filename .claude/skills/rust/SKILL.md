---
name: rust
description: Rust best practices for systems programming. Use when writing Rust code for performance-critical or systems-level applications.
---

# Rust Development Skill

Best practices for safe, performant Rust development.

## Project Structure

```
project/
├── src/
│   ├── main.rs            # Binary entry
│   ├── lib.rs             # Library root
│   ├── domain/            # Business logic
│   │   ├── mod.rs
│   │   └── user.rs
│   ├── application/       # Use cases
│   ├── infrastructure/    # External
│   └── error.rs           # Error types
├── tests/                 # Integration tests
├── benches/              # Benchmarks
├── Cargo.toml
└── Cargo.lock
```

## Ownership & Borrowing

### Ownership Rules
```rust
fn main() {
    let s1 = String::from("hello");
    let s2 = s1;  // s1 moved to s2
    // println!("{}", s1);  // Error: s1 no longer valid
    
    let s3 = s2.clone();  // Deep copy
    println!("{} {}", s2, s3);  // Both valid
}
```

### Borrowing
```rust
fn calculate_length(s: &String) -> usize {  // Borrow, don't own
    s.len()
}

fn append(s: &mut String) {  // Mutable borrow
    s.push_str(" world");
}

fn main() {
    let mut s = String::from("hello");
    let len = calculate_length(&s);
    append(&mut s);
}
```

### Lifetimes
```rust
// Explicit lifetime annotation
fn longest<'a>(x: &'a str, y: &'a str) -> &'a str {
    if x.len() > y.len() { x } else { y }
}

// Struct with reference
struct User<'a> {
    name: &'a str,
}
```

## Error Handling

### Result Type
```rust
use std::fs::File;
use std::io::{self, Read};

fn read_file(path: &str) -> Result<String, io::Error> {
    let mut file = File::open(path)?;  // ? propagates error
    let mut contents = String::new();
    file.read_to_string(&mut contents)?;
    Ok(contents)
}
```

### Custom Errors
```rust
use thiserror::Error;

#[derive(Error, Debug)]
pub enum AppError {
    #[error("User not found: {0}")]
    NotFound(String),
    
    #[error("Validation error: {field} - {message}")]
    Validation { field: String, message: String },
    
    #[error("Database error")]
    Database(#[from] sqlx::Error),
    
    #[error("IO error")]
    Io(#[from] io::Error),
}
```

### Error Propagation
```rust
use anyhow::{Context, Result};

fn process_user(id: &str) -> Result<User> {
    let data = read_file("users.json")
        .context("Failed to read users file")?;
    
    let user = parse_user(&data, id)
        .context(format!("Failed to parse user {}", id))?;
    
    Ok(user)
}
```

## Structs & Traits

### Struct Definition
```rust
#[derive(Debug, Clone, PartialEq)]
pub struct User {
    pub id: String,
    pub email: String,
    pub name: String,
}

impl User {
    pub fn new(id: impl Into<String>, email: impl Into<String>, name: impl Into<String>) -> Self {
        Self {
            id: id.into(),
            email: email.into(),
            name: name.into(),
        }
    }
}
```

### Traits
```rust
pub trait Repository<T> {
    fn find_by_id(&self, id: &str) -> Result<Option<T>, AppError>;
    fn save(&self, entity: &T) -> Result<T, AppError>;
}

impl Repository<User> for PostgresUserRepository {
    fn find_by_id(&self, id: &str) -> Result<Option<User>, AppError> {
        // Implementation
    }
    
    fn save(&self, user: &User) -> Result<User, AppError> {
        // Implementation
    }
}
```

### Generic Traits
```rust
pub trait Identifiable {
    fn id(&self) -> &str;
}

impl Identifiable for User {
    fn id(&self) -> &str {
        &self.id
    }
}

fn print_id<T: Identifiable>(item: &T) {
    println!("ID: {}", item.id());
}
```

## Async Programming

### Async Functions
```rust
use tokio;

async fn fetch_user(id: &str) -> Result<User, AppError> {
    let response = reqwest::get(&format!("/users/{}", id))
        .await?
        .json::<User>()
        .await?;
    Ok(response)
}

#[tokio::main]
async fn main() -> Result<(), AppError> {
    let user = fetch_user("123").await?;
    println!("{:?}", user);
    Ok(())
}
```

### Concurrent Operations
```rust
use futures::future::join_all;

async fn fetch_all_users(ids: Vec<&str>) -> Vec<Result<User, AppError>> {
    let futures: Vec<_> = ids.iter()
        .map(|id| fetch_user(id))
        .collect();
    
    join_all(futures).await
}
```

## Testing

### Unit Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn test_user_creation() {
        let user = User::new("1", "test@example.com", "Test User");
        
        assert_eq!(user.id, "1");
        assert_eq!(user.email, "test@example.com");
    }

    #[test]
    fn test_validation() {
        let result = validate_email("invalid");
        assert!(result.is_err());
    }
}
```

### Async Tests
```rust
#[cfg(test)]
mod tests {
    use super::*;

    #[tokio::test]
    async fn test_fetch_user() {
        let user = fetch_user("123").await.unwrap();
        assert!(!user.name.is_empty());
    }
}
```

### Integration Tests
```rust
// tests/integration_test.rs
use project_name::UserService;

#[test]
fn test_full_workflow() {
    let service = UserService::new();
    let user = service.create_user("test@example.com", "Test").unwrap();
    
    let found = service.find_by_id(&user.id).unwrap();
    assert_eq!(found.email, "test@example.com");
}
```

## Cargo Commands

```bash
# Build
cargo build
cargo build --release

# Run
cargo run
cargo run --release

# Test
cargo test
cargo test -- --nocapture  # Show prints

# Check (fast, no codegen)
cargo check

# Format
cargo fmt

# Lint
cargo clippy

# Documentation
cargo doc --open
```

## Cargo.toml

```toml
[package]
name = "project-name"
version = "0.1.0"
edition = "2021"

[dependencies]
tokio = { version = "1", features = ["full"] }
serde = { version = "1", features = ["derive"] }
serde_json = "1"
thiserror = "1"
anyhow = "1"
tracing = "0.1"

[dev-dependencies]
mockall = "0.11"
tokio-test = "0.4"

[profile.release]
lto = true
codegen-units = 1
```
