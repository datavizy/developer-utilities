## Overview

`csv-profile` is a command-line utility for profiling missing values, row shape, and numeric statistics in a CSV file. It prints a JSON report that can serve as a quick, reproducible input check before data cleaning or statistical analysis. The linear algebra topic motivates an important workflow habit: interpret a matrix only after checking the data used to build it. This utility supports that habit, but it does not calculate matrices, eigenvalues, or scientific conclusions.

## Prerequisites

The launcher is a Bash script and invokes Python 3. There are no third-party Python dependencies. The implementation uses Python's standard library. If needed, set `PYTHON_BIN` to the Python 3 executable to use. Run the script from a shell that can execute Bash.

## Input format and launch

Provide a UTF-8 CSV with a unique, nonempty header row. A UTF-8 byte-order mark is accepted. Fields are parsed using Python's CSV reader, so quoted fields and commas inside quoted fields follow standard CSV parsing behavior.

```bash
bash csv-profile.sh --file measurements.csv
```

The supported options are `--file` (required to generate a report) and argparse's `-h`/`--help`. The script expects the named file to be readable.

## Reading the report

The JSON object contains `ok`, `rows`, `ragged_rows`, and `columns`. `rows` counts data records after the header. `ragged_rows` lists one-based logical CSV record numbers, with the header as record 1, whose field count differs from the header. `ok` is false when that list is nonempty. Each column reports `missing`, `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`. A blank or whitespace-only field increments `missing`. Other nonblank values that cannot be parsed as numbers are excluded from numeric summaries but are not counted as missing. Parsed nonfinite values, such as `NaN` or infinity, are also excluded. Means and extrema are descriptive summaries of the finite values accepted as numeric; they do not support significance or causal claims. Extremely large finite values can overflow the accumulated sum and prevent report generation. When a column has no accepted numeric values, its mean and extrema are `null`.

Rows with a field count different from the header are recorded and skipped for all per-column counts and numeric summaries. The program still counts them in `rows`.

## Method and complexity

The program streams records from the CSV reader and updates per-column counters and numeric totals. For a rectangular file with $R$ data rows and $C$ columns, processing time is $O(RC)$, plus CSV parsing and JSON output. Space use is $O(C+K+W)$, where $K$ is the number of ragged-row record numbers retained and $W$ is the size of the current parsed record. It stores summary statistics rather than all valid rows.

## Limitations

This is a basic profile, not a full schema validator. It does not infer data types, impute missing values, detect outliers, check scientific units, or compute correlations, covariance matrices, eigenvalues, confidence intervals, or tests. A nonblank text value is simply not included in numeric statistics. The tool requires unique, nonempty column names and does not provide a configurable missing-value vocabulary. Results describe the file as parsed; they do not establish that the dataset is representative or that a later model is valid. Inspect the input and document any cleaning and transformations before drawing research conclusions.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Linear Algebra_ Key Ideas and Methods for a First Course -- Haiyan Tian -- 2025, Selected body passage. The implementation is an independently written practical utility.
