## csv-profile

`csv-profile` is a small command-line utility for profiling missing values, row shape, and numeric statistics in a CSV file. It is useful before analysis: a quick profile can expose blank fields, malformed row widths, and numeric ranges that deserve investigation. In a reproducible research workflow, keep the input file and the resulting JSON report with the analysis record, then document any cleaning decisions separately. This supports careful interpretation of downstream visualizations and statistics. The clustering discussion motivates checking inputs before drawing conclusions, but does not specify this utility.

### Prerequisites

The launcher is a Bash script and invokes Python 3. No third-party Python packages are required. Ensure Bash and Python 3 are available. The script accepts `PYTHON_BIN` as an environment override for the Python executable; otherwise it uses `python3`.

### Input and launch

Provide a UTF-8 CSV file with a header row containing nonempty, unique column names. A UTF-8 byte-order mark is accepted. Run:

```bash
bash csv-profile.sh --file measurements.csv
```

The program writes a JSON profile to standard output. It reads the CSV with Python's CSV reader, so quoted fields and quoted delimiters are handled as CSV fields rather than split naively on commas. A blank physical line outside a quoted field is read as an empty record and counted as ragged; a blank line inside a quoted field is part of that field.

### Reading the output

The JSON object contains `ok`, `rows`, `ragged_rows`, and `columns`. `rows` counts data records read after the header. `ragged_rows` lists their one-based CSV record numbers, beginning with record 2 for the first data record; record 1 is the header. A row whose number of fields differs from the header is recorded as ragged and excluded from per-column statistics. `ok` is false if any ragged rows were found; in that case the tool exits with status 1 after printing the JSON.

For each header field, `missing` counts whitespace-only values in well-shaped rows. `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max` describe values that can be parsed as finite floating-point numbers. Nonblank text that is not numeric is ignored for numeric statistics, as are nonfinite parsed values such as `NaN` or infinity. Such values are not counted as missing. If a column has no finite numeric values, its mean, minimum, and maximum are `null`. The mean is the numeric sum divided by the numeric count. If that sum overflows floating-point range, the utility reports an error instead of producing a JSON profile. These are descriptive summaries only, not significance tests or evidence of causation.

### Algorithm and limitations

The utility makes one pass through the CSV, maintaining counts, sums, minima, maxima, and ragged-row line numbers. For `n` data records and `p` columns, profiling takes time proportional to the number of input fields, approximately $O(np)$, with memory proportional to the column summaries plus the list of ragged line numbers. It does not retain all well-shaped rows.

The tool does not infer column types, impute missing values, validate a domain schema, or explain why data are absent. Ragged rows are skipped for column summaries rather than repaired. It does not flag outliers, distinguish special missing-value tokens such as `NA` from ordinary text, or calculate quantiles and standard deviations. Numeric-looking values are interpreted as Python floating-point numbers; locale-specific formats may not parse as intended. Review the input and study design before using this profile to make analysis decisions.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** An Introduction to Statistical Learning  with Applications in R, 401 A Tempered Approach to Interpreting the Results of Clustering. The implementation is an independently written practical utility.
