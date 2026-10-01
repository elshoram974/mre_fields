---
description: Delete scratch/temporary scripts after one-off tasks
globs: *
alwaysApply: true
---
# Cleanup Temporary Files

1. Temporary scripts (`scratch/`, root one-shot `.py` / `.sh`, migration helpers) MUST be deleted with `rm` as soon as they are no longer needed.
2. Leave the package free of leftover scratch files from agent runs.
