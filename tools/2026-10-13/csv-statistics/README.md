# csv-statistics

`csv-statistics.sh` summarizes one numeric column in a UTF-8 CSV file and computes a percentile bootstrap interval for its mean. It is useful when a researcher or developer wants a small, scriptable descriptive report before plotting data, comparing a measurement with other evidence, or saving an analysis result alongside its inputs. The broader lesson from data-visualization workflows is that a useful chart or statistic depends on explicit definitions and traceable preprocessing. This tool supports that workflow; it does not automate data validation or make scientific claims.

## Requirements and input

Run the Bash launcher with Bash and Python 3 available. The Python algorithm is self-contained and has no third-party dependencies. The input must be a UTF-8 CSV with a header row. The requested column must exist and contain between 1 and 10,000 finite numeric values after parsing. A UTF-8 byte-order mark is accepted. Values are converted with Python’s `float` parser.

Blank or absent selected-column cells are counted as `missing` and skipped. Non-numeric values and nonfinite values such as `NaN` or infinity are counted as `invalid` and skipped. At least one finite numeric value must remain. The program does not impute values or inspect whether the remaining observations represent a target population.

## Launch

From a shell, use the documented command:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

`--file` and `--column` are required. `--seed` is an integer and defaults to `42`. The optional `--resamples` setting defaults to `2000` and must be between 100 and 10,000. For example:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42 --resamples 5000
```

The launcher uses `python3` unless the `PYTHON_BIN` environment variable names another Python executable. Argument errors and handled input errors are reported through the argument parser and result in a nonzero exit status.

## Output and method

Successful runs print indented, key-sorted JSON. The `n` field is the number of retained finite values; `missing` and `invalid` report skipped cells. The output includes mean, median, minimum, maximum, and sample standard deviation. For a single retained value, sample standard deviation is `null`, since it is undefined with fewer than two observations.

For the bootstrap, the tool draws `n` values with replacement from the retained data for each resample, computes that resample’s mean, and sorts all resample means. It reports the percentile interval using indices `int(0.025 * (B - 1))` and `int(0.975 * (B - 1))`, where `B` is the resample count. The JSON identifies the method as `percentile` and records the seed and resample count. Fixing the seed and keeping the input and settings unchanged makes the pseudorandom run reproducible in the same implementation environment.

The work is approximately $O(Bn + B\log B)$: generating and averaging resamples takes $O(Bn)$, and sorting their means takes $O(B\log B)$. Memory use includes the retained values and the list of $B$ bootstrap means.

## Limits

The interval is descriptive and depends on the observed sample. It does not establish statistical significance, causality, representativeness, or measurement validity. Ordinary row resampling assumes observations are suitable for independent resampling; clustered, paired, or time-dependent data may require a different method. A seed cannot correct selection bias, and more resamples reduce Monte Carlo variability without fixing poor data. Extreme finite values can still cause arithmetic overflow during summary or resampling calculations. Inspect the CSV, document collection and cleaning decisions, and interpret the JSON in its scientific context.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Practical Web Scraping for Data Science_ Best Practices and Examples with Python, 233 Chapter 9 examples. The implementation is an independently written practical utility.
