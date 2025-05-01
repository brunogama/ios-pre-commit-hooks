# Accessibility Check

## Why Use This Template

This hook reminds developers to add accessibility identifiers to UI elements, which is crucial for:

- **UI Testing**: Enables reliable automated UI testing
- **Accessibility**: Supports better accessibility for users with disabilities
- **Quality Assurance**: Makes manual testing more efficient

## Benefits

- **Better UI Tests**: Accessibility identifiers make UI tests more reliable
- **Accessibility Compliance**: Encourages thinking about accessibility early
- **Testing Efficiency**: Simplifies both automated and manual testing
- **User Experience**: Improves app usability for all users

## How It Works

The script identifies Swift files that contain UI components (like UIButton, UILabel, etc.) and checks if they include accessibility identifiers. It warns about files that likely contain UI elements but don't set accessibility identifiers.

This is a warning-only hook to remind developers rather than block commits, as there may be valid reasons some UI files don't need identifiers.

## Recommended For

- Teams that perform UI testing
- Projects with accessibility requirements
- Apps with complex user interfaces
- Projects aiming for higher quality standards

This simple reminder can significantly improve testability and accessibility over time.
