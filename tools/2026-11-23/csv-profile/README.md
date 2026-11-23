# csv-profile

`csv-profile` is a small command-line utility for checking a CSV file’s row shape, blank fields, and basic numeric summaries before analysis. It is useful when a researcher receives instrument exports or merges files from multiple sources and wants a quick, reproducible first look before plotting or fitting a model. Inner-product geometry motivates many later analyses, such as projections and least squares, but this utility is a separate engineering aid. It checks input structure and describes numeric values; it does not implement the mathematics of the book or validate a statistical model.

## Requirements and input

The launcher is a Bash script that invokes Python 3. The Python algorithm uses only the standard library, so there are no third-party dependencies. Set `PYTHON_BIN` if Python 3 is not available under the name `python3` in your environment.

The input must be a UTF-8 CSV file with a header row. A UTF-8 byte-order mark is accepted. Header names must be nonempty and unique. Fields are parsed according to Python’s CSV reader conventions, so quote fields containing commas or newlines. A row with a different number of fields from the header is recorded as ragged and is not included in per-column summaries.

## Run

From the directory containing the script:

```bash
bash csv-profile.sh --file measurements.csv
```

The required `--file` argument names the CSV to profile. The command prints indented JSON to standard output. It exits with status 1 if ragged rows were found. Invalid headers, unreadable files, and other handled input errors are reported through the argument parser as errors.

## Reading the output

The JSON contains `ok`, `rows`, `ragged_rows`, and `columns`. `rows` counts data records after the header. Reported positions use one-based logical CSV record numbers, including the header, not physical text-line numbers, so quoted fields with embedded newlines count as one record (the first data record is row 2). `ok` is false when at least one ragged record is found. Each column reports `missing`, `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`.

A value is missing when it contains only whitespace. Nonblank values that cannot be parsed as a floating-point number are ignored for numeric statistics, not counted as missing. Values that parse as NaN or infinity are also excluded from numeric summaries. `numeric_count` counts only finite parsed numbers. The mean is their arithmetic mean when the accumulated sum stays finite, or `null` when there are none; minimum and maximum are also `null` when no finite numeric value exists. If summing finite values overflows to infinity, JSON output fails and the program reports an error. These are descriptive summaries, not tests of significance, estimates of causal effects, or evidence that a measurement process is valid.

## Method, cost, and limitations

The program reads records sequentially, counts blank cells, attempts to parse each nonblank field as a float, and accumulates sum, count, minimum, and maximum. It retains the list of ragged row numbers and column summaries. For $R$ records and $C$ columns, processing is $O(RC)$ in the number of cells, with additional memory for the header, per-column accumulators, and ragged-row list. It does not load all well-formed records into memory.

The tool does not infer missing-value markers such as `NA` or `-999`, inspect units, detect outliers, distinguish numeric identifiers from measurements, or report medians, quantiles, correlations, and distributions. A syntactically valid but semantically incorrect CSV can still produce plausible output. Preserve the source file and record the command when reproducibility matters, then follow up with domain-specific validation before drawing conclusions.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** A Course in Linear Algebra -- Raju K_ George, Abhijith Ajayakumar -- Springer Nature, 5.2 Inner Product Spaces. The implementation is an independently written practical utility.
