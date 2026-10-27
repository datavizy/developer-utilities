## CSV Visualizer

`csv-visualize` exports a labeled scatter plot or histogram from a CSV file using Matplotlib’s headless renderer. It is useful when a scientist needs a quick, reproducible visual check of measurements before deciding what statistical analysis is appropriate. Nested structures and recursive algorithms motivate careful decomposition of data tasks, but this utility is a separate engineering tool, not a feature specified by the book section.

### Requirements

The launcher is Bash and invokes Python 3. Matplotlib 3.10.8 is required. Use a project-local virtual environment so the plotting dependency is isolated from system Python:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

Save the executable as `csv-visualize.sh` and make it executable with `chmod +x csv-visualize.sh`. The Matplotlib `Agg` backend is selected by the utility, so a graphical desktop is not required.

### Input and commands

The input must be a UTF-8 CSV file with a header row. The selected column names must match header fields exactly, and selected values must be numeric. A scatter plot requires both an x and y column. A histogram uses the x column as its single variable; the y option is not used for histogram data.

Exact scatter command:

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

Histogram command:

```bash
bash csv-visualize.sh --file measurements.csv --x concentration --kind histogram --title "Concentration distribution" --output concentration.png
```

The default kind is `scatter`; the default title is `Exploratory data visualization`. Outputs must have an `.svg` or `.png` extension. The tool refuses to replace an existing output file, so choose a new filename for each export.

### Results and behavior

The plot labels the horizontal axis with the selected x column and, for scatter plots, the vertical axis with the selected y column. Histograms label the vertical axis “Count.” Both include a title and light grid lines. On success, standard output contains JSON with the output path, plot kind, number of included observations, and number of omitted rows. Rows with missing, nonnumeric, infinite, or NaN selected values are omitted. If no complete finite observations remain, the command reports an error rather than creating a plot.

The implementation reads rows sequentially and stores valid observations before plotting. For $n$ rows and fixed-size numeric records, parsing and plotting preparation require $O(n)$ time and $O(n)$ observation storage; rendering cost depends on Matplotlib and output format. Histogram bin selection uses Matplotlib’s `bins="auto"` behavior. The tool does not calculate summary statistics, fit a model, test hypotheses, or make causal claims. Treat the figures as descriptive views of the retained rows.

### Concrete limitations

The utility supports only scatter plots and one-variable histograms, not automatic column discovery, filtering, grouping, uncertainty intervals, or statistical inference. It does not interpret units, detect outliers, or impute missing values. A scatter plot can overplot repeated observations, and an automatically binned histogram can conceal features that appear under other bin choices. Check row counts and data meaning before communicating a figure. CSV dialects beyond the standard reader’s handling, malformed encodings, and very large files may require preprocessing or a different workflow.

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

**Research inspiration:** Discrete Mathematics for Data Science -- Jack Pope; -- 2026 -- CRC Press, 11.1 Recursion. The implementation is an independently written practical utility.
