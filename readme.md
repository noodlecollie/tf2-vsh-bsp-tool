TF2 VSH BSP Tool
================

This tool can be used to update legacy TF2 VSH maps to use the [new VSH game mode](https://tf2maps.net/downloads/vs-saxton-hale-vscript.15067/) that operates using VScripts.

Credits go to the creators of the VSH mode (specifically LizardOfOz). This script doesn't do anything new in terms of the mode - it simply repackages it into maps.

## Requirements

You must have [Python 3](https://www.python.org/downloads/) installed on the system where you run this tool.

## Upgrading A Map

To upgrade a map using default settings, run:

```
python upgrade_legacy_vsh_bsp.py vsh_mymap.bsp
```

After the process is complete, `vsh_mymap_cu.bsp` will be output alongside the original map file. The default suffix `_cu` is for Community Update, referencing [the update](https://wiki.teamfortress.com/wiki/July_12,_2023_Patch) where maps using the new mode were officially made part of the game.

For more information on the parameters available to the script, run:

```
python upgrade_legacy_vsh_bsp.py --help
```

## Tweaking Game Mode Settings

The following setting switches may be provided to the script to customise aspects of the VSH mode on a per-map basis:

* `--setting-boss-scale`: Scale factor for Hale model size. (default: 1.2)
* `--setting-round-time`: How long each round should last for, in seconds. (default: 240)
* `--setting-jump-force`: Amount of force to apply when Hale double-jumps. (default: 700)
* `--setting-health-factor`: Scale factor for Hale's max health. (default: 40)
* `--setting-setup-length`: How many seconds of setup time before each round begins. (default: 16)
* `--setting-setup-lines`: Whether to play Hale voice lines during setup. (default: true)
* `--setting-beer-lines`: Whether to play beer-related Hale voice lines during setup. (default: false)
* `--setting-long-setup-lines`: Whether to play longer Hale voice lines during setup. (default: true)
* `--setting-setup-countdown-lines`: Whether to play Hale voice lines when the round timer is counting down during setup. (default: true)
* `--setting-spawn-protection`: Whether to apply damage reduction to attacks against Hale until a while after round start. (default: false)
* `--setting-ability-hud-folder`: Path under materials folder where HUD images are found. (default: vgui/vssaxtonhale/)
