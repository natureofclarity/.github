#!/usr/bin/env bash
# Validate the org-wide community health files exactly the way GitHub parses them:
# every YAML file must be well-formed, each issue-template must carry valid YAML
# front matter, and all Markdown must pass lint. Safe to run repeatedly.
set -euo pipefail

cd "$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"

fail=0
step() { printf '\n\033[1m==> %s\033[0m\n' "$1"; }
ok()   { printf '  \033[32mPASS\033[0m %s\n' "$1"; }
bad()  { printf '  \033[31mFAIL\033[0m %s\n' "$1"; fail=1; }

step "yamllint: all YAML files parse"
mapfile -t yaml_files < <(git ls-files '*.yml' '*.yaml')
if [ "${#yaml_files[@]}" -eq 0 ]; then
  echo "  (no YAML files found)"
else
  if python3 -m yamllint -c .yamllint.yml "${yaml_files[@]}"; then
    ok "${#yaml_files[@]} YAML file(s) valid"
  else
    bad "yamllint reported problems"
  fi
fi

step "issue templates: valid YAML front matter"
mapfile -t tmpl_files < <(git ls-files 'ISSUE_TEMPLATE/*.md')
if [ "${#tmpl_files[@]}" -eq 0 ]; then
  echo "  (no issue templates found)"
else
  for f in "${tmpl_files[@]}"; do
    if python3 scripts/check_frontmatter.py "$f"; then
      ok "$f"
    else
      bad "$f (invalid or missing front matter)"
    fi
  done
fi

step "markdownlint: all Markdown files"
mapfile -t md_files < <(git ls-files '*.md')
if [ "${#md_files[@]}" -eq 0 ]; then
  echo "  (no Markdown files found)"
else
  if ./node_modules/.bin/markdownlint-cli2; then
    ok "${#md_files[@]} Markdown file(s) lint clean"
  else
    bad "markdownlint reported problems"
  fi
fi

echo
if [ "$fail" -eq 0 ]; then
  printf '\033[32mAll community health files are valid.\033[0m\n'
else
  printf '\033[31mValidation failed.\033[0m\n'
fi
exit "$fail"
