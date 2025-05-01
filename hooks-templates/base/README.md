# Base Hooks

## Why Use This Template

These are essential hooks that should be included in every project. They handle basic file hygiene and prevent common issues:

- **check-yaml**: Ensures all YAML files are valid and can be parsed
- **check-json**: Verifies JSON files are well-formed
- **pretty-format-json**: Formats JSON files consistently
- **end-of-file-fixer**: Ensures files end with a newline
- **trailing-whitespace**: Removes trailing whitespace from files
- **check-merge-conflict**: Prevents committing files with merge conflict markers
- **check-executables-have-shebangs**: Ensures executable files have proper shebang lines
- **check-added-large-files**: Prevents accidentally committing large files

## Benefits

- Prevents common formatting issues that can cause merge conflicts
- Ensures consistent file formatting across the project
- Catches basic issues before they cause problems
- Makes code reviews more focused on actual code instead of formatting

## Recommended For

All projects, regardless of language or framework. These hooks have minimal overhead and prevent many common issues.
