## Purpose

`csv-statistics.sh` summarizes one numeric column in a CSV file and estimates a 95% percentile bootstrap interval for its mean. It is useful in a reproducible research workflow when a scientist needs a quick, inspectable summary before plotting data, comparing groups with an appropriate method, or documenting a measurement series. The linear-algebra idea that a model’s solution set can contain multiple valid possibilities is a reminder to inspect data and assumptions rather than treating one summary as the whole story. That connection motivates the workflow; it does not mean the book specifies this utility.

## Requirements and input

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and uses only the standard library. Provide a UTF-8 CSV file with a header row and a named numeric column. The file is read with Python’s CSV dictionary reader, so the selected header must match the column name exactly. UTF-8 files with a byte-order mark are supported. Each nonblank cell in the selected column must parse as a finite floating-point number to be included. Blank or absent cells are counted as missing; nonblank values that cannot be parsed, as well as nonfinite values such as `NaN` or infinity, are counted as invalid and excluded. The usable column must contain 1 to 10,000 finite values.

## Run it

From the directory containing the script and data file, run the documented command:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

The seed is optional and defaults to 42. The resample count is optional and defaults to 2,000; if provided, it must be from 100 through 10,000. For example:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42 --resamples 5000
```

## Output and method

The program prints JSON. It reports the selected column, number of included observations, missing and invalid counts, arithmetic mean, median, minimum, maximum, and sample standard deviation. The standard deviation is `null` for a single included observation. It also reports `bootstrap_mean_interval_95`, the method name `percentile`, the seed, and resample count.

Each bootstrap sample draws the original number of values with replacement. The tool calculates that sample’s mean, repeats the process, sorts the means, and selects entries at indices `int(0.025 * (resamples - 1))` and `int(0.975 * (resamples - 1))`. This is a percentile interval, not a test of significance. A fixed seed and identical input, Python random implementation, and settings make the run reproducible. Sorting the bootstrap means takes $O(R\log R)$ time for $R$ resamples; generating them requires $O(nR)$ draws for $n$ observations. The stored bootstrap means require $O(R)$ space, in addition to the input values.

## Interpretation and limitations

Treat the interval as a descriptive, resampling-based summary of uncertainty in the mean under the observed data and the bootstrap procedure. It does not establish causality, statistical significance, or representativeness. The program assumes the selected observations are suitable for resampling as independent, identically distributed observations. It does not group data, model dependence, handle survey weights, impute missing values, or check scientific plausibility. Missing and invalid entries are excluded, so review their counts before interpreting results. The utility accepts at most 10,000 finite values and does not provide a configurable confidence level or alternate interval method. Use a domain-appropriate analysis when the sampling design or research question requires more than this summary.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Interactive Linear Algebra -- Conrad Plaut; -- 2026 -- CRC Press, 2.5 Homogeneous Systems. The implementation is an independently written practical utility.
