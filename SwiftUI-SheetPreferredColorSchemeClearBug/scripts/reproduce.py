#!/usr/bin/env python3
"""Replay the sheet bug using RocketSim. Requires the sample running in Light Mode.

Exit 1 means the stale-dark bug reproduced; exit 0 means appearance recovered.
Exit 2 means setup or automation failed. JSON preserves the observed UI states.
"""

import argparse
import json
import shutil
import subprocess
import sys
from pathlib import Path


def main():
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--udid", required=True)
    parser.add_argument("--output", type=Path, required=True)
    args = parser.parse_args()
    rocket = shutil.which("rocketsim")
    if not rocket:
        raise RuntimeError("Install the RocketSim CLI first")

    def run(*command):
        target = [] if command[:2] == ("wait", "time") else ["--udid", args.udid]
        result = json.loads(subprocess.check_output(
            [rocket, *command, *target], text=True))
        if not result.get("ok"):
            raise RuntimeError(result.get("error"))
        return result

    def snapshot():
        run("wait", "time", "--ms", "500")
        result = run("elements", "--agent", "--agent-mode", "act")
        return result, [row.split("|") for row in result["data"]["rows"]
                        if not row.startswith("!")]

    def tap(row):
        run("interact", "tap", "--id", row[0], "--screen", "latest")

    def modal_radio(label, root=False):
        _, rows = snapshot()
        title = next(int(r[0]) for r in rows if r[2] == "SwiftUI .sheet")
        root_title = next(int(r[0]) for r in rows
                          if r[2] == "RootView.preferredColorScheme")
        candidates = [r for r in rows if r[1] == "radioButton" and r[2] == label
                      and int(r[0]) > (root_title if root else title)
                      and (root or int(r[0]) < root_title)]
        if len(candidates) != 1:
            raise RuntimeError(f"Cannot identify modal {label}: {candidates}")
        tap(candidates[0])
        for _ in range(8):
            run("wait", "time", "--ms", "500")
            _, current = snapshot()
            matches = [r for r in current if r[1] == "radioButton" and r[2] == label]
            selected = matches[-1] if root else matches[-2]
            if selected[3] == "1":
                return
        raise RuntimeError(f"Radio selection did not settle: {label}")

    def modal_readout(rows):
        title = next(int(r[0]) for r in rows if r[2] == "SwiftUI .sheet")
        values = [r[2] for r in rows if int(r[0]) > title
                  and r[2].startswith("SwiftUI colorScheme, ")]
        if not values:
            raise RuntimeError("Modal readout is offscreen; use a taller Simulator display")
        return values[-1]

    _, rows = snapshot()
    done = [r for r in rows if r[1] == "button" and r[2] == "Done"]
    while done:
        tap(done[-1])
        _, rows = snapshot()
        done = [r for r in rows if r[1] == "button" and r[2] == "Done"]
    tap(next(r for r in rows if r[1] == "radioButton" and r[2] == "nil"))
    _, rows = snapshot()
    tap(next(r for r in rows if r[1] == "button" and r[2] == ".sheet"))
    modal_radio("nil", root=True)
    _, rows = snapshot()
    conditional = next(r for r in rows if r[1] == "checkBox"
                       and r[2] == "Apply .preferredColorScheme conditionally")
    if conditional[3] != "0":
        tap(conditional)
    # Reopen after setup so previous explicit preferences cannot contaminate baseline.
    modal_radio("nil")
    _, rows = snapshot()
    tap(next(r for r in rows if r[1] == "button" and r[2] == "Done"))
    _, rows = snapshot()
    tap(next(r for r in rows if r[1] == "button" and r[2] == ".sheet"))
    baseline, rows = snapshot()
    if modal_readout(rows) != "SwiftUI colorScheme, .light":
        raise RuntimeError("Baseline is not light. Set Simulator system appearance to light.")
    modal_radio(".dark")
    dark, rows = snapshot()
    if modal_readout(rows) != "SwiftUI colorScheme, .dark":
        raise RuntimeError("Sheet did not become dark before clearing preference")
    modal_radio("nil")
    run("wait", "time", "--ms", "1000")
    cleared, rows = snapshot()
    stale = modal_readout(rows) == "SwiftUI colorScheme, .dark"
    result = {"udid": args.udid, "bug_reproduced": stale,
              "baseline": baseline, "dark": dark, "cleared": cleared}
    args.output.parent.mkdir(parents=True, exist_ok=True)
    args.output.write_text(json.dumps(result, indent=2) + "\n")
    print("Live preview:", cleared.get("context", {}).get("preview_url", "unavailable"))
    print("FAIL: nil retained .dark" if stale else "PASS: nil restored .light")
    print("Evidence:", args.output)
    return 1 if stale else 0


if __name__ == "__main__":
    try:
        sys.exit(main())
    except (RuntimeError, StopIteration, subprocess.CalledProcessError) as error:
        print(f"Automation/setup failed: {error}", file=sys.stderr)
        sys.exit(2)
