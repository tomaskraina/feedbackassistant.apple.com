#!/usr/bin/env python3
"""Create a clean, self-contained Apple Feedback attachment from this sample."""
from pathlib import Path
from zipfile import ZIP_DEFLATED, ZipFile

root = Path(__file__).resolve().parents[1]
output = root / "dist" / "SheetPreferredColorSchemeClearBug.zip"
files = [root / name for name in ("README.md", "LICENSE", "project.yml", ".gitignore")]
for name in ("Sources", "SheetPreferredColorSchemeClearBug.xcodeproj", "docs", "media", "scripts"):
    files.extend(p for p in (root / name).rglob("*") if p.is_file()
                 and not any(part in ("xcuserdata", "__pycache__") for part in p.parts)
                 and p.name != ".DS_Store" and p.suffix != ".xcuserstate")
output.parent.mkdir(exist_ok=True)
with ZipFile(output, "w", ZIP_DEFLATED) as archive:
    for path in sorted(files):
        archive.write(path, Path(root.name) / path.relative_to(root))
print(output)
print(f"{len(files)} files; {output.stat().st_size:,} bytes")
