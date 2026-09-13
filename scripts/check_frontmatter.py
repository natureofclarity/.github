#!/usr/bin/env python3
"""Validate the YAML front matter of a GitHub issue-template Markdown file.

GitHub requires each issue template to begin with a `---` delimited YAML block
containing at least `name` and `about`. This checks the block parses and that
those required keys are present and non-empty.
"""
import sys

import yaml

REQUIRED_KEYS = ("name", "about")


def main(path: str) -> int:
    with open(path, "r", encoding="utf-8") as fh:
        text = fh.read()

    if not text.startswith("---"):
        print(f"{path}: missing opening '---' front matter delimiter", file=sys.stderr)
        return 1

    parts = text.split("---", 2)
    if len(parts) < 3:
        print(f"{path}: front matter is not closed with '---'", file=sys.stderr)
        return 1

    try:
        data = yaml.safe_load(parts[1])
    except yaml.YAMLError as exc:
        print(f"{path}: front matter is not valid YAML: {exc}", file=sys.stderr)
        return 1

    if not isinstance(data, dict):
        print(f"{path}: front matter must be a YAML mapping", file=sys.stderr)
        return 1

    for key in REQUIRED_KEYS:
        if not data.get(key):
            print(f"{path}: missing required key '{key}'", file=sys.stderr)
            return 1

    return 0


if __name__ == "__main__":
    if len(sys.argv) != 2:
        print("usage: check_frontmatter.py <file.md>", file=sys.stderr)
        raise SystemExit(2)
    raise SystemExit(main(sys.argv[1]))
