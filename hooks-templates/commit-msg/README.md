# Conventional Commits

## Why Use This Template

Conventional Commits enforces a standardized commit message format, making your repository history more readable and useful:

- **Structured Messages**: Enforces a consistent format for all commit messages
- **Semantic Versioning**: Facilitates automated version management and releases
- **Automated Changelogs**: Makes generating change logs straightforward
- **Clear Communication**: Improves team understanding of changes

## Benefits

- **Better History**: Creates a clear, navigable commit history
- **Automated Tooling**: Enables automated versioning and release notes
- **Easier Reviews**: Provides more context in pull requests
- **Streamlined Collaboration**: Makes it easier to understand why changes were made

## Format

Commit messages follow this structure:
```
type(scope): description

[optional body]

[optional footer]
```

Where `type` is one of:
- feat: A new feature
- fix: A bug fix
- docs: Documentation only changes
- style: Changes that don't affect code meaning
- refactor: Code change that neither fixes a bug nor adds a feature
- perf: Performance improvement
- test: Adding or correcting tests
- build: Changes to the build system or dependencies
- ci: Changes to CI configuration

## Recommended For

- Teams looking to improve collaboration and communication
- Projects needing automated versioning and changelog generation
- Open source projects where clear history is valuable
- Any project wanting to maintain a professional and organized git history

This hook is especially valuable for larger teams and projects with longer lifespans.
