# Tools

Scripts that check the repository locally and in continuous integration. Each script runs from any directory in the repository and needs only Python 3 and Git. They check tracked and untracked files and skip files ignored by Git.

## Scripts

| Script | Purpose |
| --- | --- |
| `scripts/run_checks.py` | Runs every check, or the checks named on the command line |
| `scripts/check_acronyms.py` | Checks that acronyms used in Markdown are defined in the [Glossary](../docs/glossary.md) |
| `scripts/check_links.py` | Checks that relative Markdown links point to existing files, headings, and anchors |
| `scripts/check_whitespace.py` | Checks the line-ending, final-newline, and trailing-whitespace rules from `.editorconfig` |

`scripts/acronym-ignore.txt` lists uppercase words the acronym check should accept that are not acronyms. Define real acronyms in the glossary instead of listing them here.

## Running Checks Locally

Run the checks from the repository root before requesting review.

```sh
python3 tools/scripts/run_checks.py
```

To run selected checks, name them.

```sh
python3 tools/scripts/run_checks.py links whitespace
```

The [checks workflow](../.github/workflows/checks.yml) runs each check as a separate job named `check/<name>`, such as `check/acronyms`. It runs on every pull request, on pushes to `main`, and when started manually from the Actions tab.

To add a check, add its script to `scripts/`, list it in the table above, register it in `CHECKS` in `scripts/run_checks.py`, and add its name to the `check` list in the workflow.

## Fixing Failures

Each check reports the file, and the line where possible, for each problem.

### Acronyms

* For a real acronym, add it to the Acronyms and Abbreviations table in the glossary.
* For a word that is not an acronym, such as an all-caps label, add it to `scripts/acronym-ignore.txt` with a comment explaining why.
* Write code, commands, and file names in backticks. The check skips code spans, code blocks, link targets, URLs, and file names.

### Links

* Correct the path relative to the linking file, or the fragment to match the target heading. A heading's anchor is its text in lowercase, with punctuation removed and spaces replaced by hyphens.
* Links to other websites are not checked, so that the check works offline and does not fail when an external site is unavailable.

### Whitespace

* Configure your editor to follow `.editorconfig`, which most editors support directly or through a plugin.
* Convert CRLF line endings to LF. The `.gitattributes` file normalizes line endings when files are committed.
