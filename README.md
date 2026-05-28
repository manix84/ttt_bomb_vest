# [TTT] Bomb Vest
![Icon](https://raw.githubusercontent.com/manix84/ttt_bomb_vest/master/images/icon/ttt_bomb_vest_128x.png)

> Walk into a crowded room. Click... 3, 2, 1, Boom!

There is always a server of friends who have realised that grouping together is the best way to survive a round of TTT. This weapon allows the traitors to take advantage of that, and perhaps teach your friends that it's not safe to group up like that any more.

This is an alternative to the Jihad Bomb, which is incredibly popular in TTT. I'm really not comfortable with the name, the description, of the sound effect from this add-on, and I struggled to find an alternative for my after work gaming sessions.

## Features
- No references to Jihad in any of the files or folder structures (except this one).
- Your Traitor body get's burned up.
- Using the Slam Detonator as the trigger.
- Killing the bomber doesn't stop the explosion.
- Delayed trigger press and optional sparks before detonation.
- Configurable pre-explosion sound effects, including a random option.
- Configurable left or right handed view model.
- GMod admin panel for server settings.
- Explosion stats are sent to the bomber after detonation.
- LEEEEEEROOOY JEEEENKIIINSSS!!!

## Usage
1. Install the Addon (preferably with the Steam Workshop)
    1. Goto "[TTT] Bomb Vest" on the [Steam Workshop](https://steamcommunity.com/sharedfiles/filedetails/?id=2166317811)
    2. Click "Subscribe"
    - OR
    1. Download the latest `ttt_bomb_vest-<version>.zip` package from [GitHub Releases](https://github.com/manix84/ttt_bomb_vest/releases).
    2. Extract `ttt_bomb_vest-<version>.zip`.
    3. Place the extracted `ttt_bomb_vest` folder in `garrysmod/addons` (`Steam\steamapps\common\GarrysMod\garrysmod\addons\ttt_bomb_vest`).
2. It's now available for purchase in the Traitor Store 😊.

## Versioning
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

GitHub Actions builds the installable package for pull requests and pushes. Pushing a `v*` tag publishes a GitHub Release with the package attached.

## Steam Workshop deployment
The `Deploy to Steam Workshop` GitHub Actions workflow manually deploys the addon to Steam Workshop using Garry's Mod's `gmad` and `gmpublish` tools.

Required repository secret:
- `STEAM_USERNAME`

Authentication repository secrets:
- `STEAM_CONFIG_VDF_BASE64` - recommended. Base64-encoded SteamCMD `config/config.vdf` from a machine that has already completed Steam Guard.
- `STEAM_PASSWORD` - fallback when no SteamCMD config token is available.

A Steam Web API key or game server login token is not enough for this Garry's Mod Workshop upload path. The workflow uses `gmpublish`, which authenticates through SteamCMD/Steam.

Optional repository variable:
- `STEAM_WORKSHOP_ITEM_ID` - defaults to `2166317811`.

Run the workflow from GitHub Actions and provide change notes when prompted.

## Admin panel
Open `Utilities > TTT > Bomb Vest` in the GMod spawn menu.

All players can change:
- `Right handed view model` - local client preference only.

Admins can also change server settings:
- `Buyable for Traitors`
- `Traitor loadout`
- `Pre-explosion delay`
- `Sparks before detonation`
- `Pre-explosion sound effect`
- `Pre-explosion sound override`

Legacy sound cvars are not shown in the panel. If `ttt_bomb_vest_countdown_sound` or `ttt_bomb_vest_sound_effect` still contain old values, the addon migrates them into the new pre-explosion settings and clears the legacy cvars.

## Variables

|Variable|Default|Description|
|--------|-------|-----------|
|`ttt_bomb_vest_buyable`|1|Should the Bomb Vest be buyable for Traitors? (1=Yes, 0=No)
|`ttt_bomb_vest_loadout`|0|Should the Bomb Vest be in the loadout for Traitors? (1=Yes, 0=No)
|`ttt_bomb_vest_pre_explosion_sound_effect`|"leeroy_jenkins"|The sound effect played before the vest explodes. Options: `random`, `dj_airhorn`, `kamehameha`, `leeroy_jenkins`, `mlg_airhorn`, `run_vine`, `shutup`, `this_is_sparta`, `wtf_boom`.|
|`ttt_bomb_vest_pre_explosion_sound`|""|Sound path override for the pre-explosion sound. Leave blank to use `ttt_bomb_vest_pre_explosion_sound_effect`.|
|`ttt_bomb_vest_countdown_length`|2|How long, in seconds, after pulling the trigger before the bomb vest goes bang?|
|`ttt_bomb_vest_sparks`|1|Should sparks show when the detonator trigger is pressed? (1=Yes, 0=No)|
|`ttt_bomb_vest_right_handed`|1|Client-side preference. Should your view model be right handed? (1=Yes, 0=No)|

## Screenshots
### Traitor Store
![Traitor Store](https://i.imgur.com/rgHvHwI.jpg)
### Trigger in Hand
![Trigger in Hand](https://i.imgur.com/meTL2xy.jpg)
### Two victims
![Two Victims](https://i.imgur.com/Uej4x11.jpg)
### See it in action (On YouTube)
[![See it in action (On YouTube)](https://i.imgur.com/0K6A4Ak.png)](https://youtu.be/N4mpn7iXM74)
