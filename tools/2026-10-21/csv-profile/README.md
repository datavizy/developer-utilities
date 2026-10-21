## Overview

`csv-profile` reads a CSV file and reports its number of data rows, rows whose field count differs from the header, and per-column missing-value and numeric summaries. It is a compact first-pass quality check before joining files, building visualizations, or running a statistical analysis. It reports descriptive properties only. It does not test hypotheses, establish significance, or support causal conclusions.

The workflow ideas behind command-line data analysis motivate this utility: inspect data early, make file structure visible, and put repeatable checks near the start of a pipeline. This is an engineering application of those ideas, not a claim that the book specifies this program.

## Requirements and launch

The executable is a Bash launcher that runs a self-contained Python 3 program. Bash and Python 3 must be available. The Python algorithm uses only the standard library, so there are no third-party package dependencies. The launcher uses `python3` by default; set `PYTHON_BIN` to select another Python executable if needed.

Run the supplied command from the directory containing the script:

```bash
bash csv-profile.sh --file measurements.csv
```

The `--file` argument is required. The tool reads that file; it does not read CSV data from standard input.

## Input expectations

The file must be UTF-8 CSV with a unique header row. A UTF-8 byte-order mark is accepted. Header names must be nonempty after whitespace is stripped, and duplicate names are rejected. The parser honors CSV quoting, so a quoted field may contain a delimiter. Each data record is expected to have the same number of fields as the header.

A row with a different field count is reported by its one-based CSV record number, counting the header as record 1; quoted newlines do not increase this number. Ragged rows are skipped for all per-column calculations. Empty or whitespace-only cells in correctly shaped rows count as missing. Nonempty cells are tested as floating-point numbers. Numeric counts, means, minima, and maxima include only values that parse as finite numbers. Non-numeric text and non-finite values such as `NaN` or infinity are not counted as missing and do not enter numeric statistics.

## Reading the result

The JSON output contains `ok`, `rows`, `ragged_rows`, and `columns`. `rows` counts data records read after the header, including ragged ones. Each column reports `missing` and `numeric_count`; it also reports `numeric_mean`, `numeric_min`, and `numeric_max`. When no finite numeric values exist for a column, its numeric count is zero and its mean, minimum, and maximum are `null`. `ok` is false when one or more ragged rows were found. In that case the program prints the report and exits with status 1. File-access, decoding, and validation errors caught by the program are reported by the command-line parser and produce a nonzero exit.

## Method, cost, and limits

The program parses records with Python’s standard `csv` reader and updates counters and numeric totals in one pass. For $R$ records and $C$ columns, the time cost is $O(RC)$ because each field is examined once. Memory use is $O(C + K)$, where $K$ is the number of ragged-row line numbers retained for the report. It does not keep the full dataset in memory.

This is a screening profile, not a schema validator or repair tool; sufficiently large finite values can overflow the floating-point total and prevent a JSON report. It does not infer units, distinguish numeric identifiers from measurements, interpret special missing-value codes, report variance or quantiles, check uniqueness of data rows, or diagnose why values are missing. Because ragged rows are omitted from column summaries, inspect `ragged_rows` before interpreting those summaries as representative. Review the input and study context before deciding what any count or mean means.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Hands-On Data Science with the Command Line - Automate -- Jason Morris; Chris McCubbin; Raymond Page, Selected body passage. The implementation is an independently written practical utility.
