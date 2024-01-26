# visionOS - Close button on inline PhotosPicker doesn’t work (PhotosUI/SwiftUI)
FB13557150

This project demostrates an issue with Close button not working on PhotosPicker when .photosPickerStyle(.inline) is used.

## Close button on inline PhotosPicker doesn’t work

Close button on PhotosPicker presented with .photosPickerStyle(.inline) doesn’t do anything when tapped/clicked.

### Why we need it to use the system-provided Close button

We want to have a full-featured and nice looking picker that’s simple to use in code. In our codebase, we present PhotosPicker embedded in another view (ImagePickerView) that’s then presented as a sheet. This is because we need to support more types or pickers than just photos picker while having a single SwiftUI view to present. In order to embed the photos picker in our view, we use .photosPickerStyle(.inline). The picker is presented nicely, with sidebar and a compact Close button. Unfortunately, the button doesn’t work.

### What we also tried to work around this issue

We tried to remove the Close button with .photosPickerDisabledCapabilities(.selectionActions), wrap the PhotosPicker with NavigationView and provide a custom close button via ToolbarItem. This unfortunately results in an ugly-looking navigation bar that takes excessive space and a clipped top of the sidebar. See the attached screenshots.

### Steps to reproduce
1. Run the attached project in Xcode on Apple Vision Pro Simulator
2. Click the button “Present embedded PhotosPicker in ImagePickerView”
3. Click the close button marked with X

### Expected results
- The photos picker is closed

### Actual results
- The photos picker stays open with no way to close it

## How we expect this to work
SwiftUI provides DismissAction via the Environment that can be used to dismiss presented sheet. We would expect Cancel button in PhotosPicker to invoke the DismissAction to close the presented sheet.

### Versions

- Xcode Version 15.2 (15C500b)
- visionOS 1.0 (21N305)
- Version 15.2 (1019)
- macOS 14.2.1 (23C71)
