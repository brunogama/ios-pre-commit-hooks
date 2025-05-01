# Unused Assets Check

## Why Use This Template

This hook identifies images and colors in your asset catalogs that aren't referenced in your code:

- **App Size Optimization**: Helps reduce app bundle size
- **Resource Management**: Identifies forgotten or obsolete assets
- **Clean Codebase**: Encourages removal of unused resources

## Benefits

- **Smaller App Size**: Removing unused assets leads to smaller downloads
- **Better Organization**: Keeps asset catalogs clean and relevant
- **Performance Improvements**: Fewer assets can mean faster app startup
- **Reduced Maintenance**: Less resources to manage and update

## How It Works

The script scans all `.xcassets` directories for image and color assets, then searches Swift, Objective-C, XIB, and Storyboard files for references to those assets. It warns about assets that don't appear to be used.

Note: This is a warning-only hook and won't block commits, as there may be legitimate cases of assets referenced dynamically or in ways the script cannot detect.

## Recommended For

- Projects concerned about app size
- Older projects that have accumulated many assets over time
- Teams transitioning between design systems
- Any project wanting to maintain a clean resource footprint

This check is especially valuable before major releases to optimize bundle size.
