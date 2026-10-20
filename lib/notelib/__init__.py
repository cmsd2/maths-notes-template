"""Code shared between notes.

Grow this package by subject (`notelib.series`, `notelib.relativity`, ...) or
by job (`notelib.plot` for house style). Move code here from a note only when
a second note needs it, or when it hides the maths.

Keep computing separate from drawing: functions that compute return plain
values or NumPy arrays; functions that draw take a Matplotlib `ax` and never
create figures or call `plt.show()`, so each note controls its own layout.
Tests live in `tests/`.

Quarto's freeze only notices changes to a note's own `.qmd`, so after editing
this package, re-render the notes that use it (`quarto render notes/x.qmd`).
"""

from maxima_tex import maxima, maxima_tex

__all__ = ["maxima", "maxima_tex"]
