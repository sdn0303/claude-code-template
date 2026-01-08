#!/bin/bash
# .claude/hooks/formatter.sh
# Auto-format code before commit based on file type

set -e

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only --diff-filter=ACM)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

# Track if any files were modified
MODIFIED=0

# Go files
GO_FILES=$(echo "$STAGED_FILES" | grep '\.go$' || true)
if [ -n "$GO_FILES" ]; then
    echo "Formatting Go files..."
    for file in $GO_FILES; do
        if [ -f "$file" ]; then
            gofmt -w "$file"
            goimports -w "$file" 2>/dev/null || true
            git add "$file"
            MODIFIED=1
        fi
    done
fi

# TypeScript/JavaScript files
TS_FILES=$(echo "$STAGED_FILES" | grep -E '\.(ts|tsx|js|jsx)$' || true)
if [ -n "$TS_FILES" ]; then
    echo "Formatting TypeScript/JavaScript files..."
    if command -v pnpm &> /dev/null && [ -f "package.json" ]; then
        pnpm prettier --write $TS_FILES 2>/dev/null || true
        pnpm eslint --fix $TS_FILES 2>/dev/null || true
        git add $TS_FILES
        MODIFIED=1
    fi
fi

# Python files
PY_FILES=$(echo "$STAGED_FILES" | grep '\.py$' || true)
if [ -n "$PY_FILES" ]; then
    echo "Formatting Python files..."
    if command -v ruff &> /dev/null; then
        ruff format $PY_FILES 2>/dev/null || true
        ruff check --fix $PY_FILES 2>/dev/null || true
        git add $PY_FILES
        MODIFIED=1
    elif command -v black &> /dev/null; then
        black $PY_FILES 2>/dev/null || true
        git add $PY_FILES
        MODIFIED=1
    fi
fi

# Rust files
RS_FILES=$(echo "$STAGED_FILES" | grep '\.rs$' || true)
if [ -n "$RS_FILES" ]; then
    echo "Formatting Rust files..."
    if command -v rustfmt &> /dev/null; then
        rustfmt $RS_FILES 2>/dev/null || true
        git add $RS_FILES
        MODIFIED=1
    fi
fi

# Terraform files
TF_FILES=$(echo "$STAGED_FILES" | grep '\.tf$' || true)
if [ -n "$TF_FILES" ]; then
    echo "Formatting Terraform files..."
    if command -v terraform &> /dev/null; then
        terraform fmt $TF_FILES 2>/dev/null || true
        git add $TF_FILES
        MODIFIED=1
    fi
fi

# SQL files
SQL_FILES=$(echo "$STAGED_FILES" | grep '\.sql$' || true)
if [ -n "$SQL_FILES" ]; then
    echo "Formatting SQL files..."
    if command -v sql-formatter &> /dev/null; then
        for file in $SQL_FILES; do
            sql-formatter --fix "$file" 2>/dev/null || true
        done
        git add $SQL_FILES
        MODIFIED=1
    fi
fi

if [ $MODIFIED -eq 1 ]; then
    echo "Files formatted and re-staged."
fi

exit 0
