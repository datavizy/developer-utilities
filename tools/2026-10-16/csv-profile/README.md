## csv-profile

`csv-profile.sh` is a small command-line utility for profiling missing values, row shape, and numeric statistics in a CSV file. It is useful as an early check when preparing behavioral or rating data for analysis. In a recommender workflow, a blank rating is not automatically a negative rating, and a malformed row should not silently become a model input. This tool helps surface some structural facts before researchers or engineers make those decisions. The book topic motivates this workflow, but the utility is an independent data-quality aid, not a recommender or a feature described by the book.

### Prerequisites

Run the Bash script with Bash and Python 3 available. The implementation uses only the Python standard library and has no third-party dependencies. `PYTHON_BIN` may be set to choose the Python executable; otherwise the script launches `python3`.

### Input format

The input must be a UTF-8 CSV with a header row containing nonempty, unique column names. A UTF-8 byte order mark is accepted. Fields are parsed with Python's CSV reader, so quoted delimiters and quoted newlines follow that parser's CSV behavior. Each data record should have the same number of fields as the header.

A field containing only whitespace is counted as missing. Other nonblank fields are tested as numbers using Python's `float` conversion. Finite numeric values contribute to `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`; the sum is an internal accumulator and is not included in the JSON. Non-numeric text and nonfinite values such as `nan` or `inf` are excluded from numeric summaries, but are not counted as missing. Rows whose field count differs from the header are listed as ragged and skipped for all column statistics.

### Run it

```bash
bash csv-profile.sh --file measurements.csv
```

The only data-file option is the required `--file` path. The argument parser also provides its standard `--help` option. The script prints indented JSON with `ok`, `rows`, `ragged_rows`, and per-column statistics. `rows` counts data records read after the header, including ragged records. `ok` is true when there are no ragged rows. Each column reports `missing`, `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`. A statistic is `null` when there are no finite numeric values for that column. The tool exits with status 1 if ragged rows are found, even though it prints the profile. Argument parsing and caught input or validation errors are reported by the argument parser. Some `csv.Error` exceptions, such as fields exceeding Python's CSV field-size limit, are not caught.

### Algorithm and limitations

The program reads records sequentially, checks each row's width, and updates per-column counters and numeric aggregates. Its time complexity is $O(NC)$ for $N$ data rows and $C$ columns, plus CSV parsing costs. Statistics require $O(C)$ aggregate storage, with additional space for the list of ragged row numbers. These numbers refer to logical CSV records, not physical text lines; the header is record 1. The entire file is not loaded into memory.

The mean is the arithmetic mean of finite values recognized by `float`; this is descriptive profiling, not inference. The utility does not compute variance, detect outliers, validate units or schemas, infer why values are missing, or determine whether an event represents a user's preference. It does not repair data. In recommender research, use its output as a prompt to investigate data definitions and collection procedures, not as evidence of significance, causality, or model quality.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Practical Data Science with Python 3, 1 You can find many attractive and free pictures on Pixabay (visit. The implementation is an independently written practical utility.
