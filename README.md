# maths-notes-template

[![Render](https://github.com/cmsd2/maths-notes-template/actions/workflows/render.yml/badge.svg)](https://github.com/cmsd2/maths-notes-template/actions/workflows/render.yml)
[![Notes](https://img.shields.io/badge/notes-online-blue)](https://cmsd2.github.io/maths-notes-template/)

Rendered notes: **<https://cmsd2.github.io/maths-notes-template/>**, with
the example also as a
[PDF](https://cmsd2.github.io/maths-notes-template/notes/example.pdf).

A starting point for maths notes that mix prose, computer algebra, Python
figures and Lean proofs, rendered to PDF and HTML by
[Quarto](https://quarto.org).

`notes/example.qmd` shows all of it on one fact: Maxima finds the closed form
of 0 + 1 + ⋯ + n, Python plots it, and Lean proves it, with the proof shown
in the note straight from the file Lean checked.

It is assembled from two separate pieces, which you can also use on their
own:

- [quarto-lean](https://github.com/cmsd2/quarto-lean): Lean 4 highlighting in
  VS Code colours, snippet includes from a Lake project, PDF code that fits.
- [maxima-tex](https://github.com/cmsd2/maxima-tex): run Maxima from a code
  cell and show the result as typeset maths.

Click **Use this template** on GitHub to make your own copy.

## Layout

```
notes/            your notes, as .qmd files, in any folders you like
index.qmd         the contents page: a table of every note in notes/
lib/notelib/      Python shared between notes (an installed package)
tests/            pytest tests for notelib
lean/             a Lake project; notes include snippets from it
shared/           LaTeX and MathJax macros, and the HTML font, used by every note
_extensions/      the quarto-lean extension (vendored; don't edit)
_freeze/          saved results of code cells (created on first render; commit it)
```

Every `.qmd` in the repo is rendered, so organise `notes/` however you like,
or rename it (and change `contents:` in `index.qmd` to match). Folders
starting with `_` or `.` are skipped.

The repo is a Quarto website: each note becomes an HTML page with a link to
its PDF, and `index.qmd` lists them all. The HTML sets its text in Latin
Modern, the font of the PDF, from `shared/latin-modern.css`.

## Setup

You need:

| Tool | macOS | Windows | Linux |
|---|---|---|---|
| [Quarto](https://quarto.org/docs/get-started/) | installer or `brew install --cask quarto` | installer | installer |
| LaTeX with LuaLaTeX | `quarto install tinytex`, or MacTeX | `quarto install tinytex`, or MiKTeX | `quarto install tinytex`, or TeX Live |
| [uv](https://docs.astral.sh/uv/) | `brew install uv` | `winget install astral-sh.uv` | install script |
| [Maxima](https://maxima.sourceforge.io) | `brew install maxima` | installer from SourceForge | `apt install maxima` |
| [elan](https://lean-lang.org/install/) (Lean) | install script | installer | install script |

Then, in your copy of the repo:

```sh
uv sync                  # Python, Jupyter and the note packages, into .venv
uv run quarto render     # every note to _site/, as HTML and PDF
cd lean && lake build    # check the Lean project
```

Run Quarto through `uv run` so notes use the project's Python, not the
system one. To preview one note while you edit it:

```sh
uv run quarto preview notes/example.qmd
```

**Windows.** The Maxima installer doesn't add itself to `PATH`. Either add
its `bin` folder (for example `C:\maxima-5.48.1\bin`) to your user `PATH`,
or set `MAXIMA` to the full path of `maxima.bat`. With MiKTeX, the first
PDF render installs LaTeX packages on the fly and may fail part-way; render
again.

## Editing in VS Code (recommended)

[VS Code](https://code.visualstudio.com) handles every part of this repo in
one window: Quarto notes with live preview, Python cells, and Lean with
its interactive proof state.

1. Open the repo folder. VS Code offers to install the recommended
   extensions; accept. They are Quarto, Python, Jupyter, Lean 4, and
   Unicode LaTeX, which turns `\alpha`, `\forall` or `\to` into α, ∀ or →
   as you type in notes and Python. The Lean extension does the same in
   `.lean` files.
2. In VS Code's terminal, run `uv sync`.
3. Run **Python: Select Interpreter** from the Command Palette
   (Ctrl+Shift+P, or Cmd+Shift+P on macOS) and pick the `.venv` interpreter.
4. Open `notes/example.qmd` and run **Quarto: Preview**
   (Ctrl+Shift+K, or Cmd+Shift+K). The preview refreshes on every save.

Lean files under `lean/` work in the same window: the Lean 4 extension
finds the Lake project by itself and shows goals as you move through a
proof.

## Writing notes

- **Computer algebra.** `from notelib import maxima`, then
  `maxima("expression", setup="...", lhs="E(X)")` in a code cell with
  `#| echo: false`. Each call is a fresh Maxima process; any Maxima error
  stops the render instead of showing a stale result. Use ASCII names
  (`lambda`, not `λ`).
- **Lean.** Mark a region of a `.lean` file with `-- start snippet name` and
  `-- end snippet name`, then write an empty block
  `{.lean include="/lean/Notes/File.lean" snippet="name"}`. The leading `/`
  means the repo root, so the note can live at any depth. A missing file or
  snippet stops the render.
- **Notation.** Add macros to both `shared/macros.tex` (PDF) and
  `shared/macros.html` (HTML).
- **Shared code.** Move code from a note into `lib/notelib/` once a second
  note needs it. Keep computing separate from drawing: drawing functions
  take a Matplotlib `ax` and never create figures, so each note controls its
  own layout. Add tests to `tests/` and run `uv run pytest`.

## Freeze

`execute: freeze: auto` re-runs a note's code only when the note's `.qmd`
changes, and saves the results in `_freeze/`. Commit `_freeze/`: machines
and CI then render notes without running Maxima or Python.

Two things to know:

- **Editing `notelib` doesn't mark notes stale**, because the hash covers
  only the `.qmd`. Re-render the notes that use the changed code with
  `uv run quarto render notes/that-note.qmd`. Rendering a single file always
  runs its code.
- **Line endings matter.** `.gitattributes` checks `.qmd` and `_freeze/` out
  with LF on every OS. Without it, Windows sees a different hash and re-runs
  everything.

## Adding Mathlib

The Lake project starts without Mathlib so it builds in seconds. See
[`lean/README.md`](lean/README.md) to add it.

## CI and GitHub Pages

`.github/workflows/render.yml` runs the tests, checks the Lean project and
renders every note to HTML and PDF. On pushes to the default branch it
publishes `_site/` to GitHub Pages; pull requests only render.

In your copy, switch Pages on once, with GitHub Actions as the source:
**Settings → Pages → Build and deployment → Source: GitHub Actions**, or

```sh
gh api -X POST repos/OWNER/REPO/pages -f build_type=workflow
```

Then change the links at the top of this README to
`https://OWNER.github.io/REPO/`. Pages on a private repository needs a paid
GitHub plan; without one, delete the `deploy` job and the notes still render
in CI.

## Licence

[MIT](LICENSE). Your notes are your own: keep your copy private if they
contain anything you shouldn't publish, such as answers to assessed work.
