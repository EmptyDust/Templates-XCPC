"""编译实际书稿正文；编译命令、生成源和诊断保留在 build/regression。"""
import os
from pathlib import Path
import shlex
import subprocess
import sys

ROOT = Path(__file__).resolve().parents[1]
sys.path.insert(0, str(ROOT / "tools"))
from sync_snippets import printed

HEADER = '#include "code/contest.hpp"\n'
BUILD = ROOT / "build" / "regression"


def compile_program(name, source):
    BUILD.mkdir(parents=True, exist_ok=True)
    cpp, exe = BUILD / (name + ".cpp"), BUILD / name
    cpp.write_text(HEADER + source, encoding="utf-8")
    command = shlex.split(os.environ.get("CXX", "g++")) + [
        "-std=gnu++20", "-O1", "-g", "-D_GLIBCXX_ASSERTIONS",
        "-fsanitize=undefined", "-fno-sanitize-recover=all",
        "-Werror=return-type", "-Werror=format", "-I", str(ROOT),
        str(cpp), "-o", str(exe),
    ]
    result = subprocess.run(command, text=True, capture_output=True, timeout=120)
    (BUILD / (name + ".log")).write_text(shlex.join(command) + "\n" + result.stdout + result.stderr)
    if result.returncode:
        raise AssertionError(result.stderr)
    return exe


def run(exe, data="", expected=None, timeout=30):
    result = subprocess.run([str(exe)], input=data, text=True, capture_output=True, timeout=timeout)
    if result.returncode:
        raise AssertionError(f"{exe.name}: exit {result.returncode}\n{result.stdout}{result.stderr}")
    if expected is not None and result.stdout.strip() != expected.strip():
        raise AssertionError(f"{exe.name}: expected {expected!r}, got {result.stdout!r}")
    return result.stdout


def check(name, source, data="", expected=None, timeout=30):
    return run(compile_program(name, source), data, expected, timeout)
