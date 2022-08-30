# UIFindInteraction UI is not usable when Stage Manager is enabled
FB11339648

This project demonstates a bug in UIKit - Find panel in iPadOS 16 is not usable when Stage Manager is enabled

## Steps to reproduce:

1. Run this project on iPad Simulator
2. Enable Stage Manager in Simulator by executing this command in Terminal:
    ```
    xcrun simctl spawn booted defaults write -g SBChamoisWindowingEnabled -bool true
    ```
3. Tap "Toggle Search" in the app in the navigation bar as many times as you want

## Expected results
- The find bar appears and stays present until dismissed, can be used for search

## Actual results
- The find bar appears for a fraction of second and then disappers

