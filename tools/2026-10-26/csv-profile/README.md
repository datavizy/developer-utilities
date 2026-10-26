## Overview

`csv-profile.sh` summarizes missing values, row shape, and finite numeric values in a CSV file, then prints a JSON report. It is a compact first check before plotting, fitting a model, or sharing a dataset. In simulation work, a workflow such as least-squares Monte Carlo depends on correctly shaped arrays and meaningful numeric inputs. This utility does not implement that book topic or validate a statistical model. It helps researchers inspect a CSV export before importing it into a larger, reproducible analysis.

## Prerequisites and launch

The launcher is Bash and invokes Python 3. The Python algorithm is self-contained and has no third-party dependencies. Make the script executable if needed, then run:

```bash
chmod +x csv-profile.sh
./csv-profile.sh --file measurements.csv
```

The equivalent explicit Bash launch is:

```bash
bash csv-profile.sh --file measurements.csv
```

The only supported option is `--file`, which is required. `PYTHON_BIN` can select the Python executable used by the launcher, for example `PYTHON_BIN=python3 bash csv-profile.sh --file measurements.csv`.

## Input format

The input must be readable as UTF-8 CSV and have a unique, nonempty header row. A UTF-8 byte-order mark is accepted. Header names must be unique as exact strings and cannot be blank after trimming whitespace. Rows are parsed using Python's CSV reader. A row whose field count differs from the header is recorded as ragged and excluded from all per-column counts and statistics. The report's `rows` count includes every data row encountered, including ragged rows.

A blank or whitespace-only cell counts as missing. Nonblank cells are converted with Python's `float` conversion when possible. Finite converted values contribute to numeric count, sum, minimum, maximum, and mean. Non-numeric text and nonfinite numeric values such as `NaN` or infinity are not counted as missing and do not contribute to numeric statistics. Consequently, `numeric_count` can be smaller than the number of nonblank cells. A column with no finite numeric values has `numeric_mean`, `numeric_min`, and `numeric_max` set to JSON `null`.

## Reading the output

The JSON object has `ok`, `rows`, `ragged_rows`, and `columns`. `ok` is true only when no ragged rows were found. `ragged_rows` contains one-based logical CSV record numbers, including the header as record 1, so the first data record is record 2. A quoted field spanning multiple physical lines counts as one record. Each column reports `missing`, `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`. The temporary numeric sum is used to calculate the mean and is not included in the output.

The tool prints the report even when ragged rows exist, then exits with status 1. Successful shape validation exits with status 0. File and header errors handled by the script are reported through argparse as errors. The script does not catch `csv.Error` from the reader, so such errors may produce a traceback. Treat all summaries as descriptive profiling, not hypothesis tests, significance measures, causal evidence, or validation of scientific assumptions.

## Algorithm, cost, and limitations

The script reads rows sequentially, maintaining per-column counters and numeric summaries. For $R$ data rows and $C$ columns, its processing time is $O(RC)$ in the usual case, plus CSV parsing; memory is $O(C+G)$, where $G$ is the number of ragged-row record numbers retained. It does not load the full table into memory.

This is a screening utility, not a complete CSV validator. It does not infer dates, enforce units or ranges, repair malformed records, distinguish multiple missing-value conventions such as `NA`, or calculate quantiles and standard deviations. Non-numeric and nonfinite cells are omitted from numeric summaries rather than flagged separately. Review the source data and domain rules before relying on a downstream analysis.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Derivatives Analytics with Python- Data Analysis, Models, 13.5.4 LSM Delta Hedging in BCC97 (Single Path). The implementation is an independently written practical utility.
