@echo off
REM Melina Bakes - Git Push Helper for Windows

echo 🧁 Melina Bakes - GitHub Push Script
echo ====================================
echo.

if not exist ".git" (
    echo ❌ Error: Not a git repository.
    exit /b 1
)

echo ⬆️ Pushing to GitHub...
git branch -M main
git push -u origin main

echo.
echo ✅ Done! Check https://github.com/SsenfumaAdrian/melina_bakes.git
pause
