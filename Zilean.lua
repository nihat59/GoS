--[[ Rx Zilean Version 0.576
     Ver 0.576: Fix somethings
     Go to http://gamingonsteroids.com   To Download more script. 
------------------------------------------------------------------------------------]]
require('Inspired')
require('OpenPredict')
PrintChat("<font color='#FFFFFF'>Credits to </font><font color='#54FF9F'>Deftsu, Inspired </font>")

class "RxZilean"
function RxZilean:__init()
---- Create Menu ----
Zilean = MenuConfig("Zilean", "Zilean")
tslowhp = TargetSelector(myHero:GetSpellData(_Q).range, 8, DAMAGE_MAGIC)

-- [[ Combo ]] --
Zilean:Menu("cb", "Zilean Combo")
Zilean.cb:Boolean("QCB", "Use Q", true)
Zilean.cb:Boolean("WCB", "Use W", true)
Zilean.cb:Boolean("ECB", "Use E", true)
Zilean.cb:Info("infoE", "If MyTeam >= EnemyTeam then E target lowest HP")
Zilean.cb:Info("infoE", "If MyTeam < EnemyTeam then E ally or myHero near mouse, move your mouse >3")
Zilean.cb:Info("infoE", "If not AllyAround my Hero then Use E in myHero")

-- [[ Harass ]] --
Zilean:Menu("hr", "Harass")
Zilean.hr:Slider("HrMana", "Harass if %MP >= ", 15, 1, 100, 1)
Zilean.hr:Boolean("HrQ", "Use Q", true)

-- [[ LaneJungleClear ]] --
Zilean:Menu("ljc", "LaneJungle Clear")
Zilean.ljc:Boolean("LJcQ", "Use Q", true)
Zilean.ljc:Slider("checkMP", "Enable if %MP >= ", 15, 1, 100, 1)

-- [[ Auto Spell ]] --
Zilean:Menu("AtSpell", "Auto Spell")
Zilean.AtSpell:Boolean("ASEb", "Enable Auto Spell", true)
Zilean.AtSpell:Slider("ASMP", "Auto Spell if %MP >=", 15, 1, 100, 1)
Zilean.AtSpell:SubMenu("ATSQ", "Auto Spell Q")
Zilean.AtSpell.ATSQ:Boolean("ASQ", "Auto stun", true)
Zilean.AtSpell.ATSQ:Info("info1", "Auto Q if can stun enemy")
Zilean.AtSpell.ATSQ:Info("info2", "Q to enemy have a bomb")
Zilean.AtSpell:SubMenu("ATSE", "Auto Spell E")
Zilean.AtSpell.ATSE:Boolean("ASE", "Auto E for Run", true)
Zilean.AtSpell.ATSE:Key("KeyE", "Running! (T)", string.byte("T"))
Zilean.AtSpell.ATSE:Info("info3", "This is a Mode 'RUNNING!'")
PermaShow(Zilean.AtSpell.ATSQ.ASQ)
PermaShow(Zilean.AtSpell.ATSE.KeyE)

-- [[ Drawings ]] --
Zilean:Menu("Draws", "Drawings")
Zilean.Draws:Boolean("DrawsEb", "Enable Drawings", true)
Zilean.Draws:Slider("QualiDraw", "Quality Drawings", 50, 1, 100, 1)
Zilean.Draws:Boolean("DrawQR", "Range Q + R", true)
Zilean.Draws:ColorPick("QRcol", "Q + R Color", {135, 244, 245, 120})
Zilean.Draws:Boolean("DrawE", "Range E", true)
Zilean.Draws:ColorPick("Ecol", "E Color", {220, 155, 48, 255})
Zilean.Draws:Boolean("DrawText", "Draw Text", true)
Zilean.Draws:Info("infoR", "Draw Text If Allies in 2500 Range and %HP Allies <= 20%")

-- [[ KillSteal ]] --
Zilean:Menu("KS", "Kill Steal")
Zilean.KS:Boolean("KSEb", "Enable KillSteal", true)
Zilean.KS:Boolean("QKS", "KS with Q", true)
Zilean.KS:Boolean("IgniteKS", "KS with IgniteKS", true)

