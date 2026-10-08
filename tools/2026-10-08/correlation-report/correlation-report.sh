#!/usr/bin/env bash
# correlation-report: Compute Pearson correlation and a least-squares line from paired CSV observations.
# Published 2026-10-08. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Compute Pearson correlation and a least-squares line from paired CSV observations.')
try:
    parser.add_argument("--file", required=True, type=Path, help="UTF-8 CSV file")
    parser.add_argument("--x", required=True, help="Predictor column")
    parser.add_argument("--y", required=True, help="Response column")
    args = parser.parse_args()
    import csv, math, statistics
    pairs, omitted = [], 0
    with args.file.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if args.x not in (reader.fieldnames or []) or args.y not in (reader.fieldnames or []):
            raise ValueError("both selected columns must exist")
        for row in reader:
            try:
                x, y = float(row.get(args.x) or "nan"), float(row.get(args.y) or "nan")
                if not math.isfinite(x) or not math.isfinite(y):
                    raise ValueError("nonfinite")
            except ValueError:
                omitted += 1
                continue
            pairs.append((x, y))
    if len(pairs) < 2:
        raise ValueError("at least two complete finite pairs are required")
    xs, ys = zip(*pairs)
    mx, my = statistics.fmean(xs), statistics.fmean(ys)
    sxx = math.fsum((x - mx) ** 2 for x in xs)
    syy = math.fsum((y - my) ** 2 for y in ys)
    sxy = math.fsum((x - mx) * (y - my) for x, y in pairs)
    if not sxx or not syy:
        raise ValueError("correlation requires variation in both columns")
    r = max(-1.0, min(1.0, sxy / math.sqrt(sxx * syy)))
    result = {"n_pairs": len(pairs), "omitted_rows": omitted, "x_column": args.x, "y_column": args.y,
              "pearson_r": r, "least_squares_slope": sxy / sxx, "least_squares_intercept": my - (sxy / sxx) * mx,
              "interpretation": "Descriptive association and a fitted line; no causal or significance claim."}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
