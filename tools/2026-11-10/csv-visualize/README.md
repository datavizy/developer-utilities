## CSV Visualizer

`csv-visualize` exports a labeled scatter plot or histogram from a CSV file. It uses Matplotlib's headless `Agg` renderer, so it writes an image without opening a graphical window. This is useful in a research workflow where a scientist wants a quick, repeatable view of paired measurements or the distribution of one numeric variable, then can inspect the CSV and decide what further analysis is justified. The book topic motivates the workflow: select a visualization that fits the variable types and make exploratory work runnable as a script. The book does not specify this utility.

### Requirements

The launcher uses Bash and Python 3. Matplotlib 3.10.8 is required. Install it in a project-local virtual environment, for example:

```bash
python3 -m venv .venv
source .venv/bin/activate
python -m pip install matplotlib==3.10.8
```

Run the executable launcher from the project directory:

```bash
bash csv-visualize.sh --file measurements.csv --x x --y y --output scatter.svg
```

For a histogram, select the kind and omit `--y`:

```bash
bash csv-visualize.sh --file measurements.csv --x temperature --kind histogram --output temperature.png
```

Available arguments are `--file` (required UTF-8 CSV), `--x` (required numeric column), `--y` (numeric vertical-axis column, required for scatter), `--kind` (`scatter` or `histogram`, default `scatter`), `--title` (default `Exploratory data visualization`), and `--output` (required `.svg` or `.png` path). The CSV needs a header row. The selected column names must match header fields. The file is opened with UTF-8 BOM support.

### Results and behavior

The image has a title, labeled axes, and a light grid. Scatter points use a fixed blue style. Histograms use Matplotlib's automatic bin selection and show counts. On success, standard output contains JSON with the output path, plot kind, number of included observations, and number of omitted rows. Rows with blank, nonnumeric, NaN, or infinite values in a selected field are omitted. If no complete finite observations remain, the command reports an error. Existing output files and symlinks are not replaced; choose a new filename. Only SVG and PNG extensions are accepted.

The program reads rows once and stores complete selected observations before plotting. For $n$ input rows, parsing takes $O(n)$ time and storage is $O(n)$ for the retained points. Rendering cost depends on the plotting backend and output format. The output is descriptive, not inferential: it does not compute significance, estimate causality, validate units, or assess whether omissions bias conclusions.

### Concrete limitations

The tool supports only scatter plots and one-variable histograms. It does not filter by category, group observations, transform variables, select histogram bins manually, calculate summary statistics, or handle nonnumeric category axes. It does not validate whether the selected columns truly represent meaningful numerical measurements. Inspect headers, units, row quality, and omitted-row counts before interpreting the plot. A scatter pattern is not proof of a causal relationship.

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

**Research inspiration:** Hands-On Data Science and Python Machine Learning, 0 1 2 3 4 5 6 7 8 9. The implementation is an independently written practical utility.