---- Misc Menu ----
Zilean:Menu("Misc", "Misc Mode")
Zilean.Misc:Menu("AutoR", "Auto Use R")
Zilean.Misc.AutoR:Boolean("EnbR", "Enable Auto R", true)
PermaShow(Zilean.Misc.AutoR.EnbR)
Zilean.Misc.AutoR:Slider("myHP", "If %MyHP < x%", 15, 1, 100, 1)
Zilean.Misc.AutoR:Boolean("DrawR", "Draw xHP to R (x-x%)", true)
Zilean.Misc.AutoR:Info("DRInfo", "It will draw hp from x%HP, if MyHP <= HP then auto R")
Zilean.Misc.AutoR:Info("DRInfo2", "You muse enable AutoR and draw HP to see this")
Zilean.Misc:Menu("AutoLvlUp", "Auto Level Up")
Zilean.Misc.AutoLvlUp:Boolean("UpSpellEb", "Enable Auto Lvl Up", true)
Zilean.Misc.AutoLvlUp:DropDown("AutoSkillUp", "Settings", 1, {"Q-W-E", "Q-E-W"})
Zilean.Misc:Menu("Interrupt", "Q-Q to Stop Spell enemy")
Zilean.Misc.Interrupt:Info("InfoQ", "If you don't see any ON/OFF => No enemy can Interrupt.")
Zilean.Misc:Slider("Qhc", "Q Hit-Chance", 2, 1, 10, 0.5)
Callback.Add("Tick", function(myHero) self:Fight(myHero) end)
Callback.Add("Draw", function(myHero) self:Draws(myHero) end)
Callback.Add("ProcessSpell", function(unit, spell) self:AutoQQ(unit, spell) end)
Callback.Add("UpdateBuff", function(o, buff) self:UpdateBuff(o, buff) end)
Callback.Add("RemoveBuff", function(o, buff) self:RemoveBuff(o, buff) end)
end
--- [[ Location ]] ---
local ANTI_SPELLS = {
    ["CaitlynAceintheHole"]         = {Name = "Caitlyn",      Spellslot = _R},
    ["KatarinaR"]                   = {Name = "Katarina",     Spellslot = _R},
    ["Crowstorm"]                   = {Name = "FiddleSticks", Spellslot = _R},
    ["GalioIdolOfDurand"]           = {Name = "Galio",        Spellslot = _R},
    ["LucianR"]                     = {Name = "Lucian",       Spellslot = _R},
    ["MissFortuneBulletTime"]       = {Name = "MissFortune",  Spellslot = _R},
    ["AbsoluteZero"]                = {Name = "Nunu",         Spellslot = _R}, 
    ["ShenStandUnited"]             = {Name = "Shen",         Spellslot = _R},
    ["KarthusFallenOne"]            = {Name = "Karthus",      Spellslot = _R},
    ["AlZaharNetherGrasp"]          = {Name = "Malzahar",     Spellslot = _R},
    ["Pantheon_GrandSkyfall_Jump"]  = {Name = "Pantheon",     Spellslot = _R},
    ["InfiniteDuress"]              = {Name = "Warwick",      Spellslot = _R}, 
    ["EzrealTrueshotBarrage"]       = {Name = "Ezreal",       Spellslot = _R}, 
    ["TahmKenchR"]                  = {Name = "TahmKench",    Spellslot = _R}, 
    ["VelKozR"]                     = {Name = "VelKoz",       Spellslot = _R}, 
    ["XerathR"]                     = {Name = "Xerath",       Spellslot = _R} 
}
local QDmg, QRange, ERange, CanR, text = {75, 115, 165, 230, 300}, myHero:GetSpellData(_Q).range, myHero:GetSpellData(_E).range, false
local Ignite = (GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))

local function ZileanQ(unit)
 return { delay = 0, speed = math.min(GetDistance(unit.pos)/0.445,2000), radius = 80, range = QRange }
end

local function CheckQ(unit)
 return GotBuff(unit, "zileanqenemybomb") > 0
end

local function CheckE(unit)
 return GotBuff(unit, "TimeWarp") < 1
end

local function CheckR(unit)
 return GotBuff(unit, "karthusfallenonetarget") > 0
end

local function IsInRange(unit, range)
    return unit.visible == true and unit.alive and IsInDistance(unit, range)
end

local function KarthusDmg(unit)
 for i, enemy in pairs(GetEnemyHeroes()) do
  if enemy ~= nil and enemy.charName == "Karthus" then
   return enemy:CalcMagicDamage(unit, myHero:GetSpellData(_R).level*150 + 100 + 0.6*enemy.ap)
  else
   return 0
  end
 end
