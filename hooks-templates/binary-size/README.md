# Binary Size Check

## Why Use This Template

This hook monitors your app's binary size to prevent unexpected increases:

- **Size Monitoring**: Tracks app size over time
- **Threshold Alerts**: Warns when app size approaches limits
- **Bloat Prevention**: Catches large size increases early

## Benefits

- **App Store Compliance**: Helps stay under App Store size limits
- **Download Size Optimization**: Smaller apps have higher install rates
- **Bandwidth Consideration**: Better user experience for those with limited data
- **Performance Focus**: Encourages developers to consider app size impact

## Configuration

You can configure size thresholds in the script:
- `MAX_SIZE_MB`: Maximum allowed size (default: 100MB)
- `WARNING_SIZE_MB`: Warning threshold (default: 80MB)

## How It Works

The script checks the most recent archive in your Xcode Archives directory and compares its size against configured thresholds. It also maintains a size history in a `.app_size_history` file.

## Recommended For

- Teams focused on app performance and user experience
- Projects with size constraints or concerns
- Apps targeting markets with limited bandwidth
- Projects that have experienced unintended size increases in the past

This hook runs on pre-push rather than pre-commit, as it needs to check an archived build.
