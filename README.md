# 🧨 [TTT] Bomb Vest
![Icon](https://raw.githubusercontent.com/manix84/ttt-bomb-vest/master/images/icon/ttt_bomb_vest_128x.png)

> Walk into a crowded room. Click... 3, 2, 1, Boom!

[![Deploy to Workshop](https://github.com/manix84/ttt-bomb-vest/actions/workflows/deploy.yml/badge.svg)](https://github.com/manix84/ttt-bomb-vest/actions/workflows/deploy.yml) [![Release](https://github.com/manix84/ttt-bomb-vest/actions/workflows/release.yml/badge.svg)](https://github.com/manix84/ttt-bomb-vest/actions/workflows/release.yml) 

There is always a server of friends who have realised that grouping together is the best way to survive a round of TTT. This weapon lets Traitors take advantage of that, and perhaps teach your friends that it is not safe to group up like that any more.

This is an alternative to the Jihad Bomb, which is incredibly popular in TTT. I wanted a version that fits better in mixed company, keeps the joke configurable, and gives servers more control over sounds, effects, and player preferences.

See [What's New](WHATSNEW.md) for recent changes and [Privacy](PRIVACY.md) for privacy details.

## ✨ Features
- No references to Jihad in any of the files or folder structures (except this one).
- Your Traitor body gets burned up.
- Uses the Slam Detonator as the trigger.
- Killing the bomber doesn't stop the explosion.
- Delayed trigger press and optional sparks before detonation.
- Configurable pre-explosion sound effects, including a random option.
- Right handed view model by default, with an optional left handed client preference.
- GMod admin panel for server settings.
- Explosion stats are sent to the bomber after detonation.
- LEEEEEEROOOY JEEEENKIIINSSS!!!

## 📦 Usage
Install with one of these methods:

|Method|Steps|
|------|-----|
|Steam Workshop|Open [[TTT] Bomb Vest](https://steamcommunity.com/sharedfiles/filedetails/?id=2166317811) and click `Subscribe`.|
|Manual install|Download the latest `ttt_bomb_vest-<version>.zip` from [GitHub Releases](https://github.com/manix84/ttt-bomb-vest/releases), extract it, and place the extracted `ttt_bomb_vest` folder in `garrysmod/addons`.|

After installation, the Bomb Vest is available for purchase in the Traitor Store 😊.

On Windows, the manual install path usually looks like:

```text
Steam\steamapps\common\GarrysMod\garrysmod\addons\ttt_bomb_vest
```

## ⚙️ Admin panel
Open `Utilities > TTT > Bomb Vest` in the GMod spawn menu.

All players can change:
- `Left handed view model` - local client preference only.

Admins can also change server settings:
- `Buyable for Traitors`
- `Traitor loadout`
- `Pre-explosion delay`
- `Sparks before detonation`
- `Pre-explosion sound effect`
- `Pre-explosion sound override`

Legacy sound cvars are not shown in the panel. If `ttt_bomb_vest_countdown_sound` or `ttt_bomb_vest_sound_effect` still contain old values, the addon migrates them into the new pre-explosion settings and clears the legacy cvars.

## 🧰 Variables

|Variable|Default|Scope|Description|
|--------|-------|-----|-----------|
|`ttt_bomb_vest_buyable`|1|Server|Should the Bomb Vest be buyable for Traitors? (1=Yes, 0=No)|
|`ttt_bomb_vest_loadout`|0|Server|Should the Bomb Vest be in the loadout for Traitors? (1=Yes, 0=No)|
|`ttt_bomb_vest_pre_explosion_sound_effect`|"leeroy_jenkins"|Server|The sound effect played before the vest explodes. Options: `random`, `dj_airhorn`, `kamehameha`, `leeroy_jenkins`, `mlg_airhorn`, `run_vine`, `shutup`, `this_is_sparta`, `wtf_boom`.|
|`ttt_bomb_vest_pre_explosion_sound`|""|Server|Sound path override for the pre-explosion sound. Leave blank to use `ttt_bomb_vest_pre_explosion_sound_effect`.|
|`ttt_bomb_vest_countdown_length`|2|Server|How long, in seconds, after pulling the trigger before the bomb vest goes bang?|
|`ttt_bomb_vest_sparks`|1|Server|Should sparks show when the detonator trigger is pressed? (1=Yes, 0=No)|
|`ttt_bomb_vest_left_handed`|0|Client|Should your view model be left handed? (1=Yes, 0=No)|

## 🛠️ Development

### 🔖 Versioning

The package version is tracked in `VERSION`. Version bumps are handled with:

```sh
./scripts/bump-version.sh auto
./scripts/bump-version.sh patch
./scripts/bump-version.sh minor
./scripts/bump-version.sh major
./scripts/bump-version.sh 1.2.3
```

Enable the pre-commit hook to bump `VERSION` automatically:

```sh
./scripts/setup-hooks.sh
```

The pre-commit hook defaults to a patch bump and skips bumping if `VERSION` is already ahead of `HEAD`. Set `VERSION_BUMP=major|minor|patch` before committing to force a specific bump. The `auto` and `prepush` modes use conventional commit messages to infer the bump: `feat:` for minor, `BREAKING CHANGE:` or `!` commits for major, and patch otherwise.

### 🧹 Linting

`glualint` is installed project-locally so it does not need to be available globally in `PATH`.

```sh
./scripts/glualint.sh
```

The wrapper downloads `FPtje/GLuaFixer` into `.tools/` on first run and then lints `shared.lua`. You can pass normal `glualint` commands through the wrapper:

```sh
./scripts/glualint.sh version
./scripts/glualint.sh lint gamemodes/terrortown/entities/weapons/ttt_bomb_vest/shared.lua
```

Point editor integrations at `scripts/glualint.sh` if they allow a custom executable path.

### 📦 Release packaging

GitHub Actions builds the installable package for pull requests. Merges into `main` publish a GitHub Release with the package attached.

## 🚀 Steam Workshop deployment
Merges into `main` publish a GitHub Release and deploy to Steam Workshop. Both workflows generate matching release notes from the current `VERSION` and recent git history: Markdown for GitHub Releases, and Steam Workshop BBCode for Workshop change notes.

The `Deploy to Steam Workshop` GitHub Actions workflow can also be run manually. It builds the addon with Garry's Mod's `gmad` tool, then uploads through SteamCMD's headless `workshop_build_item` command so a desktop Steam client is not required on the runner.

Required repository variable:
- `STEAM_USERNAME`

You can also provide `STEAM_USERNAME` as a repository secret if you prefer.

Authentication repository secrets:
- `STEAM_CONFIG_VDF_BASE64` - required. Base64-encoded SteamCMD `config/config.vdf` from a machine that has already completed Steam Guard.
- `STEAM_LOGINUSERS_VDF_BASE64` - required. Base64-encoded SteamCMD `config/loginusers.vdf` from the same machine.

To create the Steam auth secrets, log in once with SteamCMD on your own machine, approve the Steam Guard prompt, then make sure SteamCMD can log in again without asking for a password:

```sh
steamcmd +login manix84 +quit
```

If this prints `Cached credentials not found`, the local SteamCMD login did not create reusable cached credentials yet. Complete a successful interactive SteamCMD login before encoding the files.

Then base64 encode that SteamCMD install's auth files.

On macOS, copy `STEAM_CONFIG_VDF_BASE64`:

```sh
base64 -e "$HOME/Library/Application Support/Steam/config/config.vdf" | tr -d '\n' | pbcopy
```

Then copy `STEAM_LOGINUSERS_VDF_BASE64`:

```sh
base64 -e "$HOME/Library/Application Support/Steam/config/loginusers.vdf" | tr -d '\n' | pbcopy
```

Paste each copied value into the matching repository secret.

A Steam Web API key or game server login token is not enough for this Garry's Mod Workshop upload path. The workflow uses `gmpublish`, which authenticates through SteamCMD/Steam.

Optional repository variable:
- `STEAM_WORKSHOP_ITEM_ID` - defaults to `2166317811`.

Run the workflow from GitHub Actions and provide change notes when prompted.

## 📸 Screenshots
### 🛒 Traitor Store
![Traitor Store](https://i.imgur.com/rgHvHwI.jpg)
### 🕹️ Trigger in Hand
![Trigger in Hand](https://i.imgur.com/meTL2xy.jpg)
### 💥 Two victims
![Two Victims](https://i.imgur.com/Uej4x11.jpg)
### ▶️ See it in action (On YouTube)
[![See it in action (On YouTube)](https://i.imgur.com/0K6A4Ak.png)](https://youtu.be/N4mpn7iXM74)