end

function RxZilean:Fight(myHero)
 if IOW:Mode() == "Combo" then
  self:Combo()
 elseif IOW:Mode() == "Harass" then
  self:Harass()
 elseif IOW:Mode() == "LaneClear" then
  self:LaneJungleClear()
 end
 if Zilean.KS.KSEb:Value() then self:KillSteal() end
 if Zilean.AtSpell.ASEb:Value() then self:AutoSpell() end
 if Zilean.Misc.AutoLvlUp.UpSpellEb:Value() then self:LevelUp() end
 if Zilean.Misc.AutoR.EnbR:Value() then self:AutoR() end	  
end

function RxZilean:CastW()
local target = tslowhp:GetTarget()
 if target and IsInRange(target, QRange) then
  myHero:Cast(_W)
 end
end

function RxZilean:CastQ(target)
local target = tslowhp:GetTarget()
 if target and IsInRange(target, QRange) then
  local QPred = GetCircularAOEPrediction(target, ZileanQ(target))
  if QPred.hitChance >= Zilean.Misc.Qhc:Value()/10 then
   myHero:Cast(_Q, QPred.castPos)
  end
 end
end

function RxZilean:Combo()
 if IsReady(_Q) and Zilean.cb.QCB:Value() then
    self:CastQ()
 end
 
 if IsReady(_W) and Zilean.cb.WCB:Value() and GetCurrentMana(myHero) >= 90 + 5*myHero:GetSpellData(_Q).level and not IsReady(_Q) then
    self:CastW()
 end
 
 if IsReady(_E) and Zilean.cb.ECB:Value() then
    self:CastECb()
 end
end

function RxZilean:AutoR()
 if CountObjectsNearPos(myHero.pos, 1000, 1000, GetEnemyHeroes(), MINION_ENEMY) > 0 and GetPercentHP(myHero) <= Zilean.Misc.AutoR.myHP:Value() then myHero:Cast(_R, myHero) end
 if CanR and KarthusDmg(myHero) > myHero.health + myHero.shieldAD + myHero.shieldAP then myHero:Cast(_R, myHero) end
end

function RxZilean:CastECb()
local target = tslowhp:GetTarget()
local unit = GetCurrentTarget()
 for i, enemy in pairs(GetEnemyHeroes()) do
  if target and IsInDistance(enemy, ERange) then 
   for l, ally in pairs(GetAllyHeroes()) do
   local Al = AlliesAround(myHero.pos, ERange)
   local Enm = EnemiesAround(myHero.pos, ERange)
   local ali = ClosestAlly(GetMousePos())
    if Al > 0 and 1 + Al >= Enm and GotBuff(target, "Stun") < 1 then
     myHero:Cast(_E, target)
    elseif Al > 0 and Al < Enm then
	 if IsInDistance(ally, ERange) then
      if GetDistance(ali, GetMousePos()) <= 160 and GetDistance(ali, GetMousePos()) < GetDistance(myHero.pos, GetMousePos()) and CheckE(ali) then
       myHero:Cast(_E, ali)
      else
       if CheckE(myHero) and GetDistance(myHero.pos, GetMousePos()) <= 160 then myHero:Cast(_E, myHero) end
      end
     end
    elseif Al < 1 and IsInDistance(unit, ERange) and CheckE(myHero) and not IsInDistance(unit, 880) then
     myHero:Cast(_E, myHero)
    end
   end
  end
 end
end

function RxZilean:KillSteal()
 for i, enemy in pairs(GetEnemyHeroes()) do
  if Ignite and Zilean.KS.IgniteKS:Value() then
   if IsReady(Ignite) and 20*GetLevel(myHero)+50 >= enemy.health+enemy.shieldAD + enemy.hpRegen*2.5 and IsInRange(enemy, 600) then
	myHero:Cast(Ignite, enemy)
   end
  end

  if IsReady(_Q) and Zilean.KS.QKS:Value() and enemy.health + enemy.shieldAD + enemy.shieldAP < myHero:CalcMagicDamage(enemy, 0.9*myHero.ap + QDmg[myHero:GetSpellData(_Q).level]) and IsInRange(enemy, QRange) then
   local QPred = GetCircularAOEPrediction(enemy, ZileanQ(enemy))
   if QPred.hitChance >= 0.2 then myHero:Cast(_Q, QPred.castPos) end
   if IsReady(_W) and GetCurrentMana(myHero) >= 145 + 5*myHero:GetSpellData(_Q).level and not IsReady(_Q) then myHero:Cast(_W) end
  end
 end
