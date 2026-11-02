## csv-visualize

`csv-visualize` exports a labeled scatter plot or histogram from a CSV file using Matplotlib's headless renderer. It is a compact inspection step for scientists and developers who want a shareable figure without opening a notebook or starting a graphical desktop session. A scatter plot can help inspect paired numeric measurements, while a histogram shows the distribution of one numeric column. These are descriptive views, not tests of significance or evidence of causation.

### Requirements

The Bash launcher runs Python 3.10 or later. The Python algorithm is self-contained, and Matplotlib 3.10.8 is required. Use a project-local virtual environment to keep the dependency reproducible. For example:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

The script selects Matplotlib's `Agg` backend, so it can render without a display server. Save the supplied launcher as `csv-visualize.sh` and make it executable if desired:

```bash
chmod +x csv-visualize.sh
```

Exact launch command:

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

The utility also accepts `--kind histogram`, with `--x` naming the numeric variable. `--kind` defaults to `scatter`; scatter plots require `--y`. The optional `--title` sets the chart title. The output path must end in `.svg` or `.png` and must not already exist. For example:

```bash
bash csv-visualize.sh --file measurements.csv --x temperature --kind histogram --title 'Temperature distribution' --output temperature.svg
```

### Input and results

Input is a UTF-8 CSV file with a header row. Selected column names must match header fields and contain numeric values. The utility accepts a UTF-8 byte-order mark. For a scatter plot, each retained row must have finite numeric values in both selected columns. For a histogram, only the selected `--x` field is required. Blank, nonnumeric, infinite, and NaN values in required fields cause that row to be omitted. If no complete finite observations remain, the command reports an error.

On success, the utility writes the figure and prints JSON containing `output`, `kind`, `observations`, and `omitted_rows`. `observations` counts rows plotted, and `omitted_rows` counts rows skipped because required values could not be parsed as finite numbers. Review omissions against the source data; the tool does not identify why a value is absent or invalid.

### Implementation and limits

The script reads rows with Python's CSV reader, converts selected values to floating-point numbers, filters invalid rows, then draws a Matplotlib scatter plot or an automatically binned histogram. It labels the axes, applies a title and light grid, and saves SVG or PNG. Its processing and plotting work scale approximately linearly with the number of CSV rows, apart from Matplotlib rendering costs.

This is an exploratory plotting utility, not a statistical analysis package. It does not calculate correlations, fit models, validate units, detect duplicates, interpret dates, impute missing data, or establish that observations are independent or representative. Histogram bins are selected automatically. Large datasets may take time to render, and dense scatter plots can obscure overlapping observations. It does not replace an existing output file, so choose a new filename for each run. A successful plot is not a validation of the research design or the conclusions drawn from it.

## Reproducible setup and checks

```bash
python3 -m venv .venv
.venv/bin/python -m pip install -r requirements.txt
export PYTHON_BIN="$PWD/.venv/bin/python"
```

```bash
bash csv-visualize.sh --help
${PYTHON_BIN:-python3} -m unittest test_utility.py -v
```

The example inputs and expected output are in `examples/`. Tests use local fixtures and need no network or credentials.

**Research inspiration:** Data Visualization in Finance with Python_ A Comprehensive -- Schwartz, Alice & Van Der Post, Hayden -- 2024 -- Reactive Publishing, CHAPTER 5: VISUALIZATION TOOLS. The implementation is an independently written practical utility.
