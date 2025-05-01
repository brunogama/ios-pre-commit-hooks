# SwiftGen

## Why Use This Template

SwiftGen generates Swift code for your resources, making them type-safe and easier to use:

- **Type Safety**: Access resources with compile-time checking
- **Auto-completion**: Get IDE suggestions for available resources
- **Prevents Typos**: Eliminates string-based resource access errors
- **Centralized Access**: Creates a single point of access for all resources

## Benefits

- **Safer Code**: No more runtime crashes from mistyped resource names
- **Better Developer Experience**: Autocomplete for all resources
- **Refactoring Support**: Rename or move resources with confidence
- **Discoverability**: Easily find all available resources

## Configuration

This hook requires a `swiftgen.yml` configuration file in your project root that defines which resources to generate code for (strings, assets, fonts, etc.).

## Recommended For

- Swift projects with multiple resources (images, colors, strings, fonts)
- Teams focused on type safety and code quality
- Projects where resources change frequently
- Any codebase where you want to eliminate "stringly-typed" code

This tool pairs well with SwiftLint and SwiftFormat to create a comprehensive Swift quality toolchain.
