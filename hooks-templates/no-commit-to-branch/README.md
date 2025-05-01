# Protected Branch Check

## Why Use This Template

This hook prevents direct commits to protected branches, enforcing the use of pull requests or merge requests:

- **Branch Protection**: Prevents accidental commits to important branches
- **Workflow Enforcement**: Ensures all changes go through proper review
- **Quality Control**: Maintains stability of critical branches

## Benefits

- **Stable Main Branch**: Keeps your main branch clean and working
- **Enforced Code Review**: Ensures all code is reviewed before reaching important branches
- **Consistent Process**: Helps teams follow a consistent development workflow
- **Reduced Mistakes**: Prevents accidental commits to production branches

## Configuration

You can customize which branches are protected by modifying the `args` in the template. By default, it protects:
- main
- master
- dev
- develop
- release

## Recommended For

- Teams of all sizes to maintain branch hygiene
- Projects with defined release processes
- Any repository where main branch stability is important
- CI/CD environments that depend on clean primary branches

This hook is a simple yet effective way to enforce good branching practices.
