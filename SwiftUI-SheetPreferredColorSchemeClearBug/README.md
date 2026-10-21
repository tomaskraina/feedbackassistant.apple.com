# SwiftUI sheet stays dark after clearing `preferredColorScheme`

Changing an open sheet’s `.preferredColorScheme` from `.dark` to `nil` leaves
its content in Dark Mode even when the system and presenting root are light.
Dismissing and reopening the sheet with `nil` selected restores Light Mode.

This standalone iPhone/iPad sample reproduces that failure and keeps additional
controls for investigating presentation boundaries. No packages, accounts, or
XcodeGen installation are needed to run it. Minimum deployment target: iOS 18.

## Demonstration

The recording uses the iPhone 18 Pro Simulator on iOS 27.2 (24B114).

media/preferred-color-scheme-bug.mp4

## Run and reproduce

1. Open `SheetPreferredColorSchemeClearBug.xcodeproj` in Xcode and select the
   `SheetPreferredColorSchemeClearBug` scheme and an iPhone Simulator.
2. Set the Simulator’s system appearance to **Light** and run the app.
3. Tap **Reset sample settings** at the bottom of the main screen. This sets both
   preferences to `nil` and disables conditional modifier application.
4. Tap **.sheet**. Leave **RootView.preferredColorScheme** set to `nil` and
   **Apply .preferredColorScheme conditionally** off.
5. In the sheet’s first picker, select **.dark**, then **nil**, without dismissing.

**Expected:** Clearing the preference lets the sheet follow the light appearance
of its presenter/system, just as a newly opened sheet with `nil` does.

**Actual:** The sheet’s background and controls remain dark. Its SwiftUI
`colorScheme` readout stays `.dark`, while UIScreen and UIWindowScene report
`.light`. The `nil` selection is visible in both preference pickers.

Tap **Done**, then **.sheet** again with `nil` still selected: the fresh sheet is
light. The failure concerns updating an existing presentation.

Apple documents `nil` as indicating no preference, and the modifier as applying
to the nearest enclosing presentation. The expected transition above is our
interpretation of that contract, also supported by the fresh-sheet comparison.
See [Apple’s preferredColorScheme documentation](https://developer.apple.com/documentation/swiftui/view/preferredcolorscheme(_:)).

## Verified environments

Tested on 2026-10-21 using Xcode 27.2 (27B48), targeting iOS 18 and later.

| Simulator runtime | Device | Result for `.dark` → `nil` in an open sheet |
| --- | --- | --- |
| iOS 18.6 (22G86) | iPhone 16 Pro | Reproduced |
| iOS 26.5 (23F77) | iPhone 17 Pro | Reproduced |
| iOS 27.0 (24A434) | iPhone 17 Pro | Reproduced |
| iOS 27.2 (24B114) | iPhone 18 Pro | Reproduced, including a repeat from a fresh sheet |

[Detailed observations and replay instructions](docs/RESULTS.md) distinguish the
verified sheet case from the additional experiments. These Simulator results do
not establish physical-device behavior or the first affected OS release.

## Further investigation

The sample also supports `.fullScreenCover`, a UIKit-presented
`UIHostingController`, nested presentations, an independent presenting-root
preference, and comparing `nil` with removing the modifier entirely.

[Controls, implementation, and diagnostic limitations](docs/INVESTIGATION.md).
Conditional application changes structural identity and is an experiment; it is
not presented as a validated production workaround. UIKit probes only read
appearance and never supply fallback values or apply overrides.

## Apple Feedback and sharing

- [Report draft](docs/APPLE-FEEDBACK.md), ready to copy into Feedback Assistant.
- [Recording details and transcript](media/README.md).
- [Social post draft](docs/SHARING.md).
- Create a clean attachment with `python3 scripts/package-sample.py`; the ZIP is
  written to `dist/SheetPreferredColorSchemeClearBug.zip`.

The Xcode project is checked in. `project.yml` is provided for optional
regeneration with XcodeGen. For a physical device, choose your development team
and change the bundle identifier if needed.

## License

[MIT](LICENSE), scoped to this sample directory.
