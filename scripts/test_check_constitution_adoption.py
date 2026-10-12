"""The historical exception must fail closed on changed or active content."""

from __future__ import annotations

import hashlib
import importlib.util
import tempfile
import unittest
from pathlib import Path


SOURCE = Path(__file__).with_name("check-constitution-adoption.py")
SPEC = importlib.util.spec_from_file_location("rustmc_adoption", SOURCE)
assert SPEC is not None and SPEC.loader is not None
ADOPTION = importlib.util.module_from_spec(SPEC)
SPEC.loader.exec_module(ADOPTION)


class HistoricalExceptionTests(unittest.TestCase):
    def test_only_exact_historical_bytes_receive_exception(self):
        with tempfile.TemporaryDirectory() as temporary:
            root = Path(temporary)
            report = root / "docs" / "dated-report.md"
            report.parent.mkdir()
            report.write_bytes(b"Historical evidence\r\n")
            expected = hashlib.sha256(b"Historical evidence\n").hexdigest()
            hashes = {"docs/dated-report.md": expected}

            self.assertTrue(ADOPTION.is_verified_history("LEGACY_REFERENCE", "docs/dated-report.md", root, hashes))
            self.assertFalse(ADOPTION.is_verified_history("OLD_PACK_DIRECTORY", "docs/dated-report.md", root, hashes))
            self.assertFalse(ADOPTION.is_verified_history("LEGACY_REFERENCE", "docs/new-report.md", root, hashes))
            report.write_bytes(b"Historical evidence\nNew live instruction\n")
            self.assertFalse(ADOPTION.is_verified_history("LEGACY_REFERENCE", "docs/dated-report.md", root, hashes))


if __name__ == "__main__":
    unittest.main()
