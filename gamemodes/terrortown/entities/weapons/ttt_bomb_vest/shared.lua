--[[Author informations]]--
SWEP.Author = "Manix84"
SWEP.Contact = "https://steamcommunity.com/id/manix84"

local isBuyable = CreateConVar("ttt_bomb_vest_buyable", 1, 1, "Should the Bomb Vest be buyable for Traitors?", 0, 1)
local isLoadout = CreateConVar("ttt_bomb_vest_loadout", 0, 1, "Should the Bomb Vest be in the loadout for Traitors?", 0, 1)
local countdownSound = CreateConVar("ttt_bomb_vest_countdown_sound", "weapons/bomb_vest/countdown.wav", 1, "The sound when triggering the bomb vest.")
local countdownLength = CreateConVar("ttt_bomb_vest_countdown_length", 2, 1, "How long, in seconds, after pulling the trigger before the bomb vest goes bang?") 

if SERVER then
  AddCSLuaFile()

  resource.AddFile("materials/VGUI/ttt/icon_bomb_vest.vmt")
  resource.AddFile("sound/weapons/bomb_vest/explosion.wav")
  resource.AddFile("sound/weapons/bomb_vest/countdown.wav")
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

function SWEP:Reload()
  return false
end

function SWEP:Initialize()
  self:SetHoldType(self.HoldType)

  util.PrecacheSound("weapons/bomb_vest/countdown.wav")
  util.PrecacheSound("weapons/bomb_vest/explosion.wav")

  util.PrecacheModel("models/humans/charple01.mdl")
  util.PrecacheModel("models/humans/charple02.mdl")
  util.PrecacheModel("models/humans/charple03.mdl")
  util.PrecacheModel("models/humans/charple04.mdl")

  self:SetNWBool("Exploding", false)
end


-- particle effects / begin attack
function SWEP:PrimaryAttack()
  self:SetNextPrimaryFire(CurTime() + countdownLength:GetInt())
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

    timer.Simple(countdownLength:GetInt() - 1, function()
      self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)
      util.Effect("Sparks", effectdata)
      timer.Simple(1, function()
        self:Explode()
      end)
    end)
    self:GetOwner():EmitSound(
      countdownSound:GetString(),
      math.random(100, 150),
      math.random(90, 105),
      1,
      CHAN_VOICE
    )
  end
end

-- explosion properties
function SWEP:Explode()
  self.AllowDrop = false

  local dmg_owner = self:GetOwner()
  local dmg = 200
  local pos = self:GetPos()

  local r_inr = 550
  local r_otr = r_inr * 1.15
  local corpse_model = "models/Humans/Charple0" .. math.random(1,4) .. ".mdl"

  self:EmitSound(
    "weapons/bomb_vest/explosion.wav",
    400,
    math.random(100, 125),
    1,
    CHAN_WEAPON
  )

  if (self:GetOwner():IsValid()) then
    dmg_owner:SetModel(corpse_model)
    print('dmg_owner pre-kill:', dmg_owner)
  end

  print('dmg_owner:', dmg_owner)

  -- damage through walls
  self:SphereDamage(dmg_owner, pos, r_inr)

  -- explosion damage
  util.BlastDamage(self, dmg_owner:IsValid() and dmg_owner or self, pos, r_otr, dmg)
  

  local effect = EffectData()
  effect:SetStart(pos)
  effect:SetOrigin(pos)
  effect:SetScale(r_otr)
  effect:SetRadius(r_otr)
  effect:SetMagnitude(dmg)
  util.Effect("Explosion", effect, true, true)

  -- make sure the owner dies anyway
  if (SERVER and IsValid(dmgowner) and dmgowner:Alive()) then
    dmgowner:Kill()
  end

  self:BurnCorps(corpse_model, dmg_owner)
  self:Remove()
end

function SWEP:SphereDamage(dmg_owner, center, radius)
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
        dmginfo:SetAttacker(dmg_owner:IsValid() and dmg_owner or self)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageType(DMG_BLAST)
        dmginfo:SetDamageForce(diff)
        dmginfo:SetDamagePosition(target_ply:GetPos())

        target_ply:TakeDamageInfo(dmginfo)
      end
    end
  end
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
end

function SWEP:Holster()
  self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_HOLSTER)
  return not self:GetNWBool("Exploding")
end