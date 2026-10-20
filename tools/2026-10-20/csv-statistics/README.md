## Overview

`csv-statistics.sh` summarizes one numeric column in a CSV file and computes a reproducible 95% percentile bootstrap interval for its mean. It is a compact first-pass check for research or FP&A data: inspect the selected column’s size, center, range, spread, and resampling interval before using it in a larger analysis. This supports the broader forecasting practice of validating inputs and making analysis repeatable. The book topic motivates that workflow; the book does not specify this utility.

The output is descriptive. It does not forecast future observations, test statistical significance, establish causality, or determine whether the resampling assumptions are appropriate.

## Requirements and input

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and uses only the standard library; there are no third-party dependencies. The input must be a UTF-8 CSV with a header row and the requested numeric column. The file is opened with UTF-8 BOM handling. Values that are blank or absent are counted as `missing`. Values that cannot be parsed as finite floating-point numbers, including nonfinite values such as `NaN` or infinity, are counted as `invalid`. Both groups are excluded from the calculations. The selected column must contain 1 to 10,000 finite numeric values.

## Run

From a shell with Bash and Python 3 available, run:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

The seed defaults to `42`. The resample count defaults to `2000` and must be between `100` and `10000`. For example, to set it explicitly:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42 --resamples 5000
```

## Output and method

The command prints formatted JSON. It includes the column name, usable observation count (`n`), missing and invalid counts, mean, median, minimum, maximum, and sample standard deviation. The standard deviation is `null` when there is only one usable observation. The `bootstrap_mean_interval_95` field contains the lower and upper endpoints; `bootstrap_method`, `seed`, and `resamples` record the method and settings.

For each resample, the utility draws `n` values with replacement from the usable observations and computes their mean. It sorts the resample means, then selects indices `int(0.025 * (B - 1))` and `int(0.975 * (B - 1))`, where `B` is the resample count. The endpoints are therefore the implementation’s discrete percentile selections, not interpolated quantiles. A seeded Python random generator makes the resampling reproducible for the same data, seed, and runtime behavior.

The summary pass takes linear time in the number of rows. Bootstrap work takes approximately `O(B n)` to generate and calculate means, plus `O(B log B)` to sort them. Memory use grows with the number of usable values and stored bootstrap means.

## Limitations

The interval reflects resampling from the observed values; it does not account for time order, clusters, changing processes, or future shocks. It is not automatically a prediction interval or a guarantee about future costs. Missing and invalid entries are excluded rather than imputed, and their counts should be reviewed. The utility accepts only one numeric column at a time, rejects more than 10,000 usable values, and does not validate business units, dates, duplicate records, or the meaning of rows. Review the data and assumptions before using output in a decision.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Financial Data Analysis For FP&A- With Excel and Python, Chapter 5: Financial Forecasting and Budgeting. The implementation is an independently written practical utility.
