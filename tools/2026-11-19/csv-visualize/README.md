# csv-visualize

`csv-visualize.sh` exports a labeled scatter plot or histogram from a CSV file using Matplotlib's headless renderer. It is useful when a scientist or developer needs a quick, repeatable exploratory figure in a terminal-based workflow, such as checking paired instrument measurements before a review or adding a simple chart artifact to a data-processing run. The array-and-plot workflow motivates this engineering convenience; the book section does not specify this utility.

## Prerequisites

The script launches Python 3 through Bash. Install Matplotlib 3.10.8 in a project-local virtual environment, then activate that environment before running the script. The utility selects Matplotlib's `Agg` backend, so it can render without a graphical desktop. The Python algorithm is self-contained in the script; NumPy is not required by its implementation.

Example setup and launch:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

The script can also be made executable and launched directly if its file permissions permit it. To select a histogram, provide `--kind histogram` and use `--x` for the numeric variable:

```bash
bash csv-visualize.sh --file measurements.csv --x temperature --kind histogram --output temperature.png
```

## Input and options

Input must be a UTF-8 CSV readable by Python's CSV reader. The header must contain the selected column names. `--file`, `--x`, and `--output` are required. For the default `scatter` kind, `--y` is required and names the numeric vertical-axis column. For `histogram`, `--y` is not used. `--title` sets the plot title and defaults to `Exploratory data visualization`. `--kind` accepts `scatter` or `histogram` and defaults to `scatter`.

The output filename must end in `.svg` or `.png`, case-insensitively. The tool refuses to replace an existing output file or symlink. It labels the horizontal axis with `--x`; scatter plots label the vertical axis with `--y`, while histograms use `Count`. The chart includes a light grid. Histogram bin selection uses Matplotlib's `bins="auto"` behavior.

## Output and behavior

On success, the command prints JSON containing the output path, plot kind, number of observations plotted, and number of omitted rows. Rows with blank, nonnumeric, or nonfinite selected values are omitted. The count applies to rows, not to distinct subjects or independent experimental units. If no complete finite numeric observations remain, the tool reports an error. Treat the result as exploratory description: it does not calculate significance, uncertainty, or causal effects.

The utility reads rows once and stores the valid selected values before plotting. For $n$ input rows, parsing and storage are $O(n)$ in time and memory; rendering cost also depends on the plotting backend and output. The figure uses a fixed size and a scatter style with partially transparent blue markers. SVG output sets a fixed hash salt and omits the metadata date; PNG output passes an empty metadata dictionary to Matplotlib.

## Concrete limitations

The tool does not validate units, detect duplicate records, infer data types beyond numeric conversion, impute missing values, or check whether observations are independent. CSV quoting is handled by Python's CSV reader, but locale-specific decimal conventions are not interpreted. It plots every accepted row, so very large files can require substantial memory and produce crowded figures. Inspect the chart and verify the input columns before using it in a report. A reproducible file-generation step is valuable, but it does not replace statistical design or scientific judgment.

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

**Research inspiration:** Python data science cookbook - over 60 practical recipes, Chapter 2. Python Environments. The implementation is an independently written practical utility.
