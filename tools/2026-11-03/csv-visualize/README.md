## CSV Visualizer

`csv-visualize` exports a labeled scatter plot or histogram from a CSV file. It uses Matplotlib’s headless `Agg` renderer, so it can create image files on a server or in a scripted analysis without opening a desktop window. The tool is useful for a quick, reproducible look at measurements before fitting a model, checking data quality, or sharing an exploratory figure. The book topic motivates a real workflow: market and model analyses depend on understanding observed data before interpreting fitted values. The book does not specify this utility.

### Requirements

Use Bash, Python 3, and Matplotlib 3.10.8. A project-local virtual environment keeps the plotting dependency separate from system Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

Place `csv-visualize.sh` on your path or run it from its directory. To pin the interpreter explicitly, set `PYTHON_BIN`; otherwise the script launches `python3`.

### Input and commands

The input is a UTF-8 CSV with a header row. Selected columns must contain numeric values. A scatter plot requires both the horizontal `--x` and vertical `--y` columns. A histogram uses `--x` as its variable and does not require `--y`.

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

Choose a histogram explicitly with `--kind histogram`:

```bash
bash csv-visualize.sh --file measurements.csv --x temperature --kind histogram --title 'Temperature distribution' --output temperature.png
```

The supported kinds are `scatter` and `histogram`; scatter is the default. Outputs must use `.svg` or `.png`. The output path must be new: existing files and symlinks are not replaced. The script reports errors through argparse and returns nonzero on handled errors.

### Results and implementation

The figure labels its axes with the selected column names, uses the supplied title, and includes a light grid. A histogram uses Matplotlib’s automatic bin selection. On success, standard output contains JSON with the output path, plot kind, number of observations used, and number of omitted rows. Blank, nonnumeric, missing, NaN, and infinite selected values are omitted row by row. For scatter plots, both selected values must be finite; for histograms, only the x value is checked. If no usable observations remain, the tool errors rather than producing an empty plot.

The Python algorithm is self-contained in the Bash launcher: it reads CSV rows, converts required fields to floats, filters invalid rows, then delegates plotting and file encoding to Matplotlib. For $n$ input rows, reading and filtering take $O(n)$ time and retain up to $O(n)$ plotted values. Rendering and output size also depend on the plotting backend and figure content. A fixed SVG hash salt and removal of SVG date metadata support more reproducible SVG output, but do not guarantee identical files across environments or Matplotlib versions.

### Limitations

These are descriptive exploratory graphics, not statistical tests or evidence of significance, causation, or a fitted relationship. The tool does not calculate summaries, confidence intervals, regression, or custom bin settings. It does not infer units, validate scientific meaning, or repair malformed data. CSV quoting is handled by Python’s CSV reader, but duplicate or ambiguous headers are not resolved. Inspect omissions and labels, check units and provenance, and use a documented analysis for inferential claims.

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

**Research inspiration:** Derivatives Analytics with Python- Data Analysis, Models, 11.2.1 Why Calibration at All?. The implementation is an independently written practical utility.
