# csv-statistics

`csv-statistics.sh` summarizes one numeric CSV column and computes a reproducible percentile bootstrap interval for its mean. It is a small command-line companion for exploratory analysis: a researcher can inspect a measurement column, record sample-quality counts, and preserve the seed and resample count alongside the output. The Collatz matrix discussion shows how a compact mathematical model can expose structure; this tool serves a different purpose, but similarly makes a computational workflow explicit and repeatable. The book topic motivates careful computational practice here, not this utility’s design or claims.

## Requirements and input

The launcher requires Bash and Python 3. The Python algorithm uses only the standard library, with no third-party dependencies. Provide a UTF-8 CSV file with a header row and a named numeric column. Quoted CSV fields are supported by Python’s CSV reader. A UTF-8 byte-order mark is accepted. Blank selected-column fields are counted as missing; values that cannot be parsed as finite numbers, including `NaN` and infinities, are counted as invalid and excluded. Other columns are ignored. The selected column must contain 1 to 10,000 finite numeric values.

Run the documented example:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

The seed defaults to 42. The resample count defaults to 2,000 and can be set from 100 through 10,000 with `--resamples`. For example:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42 --resamples 5000
```

## Output and interpretation

The program prints indented, sorted JSON. It reports the selected column, retained `n`, counts of `missing` and `invalid` entries, arithmetic `mean`, `median`, `minimum`, `maximum`, and sample standard deviation. The sample standard deviation is `null` when only one valid value remains. `bootstrap_mean_interval_95` contains the two endpoints of a 95% percentile bootstrap interval. The output also records `bootstrap_method`, `seed`, and `resamples` so the calculation can be reproduced.

Each bootstrap resample draws `n` values with replacement from the retained observations and calculates their mean. The interval endpoints are selected from the sorted bootstrap means using the implementation’s indices `int(0.025 * (B - 1))` and `int(0.975 * (B - 1))`, where `B` is the resample count. The fixed seed makes results repeatable for the same input and runtime behavior. The work is approximately $O(Bn + B\log B)$, dominated by resampling and sorting the bootstrap means; memory use is $O(B+n)$.

## Limits to keep in view

These are descriptive summaries and a bootstrap interval under resampling of the observed values. They do not establish statistical significance, causal effects, or that a sampling design is representative. The percentile interval may be unsuitable for some data or small samples, and this utility does not offer alternative interval methods, missing-data imputation, weighting, or diagnostics. Inspect the input and study design before interpreting results. Errors such as an absent column, unreadable file, invalid resample count, or no valid observations are reported by the command-line parser rather than returned as a successful summary.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Exploring Linear Algebra_ Labs and Projects with -- Arangala, Crista -- 2024 -- CRC Press, 34 Project 3: The Collatz Problem. The implementation is an independently written practical utility.
