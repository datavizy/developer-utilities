#!/usr/bin/env bash
# csv-visualize: Export a labeled scatter plot or histogram from CSV using Matplotlib's headless renderer.
# Published 2026-10-02. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description="Export a labeled scatter plot or histogram from CSV using Matplotlib's headless renderer.")
try:
    parser.add_argument("--file", required=True, type=Path, help="UTF-8 CSV file")
    parser.add_argument("--x", required=True, help="Numeric column; horizontal axis or histogram variable")
    parser.add_argument("--y", help="Numeric vertical-axis column, required for a scatter plot")
    parser.add_argument("--kind", choices=["scatter", "histogram"], default="scatter")
    parser.add_argument("--title", default="Exploratory data visualization")
    parser.add_argument("--output", required=True, type=Path, help="New .svg or .png file; existing files are never replaced")
    args = parser.parse_args()
    import csv, math
    import matplotlib
    matplotlib.use("Agg")
    from matplotlib import pyplot as plt
    if args.output.suffix.lower() not in (".svg", ".png"):
        raise ValueError("output extension must be .svg or .png")
    if args.output.exists() or args.output.is_symlink():
        raise ValueError("output already exists; select a new filename")
    if args.kind == "scatter" and not args.y:
        raise ValueError("scatter plots require --y")
    points, omitted = [], 0
    with args.file.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        required = [args.x] + ([args.y] if args.kind == "scatter" else [])
        if any(field not in (reader.fieldnames or []) for field in required):
            raise ValueError("selected columns must exist")
        for row in reader:
            try:
                point = tuple(float(row.get(field) or "nan") for field in required)
                if not all(math.isfinite(value) for value in point):
                    raise ValueError("nonfinite")
            except ValueError:
                omitted += 1
                continue
            points.append(point)
    if not points:
        raise ValueError("no complete finite numeric observations")
    plt.rcParams["svg.hashsalt"] = "datavizy-developer-utilities-v1"
    fig, ax = plt.subplots(figsize=(8, 5), layout="constrained")
    if args.kind == "scatter":
        xs, ys = zip(*points)
        ax.scatter(xs, ys, s=38, alpha=0.8, color="#2563eb", edgecolors="none")
        ax.set_ylabel(args.y)
    else:
        ax.hist([point[0] for point in points], bins="auto", color="#2563eb", edgecolor="white")
        ax.set_ylabel("Count")
    ax.set_xlabel(args.x)
    ax.set_title(args.title)
    ax.grid(alpha=0.2)
    ax.set_axisbelow(True)
    with args.output.open("xb") as output:
        fig.savefig(output, format=args.output.suffix.lower()[1:], dpi=180, metadata={"Date": None} if args.output.suffix.lower() == ".svg" else {})
    plt.close(fig)
    result = {"output": str(args.output), "kind": args.kind, "observations": len(points), "omitted_rows": omitted}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
