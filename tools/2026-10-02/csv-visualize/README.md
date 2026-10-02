## Overview

A table of measurements is a good place to start. A plot gives you another way to explore it. `csv-visualize.sh` exports a labeled scatter plot or histogram from your CSV using Matplotlib's headless `Agg` renderer. Try it while cleaning data, reviewing measurements, or sharing a descriptive pattern. You get a reproducible visual check without opening a desktop application. The tool does not fit a statistical model or establish significance or causality.

## Prerequisites

Use Bash, Python 3, and Matplotlib 3.10.8. A project-local virtual environment keeps the plotting dependency separate from system Python. From the project directory, create and activate it, then install the required version:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

The script uses `python3` by default. If your environment requires a different Python executable, set `PYTHON_BIN` for that command. The plotting backend is explicitly set to `Agg`, so no graphical display is required.

## Input and commands

Input must be a UTF-8 CSV with a header row. Selected columns must exist; only numeric, finite values are plotted. Scatter plots require numeric `--x` and `--y` columns. Histograms use the numeric `--x` column; `--y` is not required. The script omits rows with missing, nonnumeric, or nonfinite selected values. It errors if no complete finite observations remain.

Scatter plot (the default):

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

Histogram:

```bash
bash csv-visualize.sh --file measurements.csv --x temperature --kind histogram --title "Temperature distribution" --output temperature.png
```

`--kind` accepts `scatter` or `histogram`; the default is `scatter`. `--title` is optional. Output must have an `.svg` or `.png` extension. Existing output files are never replaced: choose a new filename for each run.

## Read the picture and the counts

The plot labels the x-axis with the selected x column, labels the scatter y-axis with its selected y column or the histogram y-axis “Count,” and displays the requested title. Both plot types include a light grid. On success, standard output contains JSON with the output path, plot kind, number of plotted observations, and number of omitted rows. Read those counts alongside the picture. They make missing-data handling visible, although they do not explain why a row was omitted.

The script reads the CSV once, converts selected fields to floating-point values, retains complete finite observations, and then passes them to Matplotlib. Reading and retaining data takes $O(n)$ time and $O(n)$ memory for $n$ rows, apart from plotting and histogram bin selection. A scatter plot displays the retained pairs; a histogram uses Matplotlib’s automatic bin selection. Results are descriptive summaries of the supplied values, not inferential tests.

## Limitations and workflow

The utility does not clean or impute data, validate units, resolve duplicate records, check join cardinality, or infer causal relationships. It accepts numeric values only for plotted fields, and omitted rows may warrant investigation rather than dismissal. A plot can expose clusters, outliers, or unexpected distributions, but those patterns need domain review and a documented analysis. In a join-audit workflow, first verify that the joined table has the intended row grain; then plot relevant measurements as an exploratory check. The book section motivates that careful data workflow, but does not specify this utility.

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

**Research inspiration:** Data Science Fundamentals with R, Python, and Open Data -- Marco Cremonini, 10.1.5 Duplicated Keys. The implementation is an independently written practical utility.
