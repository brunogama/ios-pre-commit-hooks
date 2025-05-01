# Dangling References Check

## Why Use This Template

This hook checks for dangling file references in Xcode projects - files that are referenced in the project but don't actually exist on disk:

- **Prevents Build Errors**: Catches missing files before they cause build failures
- **Maintains Project Health**: Ensures project references match actual files
- **Improves Developer Experience**: Eliminates confusing "file not found" errors

## Benefits

- **Clean Projects**: Keeps your Xcode project in sync with the file system
- **Fewer Random Errors**: Prevents mysterious build failures due to missing files
- **Smoother Onboarding**: New team members don't encounter broken references
- **Better Collaboration**: Ensures all team members have the complete set of files

## How It Works

The hook scans .pbxproj files for file references and verifies that each referenced file exists on disk. If any files are missing, the commit is blocked until the references are fixed.

## Recommended For

- All iOS projects, especially those with frequent file additions/removals
- Teams with multiple developers who might not communicate every file change
- Projects undergoing refactoring or reorganization

This hook is lightweight but crucial for maintaining a healthy Xcode project.
