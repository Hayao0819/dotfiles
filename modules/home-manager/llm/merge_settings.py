import argparse
import json
import os
import stat
import sys
import tempfile
from collections.abc import MutableMapping
from pathlib import Path

import tomlkit


def fingerprint(path):
    try:
        info = path.lstat()
    except FileNotFoundError:
        return None
    return (
        info.st_dev,
        info.st_ino,
        info.st_mode,
        info.st_size,
        info.st_mtime_ns,
        info.st_ctime_ns,
    )


def snapshot(path):
    before = fingerprint(path)
    if before is None:
        return None, None
    contents = path.read_bytes()
    if fingerprint(path) != before:
        raise ValueError(f"{path} changed while being read; retry activation")
    return before, contents


def merge(dynamic, declared):
    for key, value in declared.items():
        if isinstance(value, dict) and isinstance(dynamic.get(key), MutableMapping):
            merge(dynamic[key], value)
        else:
            dynamic[key] = value
    return dynamic


def merge_file(format_name, source, destination, dry_run=False):
    declared = json.loads(source.read_bytes())
    if not isinstance(declared, dict):
        raise ValueError(f"{source} must contain a JSON object")

    original = snapshot(destination)
    raw = original[1]
    if format_name == "json":
        dynamic = json.loads(raw) if raw is not None else {}
        if not isinstance(dynamic, dict):
            raise ValueError(f"{destination} must contain a JSON object")
        output = (json.dumps(merge(dynamic, declared), indent=2) + "\n").encode()
    else:
        dynamic = tomlkit.parse(raw.decode()) if raw is not None else tomlkit.document()
        output = tomlkit.dumps(merge(dynamic, declared)).encode()

    if dry_run:
        print(f"Would merge declared settings into {destination}")
        return
    if original[0] is not None and stat.S_ISREG(original[0][2]):
        if output == raw and stat.S_IMODE(original[0][2]) == 0o600:
            return

    destination.parent.mkdir(parents=True, exist_ok=True)
    descriptor, temporary = tempfile.mkstemp(
        prefix=f".{destination.name}.", dir=destination.parent
    )
    try:
        with os.fdopen(descriptor, "wb") as handle:
            handle.write(output)
            handle.flush()
            os.fsync(handle.fileno())
        if snapshot(destination) != original:
            raise ValueError(f"{destination} changed during merge; retry activation")
        # Replacing the link itself avoids writing through a Nix store symlink.
        os.replace(temporary, destination)
    finally:
        Path(temporary).unlink(missing_ok=True)


def main():
    parser = argparse.ArgumentParser()
    parser.add_argument("format", choices=("json", "toml"))
    parser.add_argument("source", type=Path)
    parser.add_argument("destination", type=Path)
    parser.add_argument("--dry-run", action="store_true")
    args = parser.parse_args()
    try:
        merge_file(args.format, args.source, args.destination, args.dry_run)
    except Exception as error:
        print(f"Cannot merge {args.destination}: {error}", file=sys.stderr)
        return 1
    return 0


if __name__ == "__main__":
    sys.exit(main())
