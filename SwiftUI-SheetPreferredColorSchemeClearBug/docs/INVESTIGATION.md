# Investigation controls and implementation

A standalone SwiftUI iPhone/iPad app for investigating stale appearance across
sheet and full-screen presentation boundaries. No packages, accounts,
or dependencies on another app are required. Minimum deployment target: iOS 18.

## Run

Project paths in this document are relative to the sample directory.

Open `SheetPreferredColorSchemeClearBug.xcodeproj`, select the `SheetPreferredColorSchemeClearBug` scheme and
an iOS Simulator, then Run. For a physical device, select your development team
and change the bundle identifier if needed.

The project is ready to open. `project.yml` is included for optional regeneration
with `xcodegen generate`; XcodeGen is not needed to run the app.

## Experiment

Determine whether an already-visible modal correctly updates when its
`preferredColorScheme` argument changes or clears, and whether the presenting
root's preference affects the result. Compare passing `nil` with omitting the
modifier entirely. The sample does not assume every OS version reproduces a bug.

## Controls

- **Modal:** main section containing a labeled `.preferredColorScheme(_:)`
  segmented `nil` / `.light` / `.dark` picker and side-by-side **sheet** and
  **fullScreen** buttons on the **SwiftUI** row. A second **UIKit** row has a
  **present UIHostingController** button that presents a UIKit sheet hosting the same
  SwiftUI controls and readouts.
- **`.preferredColorScheme(_:)`:** repeated inside each modal. The
  value is shared and saved in UserDefaults. It applies only to content inside
  `.sheet`, `.fullScreenCover`, and the UIKit sheet’s hosting root, including
  nested presentations.
- **Presenting root: `.preferredColorScheme(_:)`:** independent segmented picker
  inside the modal. Its saved value applies at the scene root only while a modal
  is open. When all modals are dismissed, the root argument returns to `nil`.
- **Apply .preferredColorScheme conditionally:** toggle inside the modal, shared
  across presentation levels. Off selects `.always` (the default), including
  `nil`; on selects `.whenSpecified`, omitting the modifier for `nil`.
  The behavior is saved as a `PreferredColorSchemeBehavior` value.
- **Nested presentations:** every modal can show another sheet or full-screen
  cover. Done dismisses the current level. Sheets support swipe-to-dismiss.
- **Reset sample settings:** set both saved arguments to `nil`, behavior to
  `.always`. Older sample toggles are no
  longer read or displayed.

There is no Auto resolution or explicit fallback to screen/scene appearance.
`nil` means no preference at that boundary, so the presenter can affect the
result. The root always uses the ordinary unconditional modifier.

## Conditional modifier

The custom View helper uses an explicit behavior:

```swift
.applyPreferredColorScheme(colorScheme, behavior: .whenSpecified)
.applyPreferredColorScheme(colorScheme, behavior: .always)

enum PreferredColorSchemeBehavior: String {
    case whenSpecified
    case always
}
```

`PreferredColorSchemeModifier` implements the behavior with this branch:

```swift
if self.behavior == .always || self.colorScheme != nil {
    content.preferredColorScheme(self.colorScheme)
} else {
    content
}
```

The false toggle path always uses the ordinary modifier. The true toggle path
omits it only for `nil`. Switching between presence and absence changes structural
identity and may reset state or dismiss nested presentations. This is an explicit
part of the experiment, not an appearance workaround. There is no `.id` rebuild,
UIKit appearance override, or status-bar customization.

## UIKit comparison

`UIKitSheetPresenter` embeds a small presenting `UIViewController` using
`UIViewControllerRepresentable`. The UIKit button requests presentation through
its binding; the coordinator calls `present(_:animated:)` with a
`UIHostingController` whose `modalPresentationStyle` is `.pageSheet`.

The hosting root reuses `PresentationView` and observes UserDefaults directly.
Its hosting controller and `rootView` are created once per presentation; picker
changes update SwiftUI state without replacing the controller. UIKit content has
its own read-only live trait probe because it is a separate SwiftUI hierarchy.

Done clears the presentation binding and dismisses through UIKit. The adaptive
presentation delegate handles swipe dismissal and clears the same binding so the
sheet can reopen. The root preference remains active while this UIKit sheet is
presented, just as it does for the SwiftUI routes.

## Diagnostics

The readout shows the active root argument, SwiftUI `colorScheme`, and the
separate UIScreen and UIWindowScene `traitCollection.userInterfaceStyle` values.
UIKit values are displayed exactly, including `.unspecified`; unknown future
values retain their raw number.

A read-only UIKit probe uses `window.windowScene.screen` rather than `UIScreen.main`.
It samples both UIKit trait collections every 1,000 ms while attached, including
when a fixed scene appearance prevents a trait-change callback. Sampling stops
when detached. These diagnostics never supply fallback values to the modifiers.
The adaptive-color preview swatch has been removed.

## Reproduction walkthrough

1. Reset settings and select a known system appearance in Settings or Simulator.
2. Set the main presentation argument to `.dark`; the main screen should continue
   following the system. Tap **sheet**.
3. Without dismissing, select `.dark` → `.light` → `nil`.
4. Compare the actual status-bar text, navigation bar, and background with the
   readouts. A matching SwiftUI readout does not prove the status bar updated.
5. Repeat with presenting-root arguments `.light`, `.dark`, and `nil`.
6. Turn conditional mode on and repeat. Compare `.always` + `nil` against
   `.whenSpecified` + `nil`. Watch for nested state resets when the branch changes.
7. Repeat with **fullScreen**, UIKit’s **present UIHostingController**, and nested presentations. Dismiss and reopen to compare
   an existing presentation with a fresh one.
8. With `nil` selected, change system appearance while a modal is open. Compare
   UIScreen, UIWindowScene, and SwiftUI values.

Record the OS/runtime version, both arguments, conditional mode, and presentation
nesting with any observed failure.
