--[[Author informations]]--
SWEP.Author = "Manix84"
SWEP.Contact = "https://steamcommunity.com/id/manix84"

AddCSLuaFile()

local isBuyable = CreateConVar("ttt_bomb_vest_buyable", 1, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Bomb Vest be buyable for Traitors?", 0, 1)
local isLoadout = CreateConVar("ttt_bomb_vest_loadout", 0, {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE, FCVAR_REPLICATED}, "Should the Bomb Vest be in the loadout for Traitors?", 0, 1)
local sound = CreateConVar("ttt_bomb_vest_countdown_sound", "weapons/ttt_bomb_vest/countdown.wav", {FCVAR_SERVER_CAN_EXECUTE, FCVAR_ARCHIVE}, "The sound when triggering the bomb vest.")
local countdownLength = CreateConVar("ttt_bomb_vest_countdown_length", 2.5, 1, "") 

resource.AddFile("materials/vgui/ttt/icon_bomb_vest.vmt")

resource.AddFile("sound/weapons/ttt_bomb_vest/explosion.wav")
resource.AddFile("sound/weapons/ttt_bomb_vest/countdown.wav")

if CLIENT then
  LANG.AddToLanguage("english", "bomb_vest_name", "Bomb Vest")
  LANG.AddToLanguage("english", "bomb_vest_desc", "Walk into a crowded room, click, 3-2-1-Boom.\n\nSingle use.")

  SWEP.PrintName = "bomb_vest_name"
  SWEP.Slot = 8
  SWEP.Icon = "vgui/ttt/icon_bomb_vest"

  -- Equipment menu information is only needed on the client
  SWEP.EquipMenuData = {
    type = "item_weapon",
    desc = "bomb_vest_desc"
  }
end

-- always derive from weapon_tttbase
SWEP.Base = "weapon_tttbase"

--[[Default GMod values]]--
SWEP.Primary.Ammo = "none"
SWEP.Primary.Delay = 4
SWEP.Primary.ClipSize = -1
SWEP.Primary.DefaultClip = -1
SWEP.Primary.Automatic = false

--[[UI settings]]--
SWEP.DrawCrosshair = false

--[[Model settings]]--
SWEP.HoldType = "slam"

SWEP.UseHands = true
SWEP.DrawAmmo = false
SWEP.ViewModelFlip = false
SWEP.ViewModelFOV = 60

SWEP.ViewModel  = "models/weapons/v_slam.mdl"
SWEP.WorldModel = "models/weapons/w_c4.mdl"

--[[TTT config values]]--

-- Kind specifies the category this weapon is in. Players can only carry one of
-- each. Can be: WEAPON_... MELEE, PISTOL, HEAVY, NADE, CARRY, EQUIP1, EQUIP2 or ROLE.
-- Matching SWEP.Slot values: 0      1       2     3      4      6       7        8
SWEP.Kind = WEAPON_ROLE

-- If AutoSpawnable is true and SWEP.Kind is not WEAPON_EQUIP1/2,
-- then this gun can be spawned as a random weapon.
SWEP.AutoSpawnable = false

if (isBuyable:GetBool()) then
  -- CanBuy is a table of ROLE_* entries like ROLE_TRAITOR and ROLE_DETECTIVE. If
  -- a role is in this table, those players can buy this.
  SWEP.CanBuy = { ROLE_TRAITOR }

  -- If LimitedStock is true, you can only buy one per round.
  SWEP.LimitedStock = true
end

if (isLoadout:GetBool()) then
  -- InLoadoutFor is a table of ROLE_* entries that specifies which roles should
  -- receive this weapon as soon as the round starts.
  SWEP.InLoadoutFor = { ROLE_TRAITOR }
end

-- If AllowDrop is false, players can't manually drop the gun with Q
SWEP.AllowDrop = true

-- If IsSilent is true, victims will not scream upon death.
SWEP.IsSilent = false

-- If NoSights is true, the weapon won't have ironsights
SWEP.NoSights = true

-- precache sounds and models
function SWEP:Precache()
  util.PrecacheSound("weapons/ttt_bomb_vest/countdown.wav")
  util.PrecacheSound("weapons/ttt_bomb_vest/explosion.wav")

  util.PrecacheModel("models/humans/charple01.mdl")
  util.PrecacheModel("models/humans/charple02.mdl")
  util.PrecacheModel("models/humans/charple03.mdl")
  util.PrecacheModel("models/humans/charple04.mdl")
end

function SWEP:Initialize()
  if (CLIENT and self:Clip1() == -1) then
    self:SetClip1(self.Primary.DefaultClip)
  elseif SERVER then
    self.fingerprints = {}
  end

  self:SetDeploySpeed(self.DeploySpeed)

  if (self.SetHoldType) then
    self:SetHoldType(self.HoldType or "pistol")
  end

  -- self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DRAW)

  self:SetNWBool("Exploding", false)
