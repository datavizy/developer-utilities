# CSV Plot Exporter

`csv-visualize.sh` exports a labeled scatter plot or histogram from a CSV file. It uses Python 3 and Matplotlib's headless `Agg` renderer, so it can generate figures on a server or in a build environment without opening a desktop window. The utility is a small, reproducible way to inspect numeric data before analysis or include a quick plot in a research workflow.

## Prerequisites

Use Bash and Python 3. Install Matplotlib 3.10.8 in a project-local virtual environment, then activate it before running the script:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

Save the executable as `csv-visualize.sh`, or use the supplied executable file in your project. The Python algorithm is contained in the script. `PYTHON_BIN` can select the Python executable if needed; otherwise it uses `python3`.

## Input and commands

The input is a UTF-8 CSV file with a header row. The selected columns must contain numeric values. A byte-order mark is accepted. Empty, nonnumeric, NaN, and infinite values in required columns cause that row to be omitted. For a scatter plot, both selected columns must be finite numeric values; a histogram needs only its selected variable.

Create a scatter plot with the documented command:

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

Create a histogram by selecting its kind. The program ignores `--y` for histograms:

```bash
bash csv-visualize.sh --file measurements.csv --x temperature --kind histogram --output temperature.png
```

`--kind` accepts `scatter` or `histogram` and defaults to `scatter`. `--title` changes the default title, `Exploratory data visualization`. Outputs must have an `.svg` or `.png` extension. The tool refuses to replace an existing output file or symlink, so choose a new filename for each run.

## Output and interpretation

The chart labels the x-axis with the selected `--x` column, includes the chosen title, and uses a grid. Scatter plots label the vertical axis with `--y`; histograms label it `Count` and use automatically selected bins. The script prints JSON containing the output path, plot kind, number of observations plotted, and number of omitted rows. These counts make skipped incomplete or nonfinite records visible. A histogram count describes the rows in each bin, not a probability or inferential result.

## How it works and limitations

The script reads rows with Python's CSV reader, converts required fields to floating-point values, and keeps only rows whose required values are finite. It then passes the retained observations to Matplotlib and saves the figure using the extension's format. The data scan is $O(n)$ in the number of CSV rows; retained points are held in memory, so memory use is $O(n)$ in the number of usable rows. Histogram bin selection is delegated to Matplotlib's `auto` rule.

This is an exploratory plotting utility, not a statistical analysis package. It does not estimate significance, test hypotheses, make causal claims, impute missing values, or validate whether a chart is appropriate for a research question. It does not provide custom bin settings, grouping, styling controls, or a mechanism to overwrite files. Inspect omitted-row counts and the plot before interpreting results. The book topic motivates a useful workflow: visualize data and fold-level results to notice patterns or variation, then evaluate models with an appropriate cross-validation design. The book does not specify this utility, and a plot alone cannot establish model performance or scientific conclusions.

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

**Research inspiration:** Practical Statistics for Data Scientists - 50+ Essential -- Peter Bruce; Peter C. Bruce; Andrew Bruce; Peter Gedeck, 9 0.9 12 38.18. The implementation is an independently written practical utility.
