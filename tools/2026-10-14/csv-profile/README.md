## Purpose

`csv-profile.sh` provides a compact first look at missing values, row shape, and numeric statistics in a CSV file. This is useful before analysis or visualization: a malformed row or unexpectedly sparse field can change what a downstream calculation means. The tool reports descriptive summaries only. It does not test hypotheses, estimate causal effects, or determine whether a dataset is statistically representative.

The topic of model sensitivity illustrates why reproducible analysis needs dependable inputs. In a research workflow, analysts may profile a dataset before computing summaries or preparing a plotted grid. This utility supports that engineering step, but it is a separate tool and is not specified by the book section.

## Requirements and launch

The executable is a Bash launcher that runs Python 3. Its Python algorithm is self-contained and has no third-party dependencies. Save the script as `csv-profile.sh`, make it executable, and run:

```bash
chmod +x csv-profile.sh
bash csv-profile.sh --file measurements.csv
```

The exact CLI requires `--file` and a path. It can also be invoked directly as `./csv-profile.sh --file measurements.csv` once executable. The launcher honors `PYTHON_BIN` if set; otherwise it uses `python3` from the environment.

## Input format and output

Input must be a UTF-8 CSV with a unique, nonempty header row. A UTF-8 byte-order mark is accepted. Rows are parsed using Python's CSV reader. The report is indented JSON with `ok`, `rows`, `ragged_rows`, and `columns`. `rows` counts data records after the header. `ragged_rows` lists their logical CSV record numbers, starting at 2 because the header is record 1, when their field count differs from the header. Such rows are skipped for column-level summaries. `ok` is false if any ragged rows were found, and the process exits with status 1 after printing the report.

Each column reports `missing`, `numeric_count`, `numeric_mean`, `numeric_min`, and `numeric_max`. Whitespace-only cells count as missing. Nonempty values are converted with Python's `float`; values that cannot be converted are excluded from numeric statistics. Nonfinite values such as `NaN` and infinity are also excluded. These nonnumeric and nonfinite cells are not added to the missing count. The mean is the sum of accepted finite numbers divided by their count; when there are none, mean and extrema are `null`.

## Algorithm, complexity, and limitations

The script reads records sequentially, checks each row's shape, and updates per-column counts, sums, minima, and maxima. Its processing time is $O(nm)$ for $n$ rows and $m$ columns, with summary state proportional to the number of columns, plus memory for the list of ragged row numbers. It does not retain all valid records.

This is an initial profile, not a schema validator. Numeric interpretation is based on Python float conversion, so locale-specific decimal formats are not handled specially. It does not infer dates, units, categorical levels, or missing-value tokens such as `NA`; those nonempty strings simply fail numeric conversion. It does not report medians, distributions, correlations, or confidence intervals. Review the raw data and domain rules before relying on a profile, especially when malformed records or unrecognized missing-value conventions may affect subsequent analysis.

## Reproducible setup and checks

```bash
bash csv-profile.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Derivatives Analytics with Python- Data Analysis, Models, 5.6.3 Script for BSM Call Greeks. The implementation is an independently written practical utility.
