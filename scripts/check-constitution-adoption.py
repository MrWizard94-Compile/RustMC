#!/usr/bin/env python3
"""Run the canonical adoption audit while retaining hash-locked historical reports."""

from __future__ import annotations

import argparse
import hashlib
import importlib.util
import subprocess
import sys
from pathlib import Path


# These three dated reports describe the retired setup, not current law. Their
# historical banners and complete contents are hash-locked so edits cannot
# silently turn an active reference into an accepted exception.
HISTORICAL_REPORTS = {
    "docs/AUDIT-FULL-PROJECT.md": "2de88784860a182a6ac6ea1fd46adf1e0aee5c65a608e4789cbb2eb348aeb869",
    "docs/DELIVERY-REPORT.md": "11c4efa485ef7924acb684ef25d6603c6f39a02b07f7e265d8ffe3bf9f70a6e1",
    "docs/DELIVERY-REPORT-PLAYABLE.md": "6fbb622f8f8cb060e4fef0000f5a83965a0ad8850aafe2933bfbc4932c36b50d",
}


def is_verified_history(
    code: str, relative: str, project: Path, expected_hashes: dict[str, str] = HISTORICAL_REPORTS
) -> bool:
    expected = expected_hashes.get(relative)
    if code != "LEGACY_REFERENCE" or expected is None:
        return False
    file = project / relative
    if not file.is_file():
        return False
    actual = hashlib.sha256(file.read_bytes().replace(b"\r\n", b"\n")).hexdigest()
    return actual == expected


def main() -> int:
    parser = argparse.ArgumentParser(description=__doc__)
    parser.add_argument("--source", type=Path, required=True, help="pinned canonical check-adoption.py")
    parser.add_argument("--project", type=Path, required=True, help="RustMC Git root")
    args = parser.parse_args()

    try:
        project = args.project.resolve(strict=True)
        source = args.source.resolve(strict=True)
        spec = importlib.util.spec_from_file_location("wpai_adoption", source)
        if spec is None or spec.loader is None:
            raise ValueError("canonical adoption checker could not be loaded")
        checker = importlib.util.module_from_spec(spec)
        spec.loader.exec_module(checker)
        findings = checker.inspect(project)
    except (OSError, ValueError, ImportError, subprocess.CalledProcessError) as exc:
        print(f"FAIL: adoption audit could not complete: {exc}", file=sys.stderr)
        return 2

    unexpected = []
    retained = 0
    for code, relative, line in findings:
        if is_verified_history(code, relative, project):
            print(f"RETAINED_HISTORY: {relative}:{line} (hash verified)")
            retained += 1
            continue
        unexpected.append((code, relative, line))

    for code, relative, line in unexpected:
        print(f"{code}: {relative}:{line}", file=sys.stderr)
    if unexpected:
        print(f"FAIL: {len(unexpected)} active or changed adoption findings", file=sys.stderr)
        return 1
    print(f"PASS: canonical adoption audit; {retained} hash-locked historical references retained")
    return 0


if __name__ == "__main__":
    raise SystemExit(main())
