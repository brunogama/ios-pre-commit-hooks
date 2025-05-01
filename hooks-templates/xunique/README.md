# xUnique

## Why Use This Template

xUnique is a tool that sorts and uniquifies Xcode project files to minimize merge conflicts:

- **Reduces pbxproj Conflicts**: Standardizes Xcode project file format
- **Consistent Order**: Ensures consistent ordering of project elements
- **UUID Management**: Handles Xcode's UUIDs to avoid unnecessary conflicts

## Benefits

- **Easier Merging**: Makes .pbxproj files more merge-friendly
- **Cleaner Diffs**: Produces cleaner version control diffs
- **Less Manual Intervention**: Reduces need for manual conflict resolution

## When to Use

Use this if you're not using XcodeGen but still want to reduce Xcode project file conflicts. This is a lighter approach that doesn't require changing how you manage your Xcode project.

## Recommended For

- Teams experiencing frequent .pbxproj merge conflicts
- Projects where XcodeGen isn't feasible or desired
- Legacy projects with complex Xcode project files

Note: If you're already using XcodeGen, you typically don't need xUnique since XcodeGen solves the same problem more comprehensively.
