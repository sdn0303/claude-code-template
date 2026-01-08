#!/bin/bash
# .claude/hooks/protected_files.sh
# Prevent accidental modifications to sensitive files

set -e

# Get list of staged files
STAGED_FILES=$(git diff --cached --name-only)

if [ -z "$STAGED_FILES" ]; then
    exit 0
fi

# Define protected patterns
PROTECTED_PATTERNS=(
    "\.env$"
    "\.env\."
    "\.pem$"
    "\.key$"
    "\.p12$"
    "\.pfx$"
    "secrets/"
    "credentials/"
    "\.secrets"
    "service-account"
    "firebase-adminsdk"
    "google-credentials"
)

# Track violations
VIOLATIONS=()

for file in $STAGED_FILES; do
    for pattern in "${PROTECTED_PATTERNS[@]}"; do
        if echo "$file" | grep -qE "$pattern"; then
            VIOLATIONS+=("$file")
            break
        fi
    done
done

if [ ${#VIOLATIONS[@]} -gt 0 ]; then
    echo "⚠️  WARNING: Attempting to commit potentially sensitive files!"
    echo ""
    echo "The following files match protected patterns:"
    for file in "${VIOLATIONS[@]}"; do
        echo "  - $file"
    done
    echo ""
    echo "If you're sure you want to commit these files, use:"
    echo "  git commit --no-verify"
    echo ""
    echo "Otherwise, unstage these files with:"
    echo "  git reset HEAD <file>"
    echo ""
    
    # Prompt for confirmation in interactive mode
    if [ -t 0 ]; then
        read -p "Do you want to continue? [y/N] " -n 1 -r
        echo
        if [[ ! $REPLY =~ ^[Yy]$ ]]; then
            exit 1
        fi
    else
        # Non-interactive mode - fail by default
        exit 1
    fi
fi

# Check for hardcoded secrets patterns
SECRET_PATTERNS=(
    "password\s*=\s*['\"][^'\"]+['\"]"
    "api_key\s*=\s*['\"][^'\"]+['\"]"
    "secret\s*=\s*['\"][^'\"]+['\"]"
    "token\s*=\s*['\"][^'\"]+['\"]"
    "BEGIN RSA PRIVATE KEY"
    "BEGIN OPENSSH PRIVATE KEY"
    "AKIA[0-9A-Z]{16}"  # AWS Access Key ID
)

for file in $STAGED_FILES; do
    if [ -f "$file" ]; then
        for pattern in "${SECRET_PATTERNS[@]}"; do
            if grep -qiE "$pattern" "$file" 2>/dev/null; then
                echo "⚠️  WARNING: Potential secret detected in: $file"
                echo "  Pattern: $pattern"
                echo ""
                echo "Please review this file carefully before committing."
                echo ""
            fi
        done
    fi
done

exit 0
