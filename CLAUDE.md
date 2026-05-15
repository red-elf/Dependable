# CLAUDE.md — Dependable

This file provides guidance to Claude Code (claude.ai/code) when
working with code in this module.

## Helix Constitution inheritance

When this module is consumed inside a project that includes the
Helix Constitution as a git submodule
(https://github.com/HelixDevelopment/HelixConstitution), the rules
in `constitution/CLAUDE.md` and the `constitution/Constitution.md`
it references apply unconditionally. Use the constitution's
`find_constitution.sh` helper to locate it from any nested depth.

When this module is consumed standalone (no `constitution/`
submodule reachable in any parent), only the module-local notes
below apply.

This module stays fully decoupled and reusable per the Helix
Constitution's §11.4.28 (Submodules-As-Equal-Codebase + Decoupling
+ Dependency-Layout mandate). No project-specific context is
injected here.
