# SwiftUI: clearing preferredColorScheme on an open sheet retains the previous appearance

Status: submitted to Apple as **FB25273283**.

## Summary

An already-presented SwiftUI sheet retains Dark Mode after its
`.preferredColorScheme` argument changes from `.dark` to `nil`. The presenting
root has no color-scheme preference and the Simulator system appearance is
Light. Dismissing and reopening the same sheet with `nil` selected produces
Light Mode as expected.

## Environment

- Primary reproduction: iPhone 18 Pro Simulator, iOS 27.2 (24B114).
- Also observed: iPhone 16 Pro / iOS 18.6 (22G86), and iPhone 17 Pro /
  iOS 26.5 (23F77) and iOS 27.0 (24A434).
- Built with Xcode 27.2 (27B48), Swift 6, iOS deployment target 18.0.
- Verification date: 2026-10-21.
- Physical devices have not been tested in this verification session.

## Steps to reproduce

1. Open the attached Xcode project, select the shared
   `SheetPreferredColorSchemeClearBug` scheme, and run on an iPhone Simulator.
2. Set the Simulator’s system appearance to Light.
3. Tap Reset sample settings at the bottom of the sample’s main screen.
4. Tap .sheet; it opens in Light Mode.
5. Leave RootView.preferredColorScheme at nil and Apply .preferredColorScheme
   conditionally off. This keeps the ordinary modifier applied, including nil.
6. In the sheet’s top picker, select .dark. The sheet becomes dark.
7. Select nil in that same picker without dismissing the sheet.
8. Compare the sheet’s visible appearance and SwiftUI colorScheme readout with
   the UIScreen and UIWindowScene readouts.
9. Tap Done and reopen .sheet without changing nil.

## Expected result

At step 7, clearing the explicit preference allows the existing sheet to follow
the light appearance of its presenter/system. It should match the fresh sheet
at step 9. Apple’s documentation describes nil as indicating no preference:
[preferredColorScheme(_:)](https://developer.apple.com/documentation/swiftui/view/preferredcolorscheme(_:))

## Actual result

At step 7, nil is selected, but the sheet’s background and controls stay dark.
The sheet’s SwiftUI colorScheme remains .dark; UIScreen and UIWindowScene report
.light. At step 9, a fresh presentation with nil opens light.

On iOS 27.2 this was reproduced repeatedly, including from a fresh nil sheet.
This report concerns sheet content appearance; it does not assert that all
status-bar, nested presentation, full-screen, or UIKit routes fail identically.

## Sample implementation

The .sheet content uses a shared, saved ColorScheme? selection. With conditional
application off, the sample’s helper always executes
`content.preferredColorScheme(self.colorScheme)`, including nil. The presenting
root uses a separate preference and remains nil for this reproduction.

The sample applies no UIKit appearance override, environment colorScheme
fallback, forced identity rebuild, or status-bar customization. The UIKit probe
only samples screen/scene traits once per second. Additional investigation
controls remain available but are not prerequisites for this reproduction.

## Attachments

- `SheetPreferredColorSchemeClearBug.zip`: self-contained source project,
  documentation, replay script, and demonstration recording.
- `preferred-color-scheme-bug.mp4`: short silent recording with annotations
  outside the app image; no appearance simulation or reconstructed UI.

Create the ZIP using `python3 scripts/package-sample.py` in the sample directory.
The video can also be attached separately for convenient playback.
A sysdiagnose from the failing environment can be attached separately if needed;
none was captured in this session.
