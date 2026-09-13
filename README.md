# .github

Org-wide community health files for natureofclarity (profile, PR/issue templates, security policy)

## Development

These files are consumed directly by GitHub, so the "build" is validation: every
YAML file must parse, each issue template must carry valid front matter, and all
Markdown must lint clean.

```bash
npm install   # install validators (also run automatically on Cloud Agent setup)
npm run validate
```

`npm run validate` runs `scripts/validate.sh`, which checks:

- YAML syntax via `yamllint` (`.yamllint.yml`)
- `ISSUE_TEMPLATE/*.md` front matter via `scripts/check_frontmatter.py`
- Markdown style via `markdownlint-cli2` (`.markdownlint-cli2.jsonc`)