end

local function ScorchUnderRagdoll(ent)
  -- big scorch at center
  local mid = ent:LocalToWorld(ent:OBBCenter())
  mid.z = mid.z + 25
  util.PaintDown(mid, "Scorch", ent)
end

-- checks if the burn time is over, or if the body is in water
local function RunIgniteTimer(tname, body, burn_destroy)
  if (IsValid(body) and body:IsOnFire()) then
    if (CurTime() > burn_destroy) then
      body:SetNotSolid(true)
      body:Remove()
    elseif (body:WaterLevel() > 0) then
      body:Extinguish()
    end
  else
    timer.Remove(tname)
  end
end

-- burn the body of the user
local function BurnOwnersBody(model)
  local body
  -- Search for all ragdolls and the one with the given model
  for _, ragdoll in pairs(ents.FindByClass("prop_ragdoll")) do
    if (ragdoll:GetModel() == model) then
      body = ragdoll
    end
  end

  ScorchUnderRagdoll(body)

  if SERVER then
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

-- particle effects / begin attack
function SWEP:PrimaryAttack()
  self.Weapon:SendWeaponAnim(ACT_SLAM_DETONATOR_DETONATE)

  self:SetNextPrimaryFire(CurTime() + self.Primary.Delay)
  self.AllowDrop = false

  local effectdata = EffectData()
  effectdata:SetOrigin(self:GetPos())
  effectdata:SetNormal(self:GetPos())
  effectdata:SetMagnitude(8)
  effectdata:SetScale(1)
  effectdata:SetRadius(20)
  util.Effect("Sparks", effectdata)
  self.BaseClass.ShootEffects(self)

  -- The rest is only done on the server
  if SERVER then
    local owner = self:GetOwner()
    self:SetNWBool("Exploding", true)
    local explosionCountdownLength = 3 --2.05
    -- Only explode, if the code was completely typed in
    timer.Simple(explosionCountdownLength, function()
      if (
        IsValid(self) and
        IsValid(owner) and
        IsValid(owner:GetActiveWeapon()) and
        owner:GetActiveWeapon():GetClass() == self:GetClass()
      ) then
        self:Explode()
      end
    end)
    self:GetOwner():EmitSound(
      sound:GetString(),
      math.random(100, 150),
      math.random(95, 105),
      1,
      CHAN_VOICE
    )
  end
end

-- explosion properties
function SWEP:Explode()
  local pos = self:GetPos()
  local dmg = 200
  local dmgowner = self:GetOwner()

  local r_inner = 550
  local r_outer = r_inner * 1.15

  self:EmitSound(
    "weapons/ttt_bomb_vest/explosion.wav",
    400,
    math.random(100, 125),
    1,
    CHAN_WEAPON
  )

  -- change body to a random charred body
  local model = "models/humans/charple0" .. math.random(1,4) .. ".mdl"
  self:GetOwner():SetModel(model)

  -- damage through walls
  self:SphereDamage(dmgowner, pos, r_inner)

  -- explosion damage
  util.BlastDamage(self, dmgowner, pos, r_outer, dmg)

  local effect = EffectData()
  effect:SetStart(pos)
  effect:SetOrigin(pos)
  effect:SetScale(r_outer)
  effect:SetRadius(r_outer)
  effect:SetMagnitude(dmg)
  util.Effect("Explosion", effect, true, true)

  -- make sure the owner dies anyway
  if (SERVER and IsValid(dmgowner) and dmgowner:Alive()) then
    dmgowner:Kill()
  end

  BurnOwnersBody(model)
  self:Remove()
end

-- calculate who is affected by the damage
function SWEP:SphereDamage(dmgowner, center, radius)
  local r = radius ^ 2 -- square so we can compare with length directly

  local d = 0.0
  local diff = nil
  local dmg = 0
  for _, target_ply in pairs(player.GetAll()) do
    if (IsValid(target_ply) and target_ply:Team() == TEAM_TERROR) then
      -- get the squared length of the distance, so we don't have to calculate the square root
      diff = center - target_ply:GetPos()
      d = diff:LengthSqr()

      if d < r then
        -- deadly up to a certain range, then a falloff
        d = math.max(0, math.sqrt(d) - radius * 0.65)
        dmg = 125 + d * -1

        local dmginfo = DamageInfo()
        dmginfo:SetDamage(dmg)
        dmginfo:SetAttacker(dmgowner)
        dmginfo:SetInflictor(self)
        dmginfo:SetDamageType(DMG_BLAST)
        dmginfo:SetDamageForce(diff)
        dmginfo:SetDamagePosition(target_ply:GetPos())

        target_ply:TakeDamageInfo(dmginfo)
      end
    end
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

-- Secondary attack does nothing
function SWEP:SecondaryAttack()
end

-- Reload does nothing
function SWEP:Reload()
end
