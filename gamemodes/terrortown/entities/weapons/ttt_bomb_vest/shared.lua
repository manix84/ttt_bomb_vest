--[[Author informations]]--
SWEP.Author = "Manix84"
SWEP.Contact = "https://steamcommunity.com/id/manix84"

TTTBombVest = TTTBombVest or {}

local addon = TTTBombVest

addon.AdminRequestMessage = "TTTBombVest_AdminRequest"
addon.AdminStatusMessage = "TTTBombVest_AdminStatus"

addon.ServerConVars = addon.ServerConVars or {
  buyable = { name = "ttt_bomb_vest_buyable", default = "1", kind = "bool", help = "Should the Bomb Vest be buyable for Traitors?" },
  loadout = { name = "ttt_bomb_vest_loadout", default = "0", kind = "bool", help = "Should the Bomb Vest be in the loadout for Traitors?" },
  pre_explosion_sound = { name = "ttt_bomb_vest_pre_explosion_sound", default = "", kind = "string", help = "Override path for the sound played before the bomb vest explodes. Leave blank to use ttt_bomb_vest_pre_explosion_sound_effect." },
  countdown_sound = { name = "ttt_bomb_vest_countdown_sound", default = "", kind = "string", legacy = true, help = "Legacy override path for the sound played before the bomb vest explodes." },
  pre_explosion_sound_effect = { name = "ttt_bomb_vest_pre_explosion_sound_effect", default = "leeroy_jenkins", kind = "choice", help = "Pre-explosion sound effect: random, dj_airhorn, kamehameha, leeroy_jenkins, mlg_airhorn, run_vine, shutup, this_is_sparta, or wtf_boom." },
  sound_effect = { name = "ttt_bomb_vest_sound_effect", default = "", kind = "choice", legacy = true, help = "Legacy pre-explosion sound effect." },
  countdown_length = { name = "ttt_bomb_vest_countdown_length", default = "2", kind = "number", min = 0.5, max = 10, decimals = 1, help = "How long, in seconds, after pulling the trigger before the bomb vest goes bang?" },
  sparks = { name = "ttt_bomb_vest_sparks", default = "1", kind = "bool", help = "Should sparks show when the detonator trigger is pressed?" }
}

addon.ClientConVars = addon.ClientConVars or {
  right_handed = { name = "ttt_bomb_vest_right_handed", default = "1", kind = "bool", help = "Should your Bomb Vest view model be right handed?" }
}

local SOUND_EFFECT_CHOICES = {
  random = true,
  dj_airhorn = true,
  kamehameha = true,
  leeroy_jenkins = true,
  leroy_jenkins = true,
  mlg_airhorn = true,
  run_vine = true,
  ["run-vine"] = true,
  shutup = true,
  this_is_sparta = true,
  wtf_boom = true
}

local function conVarFlags()
  if bit and FCVAR_ARCHIVE and FCVAR_REPLICATED and FCVAR_NOTIFY then
    return bit.bor(FCVAR_ARCHIVE, FCVAR_REPLICATED, FCVAR_NOTIFY)
  end

  return 1
end

if SERVER then
  local flags = conVarFlags()

  for _, data in pairs(addon.ServerConVars) do
    if not GetConVar(data.name) then
      CreateConVar(data.name, data.default, flags, data.help)
    end
  end
end

if CLIENT then
  for _, data in pairs(addon.ClientConVars) do
    if not GetConVar(data.name) then
      CreateClientConVar(data.name, data.default, true, false, data.help)
    end
  end
end

local function getConVarString(data)
  local convar = data and GetConVar(data.name)

  if convar then return convar:GetString() end

  return data and data.default or ""
end

local function getServerString(key)
  return getConVarString(addon.ServerConVars[key])
end

local function getServerBool(key)
  local convar = GetConVar(addon.ServerConVars[key].name)

  if convar then return convar:GetBool() end

  return addon.ServerConVars[key].default == "1"
end

