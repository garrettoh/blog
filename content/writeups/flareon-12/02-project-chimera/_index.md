---
title: "02 - Project Chimera"
layout: "Notes"
overview: "Published draft: Python bytecode extraction, decompilation, and final ARC4 decryption."
status: "Draft complete"
---

## Overview

Project Chimera is a multi-stage encrypted Python challenge. Rather than trying to read the packed program directly, I extracted the staged contents into `.pyc` files and loaded them into [PyLingual](https://pylingual.io/) for a decompiled view.

## Stage one

The first decompiled stage decodes a Base64 payload, decompresses it with zlib, unmarshals the resulting Python code object, and executes it. That established the next stage of the challenge.

![PyLingual decompilation of stage one.](/images/flareon-12/02-project-chimera/stage_1_decomp.png)

## Stage two

The next `.pyc` exposed the important logic: it constructs a user signature, compares it with the lead-researcher signature, and uses the matching value as the ARC4 key for the encrypted formula.

![PyLingual decompilation of the second stage.](/images/flareon-12/02-project-chimera/stage_2_decomp.png)

## Final solve

I recreated the relevant checks in a small helper: derive the expected researcher identity, set it as the current user, rebuild the signature, and decrypt the formula with ARC4.

![The final helper mirrors the authentication and ARC4-decryption path.](/images/flareon-12/02-project-chimera/final_solve.py.png)

Running that path prints the final flag.

![Final Project Chimera output.](/images/flareon-12/02-project-chimera/flag.png)
