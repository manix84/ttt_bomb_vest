# 🧨 What's New

Recent changes for `[TTT] Bomb Vest`.

## 🚀 1.4.18

- Added automatic GitHub Release publishing when changes merge into `main`.
- Added automatic Steam Workshop deployment from GitHub Actions using SteamCMD's headless `workshop_build_item` upload path.
- Added shared release-note generation so GitHub Releases use Markdown and Steam Workshop change notes use Steam BBCode.
- Added a tagged GitHub release link to the bottom of Steam Workshop change notes.
- Limited automatic releases and deployments to packaged addon file changes, so docs, workflow, script, and version-only updates do not deploy.
- Improved SteamCMD deployment validation, cached credential setup documentation, and upload failure detection.

## 🚀 0.1.4

- Added configurable pre-explosion sound effects, including a random option.
- Added optional sparks before detonation.
- Added a local left handed view model preference.
- Added a GMod admin panel under `Utilities > TTT > Bomb Vest`.
- Added post-explosion stats for the bomber.
- Added automatic migration from legacy sound cvars to the new pre-explosion settings.
- Trimmed bundled pre-explosion audio clips to keep them short.
- Added GitHub Actions packaging, Steam Workshop deployment, smart version bumping, and project-local `glualint`.

## 🗃️ Legacy

- The Bomb Vest can be bought by Traitors.
- The bomber's body burns after detonation.
- Killing the bomber does not stop an armed vest from exploding.
- Uses the Slam Detonator view model.
