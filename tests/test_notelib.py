import numpy as np

from notelib.series import partial_sums


def test_partial_sums_match_the_closed_form():
    # The same fact the example note finds in Maxima and proves in Lean.
    n = np.arange(50)
    assert (2 * partial_sums(n) == n * (n + 1)).all()


def test_partial_sums_accept_any_order():
    assert list(partial_sums([3, 0, 10])) == [6, 0, 55]