local function getServerNumber(key)
  local data = addon.ServerConVars[key]
  local convar = GetConVar(data.name)
  local value = convar and convar:GetFloat() or tonumber(data.default) or 0

  if data.min then value = math.max(data.min, value) end
  if data.max then value = math.min(data.max, value) end

  return value
end

local function getRightHanded()
  local data = addon.ClientConVars.right_handed
  local convar = GetConVar(data.name)

  if convar then return convar:GetBool() end

  return data.default == "1"
end

local normaliseServerValue

local function migrateLegacyConVars()
  if not SERVER then return end

  local preExplosionSoundValue = string.Trim(getServerString("pre_explosion_sound"))
  local legacyCountdownSoundValue = string.Trim(getServerString("countdown_sound"))

  if preExplosionSoundValue == "" and legacyCountdownSoundValue ~= "" then
    RunConsoleCommand(addon.ServerConVars.pre_explosion_sound.name, legacyCountdownSoundValue)
  end

  if legacyCountdownSoundValue ~= "" then
    RunConsoleCommand(addon.ServerConVars.countdown_sound.name, "")
  end

  local preExplosionSoundEffectValue = string.Trim(getServerString("pre_explosion_sound_effect"))
  local legacySoundEffectValue = string.Trim(getServerString("sound_effect"))

  if (preExplosionSoundEffectValue == "" or preExplosionSoundEffectValue == addon.ServerConVars.pre_explosion_sound_effect.default) and legacySoundEffectValue ~= "" then
    RunConsoleCommand(addon.ServerConVars.pre_explosion_sound_effect.name, normaliseServerValue("pre_explosion_sound_effect", legacySoundEffectValue))
  end

  if legacySoundEffectValue ~= "" then
    RunConsoleCommand(addon.ServerConVars.sound_effect.name, "")
  end
end

local COUNTDOWN_SOUNDS = {
  dj_airhorn = "weapons/bomb_vest/countdown/dj_airhorn.mp3",
  kamehameha = "weapons/bomb_vest/countdown/kamehameha.mp3",
  leeroy_jenkins = "weapons/bomb_vest/countdown/leroy_jenkins.mp3",
  leroy_jenkins = "weapons/bomb_vest/countdown/leroy_jenkins.mp3",
  mlg_airhorn = "weapons/bomb_vest/countdown/mlg_airhorn.mp3",
  run_vine = "weapons/bomb_vest/countdown/run-vine.mp3",
  ["run-vine"] = "weapons/bomb_vest/countdown/run-vine.mp3",
  shutup = "weapons/bomb_vest/countdown/shutup.mp3",
  this_is_sparta = "weapons/bomb_vest/countdown/this_is_sparta.mp3",
  wtf_boom = "weapons/bomb_vest/countdown/wtf_boom.mp3"
}

local RANDOM_COUNTDOWN_SOUNDS = {
  "dj_airhorn",
  "kamehameha",
  "leeroy_jenkins",
  "mlg_airhorn",
  "run_vine",
  "shutup",
  "this_is_sparta",
  "wtf_boom"
}

