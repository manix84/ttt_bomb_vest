# Contributing

Thanks for helping improve `[TTT] Bomb Vest`.

## Scope

Good contributions for this addon include:

- Bug fixes for Bomb Vest gameplay, configuration, or TTT integration.
- Small compatibility improvements for Garry's Mod or TTT.
- Sound/configuration improvements that keep server owners in control.
- Documentation updates that help installation, configuration, or deployment.

Large feature changes are best discussed in an issue first so they fit the addon and do not surprise server owners.

## Development

Run the GLua linter before opening a pull request:

```sh
./scripts/glualint.sh
```

For changes that affect release packaging or Steam Workshop deployment, check the relevant GitHub Actions workflow and keep generated addon payloads limited to:

- `addon.json`
- `gamemodes/**`
- `materials/**`
- `sound/**`

## Pull Requests

Please include:

- A short summary of the change.
- How you tested it, including any local GMod/TTT checks.
- Any new or changed ConVars.

Documentation-only, version-only, script, and workflow-only changes do not trigger automatic release or Steam Workshop deployment.
