# Laminar Fluent UI

A proper rewrite of the Fluent UI Library, including bug fixes and better code in general.

## Building

*If you don't want to read the documentation...*

1. Make sure you install [pesde](https://docs.pesde.dev/installation/) **exactly** how the [documentation describes here](https://docs.pesde.dev/installation/)
2. Make sure you install lune 0.8.9 (**not 0.9.\***) [from here](https://github.com/lune-org/lune/releases/tag/v0.8.9)
3. Run `pesde install` while `cd` in this (root) directory
   1. \[Optional\] Reload Luau Language Server (`CTRL + P` and search for it)
4. Run [build.bat](./scripts/build.bat)
5. Use the outputted file in project root > `dist.lua`
