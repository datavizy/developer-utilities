# csv-profile

`csv-profile.sh` produces a compact JSON profile of missing values, row shape, and numeric statistics in a CSV file. It is useful at the start of a reproducible analysis: before estimating relationships or fitting a model, check whether rows have the expected number of fields, whether columns contain blanks, and whether numeric-looking measurements have plausible summaries. This workflow is motivated by the statistical need to inspect paired data and assumptions before interpreting correlation. The book topic motivates that workflow; it does not specify this utility.

## Requirements and input

The launcher is Bash and runs Python 3. The Python algorithm is self-contained and has no third-party dependencies. Use a UTF-8 CSV file with one header row. Headers must be nonempty and unique. The reader accepts a UTF-8 byte-order mark, uses standard CSV parsing, and treats the first row as the column names. Values are interpreted as missing when they consist only of whitespace. Other nonblank values are considered for numeric summaries by attempting a floating-point conversion.

## Run

```bash
bash csv-profile.sh --file measurements.csv
```

The `--file` argument is required. The script prints indented JSON to standard output. For example, the result includes `ok`, `rows`, `ragged_rows`, and a `columns` object. `rows` counts data records after the header. `ragged_rows` contains CSV record numbers, counting the header as record 1, for records whose field count differs from the header. `ok` is false when such rows are found. For each column, `missing` counts blank values in well-shaped rows; `numeric_count`, `numeric_min`, `numeric_max`, and `numeric_mean` summarize accepted finite numeric values. If no values qualify, numeric count is zero and the statistics are `null` where applicable. A ragged row is reported but skipped for all column summaries.

The process exits with status 1 if ragged rows are present. Invalid headers, file errors, and other handled input errors are reported through argparse as command-line errors. A successful profile with no ragged rows exits normally.

## Method and limitations

The tool reads records sequentially, keeps counts and running sums plus minimum and maximum for each column, and stores the line numbers of ragged rows. Its time complexity is $O(RC)$ for $R$ data rows and $C$ columns, with additional memory for per-column summaries and the ragged-row list. It does not load the complete table into memory.

Numeric summaries include values that Python can parse as finite floating-point numbers, although a running sum can overflow for extreme inputs and cause the command to fail. Blank strings count as missing. Nonblank text that cannot be parsed, as well as nonfinite values such as `NaN` or infinity, is excluded from numeric statistics and is not counted as missing. Consequently, `numeric_count` may be smaller than the number of nonblank cells, and the output does not explain every exclusion. The utility does not infer data types, validate units or ranges, identify duplicates, impute missing values, or calculate correlations, p-values, or causal effects. Its mean, minimum, and maximum are descriptive checks, not inferential conclusions. Review the source data and use an analysis that matches the study design before drawing scientific conclusions.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Biostatistics For Dummies, 2nd Edition, Chapter 15 Introducing Correlation and Regression. The implementation is an independently written practical utility.
