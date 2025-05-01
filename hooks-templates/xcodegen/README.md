# XcodeGen

## Why Use This Template

XcodeGen generates your Xcode project from a specification file, solving one of the most common sources of merge conflicts in iOS development:

- **Eliminates .pbxproj Conflicts**: Automatically generates Xcode project files
- **Declarative Configuration**: Defines project structure in YAML or JSON
- **Consistent Project Structure**: Ensures project settings are consistent

## Benefits

- **Painless Collaboration**: No more merge conflicts from .pbxproj files
- **Version Control Friendly**: Project specification is easy to merge
- **Reproducible Projects**: Generate identical projects on any machine
- **Automation Friendly**: Easily integrate into CI/CD pipelines

## Configuration

Requires a `project.yml` or similar specification file in your repository that defines your Xcode project structure.

## Recommended For

- Teams experiencing frequent .pbxproj merge conflicts
- Projects with multiple contributors adding files regularly
- Projects that need to maintain multiple similar Xcode project configurations
- CI/CD pipelines that generate Xcode projects

This hook automatically regenerates your Xcode project when changes are made to your specification file, ensuring everyone uses the same project structure.