end

function RxZilean:AutoQ(enemy)
 for i, enemy in pairs(GetEnemyHeroes()) do
  if IsReady(_Q) and GetPercentMP(myHero) >= Zilean.AtSpell.ASMP:Value() and Zilean.AtSpell.ATSQ.ASQ:Value() and GotBuff(myHero, "recall") < 1 and IsInRange(enemy, QRange) and CheckQ(enemy) then
   local QPred = GetCircularAOEPrediction(enemy, ZileanQ(enemy))
   if QPred.hitChance >= 1 then
    myHero:Cast(_Q, QPred.castPos)
   end
  end
 end
end
 
function RxZilean:AutoE()
 if IsReady(_E) and GetPercentMP(myHero) >= Zilean.AtSpell.ASMP:Value() and Zilean.AtSpell.ATSE.ASE:Value() and Zilean.AtSpell.ATSE.KeyE:Value() and GotBuff(myHero, "recall") < 1 and CheckE(myHero) then myHero:Cast(_E, myHero) end
  if Zilean.AtSpell.ATSE.KeyE:Value() then MoveToXYZ(GetMousePos()) end
end

function RxZilean:Harass()
 if IsReady(_Q) and Zilean.hr.HrQ:Value() then
    self:CastQ()
 end
end

function RxZilean:LaneJungleClear()
 for _, minimobs in pairs(minionManager.objects) do
  if minimobs.team == MINION_ENEMY or minimobs.team == MINION_JUNGLE then
   if minimobs.health > 0 and IsInRange(minimobs, 900) and IsReady(_Q) and Zilean.ljc.LJcQ:Value() then
    local QPred = GetCircularAOEPrediction(minimobs, ZileanQ(minimobs))
    if QPred.hitChance >= 0.1 then myHero:Cast(_Q, QPred.castPos) end
   end
  end
 end
end

function RxZilean:AutoSpell()
 self:AutoQ()
 self:AutoE()
 end
 
function RxZilean:LevelUp()
 if Zilean.Misc.AutoLvlUp.AutoSkillUp:Value() == 1 then leveltable = {_Q, _W, _E, _Q, _Q , _R, _Q , _Q, _W , _W, _R, _W, _W, _E, _E, _R, _E, _E} -- Full Q First then W
  elseif Zilean.Misc.AutoLvlUp.AutoSkillUp:Value() == 2 then leveltable = {_Q, _W, _E, _Q, _Q , _R, _Q , _Q, _E , _E, _R, _E, _E, _W, _W, _R, _W, _W} -- Full Q First then E
 end
   LevelSpell(leveltable[GetLevel(myHero)])
end

-------------------------------------------

function RxZilean:Draws(myHero)
 if Zilean.Draws.DrawsEb:Value() then

   self:Range()
   self:DmgHPBar()
  if Zilean.Draws.DrawText:Value() then
   self:DrawHP()
   self:InfoR()
   self:DrawRHP()
  end
  
 end
end

function RxZilean:Range()
local pos = myHero.pos
 if IsReady(_Q) or IsReady(_R) then
  if Zilean.Draws.DrawQR:Value() then DrawCircle3D(pos.x, pos.y, pos.z, QRange, 1, Zilean.Draws.QRcol:Value(), Zilean.Draws.QualiDraw:Value()) end
 end
 if Zilean.Draws.DrawE:Value() and IsReady(_E) then DrawCircle3D(pos.x, pos.y, pos.z, ERange, 1, Zilean.Draws.Ecol:Value(), Zilean.Draws.QualiDraw:Value()) end
end

