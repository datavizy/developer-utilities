## Purpose

`csv-profile` prints a JSON profile of a CSV file's row shape, blank cells, and finite numeric values. It is a small first-pass quality check for research exports and analytics pipelines: use it to spot unexpected short or long records, see where blank fields cluster, and check rough numeric ranges before choosing plots or statistical methods. This connects to the article's emphasis on inspecting data structure before interpreting dimensional patterns. The article motivates the workflow; it does not specify this utility.

## Prerequisites

The launcher is Bash and requires Python 3. It has no third-party Python dependencies. Set `PYTHON_BIN` if Python 3 is available under a non-default executable name. The input is read as UTF-8, with an optional UTF-8 byte-order mark, and must have a nonempty, unique header row. Header names are checked for uniqueness exactly as read; blank-only names are rejected.

## Run

From the directory containing the script:

```bash
chmod +x csv-profile.sh
bash csv-profile.sh --file measurements.csv
```

The command-line interface requires `--file` followed by the CSV path. For example, `bash csv-profile.sh --file measurements.csv`. No other options are implemented.

## Input and output

The file must be parseable as CSV. Each data row is counted, including rows whose number of fields does not match the header. Such row numbers are reported in `ragged_rows`, using CSV record numbers, with the header as record 1; quoted fields may span multiple physical lines. Ragged rows are excluded from all per-column statistics because their fields cannot be reliably aligned to the header.

The JSON result contains `ok`, `rows`, `ragged_rows`, and `columns`. Each column reports `missing`, `numeric_count`, `numeric_min`, `numeric_max`, and `numeric_mean`. A cell is missing when its value contains only whitespace. Nonblank values that cannot be parsed as floating-point numbers are ignored for numeric statistics. Parsed nonfinite values, including NaN and infinity, are also ignored. They are not counted as missing. Numeric statistics are descriptive summaries of finite values, not significance tests or evidence of causation. Very large finite values can overflow the running sum and make JSON serialization fail. If no finite numeric values remain, the count is zero and the minimum, maximum, and mean are `null`.

`ok` is false when any ragged rows are found. The tool still prints the JSON report, then exits with status 1. Caught file and input-validation errors are reported through argparse and result in a nonzero exit status; CSV parser errors may instead produce a traceback. A valid profile with no ragged rows exits successfully.

## Method and limitations

The script reads rows in order, maintains counters and numeric summaries for each column, then serializes the result as indented, sorted-key JSON. For correctly shaped data, its per-cell profiling work is $O(NC)$ for $N$ data rows and $C$ columns; CSV parsing also depends on input size. Memory use is $O(C+R)$, where $R$ is the number of ragged rows retained for reporting; the file is not loaded all at once.

The tool does not infer types, parse dates, recognize custom missing-value tokens, repair malformed rows, calculate standard deviations, or validate scientific plausibility. For example, `NA` is nonnumeric, not a missing value under this implementation. It does not trim header names or reconcile duplicate columns. Treat its output as a reproducible screening summary, then apply domain-specific checks and document any cleaning decisions before analysis.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** PRACTICAL LINEAR ALGEBRA FOR DATA SCIENCE, 2 matrix. The two vectors in the left plot (. The implementation is an independently written practical utility.
