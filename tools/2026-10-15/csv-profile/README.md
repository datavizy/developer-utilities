## Purpose

`csv-profile` summarizes missing values, row shape, and basic numeric statistics in a CSV file. It is a compact first-pass check before analysis or visualization. The connection to matrix omission and replacement is practical rather than prescriptive: after deciding which records or values need attention, a researcher should inspect the input structure and document any later edits. The book section explains matrix indexing and assignment; it does not specify this utility.

## Requirements and launch

The utility is a Bash launcher for a self-contained Python 3 program. It has no third-party Python dependencies. The input must be a readable UTF-8 CSV file with a unique, nonempty header row. A UTF-8 byte-order mark is accepted. Run it from a shell with:

```bash
bash csv-profile.sh --file measurements.csv
```

The only data option is the required `--file` path; argparse also provides `--help`. The launcher uses `python3` by default; if needed, `PYTHON_BIN` can select a Python executable, for example `PYTHON_BIN=python3 bash csv-profile.sh --file measurements.csv`.

## Input and output

The first CSV record is treated as the header. Header names must be unique and must not be blank after trimming whitespace. The program reads subsequent records as rows and reports their count. A record whose number of fields differs from the header is recorded in `ragged_rows`, using CSV record numbers that start at 2 for the first data record. Ragged rows are excluded from all per-column statistics, and the result has `ok: false`; the process exits with status 1. With no ragged rows, `ok` is true and the process exits successfully.

Output is indented JSON, with column summaries under `columns`. Each column reports `missing`, `numeric_count`, `numeric_min`, `numeric_max`, and `numeric_mean`. A field is missing when it contains only whitespace. Nonblank values are considered for numeric statistics if Python can parse them as floats and the result is finite. Text that cannot be parsed, and nonfinite numbers such as `NaN` or infinity, are excluded from numeric statistics. They are not counted as missing. When no finite numeric values exist, the numeric count is zero and mean, minimum, and maximum are `null`.

The mean is the sum of accepted finite values divided by their count. These are descriptive summaries, not significance tests or causal evidence. In particular, `numeric_count` need not equal the row count because text, blank cells, nonfinite values, and ragged rows may be excluded.

## Algorithm and limitations

The program streams CSV records and updates per-column counters, sums, minima, and maxima. For `n` data rows and `p` columns, processing time is O(n × p); summary storage is O(p), plus the list of ragged row numbers. It does not infer dates, recognize custom missing-value tokens such as `NA` as missing, validate units, detect outliers, or repair malformed rows. With extreme finite values, floating-point accumulation can overflow and prevent JSON output. Numeric-looking identifiers can be summarized as numbers, and different missingness conventions require separate handling. Review the data and domain rules before deciding what to omit or overwrite in a downstream analysis.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** The book of R - a first course in programming and statistics, 3.2.2 Omitting and Overwriting. The implementation is an independently written practical utility.
