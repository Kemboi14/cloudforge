#!/bin/bash
echo "=== Git Push Status ==="
git status
echo ""
echo "=== Recent Commits ==="
git log --oneline -3
echo ""
echo "=== Remote Status ==="
git remote -v
