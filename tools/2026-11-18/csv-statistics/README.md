## Overview

`csv-statistics.sh` reads one numeric column from a UTF-8 CSV file and prints JSON descriptive statistics plus a reproducible percentile bootstrap interval for the mean. It is useful when a researcher or developer needs a compact, repeatable first summary of a measurement column before plotting it or conducting a more complete analysis. The business-centric lesson is to connect summaries to a defined question and data meaning. This utility supports that workflow; it does not decide whether a result is actionable or establish a causal effect.

## Prerequisites and launch

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and has no third-party dependencies. Save the implemented launcher as `csv-statistics.sh`, make it executable if desired, and run:

```bash
chmod +x csv-statistics.sh
./csv-statistics.sh --file measurements.csv --column value --seed 42
```

The equivalent explicit Bash invocation is:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

The `--file` and `--column` arguments are required. `--seed` is an integer and defaults to `42`. The optional `--resamples` parameter defaults to `2000` and accepts values from 100 through 10000. For example:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42 --resamples 5000
```

## Input format and data handling

Provide a UTF-8 CSV with a header row whose selected header exactly matches `--column`. The reader uses Python's CSV dictionary reader, supports a UTF-8 BOM, and handles quoted CSV fields. Selected-column empty or whitespace-only cells are counted as `missing`. Values that cannot be parsed as finite numbers, including `NaN` and infinities, are counted as `invalid`. Both categories are excluded from calculations. The usable selected column must contain 1 to 10000 finite numeric values. The CSV parser also requires the selected column to exist.

## Output and method

Standard output is formatted JSON. It reports the column name, usable `n`, missing and invalid counts, mean, median, minimum, maximum, and sample standard deviation. The standard deviation is `null` when only one usable value exists. It also reports `bootstrap_mean_interval_95`, the method label `percentile`, the seed, and resample count.

For each bootstrap resample, the program draws `n` values with replacement from the observed values and calculates their mean. It sorts the resample means and selects indices `int(0.025 * (B - 1))` and `int(0.975 * (B - 1))`, where `B` is the number of resamples. These are implementation-specific percentile bounds, not a guarantee of exact 95 percent coverage. A fixed seed makes the pseudo-random sequence reproducible for the same inputs and runtime behavior. The work is approximately $O(Bn + B\log B)$, where $n$ is the usable row count and $B$ is the resample count; sorting bootstrap means accounts for the latter term.

## Limitations

This is descriptive output, not a significance test, causal analysis, or forecast. The bootstrap represents resampling from the observed empirical values. It cannot repair biased sampling, dependent observations, unrecorded confounders, or informative missingness. Inspect the data, define the measurement and population, and use a design appropriate to the research question before making decisions. Errors such as unreadable files, absent columns, invalid resample counts, and unusable row counts are reported through the command-line parser.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Data Science for Dummies, 2nd Edition, Chapter 3 Applying Data-Driven. The implementation is an independently written practical utility.
