# Assignment 1 reflection

## Which env file is more correct, yours, or the AI's? What's actually different?

Both are objectively correct, but include different packages. The AI's is more generally correct, because it doesn't include build strings, while the one I generated does. The main difference is that I chose to create a conda environment first, and then install jupyter into that environment to be able to run notebook kernels specifically within that environment, so jupyterlab and its dependencies are included in my env file, and it is not in the AI one. 


## What did the AI add that you forgot? What did the AI invent (hallucinated package, wrong version, nonexistent flag)?

The AI added in code to the setup_env.sh file that accounts for the possibility that a conda environment with the same name could already exist. Everytime the AI setup_env.sh code is run, any existing env with that name is purged, and a clean install from the .yml takes place. My setup file did not account for that possibility. The AI didn't seem to invent anything out of place. 

## Did the AI's setup_env.sh actually run end-to-end on a clean shell?

The AI's setup_env file did successfully create the conda env in a clean shell, but didn't initially activate the environment or install the pip requirements. For some reason, it took a long time for the new environment to be created, but it did eventually run. Initially, the code to activate the environment and install the pip reqs didn't work because the script was set to error on unbound variables, and the script to import the conda activate command didn't set a value for the $CONDA_BACKUP_CLANGXX variable, causing the script to crash. After conversing with the agent to temporarily turn off the option that treats unset variables as errors, activate the environment, and then reactivate that option. After this correction, the script ran successfully on a clean shell.

### Cursor chat excerpt
"`CONDA_BACKUP_CLANGXX: unbound variable` (the real error)

```text
/Users/coraalbers/anaconda3/etc/conda/deactivate.d/deactivate_clangxx_osx-arm64.sh: line 65: CONDA_BACKUP_CLANGXX: unbound variable
```

This came from **`setup_env.sh` using `set -u`** (via `set -euo pipefail`).

- `set -u` means: using an unset variable is an error.
- When conda switches environments, it runs hook scripts like `deactivate_clangxx_osx-arm64.sh`.
- That script references `$CONDA_BACKUP_CLANGXX` without checking whether it’s set.
- With `set -u`, that becomes: **unbound variable**.

So this is a **clash between strict bash mode and conda’s activation hooks**, not a problem with your `environment.yml`.

**Good news:** your env still built fine (`Executing transaction: done`), and you successfully activated `bash_tut` afterward — your prompt shows `(bash_tut)`.

### What to do now

You can keep going:

```bash
conda activate bash_tut
python hello.py
Rscript hello.R
bash hello.sh
```

If you want `setup_env.sh` to finish without that warning, the usual fix is to temporarily turn off `set -u` around `conda activate`, or drop `-u` from the script. I can patch `setup_env.sh` if you want.

Fixing `setup_env.sh`: `set -u` conflicts with conda's activation hooks when `CONDA_BACKUP_CLANGXX` isn't set.


**What it means:** Conda’s macOS hook script (`deactivate_clangxx_osx-arm64.sh`) uses `$CONDA_BACKUP_CLANGXX` to restore compiler settings when leaving an environment. That variable is only set if clang was changed during activation — often it isn’t, so the variable is **unset**.

Your script has `set -u`, which tells bash to error on any unset variable. When conda runs that hook during `conda activate`, bash hits an unset `$CONDA_BACKUP_CLANGXX` and prints:

```text
CONDA_BACKUP_CLANGXX: unbound variable
```

It’s a conda hook + strict bash interaction, not a broken environment. Your `bash_tut` env was created fine.

**Fix applied:** `setup_env.sh` now temporarily disables `-u` around `conda activate`:

```bash
set +u
conda activate bash_tut
set -u
```

Re-run with:

```bash
bash setup_env.sh
```

It should finish without that error."

## Time to complete A vs. B (rough estimate is fine).

Completing the manual portion took me about 20 minutes, and completing the AI portion took me about 10 minutes. 