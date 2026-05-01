#!/usr/bin/env python3
# Generates Nordzy-archblue hyprcursor theme from installed Nordzy-hyprcursors.
# Replaces the white outline (#d8dee9) with an arch blue gradient (#1793d1 -> #0d5f9a).
# Run once after fresh install: python3 scripts/gen-archblue-cursor.py

import os, shutil, zipfile, tempfile, re

SRC  = "/usr/share/icons/Nordzy-hyprcursors"
DEST = os.path.expanduser("~/.local/share/icons/Nordzy-archblue")

GRADIENT_DEFS = (
    '<defs>'
    '<linearGradient id="g" x1="0%" y1="0%" x2="100%" y2="100%">'
    '<stop offset="0%" stop-color="#1793d1"/>'
    '<stop offset="100%" stop-color="#0d5f9a"/>'
    '</linearGradient>'
    '</defs>'
)

def patch_svg(svg):
    svg = re.sub(r'(<svg[^>]*>)', r'\1' + GRADIENT_DEFS, svg, count=1)
    svg = svg.replace('fill:#d8dee9', 'fill:url(#g)')
    return svg

shutil.rmtree(DEST, ignore_errors=True)
os.makedirs(f"{DEST}/hyprcursors", exist_ok=True)

with open(f"{SRC}/manifest.hl") as f:
    manifest = f.read().replace("Nordzy-hyprcursors", "Nordzy-archblue")
with open(f"{DEST}/manifest.hl", "w") as f:
    f.write(manifest)

for hlc in os.listdir(f"{SRC}/hyprcursors"):
    if not hlc.endswith(".hlc"):
        continue
    with tempfile.TemporaryDirectory() as tmp:
        with zipfile.ZipFile(f"{SRC}/hyprcursors/{hlc}") as z:
            z.extractall(tmp)
        for fname in os.listdir(tmp):
            if fname.endswith(".svg"):
                fpath = f"{tmp}/{fname}"
                with open(fpath) as f: svg = f.read()
                with open(fpath, "w") as f: f.write(patch_svg(svg))
        with zipfile.ZipFile(f"{DEST}/hyprcursors/{hlc}", "w", zipfile.ZIP_DEFLATED) as z:
            for fname in os.listdir(tmp):
                z.write(f"{tmp}/{fname}", fname)

with open(f"{DEST}/index.theme", "w") as f:
    f.write("[Icon Theme]\nName=Nordzy-archblue\nComment=Nordzy with Arch Blue gradient\nInherits=Nordzy-cursors\n")

print(f"Done — theme written to {DEST}")
print("Run: hyprctl setcursor Nordzy-archblue 24")
