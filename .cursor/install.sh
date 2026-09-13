#!/usr/bin/env bash
# Idempotent setup for the .github community-health-files repo. Installs the
# validators used by scripts/validate.sh: yamllint + PyYAML (YAML parsing and
# issue-template front matter) and a pinned, local markdownlint-cli2 (Markdown
# lint). No root or global installs required.
set -euo pipefail

echo "Installing YAML tooling (yamllint, PyYAML)..."
pip3 install --break-system-packages --quiet yamllint pyyaml

echo "Installing Node tooling (markdownlint-cli2) from lockfile..."
if [ -f package-lock.json ]; then
  npm ci
else
  npm install
fi

chmod +x scripts/validate.sh scripts/check_frontmatter.py

echo "Tool versions:"
python3 -m yamllint --version
echo "markdownlint-cli2 $(./node_modules/.bin/markdownlint-cli2 --version 2>/dev/null | head -1)"
python3 -c "import yaml; print('PyYAML', yaml.__version__)"

echo "Install complete."
