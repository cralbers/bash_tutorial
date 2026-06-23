#!/bin/bash
set -euo pipefail

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
cd "$SCRIPT_DIR"

if conda env list | awk '{print $1}' | grep -qx bash_tut; then
  conda env update -f environment.yml --prune
else
  conda env create -f environment.yml
fi

eval "$(conda shell.bash hook)"
conda activate bash_tut
pip install -r requirements.txt

echo "Environment 'bash_tut' is ready. Run: conda activate bash_tut"
