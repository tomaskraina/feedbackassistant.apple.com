# Reproduction results — 2026-10-21

## Confirmed case

System appearance Light; presenting-root preference nil; ordinary unconditional
modifier (`behavior: .always`); one SwiftUI sheet; no nested presentation.
Open with nil, select .dark, then select nil without dismissing.

| Runtime | Simulator | Fresh nil | Explicit .dark | Clear to nil |
| --- | --- | --- | --- | --- |
| iOS 18.6 (22G86) | iPhone 16 Pro | Light | Dark | **Remains dark** |
| iOS 26.5 (23F77) | iPhone 17 Pro | Light | Dark | **Remains dark** |
| iOS 27.0 (24A434) | iPhone 17 Pro | Light | Dark | **Remains dark** |
| iOS 27.2 (24B114) | iPhone 18 Pro | Light | Dark | **Remains dark** |

All four cases used the same app binary, built with Xcode 27.2 (27B48), Swift 6,
iOS 18.0 deployment target. The failure was inspected in Simulator captures as
well as accessibility readouts. On iOS 27.2, dismiss/reopen was checked repeatedly:
a fresh nil sheet is light, then .dark → nil sticks dark again.

After clearing, the sheet’s own SwiftUI colorScheme is .dark while the screen
and scene diagnostics are .light. The root remains nil. The status bar differs
visually across OS versions; these observations do not claim a uniform
status-bar failure.

[Captured UI observations](observations.json) contain the baseline, explicit-dark,
and cleared states. Local preview URLs and machine-specific paths are omitted.

## Replay

The app itself needs only Xcode. Optional unattended replay needs Python 3 and
the RocketSim CLI. Build/run the sample on an iPhone Simulator, set its system
appearance to Light, and leave the sample visible. Run one replay at a time:

```sh
python3 scripts/reproduce.py --udid YOUR_SIMULATOR_UDID --output /tmp/sheet-result.json
```

The script opens a fresh nil sheet, sets the root to nil and conditional mode to
off, checks a light baseline, selects dark, verifies dark, clears to nil, and
reads the sheet’s SwiftUI appearance. It leaves the failing sheet visible.

- Exit 1: **bug reproduced** (nil selected, sheet readout still dark).
- Exit 0: the sheet readout restored light.
- Exit 2: setup/automation failed; not a pass or fail for SwiftUI.

Commands exercised in this session included:

```sh
python3 scripts/reproduce.py --udid FF554ADD-6DDA-4A89-8756-EFA3237EC22A --output /tmp/sheet-evidence/27.2.json
# FAIL: nil retained .dark

python3 scripts/reproduce.py --udid B87A3AE5-C664-4369-9BB7-125106E19566 --output /tmp/sheet-evidence/26.5.json
# FAIL: nil retained .dark

python3 scripts/reproduce.py --udid BCFD87EE-C268-4892-8523-8DEBB25B9B78 --output /tmp/sheet-evidence/27.0.json
# FAIL: nil retained .dark
```

Simulator UDIDs are local examples; use your own. The replay intentionally
fails if the sheet’s readout is offscreen rather than mistaking the presenting
root’s readout for the sheet’s. A taller iPhone display is the simplest target.
On a sandboxed automation host, RocketSim needs execution outside the shell
sandbox because its CLI is itself App-Sandboxed.

## Additional coverage and limits

The iPhone Duo runtimes iOS 27.1 (24A94232) and iOS 27.2 (24B91014) were also
opened and exercised. Dark content with nil selected was visible on iOS 27.1,
but the default viewport hides the sheet’s SwiftUI diagnostic. The iOS 27.2 Duo
run likewise exposed no modal colorScheme readout to automation. Both are
**exploratory/inconclusive**, excluded from the confirmed matrix above. An early
replay that read the presenter’s light value was discarded; it is not evidence
of a fix on iOS 27.1. The replay now rejects missing modal readouts.

This session does not establish behavior on physical devices, iPad, earlier OS
versions, different root preferences, conditional application, UIKit presentation,
full-screen covers, nested sheets, or system appearance changes while presented.
Those controls remain available as independent experiments. No fix or production
workaround is claimed.
