--[[Author informations]]--
SWEP.Author = "Manix84"
SWEP.Contact = "https://steamcommunity.com/id/manix84"

local isBuyable = CreateConVar("ttt_bomb_vest_buyable", 1, 1, "Should the Bomb Vest be buyable for Traitors?", 0, 1)
local isLoadout = CreateConVar("ttt_bomb_vest_loadout", 0, 1, "Should the Bomb Vest be in the loadout for Traitors?", 0, 1)
local preExplosionSound = CreateConVar("ttt_bomb_vest_pre_explosion_sound", "", 1, "Override path for the sound played before the bomb vest explodes. Leave blank to use ttt_bomb_vest_pre_explosion_sound_effect.")
local legacyCountdownSound = CreateConVar("ttt_bomb_vest_countdown_sound", "", 1, "Legacy override path for the sound played before the bomb vest explodes. Leave blank to use ttt_bomb_vest_pre_explosion_sound_effect.")
local preExplosionSoundEffect = CreateConVar("ttt_bomb_vest_pre_explosion_sound_effect", "leeroy_jenkins", 1, "Pre-explosion sound effect: random, dj_airhorn, kamehameha, leeroy_jenkins, mlg_airhorn, run_vine, shutup, this_is_sparta, or wtf_boom.")
local legacySoundEffect = CreateConVar("ttt_bomb_vest_sound_effect", "", 1, "Legacy pre-explosion sound effect. Leave blank to use ttt_bomb_vest_pre_explosion_sound_effect.")
local countdownLength = CreateConVar("ttt_bomb_vest_countdown_length", 2, 1, "How long, in seconds, after pulling the trigger before the bomb vest goes bang?")
local sparksEnabled = CreateConVar("ttt_bomb_vest_sparks", 1, 1, "Should sparks show when the detonator trigger is pressed?", 0, 1)
local rightHanded = CreateConVar("ttt_bomb_vest_right_handed", 1, 1, "Should the view model be right handed?", 0, 1)

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
  local soundPath = string.Trim(preExplosionSound:GetString())

  if soundPath ~= "" then
    return soundPath
  end

  soundPath = string.Trim(legacyCountdownSound:GetString())

  if soundPath ~= "" then
    return soundPath
  end

  local soundName = string.lower(string.Trim(preExplosionSoundEffect:GetString()))

  if soundName == "" then
    soundName = string.lower(string.Trim(legacySoundEffect:GetString()))
  end

  if soundName == "random" then
    soundName = RANDOM_COUNTDOWN_SOUNDS[math.random(#RANDOM_COUNTDOWN_SOUNDS)]
  end

  return COUNTDOWN_SOUNDS[soundName] or COUNTDOWN_SOUNDS.leeroy_jenkins
end

if SERVER then
  AddCSLuaFile()

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
SWEP.ViewModelFlip = rightHanded:GetBool()
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
  self:SetNWBool("RightHanded", rightHanded:GetBool())
end

function SWEP:Think()
  if CLIENT then
    self.ViewModelFlip = self:GetNWBool("RightHanded", rightHanded:GetBool())
  end
end

local RunBombVestExplosion

-- particle effects / begin attack
function SWEP:PrimaryAttack()
  local delay = math.max(0.5, countdownLength:GetFloat())
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
    self:SetNWBool("RightHanded", rightHanded:GetBool())

    timer.Simple(triggerDelay, function()
      if IsValid(self) then
        self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)

        if sparksEnabled:GetBool() then
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
  self:SetNWBool("RightHanded", rightHanded:GetBool())
  self.ViewModelFlip = rightHanded:GetBool()
end

function SWEP:Holster()
  self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_HOLSTER)
  return not self:GetNWBool("Exploding")
end
