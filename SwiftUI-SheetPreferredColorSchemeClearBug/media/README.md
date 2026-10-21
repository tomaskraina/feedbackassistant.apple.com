# Demonstration recording

[preferred-color-scheme-bug.mp4](preferred-color-scheme-bug.mp4) is a **14-second,
silent** recording of the real sample running on the iPhone 18 Pro Simulator,
iOS 27.2 (24B114), built with Xcode 27.2 (27B48), captured on 2026-10-21.

## Starting state

- Simulator system appearance: Light.
- SwiftUI .sheet already open with both preferences nil.
- Conditional modifier application off (`behavior: .always`).
- No nested presentation.

## Transcript

| Time | Action / annotation |
| --- | --- |
| 0–2.5 s | A fresh nil sheet is light. System Light, root nil, conditional off. |
| 2.5–6.5 s | Select .dark; the sheet becomes dark. |
| 6.5–14 s | nil is selected; the sheet stays dark. Expected: return to Light Mode. |

Caption boundaries describe the settled states; the actual touches remain visible
in the recording. Captions are burned in above and below the app image. The
app image is scaled uniformly and the recording is trimmed; it is not sped up,
spliced, or recolored. Touch indicators come from RocketSim. Encoding: H.264,
30 fps, 1080 × 2240, no audio, MP4 with fast-start metadata.

## Re-record

Set up a fresh light nil sheet using the README steps, then record with RocketSim:

```sh
rocketsim video record --udid YOUR_SIMULATOR_UDID --duration 25 --fps 30 --touches > /tmp/sheet-raw.mp4
```

While recording, select .dark, then nil, and leave enough time to inspect the
failure. Retain 10–15 seconds covering both transitions. Use captions outside the
app image and include the exact runtime/build in them. Verify selected values
and readouts in the exported video before sharing.

The MP4 is suitable for attaching to Apple Feedback and uploading natively to a
social post. The repository README links to it without requiring a screenshot.
