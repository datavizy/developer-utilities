#!/usr/bin/env bash
# csv-statistics: Summarize a numeric CSV column and compute a reproducible percentile bootstrap mean interval.
# Published 2026-10-20. Runtime requirements are documented in README.md.
set -euo pipefail
exec "${PYTHON_BIN:-python3}" - "$@" <<'PYTHON_UTILITY'
import argparse
import json
from pathlib import Path
import sys
parser = argparse.ArgumentParser(description='Summarize a numeric CSV column and compute a reproducible percentile bootstrap mean interval.')
try:
    parser.add_argument("--file", required=True, type=Path, help="UTF-8 CSV file")
    parser.add_argument("--column", required=True, help="Numeric column name")
    parser.add_argument("--seed", type=int, default=42, help="Bootstrap random seed")
    parser.add_argument("--resamples", type=int, default=2000, help="Bootstrap samples, 100 to 10000")
    args = parser.parse_args()
    import csv, math, random, statistics
    if not 100 <= args.resamples <= 10000:
        raise ValueError("resamples must be between 100 and 10000")
    values, missing, invalid = [], 0, 0
    with args.file.open(encoding="utf-8-sig", newline="") as handle:
        reader = csv.DictReader(handle)
        if args.column not in (reader.fieldnames or []):
            raise ValueError("selected column does not exist")
        for row in reader:
            raw = row.get(args.column)
            if raw is None or not raw.strip():
                missing += 1
                continue
            try:
                value = float(raw)
                if not math.isfinite(value):
                    raise ValueError("nonfinite")
            except ValueError:
                invalid += 1
                continue
            values.append(value)
    if not values or len(values) > 10000:
        raise ValueError("selected column must contain 1 to 10000 finite numeric values")
    rng = random.Random(args.seed)
    means = sorted(statistics.fmean(rng.choices(values, k=len(values))) for _ in range(args.resamples))
    result = {"column": args.column, "n": len(values), "missing": missing, "invalid": invalid,
              "mean": statistics.fmean(values), "median": statistics.median(values), "minimum": min(values), "maximum": max(values),
              "sample_standard_deviation": statistics.stdev(values) if len(values) > 1 else None,
              "bootstrap_mean_interval_95": [means[int(0.025 * (len(means) - 1))], means[int(0.975 * (len(means) - 1))]],
              "bootstrap_method": "percentile", "seed": args.seed, "resamples": args.resamples}
    print(json.dumps(result, indent=2, sort_keys=True, allow_nan=False))
    if result.get('ok') is False:
        sys.exit(1)
except (OSError, ValueError, TypeError, ZeroDivisionError, ImportError) as error:
    parser.error(str(error))
PYTHON_UTILITY
