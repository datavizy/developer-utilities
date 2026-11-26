## Overview

`csv-statistics.sh` summarizes one numeric column in a UTF-8 CSV file and reports a reproducible percentile bootstrap interval for its mean. It is useful for a small, repeatable exploratory step in a laboratory or analysis repository: a scientist can commit the input data and exact command, then regenerate the same JSON summary during review. Like PCA, the workflow emphasizes representing data through a defined statistical summary; unlike PCA, this utility does not estimate components, model dependence between observations, or determine whether a result is scientifically meaningful.

## Requirements and launch

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and has no third-party dependencies. Run it from a shell with the input path and an existing numeric column name:

```bash
bash csv-statistics.sh --file measurements.csv --column value --seed 42
```

The seed defaults to `42`; bootstrap resamples default to `2000`. The accepted resample count is 100 to 10000. The selected column must contain 1 to 10000 finite numeric values. The input is opened as UTF-8 with an optional byte-order mark, and parsed as CSV with a header row. Numeric text is converted using Python's `float` conversion.

## Output and method

The command writes a JSON object to standard output. It includes the selected column, number of valid values (`n`), missing and invalid counts, mean, median, minimum, maximum, sample standard deviation, the 95% bootstrap mean interval, method name, seed, and resample count. The sample standard deviation is `null` when there is only one valid value. Missing cells, including empty or whitespace-only cells, are counted as missing. Non-numeric values and nonfinite values such as `NaN` or infinity are counted as invalid and omitted from the calculations. If the column is absent, no valid values remain, or there are more than 10000 valid values, the command reports an argument error rather than producing a summary.

For each bootstrap draw, the program samples `n` values with replacement from the valid observations and computes their arithmetic mean. It sorts the resulting means. For `B` resamples, the reported endpoints are elements at zero-based indices `int(0.025 * (B - 1))` and `int(0.975 * (B - 1))`. This is the percentile method, not a bias-corrected or studentized interval. `random.Random(seed)` makes the draws repeatable for the same Python behavior and inputs. Sorting costs $O(B\log B)$; generating bootstrap means costs $O(Bn)$ time, with $O(B+n)$ storage for the values and sorted means.

## Interpretation and limitations

Treat the interval and descriptive statistics as summaries of the supplied values, not as a significance test, causal estimate, or guarantee about a population. The bootstrap assumes the rows are suitable sampling units for resampling. It does not preserve time-series dependence, clusters, paired measurements, or a complex survey design. Do not use it unchanged for those designs. It does not impute missing data, infer units, validate measurement protocols, or check whether the selected column represents the intended population. Inspect missing and invalid counts, document exclusions, and choose a method that matches the study design before drawing inferential conclusions.

## Reproducible setup and checks

```bash
bash csv-statistics.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Fundamentals of Linear Algebra for Signal Processing -- James Reilly -- 2024, Selected body passage. The implementation is an independently written practical utility.
