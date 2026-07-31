#!/bin/bash
# Melina Bakes - Git Push Helper
# Run this script to push the initialized repository to GitHub

set -e

REPO_URL="https://github.com/SsenfumaAdrian/melina_bakes.git"

echo "🧁 Melina Bakes - GitHub Push Script"
echo "===================================="
echo ""
echo "This will push the Phase 1 code to your GitHub repository."
echo "Repository: $REPO_URL"
echo ""

# Check if we're in the right directory
if [ ! -d ".git" ]; then
    echo "❌ Error: Not a git repository. Please run this from the melina_bakes directory."
    exit 1
fi

# Check remote
CURRENT_REMOTE=$(git remote get-url origin 2>/dev/null || echo "")
if [ "$CURRENT_REMOTE" != "$REPO_URL" ]; then
    echo "🔗 Setting remote origin..."
    git remote remove origin 2>/dev/null || true
    git remote add origin "$REPO_URL"
fi

# Ensure branch is main
git branch -M main

echo ""
echo "⬆️ Pushing to GitHub..."
echo "You will be prompted for your GitHub credentials."
echo ""
echo "💡 TIP: Use a Personal Access Token instead of your password."
echo "   Create one at: https://github.com/settings/tokens"
echo "   Required scopes: repo"
echo ""

# Push
git push -u origin main

echo ""
echo "✅ Successfully pushed to GitHub!"
echo "View your repository at: $REPO_URL"
