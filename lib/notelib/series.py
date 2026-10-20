"""Sequences and series. An example module; replace it with your own."""

import numpy as np


def partial_sums(n):
    """0 + 1 + ... + n for each value in `n`, computed by adding, not by formula."""
    n = np.asarray(n)
    sums = np.cumsum(np.arange(n.max() + 1))
    return sums[n]
