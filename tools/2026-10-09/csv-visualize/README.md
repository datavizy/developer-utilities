# csv-visualize

Export a labeled scatter plot or histogram from a CSV file using Matplotlib’s headless renderer. The Bash launcher runs a self-contained Python algorithm and prints a JSON summary after a successful export.

## Requirements and setup

Use Bash, Python 3, and Matplotlib 3.10.8. A project-local virtual environment keeps the plotting dependency separate from other projects. From the project directory, create and activate one, then install the required Matplotlib version:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

Save the executable launcher as `csv-visualize.sh`, or place the supplied launcher in your project. Make it executable if you want to invoke it directly:

```bash
chmod +x csv-visualize.sh
```

The explicit Bash launch command works without that permission change:

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

The launcher uses `python3` by default. To choose another Python executable, set `PYTHON_BIN`, for example `PYTHON_BIN=.venv/bin/python bash csv-visualize.sh ...`. Matplotlib uses the `Agg` backend, so the command can create images without opening a graphical window.

## Input and use

Input must be a UTF-8 CSV with a header row. The selected `--x` column is required and numeric. For the default `--kind scatter`, provide `--y` as the numeric vertical-axis column. The example above creates a scatter plot. To make a histogram of one column, select the histogram kind and use `--x` for its variable:

```bash
bash csv-visualize.sh --file measurements.csv --x x --kind histogram --title "Distribution of x" --output histogram.png
```

The output path must end in `.svg` or `.png`. It must not already exist; the tool refuses to replace an existing file or symlink. The title defaults to `Exploratory data visualization`. Axes are labeled with the selected column names, with `Count` as the histogram vertical-axis label.

## Results and algorithm

On success, the utility writes the figure and prints JSON containing `output`, `kind`, `observations`, and `omitted_rows`. `observations` counts rows used for the plot; `omitted_rows` counts rows that could not supply finite numeric values for the plotted variable or variables. Blank, nonnumeric, `NaN`, and infinite plotted values are omitted. A scatter row needs finite values in both selected columns. A histogram uses only `--x`.

The script reads CSV rows, converts the required field or fields to floating-point values, and stores usable observations before plotting. If there are $n$ input rows, reading and conversion take $O(n)$ time. Storage is $O(n)$ in the number of usable observations, in addition to plotting-library overhead. It errors if no usable observations remain. These counts describe the export process, not a statistical analysis.

## Scientific interpretation and limitations

The output is descriptive and exploratory. A scatter plot displays paired values; a histogram displays counts using Matplotlib’s automatic bin selection. Neither plot calculates statistical significance, confidence intervals, a fitted model, or causal effects. The utility does not impute missing data, investigate why rows were omitted, validate units, detect duplicate records, or assess whether observations are independent. Review omitted rows and data definitions before drawing conclusions. A successful image export does not certify data quality or scientific validity.

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

**Research inspiration:** Pandas for Everyone- Python Data Analysis, 20.5 Other Resources. The implementation is an independently written practical utility.
