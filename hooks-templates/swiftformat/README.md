# SwiftFormat

## Why Use This Template

SwiftFormat automatically formats Swift code according to a consistent style. Unlike SwiftLint which focuses on detecting issues, SwiftFormat actively reformats code:

- Automatically corrects spacing, indentation, and braces
- Standardizes import statements
- Ensures consistent use of `self`
- Formats Swift code according to modern best practices

## Benefits

- **Zero Effort Formatting**: Eliminates manual formatting work
- **Merge Conflict Reduction**: Consistent formatting reduces unnecessary merge conflicts
- **Focus on Logic**: Developers can focus on code logic rather than style
- **Onboarding**: New team members automatically follow project conventions

## Configuration

This hook uses a `.swiftformat` file in your project root. Customize this file to match your team's preferred style.

## Recommended For

Any Swift project, especially:
- Teams with mixed coding styles
- Projects with multiple contributors
- Codebase refactoring efforts

This is often used alongside SwiftLint, with SwiftFormat handling formatting and SwiftLint focusing on code quality and patterns.
