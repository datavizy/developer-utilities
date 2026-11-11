# csv-statistics

`csv-statistics.sh` reads one numeric column from a UTF-8 CSV file, reports descriptive summaries, and estimates a reproducible percentile bootstrap interval for the mean. It is useful for a research notebook or lightweight data-checking workflow: a scientist can summarize a measurement column before plotting or modeling, retain machine-readable JSON, and rerun the same bootstrap with the recorded seed. The classification-evaluation ideas discussed in the accompanying article motivate the broader habit of separating summaries from decisions. This utility itself does not evaluate classifiers, choose thresholds, or implement the book's examples.

## Requirements and input

The shell launcher requires Bash and Python 3. The Python algorithm is self-contained and uses only the standard library. There are no third-party dependencies. Input must be a UTF-8 CSV with a header row. Pass the exact numeric column header with `--column`. Values that parse as finite floating-point numbers are retained. Blank or absent cells are counted as missing; nonblank values that cannot be parsed as finite numbers, including `NaN` and infinity, are counted as invalid and excluded. The selected column must contain 1 to 10,000 retained values. The CSV parser expects ordinary comma-separated input, with quoting handled by Python's CSV reader.

## Run it

From a shell, make the script executable if needed, then invoke the documented command:

```bash
chmod +x csv-statistics.sh
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

The seed is optional and defaults to 42. The resample count is optional and defaults to 2,000. Its accepted range is 100 to 10,000. For example, to use 5,000 bootstrap resamples:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42 --resamples 5000
```

## Output and method

The program prints JSON containing the selected column, retained sample size (`n`), missing and invalid counts, mean, median, minimum, maximum, and sample standard deviation. The sample standard deviation is `null` when only one numeric value remains. `bootstrap_mean_interval_95` contains the two endpoints of a 95% percentile bootstrap interval; `bootstrap_method`, `seed`, and `resamples` record how that interval was produced.

For each resample, the tool draws `n` values with replacement from the retained observations and calculates their arithmetic mean. It sorts the resulting means and selects indices `int(0.025 * (B - 1))` and `int(0.975 * (B - 1))`, where `B` is the resample count. A seeded Python random generator makes repeated runs reproducible in the same compatible runtime. The procedure takes approximately O(Bn) sampling work and O(B) storage for the bootstrap means, plus O(B log B) sorting.

## Limits to keep in mind

The interval is a descriptive bootstrap estimate under resampling of the observed rows. It does not correct sampling bias, dependence between observations, measurement error, or a nonrepresentative sample. The percentile interval is not a significance test, causal estimate, or guarantee of population coverage. Inspect whether independent, identically sampled observations are a plausible basis for resampling; clustered or time-dependent data may require a different design. Missing and invalid values are excluded rather than imputed, so their counts should be reviewed before interpreting summaries. All reported results describe the retained values, not automatically the wider population.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Applied Data Science Using PySpark - Learn the End-to-End -- Ramcharan Kakarla & Sundar Krishnan & Sridhar Alla, 6.4.2.3 y-hat prediction to probability to final prediction. The implementation is an independently written practical utility.
