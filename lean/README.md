# lean/

One Lake project for the formal side of the notes.

- `lake build` checks everything. Notes never need Lean to render: the
  include filter only reads the source text.
- New file: add it under `Notes/`, then import it from `Notes.lean`.
- To show part of a file in a note, wrap it in `-- start snippet name` and
  `-- end snippet name`, then use
  `{.lean include="/lean/Notes/File.lean" snippet="name"}` in the note.
  Keep snippet lines under about 70 characters so they fit the PDF box
  without wrapping.

## Adding Mathlib

Uncomment the `[[require]]` block in `lakefile.toml`, make `lean-toolchain`
match its `rev`, then:

```sh
lake update
lake exe cache get   # downloads prebuilt Mathlib; skipping it means hours of compiling
lake build
```
