# CSV Visualizer

`csv-visualize.sh` exports a labeled scatter plot or histogram from a CSV file using Matplotlib's headless renderer. It is intended for quick, reproducible inspection of numeric measurements when you want an image file without opening a graphical display. The Bash launcher passes its arguments to a self-contained Python program.

## Prerequisites

Use Bash and Python 3, with Matplotlib 3.10.8 installed for the Python interpreter used by the script. A project-local virtual environment keeps this dependency separate from system packages. The tool selects Matplotlib's `Agg` backend, so plotting does not require a desktop session.

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

The launcher uses `python3` by default. To select another interpreter, set `PYTHON_BIN` when invoking it, for example `PYTHON_BIN=.venv/bin/python bash csv-visualize.sh ...`.

## Input and commands

The input must be a UTF-8 CSV file with a header row. A UTF-8 byte-order mark is accepted. Selected columns must contain numeric values for a row to be plotted. The script requires `--file`, `--x`, and `--output`; `--x` identifies the horizontal variable for a scatter plot or the measured variable for a histogram. Scatter is the default kind and requires `--y`.

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

For a histogram, provide `--kind histogram` and omit `--y`:

```bash
bash csv-visualize.sh --file measurements.csv --x concentration --kind histogram --title "Concentration distribution" --output concentration.png
```

The `--title` option changes the plot title. Outputs must use the `.svg` or `.png` extension. The tool refuses to replace an existing output file or symlink, so choose a new filename for each run.

## Results and processing

The plot includes the selected column name on the horizontal axis, a title, and a light grid. Scatter plots label the vertical axis with the selected `--y` column. Histograms label it `Count`; their bins are selected with Matplotlib's `auto` rule. The image is saved as SVG or PNG. The program also prints JSON containing the output path, plot kind, number of observations used, and number of omitted rows. A row is omitted when a required value is blank, nonnumeric, NaN, or infinite. If no complete finite observations remain, the command reports an error rather than creating a plot.

For $n$ CSV rows, reading and checking data takes $O(n)$ time and $O(n)$ memory because valid points are collected before plotting. Rendering and output size depend on Matplotlib and the number of observations. SVG metadata suppresses the date field, and a fixed SVG hash salt supports stable SVG element identifiers; this does not promise byte-identical files across all library versions or environments.

## Research use and limitations

A scientist can use the utility to make a labeled first-look figure from a measurement export, preserve the image with analysis notes, and report how many rows were excluded. This supports a reproducible workflow: explicit column choices, a saved artifact, and a machine-readable count accompany the visual check. Probability concepts such as distributions and random variables motivate asking what a measurement represents and which observations enter a summary. The book passage motivates that conceptual workflow; it does not specify this utility.

These plots are descriptive, not inferential. The tool does not estimate uncertainty, test significance, identify causal effects, validate a sampling design, or fit a model. It does not impute missing values, handle categorical columns, offer a bin override, or provide filtering and grouping options. A histogram's appearance depends on bin selection, while a scatter plot may conceal overlapping points. Inspect the input, document exclusions, and use an analysis appropriate to the research question before drawing scientific conclusions.

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

**Research inspiration:** Problems from the Discrete to the Continuous_ Probability, Number Theory, Graph Theory, and Combinatorics, 1 0 < , limn!1. The implementation is an independently written practical utility.