function RxZilean:DrawHP()
local per = '%'
 for l, ally in pairs(GetAllyHeroes()) do
  if IsInRange(ally, 4000) then	
  local pos = WorldToScreen(1, ally.pos)
   if myHero:GetSpellData(_R).level > 0 then
    local color = GetPercentHP(ally) > 20 and GoS.White or GoS.Red
    if CheckR(ally) and KarthusDmg(ally) > ally.health + ally.shieldAD + ally.shieldAP then
     DrawText("This Unit can die with Karthus R", 22, alliesPos.x, alliesPos.y+12, GoS.Red)
    end
     DrawText(string.format("%s HP: %d / %d | %sHP = %d%s", ally.charName, math.ceil(ally.health), math.ceil(ally.maxHealth), per, math.max(1, GetPercentHP(ally)), per), 18, pos.x, pos.y, color)
   end
  end	
 end

  if myHero.alive and myHero:GetSpellData(_R).level > 0 then
   local pos = WorldToScreen(1, myHero.pos)
   if GetPercentHP(myHero) <= 20 then DrawText(string.format("%sHP = %d%s CAREFUL!", per, math.max(1, GetPercentHP(myHero)), per), 21, pos.x-20, pos.y+16, GoS.Red) end
  end
end

function RxZilean:InfoR()
local text = ""
 for l, ally in pairs(GetAllyHeroes()) do
  if IsInRange(ally, 2500) and GetPercentHP(ally) < 20 and EnemiesAround(ally.pos, 1000) > 0 then
    text = text..ally.charName.." %HP < 20%. Should Use R\n"
  end
 end
   DrawText(text, 27, 0, 110, GoS.Green)
end

function RxZilean:DrawRHP()
 if myHero.alive and IsReady(_R) and Zilean.Misc.AutoR.DrawR:Value() and Zilean.Misc.AutoR.EnbR:Value() then
  local pos = WorldToScreen(1, myHero.pos)
  DrawText(string.format("AutoR if HP < %d | %s%s", myHero.maxHealth*Zilean.Misc.AutoR.myHP:Value()/100, Zilean.Misc.AutoR.myHP:Value(), '%'), 20, pos.x-20, pos.y, GoS.White)
 end
end

function RxZilean:DmgHPBar()
 for i, enemy in pairs(GetEnemyHeroes()) do
  if IsInRange(enemy, 3000) then
   if IsReady(_Q) or CheckQ(enemy) then
    DrawDmgOverHpBar(enemy, enemy.health, 0, myHero:CalcMagicDamage(enemy, 0.9*myHero.ap + QDmg[myHero:GetSpellData(_Q).level]), GoS.Green)
   else
    DrawDmgOverHpBar(enemy, enemy.health, myHero.damage, 0, GoS.Green)
   end
  end
 end
end

DelayAction(function()
local str = {[_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
 for i, spell in pairs(ANTI_SPELLS) do
  for _,k in pairs(GetEnemyHeroes()) do
   if spell["Name"] == k.charName then
    Zilean.Misc.Interrupt:Boolean(k.charName.."Inter", "On "..k.charName.." "..(type(spell.Spellslot) == 'number' and str[spell.Spellslot]), true)
   end
  end
 end
end, 1)

function RxZilean:AutoQQ(unit, spell)
 if unit.type == Obj_AI_Hero and unit.team ~= myHero.team and myHero.mana >= 145 + 5*myHero:GetSpellData(_Q).level then
  if IsReady(_Q) or CheckQ(unit) then
   if IsReady(_W) or CheckQ(unit) then
    if ANTI_SPELLS[spell.name] then
     if IsInRange(unit, QRange) and unit.charName == ANTI_SPELLS[spell.name].Name and Zilean.Misc.Interrupt[unit.charName.."Inter"]:Value() then 
     local QPred = GetCircularAOEPrediction(unit, ZileanQ(unit))
      if QPred.hitChance >= 0.2 then myHero:Cast(_Q, QPred.castPos) end
      if IsReady(_W) and not IsReady(_Q) then
       myHero:Cast(_W)
      end
     end
    end
   end
  end
 end
end

function RxZilean:UpdateBuff(o, buff)
 if buff.Name == "karthusfallenonetarget" and o == myHero then
  CanR = true
 end
end

function RxZilean:RemoveBuff(o, buff)
 if buff.Name == "karthusfallenonetarget" and o == myHero then
  CanR = false
 end
end

PrintChat("<font color='#FFFF00'>RxZilean Version 0.576 Loaded Success</font>")
PrintChat(string.format("<font color='#08F7F3'>Enjoy and Good Luck %s (%s)</font>", GetUser(), myHero.name))
if myHero.charName == "Zilean" then RxZilean() end
