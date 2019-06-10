# cgen

CLI to generate a number, date, string or duration column in a CSV, TSV, etc.

# Example

## Generate integers

```bash
cgen -I --min 20 --max 55 -c 100 > nums.csv
```

## Generate floating point numbers

```bash

```

## Generate Dates

```bash

```

## Generate Durations

```bash

```

## Generate Strings

```bash

```

## Pick one from

### Pick one from File

Use `--file` or `-f` to generate column from lines in the provided file.

```bash
cgen -f names.csv -c 10
```

### Pick one from List

Use `--list` or `-l` option to generate column from a list of provided values.

```bash
cgen -l "one|two|three|four" -c 10
```