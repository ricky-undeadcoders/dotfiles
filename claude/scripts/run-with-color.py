#!/usr/bin/env python3
"""
PTY wrapper to preserve ANSI colors from Click-based commands
"""
import sys
import pty
import os
import subprocess

if len(sys.argv) < 2:
    print("Usage: run-with-color.py <command> [args...]")
    sys.exit(1)

# Run command in a PTY to force color output
try:
    # Fork a pseudo-terminal
    master, slave = pty.openpty()

    # Run the command
    process = subprocess.Popen(
        sys.argv[1:],
        stdin=slave,
        stdout=slave,
        stderr=slave,
        env={**os.environ, 'FORCE_COLOR': '1', 'CLICOLOR_FORCE': '1'}
    )

    os.close(slave)

    # Read output and print it (preserving colors)
    while True:
        try:
            data = os.read(master, 1024)
            if not data:
                break
            sys.stdout.buffer.write(data)
            sys.stdout.buffer.flush()
        except OSError:
            break

    process.wait()
    os.close(master)
    sys.exit(process.returncode)

except Exception as e:
    print(f"Error: {e}", file=sys.stderr)
    sys.exit(1)