local function GetPreExplosionSound()
  local soundPath = string.Trim(getServerString("pre_explosion_sound"))

  if soundPath ~= "" then
    return soundPath
  end

  soundPath = string.Trim(getServerString("countdown_sound"))

  if soundPath ~= "" then
    return soundPath
  end

  local soundName = string.lower(string.Trim(getServerString("pre_explosion_sound_effect")))

  if soundName == "" then
    soundName = string.lower(string.Trim(getServerString("sound_effect")))
  end

  if soundName == "random" then
    soundName = RANDOM_COUNTDOWN_SOUNDS[math.random(#RANDOM_COUNTDOWN_SOUNDS)]
  end

  return COUNTDOWN_SOUNDS[soundName] or COUNTDOWN_SOUNDS.leeroy_jenkins
end

if SERVER then
  AddCSLuaFile()
  util.AddNetworkString(addon.AdminRequestMessage)
  util.AddNetworkString(addon.AdminStatusMessage)

  resource.AddFile("materials/VGUI/ttt/icon_bomb_vest.vmt")
  resource.AddFile("sound/weapons/bomb_vest/explosion.wav")
  resource.AddFile("sound/weapons/bomb_vest/countdown.wav")
  resource.AddFile("sound/weapons/bomb_vest/countdown/dj_airhorn.mp3")
  resource.AddFile("sound/weapons/bomb_vest/countdown/kamehameha.mp3")
  resource.AddFile("sound/weapons/bomb_vest/countdown/leroy_jenkins.mp3")
  resource.AddFile("sound/weapons/bomb_vest/countdown/mlg_airhorn.mp3")
  resource.AddFile("sound/weapons/bomb_vest/countdown/run-vine.mp3")
  resource.AddFile("sound/weapons/bomb_vest/countdown/shutup.mp3")
  resource.AddFile("sound/weapons/bomb_vest/countdown/this_is_sparta.mp3")
  resource.AddFile("sound/weapons/bomb_vest/countdown/wtf_boom.mp3")
end

if CLIENT then
  SWEP.PrintName = "Bomb Vest"
  SWEP.Slot = 8
  SWEP.Icon = "VGUI/ttt/icon_bomb_vest"
end

-- SWEP STUFF
-- always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"
SWEP.HoldType = "slam"
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 3
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false
SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.DrawCrosshair = false
SWEP.ViewModelFlip = true
SWEP.ViewModelFOV = 54
SWEP.ViewModel = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

-- TTT CONFIGURATION
SWEP.Kind = WEAPON_ROLE
SWEP.AutoSpawnable = false
SWEP.CanBuy = { ROLE_TRAITOR }
SWEP.InLoadoutFor = { nil }
SWEP.LimitedStock = true
SWEP.AllowDrop = false
SWEP.IsSilent = false
SWEP.NoSights = true


if CLIENT then
  -- Equipment menu information is only needed on the client
  SWEP.EquipMenuData = {
    name = "Bomb Vest",
    type = "item_weapon",
    desc = "Walk into a crowded room, click, 3-2-1-Boom.\n\nSingle use."
  }
end

local function refreshTTTConfig()
  SWEP.CanBuy = getServerBool("buyable") and { ROLE_TRAITOR } or {}
  SWEP.InLoadoutFor = getServerBool("loadout") and { ROLE_TRAITOR } or { nil }
end

refreshTTTConfig()

local function isAdmin(ply)
  if not IsValid(ply) then return true end

  return ply:IsAdmin() or ply:IsSuperAdmin()
end

normaliseServerValue = function(key, raw)
  local data = addon.ServerConVars[key]
  if not data then return nil end

  if data.kind == "bool" then
    return tostring(raw) == "1" and "1" or "0"
  end

  if data.kind == "number" then
    local value = tonumber(raw) or tonumber(data.default) or 0
    if data.min then value = math.max(data.min, value) end
    if data.max then value = math.min(data.max, value) end

    if data.decimals and data.decimals > 0 then
      local multiplier = 10 ^ data.decimals
      value = math.Round(value * multiplier) / multiplier
    else
      value = math.Round(value)
    end

    return tostring(value)
  end

  if data.kind == "choice" then
    local value = string.lower(string.Trim(tostring(raw or data.default)))
    if value == "" and data.legacy then return "" end

    return SOUND_EFFECT_CHOICES[value] and value or data.default
  end

  return string.Trim(tostring(raw or data.default))
end

if SERVER then
  timer.Simple(0, migrateLegacyConVars)

  local function setServerConVar(key, raw)
    local data = addon.ServerConVars[key]
    local value = normaliseServerValue(key, raw)

    if not data or value == nil then return false end

    RunConsoleCommand(data.name, value)

    if key == "buyable" or key == "loadout" then
      refreshTTTConfig()
    end

    return true
  end

  local function resetServerConVars()
    for key, data in pairs(addon.ServerConVars) do
      setServerConVar(key, data.default)
    end
  end

  local function sendAdminStatus(ply)
    local values = {}

    for key, data in pairs(addon.ServerConVars) do
      values[key] = getConVarString(data)
    end

    net.Start(addon.AdminStatusMessage)
    net.WriteString(util.TableToJSON(values, false) or "{}")

    if IsValid(ply) then
      net.Send(ply)
    end
  end

  net.Receive(addon.AdminRequestMessage, function(_, ply)
    local action = net.ReadString()

    if action == "status" then
      sendAdminStatus(ply)
      return
    end

    if not isAdmin(ply) then
      sendAdminStatus(ply)
      return
    end

    if action == "set" then
      setServerConVar(net.ReadString(), net.ReadString())
    elseif action == "reset" then
      resetServerConVars()
    end

    sendAdminStatus(ply)
  end)
end

if CLIENT then
  addon.AdminValues = addon.AdminValues or {}

  local soundEffectLabels = {
    { "Random", "random" },
    { "DJ Airhorn", "dj_airhorn" },
    { "Kamehameha", "kamehameha" },
    { "Leeroy Jenkins", "leeroy_jenkins" },
    { "MLG Airhorn", "mlg_airhorn" },
    { "Run Vine", "run_vine" },
    { "Shutup", "shutup" },
    { "This is Sparta", "this_is_sparta" },
    { "WTF Boom", "wtf_boom" }
  }

  local function requestStatus()
    net.Start(addon.AdminRequestMessage)
    net.WriteString("status")
    net.SendToServer()
  end

  local function sendSet(key, value)
    net.Start(addon.AdminRequestMessage)
    net.WriteString("set")
    net.WriteString(key)
    net.WriteString(tostring(value))
    net.SendToServer()
  end

  local function addServerCheck(panel, key, label, tooltip)
    local data = addon.ServerConVars[key]
    local row = vgui.Create("DCheckBoxLabel")
    row:SetText(label)
    row:SetValue((addon.AdminValues[key] or getConVarString(data)) == "1" and 1 or 0)
    row:SetDark(true)
    row:SetTooltip(tooltip or data.help)
    row:DockMargin(0, 4, 0, 4)
    row.OnChange = function(_, checked)
      sendSet(key, checked and "1" or "0")
    end

    panel:AddItem(row)
  end

  local function addServerSlider(panel, key, label, tooltip)
    local data = addon.ServerConVars[key]
    local slider = vgui.Create("DNumSlider")
    slider:SetText(label)
    slider:SetMin(data.min or 0)
    slider:SetMax(data.max or 10)
    slider:SetDecimals(data.decimals or 0)
    slider:SetValue(tonumber(addon.AdminValues[key] or getConVarString(data)) or tonumber(data.default) or 0)
    slider:SetTooltip(tooltip or data.help)
    slider:DockMargin(0, 4, 0, 4)
    slider.OnValueChanged = function(_, value)
      sendSet(key, tostring(value))
    end

    panel:AddItem(slider)
  end

  local function addServerText(panel, key, label, tooltip)
    local data = addon.ServerConVars[key]

    local textLabel = vgui.Create("DLabel")
    textLabel:SetText(label)
    textLabel:SetDark(true)
    textLabel:SetTooltip(tooltip or data.help)
    panel:AddItem(textLabel)

    local entry = vgui.Create("DTextEntry")
    entry:SetText(addon.AdminValues[key] or getConVarString(data))
    entry:SetUpdateOnType(false)
    entry:SetTooltip(tooltip or data.help)
    entry.OnEnter = function(self)
      sendSet(key, self:GetValue())
    end
    entry.OnLoseFocus = function(self)
      sendSet(key, self:GetValue())
    end

    panel:AddItem(entry)
  end

  local function addServerSoundDropdown(panel, key, label, tooltip)
    local data = addon.ServerConVars[key]

    local textLabel = vgui.Create("DLabel")
    textLabel:SetText(label)
    textLabel:SetDark(true)
    textLabel:SetTooltip(tooltip or data.help)
    panel:AddItem(textLabel)

    local combo = vgui.Create("DComboBox")
    combo:SetSortItems(false)
    combo:SetTooltip(tooltip or data.help)

    local selected = addon.AdminValues[key] or getConVarString(data)
    if selected == "" then selected = data.default end

    for _, item in ipairs(soundEffectLabels) do
      combo:AddChoice(item[1], item[2], item[2] == selected)
    end

    combo.OnSelect = function(_, _, _, value)
      sendSet(key, value)
    end

    panel:AddItem(combo)
  end

  local function addClientCheck(panel, data, label, tooltip)
    local row = vgui.Create("DCheckBoxLabel")
    row:SetText(label)
    row:SetConVar(data.name)
    row:SetDark(true)
    row:SetTooltip(tooltip or data.help)
    row:DockMargin(0, 4, 0, 4)
    panel:AddItem(row)
  end

  local function buildPanel(panel)
    panel:ClearControls()
    panel:Help("Bomb Vest")

    addClientCheck(panel, addon.ClientConVars.right_handed, "Right handed view model", "Changes only your own Bomb Vest view model.")

    if not isAdmin(LocalPlayer()) then
      panel:Help("Server settings are available to admins.")
      return
    end

    panel:Help("Server Settings")
    panel:Help("These settings are server-authoritative and apply to all players.")

    addServerCheck(panel, "buyable", "Buyable for Traitors", "Show Bomb Vest in the Traitor equipment shop.")
    addServerCheck(panel, "loadout", "Traitor loadout", "Give Bomb Vest to Traitors in their round loadout.")
    addServerSlider(panel, "countdown_length", "Pre-explosion delay", "Seconds between arming the vest and exploding.")
    addServerCheck(panel, "sparks", "Sparks before detonation", "Show sparks when the detonator trigger is pressed.")
    addServerSoundDropdown(panel, "pre_explosion_sound_effect", "Pre-explosion sound effect", "Named sound effect played before the vest explodes.")
    addServerText(panel, "pre_explosion_sound", "Pre-explosion sound override", "Optional raw sound path. Leave blank to use the selected sound effect.")

    local reset = vgui.Create("DButton")
    reset:SetText("Reset server settings to defaults")
    reset:SetTooltip("Restore every Bomb Vest server setting to its default value.")
    reset.DoClick = function()
      net.Start(addon.AdminRequestMessage)
      net.WriteString("reset")
      net.SendToServer()
    end
    panel:AddItem(reset)

    requestStatus()
  end

  hook.Add("PopulateToolMenu", "TTTBombVest_AdminPanel", function()
    spawnmenu.AddToolMenuOption("Utilities", "TTT", "TTTBombVest", "Bomb Vest", "", "", buildPanel)
  end)

  net.Receive(addon.AdminStatusMessage, function()
    addon.AdminValues = util.JSONToTable(net.ReadString() or "{}") or {}
  end)
end

function SWEP:Reload()
  return false
end

function SWEP:Initialize()
  self:SetHoldType(self.HoldType)

  util.PrecacheSound("weapons/bomb_vest/countdown.wav")
  util.PrecacheSound("weapons/bomb_vest/explosion.wav")

  for _, soundPath in pairs(COUNTDOWN_SOUNDS) do
    util.PrecacheSound(soundPath)
  end

  util.PrecacheModel("models/humans/charple01.mdl")
  util.PrecacheModel("models/humans/charple02.mdl")
  util.PrecacheModel("models/humans/charple03.mdl")
  util.PrecacheModel("models/humans/charple04.mdl")

  self:SetNWBool("Exploding", false)
end

function SWEP:Think()
  if CLIENT then
    self.ViewModelFlip = getRightHanded()
  end
end

local RunBombVestExplosion

-- particle effects / begin attack
function SWEP:PrimaryAttack()
  local delay = getServerNumber("countdown_length")
  local triggerDelay = math.max(0, delay - 0.5)
  local owner = self:GetOwner()
  local armedPos = IsValid(owner) and owner:GetPos() or self:GetPos()
  self:SetNextPrimaryFire(CurTime() + delay)
  self.AllowDrop = false

  local effectdata = EffectData()
  effectdata:SetOrigin(self:GetPos())
  effectdata:SetNormal(self:GetPos())
  effectdata:SetMagnitude(10)
  effectdata:SetScale(1)
  effectdata:SetRadius(20)

  self.BaseClass.ShootEffects(self)

  -- The rest is only done on the server
  if SERVER then
    self:SetNWBool("Exploding", true)

    timer.Simple(triggerDelay, function()
      if IsValid(self) then
        self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)

        if getServerBool("sparks") then
          util.Effect("Sparks", effectdata)
        end
      end

      timer.Simple(0.5, function()
        if IsValid(self) then
          self:Explode()
          return
        end

        RunBombVestExplosion(self, owner, IsValid(owner) and owner:GetPos() or armedPos)
      end)
    end)
    if IsValid(owner) then
      owner:EmitSound(
        GetPreExplosionSound(),
        math.random(100, 150),
        math.random(90, 105),
        1,
        CHAN_VOICE
      )
    end
  end
end

local function FormatPlayerList(players)
  local count = #players

  if count == 0 then
    return ""
  elseif count == 1 then
    return players[1]
  elseif count == 2 then
    return players[1] .. " and " .. players[2]
  end

  return table.concat(players, ", ", 1, count - 1) .. ", and " .. players[count]
end

local function FormatStatLine(count, singular, plural, players)
  if count == 1 then
    return "1 " .. singular .. " (" .. FormatPlayerList(players) .. ")"
  end

  return count .. " " .. plural .. " (" .. FormatPlayerList(players) .. ")"
end

local function CollectExplosionTargets(owner, center, radius)
  local targets = {}
  local radiusSqr = radius ^ 2

  for _, targetPly in pairs(player.GetAll()) do
    if IsValid(targetPly) and targetPly ~= owner and targetPly:Team() == TEAM_TERROR and targetPly:Alive() then
      local diff = center - targetPly:GetPos()

      if diff:LengthSqr() < radiusSqr then
        targets[targetPly] = targetPly:Health()
      end
    end
  end

  return targets
end

function SWEP:CollectExplosionTargets(owner, center, radius)
  return CollectExplosionTargets(owner, center, radius)
end

local function MessageExplosionStats(owner, targets)
  if not IsValid(owner) then return end

  local killed = {}
  local injured = {}

  for targetPly, startingHealth in pairs(targets) do
    if IsValid(targetPly) then
      if not targetPly:Alive() then
        table.insert(killed, targetPly:Nick())
      elseif targetPly:Health() < startingHealth then
        table.insert(injured, targetPly:Nick())
      end
    else
      table.insert(killed, "Unknown")
    end
  end

  table.sort(killed)
  table.sort(injured)

  if #killed == 0 and #injured == 0 then
    owner:ChatPrint("Your bomb vest exploded, but nobody else was caught in the blast.")
    return
  end

  local parts = {}

  if #killed > 0 then
    table.insert(parts, "killed " .. FormatStatLine(#killed, "person", "people", killed))
  end

  if #injured > 0 then
    table.insert(parts, "injured " .. FormatStatLine(#injured, "person", "people", injured))
  end

  owner:ChatPrint("Your bomb vest " .. table.concat(parts, " and ") .. ".")
end

function SWEP:MessageExplosionStats(owner, targets)
  MessageExplosionStats(owner, targets)
end

local function ApplySphereDamage(inflictor, attacker, center, radius)
  local r = radius ^ 2

  local d = 0.0
  local diff = nil
  local dmg = 0

  for _, target_ply in pairs(player.GetAll()) do

    if (IsValid(target_ply) and target_ply:Team() == TEAM_TERROR) then
      diff = center - target_ply:GetPos()
      d = diff:LengthSqr()

      if d < r then
        d = math.max(0, math.sqrt(d) - radius * 0.65)
        dmg = 125 + d * -1

        local dmginfo = DamageInfo()
        dmginfo:SetDamage(dmg)
        dmginfo:SetAttacker(IsValid(attacker) and attacker or inflictor)
        dmginfo:SetInflictor(inflictor)
        dmginfo:SetDamageType(DMG_BLAST)
        dmginfo:SetDamageForce(diff)
        dmginfo:SetDamagePosition(target_ply:GetPos())

        target_ply:TakeDamageInfo(dmginfo)
      end
    end
  end
end

function RunBombVestExplosion(weapon, dmg_owner, pos)
  local dmg = 200
  local inflictor = IsValid(weapon) and weapon or game.GetWorld()
  local attacker = IsValid(dmg_owner) and dmg_owner or inflictor

  local r_inr = 550
  local r_otr = r_inr * 1.15
  local corpse_model = "models/Humans/Charple0" .. math.random(1,4) .. ".mdl"
  local explosionTargets = CollectExplosionTargets(dmg_owner, pos, r_otr)

  if IsValid(weapon) then
    weapon:EmitSound(
      "weapons/bomb_vest/explosion.wav",
      400,
      math.random(100, 125),
      1,
      CHAN_WEAPON
    )
  else
    sound.Play("weapons/bomb_vest/explosion.wav", pos, 400, math.random(100, 125), 1)
  end

  if (IsValid(dmg_owner)) then
    dmg_owner:SetModel(corpse_model)
  end

  -- damage through walls
  ApplySphereDamage(inflictor, dmg_owner, pos, r_inr)

  -- explosion damage
  util.BlastDamage(inflictor, attacker, pos, r_otr, dmg)

  local effect = EffectData()
  effect:SetStart(pos)
  effect:SetOrigin(pos)
  effect:SetScale(r_otr)
  effect:SetRadius(r_otr)
  effect:SetMagnitude(dmg)
  util.Effect("Explosion", effect, true, true)

  -- make sure the owner dies anyway
  if (SERVER and IsValid(dmg_owner) and dmg_owner:Alive()) then
    dmg_owner:Kill()
  end

  MessageExplosionStats(dmg_owner, explosionTargets)

  if IsValid(weapon) then
    weapon:BurnCorps(corpse_model, dmg_owner)
    weapon:Remove()
  end
end

-- explosion properties
function SWEP:Explode()
  self.AllowDrop = false

  local dmg_owner = self:GetOwner()
  local pos = IsValid(dmg_owner) and dmg_owner:GetPos() or self:GetPos()

  RunBombVestExplosion(self, dmg_owner, pos)
end

function SWEP:SphereDamage(dmg_owner, center, radius)
  ApplySphereDamage(self, dmg_owner, center, radius)
end

function SWEP:BurnCorps(model, dmg_owner)
  local body
  -- Search for all ragdolls and the one with the given model
  for _, ragdoll in pairs(ents.FindByClass("prop_ragdoll")) do
    if (ragdoll:GetModel() == model) then
      body = ragdoll
    end
  end

  if (SERVER and IsValid(body)) then
    local burn_time = 7.5
    local burn_destroy = CurTime() + burn_time
    local tname = "burn_bomb_vest"
    timer.Simple(0.01, function()
      if (IsValid(body)) then
        body:Ignite(burn_time, 100)
      end
    end)
    timer.Create(tname, 0.1, math.ceil(1 + burn_time / 0.1), function ()
      RunIgniteTimer(tname, body, burn_destroy)
    end)
  end
end

function SWEP:Deploy()
  self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)
  self:SetNWBool("Exploding", false)
  self.ViewModelFlip = getRightHanded()
end

function SWEP:Holster()
  self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_HOLSTER)
  return not self:GetNWBool("Exploding")
end
