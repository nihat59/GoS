local SLAIO,Stage = 0.02,"Jani"

local SLSChamps = {	
	["Ahri"] = true,
}

local SLPatchnew = nil
local spawn = nil
local Spell = {}
local str3 = {[0]="Q",[1]="W",[2]="E",[3]="R"}
local IPred= false
local OpenPredict = false
local SLM = {}
local SLM2 = {}
local lastcheck = 0
local structures = {}
local turrets = {}
local Wards = {}
local Wards2 = {}
local target = nil
local ts = nil
if GetGameVersion():sub(3,4) >= "10" then
		SLPatchnew = GetGameVersion():sub(1,4)
	else
		SLPatchnew = GetGameVersion():sub(1,3)
end
local AutoUpdater = true

require 'DamageLib'
if SLSChamps[myHero.charName] then
	require 'IPrediction'	
	IPred = true
end

local function PredMenu(m,sp)
	if not m["CP"] then m:DropDown("CP", "Choose Prediction", 1 ,{"OPred", "GPred", "IPred", "GoSPred"}) end
	m:DropDown("h"..str3[sp], "Hitchance"..str3[sp], 2, {"Low", "Medium", "High"})
	if m.CP:Value() == 2 then
		require 'GPrediction'
	elseif m.CP:Value() == 1 then
		require 'OpenPredict'
		OpenPredict = true
	end
end

local function GetValue(m,sp)
	if not m["CP"] or not m["h"..str3[sp]] then return end
	if m.CP:Value() == 5 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 2
		end
	elseif m.CP:Value() == 4 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 2
		end
	elseif m.CP:Value() == 3 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 2
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 3
		end
	elseif m.CP:Value() == 2 then
		if m["h"..str3[sp]]:Value() == 1 then
			return 1
		elseif m["h"..str3[sp]]:Value() == 2 then
			return 2
		elseif m["h"..str3[sp]]:Value() == 3 then
			return 3
		end
	elseif m.CP:Value() == 1 then
		if m["h"..str3[sp]]:Value() == 1 then
			return .2
		elseif m["h"..str3[sp]]:Value() == 2 then
			return .45
		elseif m["h"..str3[sp]]:Value() == 3 then
			return .7
		end
	end
end

local function GetCollision(m,sp,t)
	if not m["CP"] or not m["h"..str3[sp]] then return end
	if m.CP:Value() == 5 then
		return t.col or false
	elseif m.CP:Value() == 4 then
		return t.col or false
	elseif m.CP:Value() == 4 then
		return t.col or false
	elseif m.CP:Value() == 3 then
		return t.col or false
	elseif m.CP:Value() == 2 then
		if t.col then
			return {"minion","champion"}
		else
			return nil
		end
	elseif m.CP:Value() == 1 then
		return t.col or false
	end
end

local function GetType(m,sp,t)
	if not m["CP"] or not m["h"..str3[sp]] then return end
	if m.CP:Value() == 3 then
		if t.type == "line" then
			return "linear"
		else
			return "circular"
		end
	else
		return t.type or "circular"
	end
end

local function CastGenericSkillShot(s,u,t,sp,m)--source,unit,table,spell,menu	
	if not m["CP"] or not m["h"..str3[sp]] then return end
	t.width = t.width or t.radius
	t.radius = t.width or t.radius
	t.col = GetCollision(m,sp,t)
	t.name = t.name or GetCastName(s,sp)
	t.count = t.count or 1
	t.angle = t.angle or 45
	t.delay = t.delay or 0.250
	t.speed = t.speed or math.huge
	t.range = t.range or 1000
	t.type = GetType(m,sp,t)
	t.aoe = t.aoe or false
	if m.CP:Value() == 1 then	
		if t.col then
			if t.type:lower():find("lin") then
				local Pred = GetPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and not Pred:mCollision(t.count) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("cir") then
				local Pred = GetCircularAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and not Pred:mCollision(t.count) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("con") then
				local Pred = GetConicAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and not Pred:mCollision(t.count) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			end
		else
			if t.type:lower():find("lin") then
				local Pred = GetPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("cir") then
				local Pred = GetCircularAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			elseif t.type:lower():find("con") then
				local Pred = GetConicAOEPrediction(u, t)
				if Pred.hitChance >= GetValue(m,sp) and GetDistance(s,Pred.castPos) < t.range then
					CastSkillShot(sp,Pred.castPos)
				end
			end
		end
	elseif m.CP:Value() == 2 then
		local Pred = _G.gPred:GetPrediction(u,s,t,t.aoe,t.col)
		if Pred.HitChance >= GetValue(m,sp) then
			CastSkillShot(sp,Pred.CastPosition)
		end
	elseif m.CP:Value() == 3 then
		local Predicted = IPrediction.Prediction({name=t.name, range=t.range, speed=t.speed, delay=t.delay, width=t.width, type=t.type, collision=t.col, collisionM=t.col, collisionH=t.col})
		local hit, pos = Predicted:Predict(u,s)
			if hit >= GetValue(m,sp) then
				CastSkillShot(sp, pos)
          end
	elseif m.CP:Value() == 4 then
		local Pred = GetPredictionForPlayer(s.pos,u,u.ms, t.speed, t.delay*1000, t.range, t.width, t.col, true)
		if Pred.HitChance == GetValue(m,sp) and GetDistance(s,Pred.PredPos) < t.range then
			CastSkillShot(sp, Pred.PredPos)
		end
	elseif m.CP:Value() == 5 then
		local SLhc,SLpos = SLP:Predict({source=s,unit=u,speed=t.speed,range=t.range,delay=t.delay,width=t.width,type=t.type,collision=t.col})
		if SLhc and SLhc+.1 >= GetValue(m,sp) and SLpos then
			CastSkillShot(sp,SLpos)
		end
	end
end


local ta = {_G.HoldPosition, _G.AttackUnit}
local function DisableHoldPosition(boolean)
	if boolean then
		_G.HoldPosition, _G.AttackUnit = function() end, function() end
	else
		_G.HoldPosition, _G.AttackUnit = ta[1], ta[2]
	end
end

local tabl = {_G.AttackUnit}
local function DisableAttacks(boolean)
	if boolean then
		 _G.AttackUnit = function() end
	else
		_G.AttackUnit = tabl[1]
	end
end

local function AllyMinionsAround(pos, range)
	local c = 0
	if pos == nil then return 0 end
	for k,v in pairs(SLM2) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == myHero.team then
			c = c + 1
		end
	end
	return c
end

local function CircleSegment(x,y,radius,sAngle,eAngle,color)
    for a = sAngle,eAngle do
        DrawLine(x,y,x+radius*math.cos(a*math.pi/180),y+radius*math.sin(a*math.pi/180),5,color)
    end
end

local function CircleSegment2(x,y,sRadius,eRadius,sAngle,eAngle,color)
    for a = sAngle,eAngle do
        DrawLine(x+sRadius*math.cos(a*math.pi/180),y+sRadius*math.sin(a*math.pi/180),x+eRadius*math.cos(a*math.pi/180),y+eRadius*math.sin(a*math.pi/180),1,color)
    end
end

local function GetLowestUnit(i,range)
	if not range then range = myHero.range+myHero.boundingRadius*2 end
	local t, p = nil, math.huge
	if i.alive and i and i.team ~= myHero.team then
		if ValidTarget(i, range) and i.health < p then
			t = i
			p = i.health
		end
	end
	return t
end

local function GetHighestUnit(i,range)
	if not range then range = myHero.range+myHero.boundingRadius*2 end
	local t = nil
		if i and i.alive and i.team ~= myHero.team then
			if ValidTarget(i, range) and not t or GetMaxHP(i) > GetMaxHP(t) then
				t = i
			end
		end
  return t
end

local function EnemyMinionsAround(pos, range)
	local c = 0
	if pos == nil then return 0 end
	for k,v in pairs(SLM) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == MINION_ENEMY then
			c = c + 1
		end
	end
	return c
end

local function JungleMinionsAround(pos, range)
	local c = 0
	if pos == nil then return 0 end
	for k,v in pairs(SLM) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == MINION_JUNGLE then
			c = c + 1
		end
	end
	return c
end

local function AllyHeroesAround(pos, range)
	local c = 0
	if not pos or not range then return end
	for k,v in pairs(GetAllyHeroes()) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == myHero.team then
			c = c + 1
		end
	end
	return c
end

local function EnemyHeroesAround(pos, range)
	local c = 0
	if not pos or not range then return end
	for k,v in pairs(GetEnemyHeroes()) do 
		if v and v.alive and GetDistanceSqr(pos,v) < range*range and v.team == MINION_ENEMY then
			c = c + 1
		end
	end
	return c
end

local function Sample(obj)
    return {x=obj.pos.x, y=obj.pos.y, z=obj.pos.z, time=GetTickCount()/1000 }
end

OnObjectLoad(function(obj)
	if obj and obj.type == Obj_AI_SpawnPoint or obj.type == Obj_AI_Turret or obj.type == Obj_AI_Barracks and obj.alive and obj.team ~= myHero.team then
		structures[obj.networkID] = obj
	end
	if obj and obj.networkID then
		if obj.name:lower():find("visionward") then
			if  ((obj.team == myHero.team) or (obj.team ~= myHero.team ))  then
				table.insert(Wards,{o=obj})
			end
		end
		if obj.name:lower():find("sightward") then
			if  ((obj.team == myHero.team) or (obj.team ~= myHero.team ))  then
				table.insert(Wards2,{o=obj,s=GetTickCount()})
			end
		end
	end
	if obj.type == Obj_AI_SpawnPoint and obj.team ~= myHero.team then
		spawn = obj
    end
end)

OnDeleteObj(function(obj)
	if obj and obj.type == Obj_AI_SpawnPoint or obj.type == Obj_AI_Turret or obj.type == Obj_AI_Barracks and obj.team == MINION_ENEMY then
		structures[obj.networkID] = nil
	end
end)

local function DisableAll(b)
	if b then
		if _G.IOW then
			IOW.movementEnabled = false
			IOW.attacksEnabled = false
		elseif _G.PW then
			PW.movementEnabled = false
			PW.attacksEnabled = false
		elseif _G.GoSWalkLoaded then
			_G.GoSWalk:EnableMovement(false)
			_G.GoSWalk:EnableAttack(false)
		elseif _G.DAC_Loaded then
			DAC:MovementEnabled(false)
			DAC:AttacksEnabled(false)
		elseif _G.AutoCarry_Loaded then
			DACR.movementEnabled = false
			DACR.attacksEnabled = false
		end
		BlockF7OrbWalk(true)
		BlockF7Dodge(true)
		BlockInput(true)
	else
		if _G.IOW then
			IOW.movementEnabled = true
			IOW.attacksEnabled = true
		elseif _G.PW then
			PW.movementEnabled = true
			PW.attacksEnabled = true
		elseif _G.GoSWalkLoaded then
			_G.GoSWalk:EnableMovement(true)
			_G.GoSWalk:EnableAttack(true)
		elseif _G.DAC_Loaded then
			DAC:MovementEnabled(true)
			DAC:AttacksEnabled(true)
		elseif _G.AutoCarry_Loaded then
			DACR.movementEnabled = true
			DACR.attacksEnabled = true
		end
		BlockF7OrbWalk(false)
		BlockF7Dodge(false)
		BlockInput(false)
	end
end

local function dArrow(s, e, w, c)--startpos,endpos,width,color
	local s2 = e-((s-e):normalized()*75):perpendicular()+(s-e):normalized()*75
	local s3 = e-((s-e):normalized()*75):perpendicular2()+(s-e):normalized()*75
	DrawLine3D(s.x,s.y,s.z,e.x,e.y,e.z,w,c)
	DrawLine3D(s2.x,s2.y,s2.z,e.x,e.y,e.z,w,c)
	DrawLine3D(s3.x,s3.y,s3.z,e.x,e.y,e.z,w,c)	
end

local Name = GetMyHero()
local ChampName = myHero.charName
local Dmg = {}
local Mode = nil
local SReady = {
	[0] = false,
	[1] = false,
	[2] = false,
	[3] = false,
}

local function GetADHP(unit)
	return GetCurrentHP(unit) + GetDmgShield(unit)
end

local function GetAPHP(unit)
	return GetCurrentHP(unit) + GetDmgShield(unit) + GetMagicShield(unit)
end

local function IsLaneCreep(unit)
	return unit.team ~= 300
end

local function GetReady()
	for s = 0,3 do 
		if CanUseSpell(myHero,s) == READY then
			SReady[s] = true
		else 
			SReady[s] = false
		end
	end
end 

local t = {_G.MoveToXYZ, _G.AttackUnit, _G.CastSkillShot, _G.CastSkillShot2, _G.CastSkillShot3, _G.HoldPosition, _G.CastSpell, _G.CastTargetSpell}
function Stop(state)
	if state then 
		_G.MoveToXYZ, _G.AttackUnit, _G.CastSkillShot, _G.CastSkillShot2, _G.CastSkillShot3, _G.HoldPosition, _G.CastSpell, _G.CastTargetSpell = function() end, function() end,function() end,function() end,function() end,function() end,function() end,function() end
		BlockF7OrbWalk(true)
		BlockF7Dodge(true)
	else
		_G.MoveToXYZ, _G.AttackUnit, _G.CastSkillShot, _G.CastSkillShot2, _G.CastSkillShot3, _G.HoldPosition, _G.CastSpell, _G.CastTargetSpell = t[1], t[2], t[3], t[4], t[5], t[6], t[7], t[8]
		BlockF7OrbWalk(false)
		BlockF7Dodge(false)
	end
end

Callback.Add("Tick", function()
	if lastcheck + 1000 < GetTickCount() then
		lastcheck = GetTickCount()
		for _,i in pairs(minionManager.objects) do
			if i.valid and i.distance < 2000 and i.alive and i.team ~= MINION_ALLY then
				SLM[i.networkID] = i
			end
		end
		for _,i in pairs(minionManager.objects) do
			if i.valid and i.distance < 2000 and i.alive and i.team == MINION_ALLY then
				SLM2[i.networkID] = i
			end
		end
		for _,i in pairs(structures) do
			if i.valid and i.alive then
				turrets[i.networkID] = i
			end
		end
	end
end)

Callback.Add("Load", function()	
	Init()
	if SLSChamps[ChampName] and L.LC:Value() then
		_G[ChampName]() 
		if myHero.charName ~= "Orianna" and myHero.charName ~= "Ahri" and myHero.charName ~= "Anivia" then
		end
	end
	if SLSChamps[ChampName] then
		PrintChat("<font color=\"#fd8b12\"><b>["..SLPatchnew.."]  v.: "..SLAIO.." - <font color=\"#FFFFFF\">" ..ChampName.." <font color=\"#F2EE00\"> Loaded! </b></font>")
	else
		PrintChat("<font color=\"#fd8b12\"><b>["..SLPatchnew.."]  v.: "..SLAIO.." - <font color=\"#FFFFFF\">" ..ChampName.." <font color=\"#F2EE00\"> is not Supported </b></font>")
	end
		if not _G.MapPosition then
			require('MapPositionGoS')
		end
	SLOrb()
end)   
 
class 'Init'

function Init:__init()
	SxcS = MenuConfig("","----["..SLPatchnew.."][v.:"..SLAIO.."|"..Stage.."]----")
	L = MenuConfig("Loader", "Scrpt Load")
	L:Info("R","")
	L:Boolean("LC", "Load Champion", true)
	L:Info("0.1", "")
	L:Boolean("LU", "Load Utility", false)
	L:Info("0.2", "")
	L:Info("0.7.", "You will have to press 2f6")
	L:Info("0.8.", "to apply the changes")
	xAntiGapCloser = {}
	xGapCloser = {}
	MapPositionGOS = {["Vayne"] = true, ["Poppy"] = true, ["Kalista"] = true, ["Kindred"] = true,}
	
	if L.LC:Value() and SLSChamps[ChampName] then
		BM = MenuConfig("Champions", ""..myHero.charName)
		if xAntiGapCloser[ChampName] == true then 
			BM.M:Menu("AGP", "AntiGapCloser") 
		end
		if xGapCloser[ChampName] == true then 
			BM.M:Menu("GC", "GapCloser")
		end
	end

	if MapPositionGOS[ChampName] == true and FileExist(COMMON_PATH .. "MapPositionGOS.lua") then
		if not _G.MapPosition then
			require('MapPositionGoS')
		end
	end
	if myHero.charName == "Vayne" or myHero.charName == "Veigar" then
		if not OpenPredict then
			require 'OpenPredict'
		end
	end
	Zwei = MenuConfig("Creators", "----[ by : Jani ]----")
	L:Info("Verison", "Current Version : "..SLAIO.." | "..Stage)
end

class 'SLOrb'

function SLOrb:__init()
	if _G.AutoCarry_Loaded or _G.PW or _G.DAC_Loaded or _G.IOW then
		ModeTable = {
		["Combo"] = "Combo",
		["Harass"] = "Harass",
		["LastHit"] = "LastHit",
		["LaneClear"] = "LaneClear",
		}    
	elseif _G.GoSWalkLoaded then
		ModeTable = {
		[0] = "Combo",
		[1] = "Harass",
		[3] = "LastHit",
		[2] = "LaneClear",
		}
		else 
		ModeTable = {}
	end
	if _G.AutoCarry_Loaded  then
		OrbMode = function() return DACR:Mode() end
	elseif _G.PW then
		OrbMode = function() return PW:Mode() end
	elseif _G.DAC_Loaded then
		OrbMode = function() return DAC:Mode() end
	elseif _G.GoSWalkLoaded then
		OrbMode = function() return _G.GoSWalk.CurrentMode end
	elseif _G.AutoCarry_Loaded  then
		OrbMode = function() return DACR:Mode() end
	elseif _G.IOW then
		OrbMode = function() return IOW:Mode() end
	else
		OrbMode = function() return nil end
	end
	
	Callback.Add("Tick",function() 
		Mode = ModeTable[OrbMode()]
	end)
end
	
---------------------------------------------------------------------------------------------
-------------------------------------CHAMPS--------------------------------------------------
---------------------------------------------------------------------------------------------
class "Aatrox"

function Aatrox:__init()
	
	Spell = { 
	[0] = { delay = 0.2, range = 650, speed = 1500, width = 113, type = "circular", col = false },
	[1] = { range = 0 },
	[2] = { delay = 0.1, range = 1000, speed = 1000, width = 150, type = "line", col = false },
	[3] = { range = 550 }
	}
	
	Dmg = {
	[0] = function (unit) return CalcDamage(myHero, unit, 35 + GetCastLevel(myHero,0)*45 + GetBonusDmg(myHero)*.6, 0) end,
	[1] = function (unit) return CalcDamage(myHero, unit, 25 + GetCastLevel(myHero,1)*35 + GetBonusDmg(myHero), 0) end,
	[2] = function (unit) return CalcDamage(myHero, unit, 0, 40 + GetCastLevel(myHero,2)*35 + GetBonusDmg(myHero)*.6 + GetBonusAP(myHero)*.6) end,
	[3] = function (unit) return CalcDamage(myHero, unit, 0, 100 + GetCastLevel(myHero,3)*100 + GetBonusAP(myHero)) end,
	}

	BM:Menu("C", "Combo")
	BM.C:Boolean("Q", "Use Q", true)
	BM.C:Boolean("W", "Use W", true)
	BM.C:Boolean("WE", "Only Toggle if enemy nearby", true)
	BM.C:Slider("WT", "Toggle W at % HP", 45, 5, 90, 5)
	BM.C:Boolean("E", "Use E", true)
	BM.C:Boolean("R", "Use R", true)
	BM.C:Slider("RE", "Use R if x enemies", 2, 1, 5, 1)
	
	BM:Menu("H", "Harass")
	BM.H:Boolean("E", "Use E", true)
	
	BM:Menu("LC", "LaneClear", true)
	BM.LC:Boolean("Q", "Use Q", true)
	BM.LC:Boolean("E", "Use E", true)	
	
	BM:Menu("JC", "JungleClear")
	BM.JC:Boolean("Q", "Use Q", true)
	BM.JC:Boolean("E", "Use E", true)
	
	BM:Menu("KS", "Killsteal")
	BM.KS:Boolean("Enable", "Enable Killsteal", true)
	BM.KS:Boolean("Q", "Use Q", false)
	BM.KS:Boolean("E", "Use E", true)
	
	BM:Menu("TS", "TargetSelector")
	ts = SLTS("AD",BM.TS,false)
	
	BM:Menu("p", "Prediction")

	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("UpdateBuff", function(unit,buff) self:Stat(unit,buff) end)
	
	if GotBuff(myHero, "aatroxwpower") == 1 then
		self.W = "dmg"
	else
		self.W = "heal"
	end

	for i = 0,2,2 do
		PredMenu(BM.p, i)	
	end
end  

function Aatrox:Tick()
	if myHero.dead then return end
	
	GetReady()
		
	self:KS()
		
	self:Toggle(target)
	target = ts:GetTarget()
	if Mode == "Combo" then
		self:Combo(target)
	elseif Mode == "LaneClear" then
		self:LaneClear()
		self:JungleClear()
	elseif Mode == "LastHit" then
	elseif Mode == "Harass" then
		self:Harass(target)
	else
		return
	end
end

function Aatrox:Toggle(target)
	if SReady[1] and BM.C.W:Value() and (not BM.C.WE:Value() or ValidTarget(target,750)) then
		if GetPercentHP(myHero) < BM.C.WT:Value()+1 and self.W == "dmg" then
			CastSpell(1)
		elseif GetPercentHP(myHero) > BM.C.WT:Value() and self.W == "heal" then
			CastSpell(1)
		end
	end
end

function Aatrox:Combo(target)
	if SReady[0] and ValidTarget(target, Spell[0].range*1.1) and BM.C.Q:Value() then
		CastGenericSkillShot(myHero,target,Spell[0],0,BM.p)
	end
	if SReady[2] and ValidTarget(target, Spell[2].range*1.1) and BM.C.E:Value() then
		CastGenericSkillShot(myHero,target,Spell[2],2,BM.p)
	end
	if SReady[3] and ValidTarget(target, 550) and BM.C.R:Value() and EnemiesAround(myHero,550) >= BM.C.RE:Value() then
		CastSpell(3)
	end
end

function Aatrox:Harass(target)
	if SReady[2] and ValidTarget(target, Spell[2].range*1.1) and BM.H.E:Value() then
		local Pred = GetPrediction(target, Spell[2])
		if Pred.hitChance >= BM.p.hE:Value()/100 and GetDistance(Pred.castPos,GetOrigin(myHero)) < Spell[2].range then
			CastSkillShot(2,Pred.castPos)
		end
	end
end

function Aatrox:LaneClear()
	for _,minion in pairs(SLM) do
		if GetTeam(minion) == MINION_ENEMY then
			if SReady[0] and ValidTarget(minion, Spell[0].range*1.1) and BM.LC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
			if SReady[2] and ValidTarget(minion, Spell[2].range*1.1) and BM.LC.E:Value() then
				CastGenericSkillShot(myHero,minion,Spell[2],2,BM.p)
			end
		end
	end		
end

function Aatrox:JungleClear()
	for _,mob in pairs(SLM) do
		if GetTeam(mob) == MINION_JUNGLE then
			if SReady[0] and ValidTarget(mob, Spell[0].range) and BM.JC.Q:Value() then
				CastGenericSkillShot(myHero,minion,Spell[0],0,BM.p)
			end
			if SReady[1] and BM.C.W:Value() and ValidTarget(mob,750) then
				if GetPercentHP(myHero) < BM.C.WT:Value()+1 and self.W == "dmg" then
					CastSpell(1)
				elseif GetPercentHP(myHero) > BM.C.WT:Value() and self.W == "heal" then
					CastSpell(1)
				end
			end
			if SReady[2] and ValidTarget(mob, Spell[2].range) and BM.JC.E:Value() then
				CastGenericSkillShot(myHero,minion,Spell[2],2,BM.p)
			end
		end
	end		
end

function Aatrox:KS()
	if not BM.KS.Enable:Value() then return end
	for _,unit in pairs(GetEnemyHeroes()) do
		if GetADHP(unit) < Dmg[0](unit) and SReady[0] and ValidTarget(unit, Spell[0].range*1.1) and BM.KS.Q:Value() then
			CastGenericSkillShot(myHero,unit,Spell[0],0,BM.p)
		end
		if GetAPHP(unit) < Dmg[2](unit) and SReady[2] and ValidTarget(unit, Spell[2].range*1.1) and BM.KS.E:Value() then
			CastGenericSkillShot(myHero,unit,Spell[2],2,BM.p)
		end
	end
end

function Aatrox:Stat(unit, buff)
	if unit == myHero and buff.Name:lower() == "aatroxwlife" then
		self.W = "heal"
	elseif unit == myHero and buff.Name:lower() == "aatroxwpower" then
		self.W = "dmg"
	end
end
---------------------------------------------------------------------------------------------
-------------------------------------UTILITY-------------------------------------------------
---------------------------------------------------------------------------------------------



class 'HitMe'

function HitMe:__init()
 
     self.str = {[-4] = "R2", [-3] = "P", [-2] = "Q3", [-1] = "Q2", [_Q] = "Q", [_W] = "W", [_E] = "E", [_R] = "R"}
 
    BM:SubMenu("SB","Spellblock")
  
	
self.s = {
	["AatroxQ"]={charName="Aatrox",slot=0,type="Circle",delay=0.6,range=650,radius=250,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0.225,displayname="Dark Flight",mcollision=false},
	["AatroxE"]={charName="Aatrox",slot=2,type="Line",delay=0.25,range=1075,radius=35,speed=1250,addHitbox=true,danger=3,dangerous=false,proj="AatroxEConeMissile",killTime=0,displayname="Blade of Torment",mcollision=false},
	["AhriOrbofDeception"]={charName="Ahri",slot=0,type="Line",delay=0.25,range=1000,radius=100,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="AhriOrbMissile",killTime=0,displayname="Orb of Deception",mcollision=false},
	["AhriOrbReturn"]={charName="Ahri",slot=0,type="Return",delay=0,range=1000,radius=100,speed=915,addHitbox=true,danger=2,dangerous=false,proj="AhriOrbReturn",killTime=0,displayname="Orb of Deception2",mcollision=false},
	["AhriSeduce"]={charName="Ahri",slot=2,type="Line",delay=0.25,range=1000,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="AhriSeduceMissile",killTime=0,displayname="Charm",mcollision=true},
	["Pulverize"]={charName="Alistar",slot=0,type="Circle",delay=0.25,range=1000,radius=200,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0.25,displayname="Pulverize",mcollision=false},
	["BandageToss"]={charName="Amumu",slot=0,type="Line",delay=0.25,range=1000,radius=90,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="SadMummyBandageToss",killTime=0,displayname="Bandage Toss",mcollision=true},
	["CurseoftheSadMummy"]={charName="Amumu",slot=3,type="Circle",delay=0.25,range=0,radius=550,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=1.25,displayname="Curse of the Sad Mummy",mcollision=false},
	["FlashFrost"]={charName="Anivia",slot=0,type="Line",delay=0.25,range=1200,radius=110,speed=850,addHitbox=true,danger=3,dangerous=true,proj="FlashFrostSpell",killTime=0,displayname="Flash Frost",mcollision=false},
	["Incinerate"]={charName="Annie",slot=1,type="Cone",delay=0.25,range=825,radius=80,speed=math.huge,angle=50,addHitbox=false,danger=2,dangerous=false,proj="nil",killTime=0,displayname="",mcollision=false},
	["InfernalGuardian"]={charName="Annie",slot=3,type="Circle",delay=0.25,range=600,radius=251,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0.3,displayname="",mcollision=false},
	-- ["Volley"]={charName="Ashe",slot=1,type="Line",delay=0.25,range=1200,radius=60,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VolleyAttack",killTime=0,displayname="",mcollision=false},
	["EnchantedCrystalArrow"]={charName="Ashe",slot=3,type="Line",delay=0.2,range=20000,radius=130,speed=1600,addHitbox=true,danger=5,dangerous=true,proj="EnchantedCrystalArrow",killTime=0,displayname="Enchanted Arrow",mcollision=false},
	["AurelionSolQ"]={charName="AurelionSol",slot=0,type="Line",delay=0.25,range=1500,radius=180,speed=850,addHitbox=true,danger=2,dangerous=false,proj="AurelionSolQMissile",killTime=0,displayname="AurelionSolQ",mcollision=false},
	["AurelionSolR"]={charName="AurelionSol",slot=3,type="Line",delay=0.3,range=1420,radius=120,speed=4500,addHitbox=true,danger=3,dangerous=true,proj="AurelionSolRBeamMissile",killTime=0,displayname="AurelionSolR",mcollision=false},
	["BardQ"]={charName="Bard",slot=0,type="Line",delay=0.25,range=850,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="BardQMissile",killTime=0,displayname="BardQ",mcollision=true},
	["BardR"]={charName="Bard",slot=3,type="Circle",delay=0.5,range=3400,radius=350,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="BardR",killTime=1,displayname="BardR",mcollision=false},
	["RocketGrab"]={charName="Blitzcrank",slot=0,type="Line",delay=0.2,range=1050,radius=70,speed=1800,addHitbox=true,danger=4,dangerous=true,proj="RocketGrabMissile",killTime=0,displayname="Rocket Grab",mcollision=true},
	["StaticField"]={charName="Blitzcrank",slot=3,type="Circle",delay=0.25,range=0,radius=600,speed=math.huge,addHitbox=false,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Static Field",mcollision=false},
	["BrandQ"]={charName="Brand",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="BrandQMissile",killTime=0,displayname="Sear",mcollision=true},
	["BrandW"]={charName="Brand",slot=1,type="Circle",delay=0.85,range=900,radius=240,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.275,displayname="Pillar of Flame"}, -- doesnt work
	["BraumQ"]={charName="Braum",slot=0,type="Line",delay=0.25,range=1000,radius=60,speed=1700,addHitbox=true,danger=3,dangerous=true,proj="BraumQMissile",killTime=0,displayname="Winter's Bite",mcollision=true},
	["BraumRWrapper"]={charName="Braum",slot=3,type="Line",delay=0.5,range=1250,radius=115,speed=1400,addHitbox=true,danger=4,dangerous=true,proj="braumrmissile",killTime=0,displayname="Glacial Fissure",mcollision=false},
	["CaitlynPiltoverPeacemaker"]={charName="Caitlyn",slot=0,type="Line",delay=0.6,range=1300,radius=90,speed=1800,addHitbox=true,danger=2,dangerous=false,proj="CaitlynPiltoverPeacemaker",killTime=0,displayname="Piltover Peacemaker",mcollision=false},
	["CaitlynEntrapment"]={charName="Caitlyn",slot=2,type="Line",delay=0.4,range=1000,radius=70,speed=1600,addHitbox=true,danger=1,dangerous=false,proj="CaitlynEntrapmentMissile",killTime=0,displayname="90 Caliber Net",mcollision=true},
	["CassiopeiaQ"]={charName="Cassiopeia",slot=0,type="Circle",delay=0.75,range=850,radius=150,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="CassiopeiaNoxiousBlast",killTime=0.2,displayname="Noxious Blast",mcollision=false},
	["CassiopeiaR"]={charName="Cassiopeia",slot=3,type="Cone",delay=0.6,range=825,radius=80,speed=math.huge,angle=80,addHitbox=false,danger=5,dangerous=true,proj="CassiopeiaPetrifyingGaze",killTime=0,displayname="Petrifying Gaze",mcollision=false},
	["Rupture"]={charName="Chogath",slot=0,type="Circle",delay=.25,range=950,radius=250,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="Rupture",killTime=1.75,displayname="Rupture",mcollision=false},
	["PhosphorusBomb"]={charName="Corki",slot=0,type="Circle",delay=0.3,range=825,radius=250,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="PhosphorusBombMissile",killTime=0.35,displayname="Phosphorus Bomb",mcollision=false},
	["CarpetBombMega"]={charName="Corki",slot=2,type="Line",delay=0.2,range=1900,radius=140,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="CarpetBombMega",killTime=0,displayname="Special Delivery",mcollision=false},
	["MissileBarrage"]={charName="Corki",slot=3,type="Line",delay=0.2,range=1300,radius=40,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="MissileBarrageMissile",killTime=0,displayname="Missile Barrage",mcollision=true},
	["MissileBarrage2"]={charName="Corki",slot=3,type="Line",delay=0.2,range=1500,radius=40,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="MissileBarrageMissile2",killTime=0,displayname="Missile Barrage big",mcollision=true},
	["DariusCleave"]={charName="Darius",slot=0,type="Circle",delay=0.75,range=0,radius=425 - 50,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="DariusCleave",killTime=0,displayname="Cleave",mcollision=false},
	["DariusAxeGrabCone"]={charName="Darius",slot=2,type="Cone",delay=0.25,range=550,radius=80,speed=math.huge,angle=30,addHitbox=false,danger=3,dangerous=true,proj="DariusAxeGrabCone",killTime=0,displayname="Apprehend",mcollision=false},
	["DianaArc"]={charName="Diana",slot=0,type="Circle",delay=0.25,range=835,radius=195,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DianaArcArc",killTime=0,displayname="",mcollision=false},
	["DianaArcArc"]={charName="Diana",slot=0,type="Arc",delay=0.25,range=835,radius=195,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DianaArcArc",killTime=0,displayname="",mcollision=false},
	["InfectedCleaverMissileCast"]={charName="DrMundo",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=2000,addHitbox=true,danger=3,dangerous=false,proj="InfectedCleaverMissile",killTime=0,displayname="Infected Cleaver",mcollision=true},
	["DravenDoubleShot"]={charName="Draven",slot=2,type="Line",delay=0.25,range=1100,radius=130,speed=1400,addHitbox=true,danger=3,dangerous=true,proj="DravenDoubleShotMissile",killTime=0,displayname="Stand Aside",mcollision=false},
	["DravenRCast"]={charName="Draven",slot=3,type="Line",delay=0.5,range=25000,radius=160,speed=2000,addHitbox=true,danger=5,dangerous=true,proj="DravenR",killTime=0,displayname="Whirling Death",mcollision=false},
	["EkkoQ"]={charName="Ekko",slot=0,type="Line",delay=0.25,range=925,radius=60,speed=1650,addHitbox=true,danger=4,dangerous=true,proj="ekkoqmis",killTime=0,displayname="Timewinder",mcollision=false},
	["EkkoW"]={charName="Ekko",slot=1,type="Circle",delay=3.75,range=1600,radius=375,speed=1650,addHitbox=false,danger=3,dangerous=false,proj="EkkoW",killTime=1.2,displayname="Parallel Convergence",mcollision=false},
	["EkkoR"]={charName="Ekko",slot=3,type="Circle",delay=0.25,range=1600,radius=375,speed=1650,addHitbox=true,danger=3,dangerous=false,proj="EkkoR",killTime=0.2,displayname="Chronobreak",mcollision=false},
	["EliseHumanE"]={charName="Elise",slot=2,type="Line",delay=0.25,range=925,radius=55,speed=1600,addHitbox=true,danger=4,dangerous=true,proj="EliseHumanE",killTime=0,displayname="Cocoon",mcollision=true},
	["EvelynnR"]={charName="Evelynn",slot=3,type="Circle",delay=0.25,range=650,radius=350,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="EvelynnR",killTime=0.2,displayname="Agony's Embrace"},
	["EzrealMysticShot"]={charName="Ezreal",slot=0,type="Line",delay=0.25,range=1300,radius=50,speed=1975,addHitbox=true,danger=2,dangerous=false,proj="EzrealMysticShotMissile",killTime=0,displayname="Mystic Shot",mcollision=true},
	["EzrealEssenceFlux"]={charName="Ezreal",slot=1,type="Line",delay=0.25,range=1000,radius=80,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="EzrealEssenceFluxMissile",killTime=0,displayname="Essence Flux",mcollision=false},
	["EzrealTrueshotBarrage"]={charName="Ezreal",slot=3,type="Line",delay=1,range=20000,radius=150,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="EzrealTrueshotBarrage",killTime=0,displayname="Trueshot Barrage",mcollision=false},
	["FioraW"]={charName="Fiora",slot=1,type="Line",delay=0.5,range=800,radius=70,speed=3200,addHitbox=true,danger=2,dangerous=false,proj="FioraWMissile",killTime=0,displayname="Riposte",mcollision=false},
	["FizzMarinerDoom"]={charName="Fizz",slot=3,type="Line",delay=0.25,range=1150,radius=120,speed=1350,addHitbox=true,danger=5,dangerous=true,proj="FizzMarinerDoomMissile",killTime=0,displayname="Chum the Waters",mcollision=false},
	["FizzMarinerDoomMissile"]={charName="Fizz",slot=3,type="Circle",delay=0.25,range=800,radius=300,speed=1350,addHitbox=true,danger=5,dangerous=true,proj="FizzMarinerDoomMissile",killTime=0,displayname="Chum the Waters End",mcollision=false},
	["GalioResoluteSmite"]={charName="Galio",slot=0,type="Circle",delay=0.25,range=900,radius=200,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="GalioResoluteSmite",killTime=0.2,displayname="Resolute Smite",mcollision=false},
	["GalioRighteousGust"]={charName="Galio",slot=2,type="Line",delay=0.25,range=1100,radius=120,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="GalioRighteousGust",killTime=0,displayname="Righteous Ghost",mcollision=false},
	["GalioIdolOfDurand"]={charName="Galio",slot=3,type="Circle",delay=0.25,range=0,radius=550,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=1,displayname="Idol of Durand",mcollision=false},
	["GnarQ"]={charName="Gnar",slot=0,type="Line",delay=0.25,range=1200,radius=60,speed=1225,addHitbox=true,danger=2,dangerous=false,proj="gnarqmissile",killTime=0,displayname="Boomerang Throw",mcollision=false},
	["GnarQReturn"]={charName="Gnar",slot=0,type="Line",delay=0,range=1200,radius=75,speed=1225,addHitbox=true,danger=2,dangerous=false,proj="GnarQMissileReturn",killTime=0,displayname="Boomerang Throw2",mcollision=false},
	["GnarBigQ"]={charName="Gnar",slot=0,type="Line",delay=0.5,range=1150,radius=90,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="GnarBigQMissile",killTime=0,displayname="Boulder Toss",mcollision=true},
	["GnarBigW"]={charName="Gnar",slot=1,type="Line",delay=0.6,range=600,radius=80,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GnarBigW",killTime=0,displayname="Wallop",mcollision=false},
	["GnarE"]={charName="Gnar",slot=2,type="Circle",delay=0,range=473,radius=150,speed=903,addHitbox=true,danger=2,dangerous=false,proj="GnarE",killTime=0.2,displayname="GnarE",mcollision=false},
	["GnarBigE"]={charName="Gnar",slot=2,type="Circle",delay=0.25,range=475,radius=200,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="GnarBigE",killTime=0.2,displayname="GnarBigE",mcollision=false},
	["GnarR"]={charName="Gnar",slot=3,type="Circle",delay=0.25,range=0,radius=500,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=0.3,displayname="GnarUlt",mcollision=false},
	["GragasQ"]={charName="Gragas",slot=0,type="Circle",delay=0.25,range=1100,radius=275,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="GragasQMissile",killTime=4.25,displayname="Barrel Roll",mcollision=false,killName="GragasQToggle"},
	["GragasE"]={charName="Gragas",slot=2,type="Line",delay=0,range=800,radius=200,speed=800,addHitbox=true,danger=2,dangerous=false,proj="GragasE",killTime=0.5,displayname="Body Slam",mcollision=true},
	["GragasR"]={charName="Gragas",slot=3,type="Circle",delay=0.25,range=1050,radius=375,speed=1800,addHitbox=true,danger=5,dangerous=true,proj="GragasRBoom",killTime=0.3,displayname="Explosive Cask",mcollision=false},
	["GravesBasicAttack"]={charName="Graves",slot=-2,type="Cone",delay=0.2,range=750,radius=140,speed=math.huge,angle=45,addHitbox=true,danger=1,dangerous=false,proj="GravesBasicAttackSpread",killTime=1,displayname="Auto Attack",mcollision=false},
	["GravesQLineMis"]={charName="Graves",slot=0,type="Rectangle",delay=0.2,range=750,radius=140,radius2=300,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GravesQLineMis",killTime=1,displayname="Buckshot Rectangle",mcollision=false},
	["GravesClusterShotSoundMissile"]={charName="Graves",slot=0,type="Line",delay=0.2,range=750,radius=60,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0,displayname="Buckshot",mcollision=false},
	["GravesQReturn"]={charName="Graves",slot=0,type="Line",delay=0,range=750,radius=60,speed=1150,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0,displayname="Buckshot return",mcollision=false},
	["GravesSmokeGrenade"]={charName="Graves",slot=1,type="Circle",delay=0.25,range=925,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="GravesSmokeGrenadeBoom",killTime=4.5,displayname="SmokeScreen",mcollision=false},
	["GravesChargeShot"]={charName="Graves",slot=3,type="Line",delay=0.2,range=1000,radius=100,speed=2100,addHitbox=true,danger=5,dangerous=true,proj="GravesChargeShotShot",killTime=0,displayname="CollateralDmg",mcollision=false},
	["GravesChargeShotFxMissile"]={charName="Graves",slot=3,type="Cone",delay=0,range=1000,radius=100,speed=2100,angle=60,addHitbox=true,danger=5,dangerous=true,proj="nil",killTime=0,displayname="CollateralDmg end",mcollision=false},
	["HecarimUlt"]={charName="Hecarim",slot=3,type="Line",delay=0.2,range=1100,radius=300,speed=1200,addHitbox=true,danger=5,dangerous=true,proj="HecarimUltMissile",killTime=0.55,displayname="HecarimR",mcollision=false},
	["HeimerdingerTurretEnergyBlast"]={charName="Heimerdinger",slot=0,type="Line",delay=0.4,range=1000,radius=70,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="HeimerdingerTurretEnergyBlast",killTime=0,displayname="Turret",mcollision=false},
	["HeimerdingerW"]={charName="Heimerdinger",slot=1,type="Cone",delay=0.25,range=800,radius=70,speed=1800,angle=10,addHitbox=true,danger=2,dangerous=false,proj="HeimerdingerWAttack2",killTime=0,displayname="HeimerUltW",mcollision=true},
	["HeimerdingerE"]={charName="Heimerdinger",slot=2,type="Circle",delay=0.25,range=925,radius=100,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="heimerdingerespell",killTime=0.3,displayname="HeimerdingerE",mcollision=false},
	["IllaoiQ"]={charName="Illaoi",slot=0,type="Line",delay=0.75,range=750,radius=160,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="illaoiemis",killTime=0,displayname="",mcollision=false},
	["IllaoiE"]={charName="Illaoi",slot=2,type="Line",delay=0.25,range=1100,radius=50,speed=1900,addHitbox=true,danger=3,dangerous=true,proj="illaoiemis",killTime=0,displayname="",mcollision=true},
	["IllaoiR"]={charName="Illaoi",slot=3,type="Circle",delay=0.5,range=0,radius=450,speed=math.huge,addHitbox=false,danger=3,dangerous=true,proj="nil",killTime=0.2,displayname="",mcollision=false},
	["IreliaTranscendentBlades"]={charName="Irelia",slot=3,type="Line",delay=0,range=1200,radius=65,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="IreliaTranscendentBlades",killTime=0,displayname="Transcendent Blades",mcollision=false},
	["IvernQ"]={charName="Ivern",slot=0,type="Line",delay=0.25,range=1100,radius=65,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="IvernQ",killTime=0,displayname="",mcollision=true},
	["HowlingGaleSpell"]={charName="Janna",slot=0,type="Line",delay=0.25,range=1700,radius=120,speed=800,addHitbox=true,danger=2,dangerous=false,proj="HowlingGaleSpell",killTime=0,displayname="HowlingGale",mcollision=false},
	["JarvanIVDragonStrike"]={charName="JarvanIV",slot=0,type="Line",delay=0.6,range=770,radius=70,speed=math.huge,addHitbox=true,danger=3,dangerous=false,proj="nil",killTime=0,displayname="DragonStrike",mcollision=false},
	["JarvanIVEQ"]={charName="JarvanIV",slot=0,type="Line",delay=0.25,range=880,radius=70,speed=1450,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="DragonStrike2",mcollision=false},
	["JarvanIVDemacianStandard"]={charName="JarvanIV",slot=2,type="Circle",delay=0.5,range=860,radius=175,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="JarvanIVDemacianStandard",killTime=1.5,displayname="Demacian Standard",mcollision=false},
	["JayceShockBlast"]={charName="Jayce",slot=0,type="Line",delay=0.25,range=1300,radius=70,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="JayceShockBlastMis",killTime=0,displayname="ShockBlast",mcollision=true},
	["JayceShockBlastWallMis"]={charName="Jayce",slot=0,type="Line",delay=0.25,range=1300,radius=70,speed=2350,addHitbox=true,danger=2,dangerous=false,proj="JayceShockBlastWallMis",killTime=0,displayname="ShockBlastCharged",mcollision=true},
	["JhinW"]={charName="Jhin",slot=1,type="Line",delay=0.75,range=2550,radius=40,speed=5000,addHitbox=true,danger=3,dangerous=true,proj="JhinWMissile",killTime=0,displayname="",mcollision=false},
	["JhinRShot"]={charName="Jhin",slot=3,type="Line",delay=0.25,range=3500,radius=80,speed=5000,addHitbox=true,danger=3,dangerous=true,proj="JhinRShotMis",killTime=0,displayname="JhinR",mcollision=false},
	["JinxW"]={charName="Jinx",slot=1,type="Line",delay=0.3,range=1600,radius=60,speed=2500,addHitbox=true,danger=3,dangerous=true,proj="JinxWMissile",killTime=.6,displayname="Zap",mcollision=true},
	["JinxE"]={charName="Jinx",slot=2,type="Rectangle",delay=0.25,range=1600,radius=100,radius2=275,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="JinxEHit",killTime=5,displayname="Zap",mcollision=true},
	["JinxR"]={charName="Jinx",slot=3,type="Line",delay=0.6,range=20000,radius=140,speed=1700,addHitbox=true,danger=5,dangerous=true,proj="JinxR",killTime=0,displayname="Death Rocket",mcollision=false},
	["KalistaMysticShot"]={charName="Kalista",slot=0,type="Line",delay=0.25,range=1200,radius=40,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="kalistamysticshotmis",killTime=0,displayname="MysticShot",mcollision=true},
	["KarmaQ"]={charName="Karma",slot=0,type="Line",delay=0.25,range=1050,radius=60,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KarmaQMissile",killTime=0,displayname="",mcollision=true},
	["KarmaQMantra"]={charName="Karma",slot=0,type="Line",delay=0.25,range=950,radius=80,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KarmaQMissileMantra",killTime=0,displayname="",mcollision=true},
	["KarthusLayWasteA1"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 1",mcollision=false},
	["KarthusLayWasteA2"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 2",mcollision=false},
	["KarthusLayWasteA3"]={charName="Karthus",slot=0,type="Circle",delay=0.625,range=875,radius=200,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.2,displayname="Lay Waste 3",mcollision=false},
	["KarthusWallOfPain"]={charName="Karthus",slot=2,type="Rectangle",delay=0.25,range=600,radius=160,radius2=500,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=5,displayname="Wall of Pain",mcollision=false},
	["RiftWalk"]={charName="Kassadin",slot=3,type="Circle",delay=0.25,range=450,radius=270,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="RiftWalk",killTime=0.3,displayname="",mcollision=false},
	["KennenShurikenHurlMissile1"]={charName="Kennen",slot=0,type="Line",delay=0.18,range=1050,radius=50,speed=1650,addHitbox=true,danger=2,dangerous=false,proj="KennenShurikenHurlMissile1",killTime=0,displayname="Thundering Shuriken",mcollision=true},
	["KhazixW"]={charName="Khazix",slot=1,type="Line",delay=0.25,range=1025,radius=70,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KhazixWMissile",killTime=0,displayname="",mcollision=true},
	["KledE"]={charName="Kled",slot=0,type="Line",delay=0.25,range=1025,radius=70,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="KhazixWMissile",killTime=0,displayname="",mcollision=true},
	["KledQ"]={charName="Kled",slot=2,type="Line",delay=0,range=750,radius=125,speed=945,addHitbox=true,danger=3,dangerous=true,proj="KledE",killTime=0,displayname="",mcollision=true},
	["KhazixE"]={charName="Khazix",slot=2,type="Circle",delay=0.25,range=600,radius=300,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="KhazixE",killTime=0.2,displayname="",mcollision=false},
	["KogMawQ"]={charName="KogMaw",slot=0,type="Line",delay=0.25,range=975,radius=70,speed=1650,addHitbox=true,danger=2,dangerous=false,proj="KogMawQ",killTime=0,displayname="",mcollision=true},
	["KogMawVoidOoze"]={charName="KogMaw",slot=2,type="Line",delay=0.25,range=1200,radius=120,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="KogMawVoidOozeMissile",killTime=0,displayname="Void Ooze",mcollision=false},
	["KogMawLivingArtillery"]={charName="KogMaw",slot=3,type="Circle",delay=0.25,range=1800,radius=225,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="KogMawLivingArtillery",killTime=1,displayname="LivingArtillery",mcollision=false},
	["LeblancSlide"]={charName="Leblanc",slot=1,type="Circle",delay=0,range=600,radius=220,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LeblancSlide",killTime=0.2,displayname="Slide",mcollision=false},
	["LeblancSlideM"]={charName="Leblanc",slot=3,type="Circle",delay=0,range=600,radius=220,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LeblancSlideM",killTime=0.2,displayname="Slide R",mcollision=false},
	["LeblancSoulShackle"]={charName="Leblanc",slot=2,type="Line",delay=0,range=950,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeblancSoulShackle",killTime=0,displayname="Ethereal Chains R",mcollision=true},
	["LeblancSoulShackleM"]={charName="Leblanc",slot=3,type="Line",delay=0,range=950,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeblancSoulShackleM",killTime=0,displayname="Ethereal Chains",mcollision=true},
	["BlindMonkQOne"]={charName="LeeSin",slot=0,type="Line",delay=0.25,range=1000,radius=80,speed=1800,addHitbox=true,danger=3,dangerous=true,proj="BlindMonkQOne",killTime=0,displayname="Sonic Wave",mcollision=true},
	["LeonaZenithBlade"]={charName="Leona",slot=2,type="Line",delay=0.25,range=875,radius=70,speed=1750,addHitbox=true,danger=3,dangerous=true,proj="LeonaZenithBladeMissile",killTime=0,displayname="Zenith Blade",mcollision=false},
	["LeonaSolarFlare"]={charName="Leona",slot=3,type="Circle",delay=1,range=1200,radius=300,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="LeonaSolarFlare",killTime=0.5,displayname="Solar Flare",mcollision=false},
	["LissandraQ"]={charName="Lissandra",slot=0,type="Line",delay=0.25,range=700,radius=75,speed=2200,addHitbox=true,danger=2,dangerous=false,proj="LissandraQMissile",killTime=0,displayname="Ice Shard",mcollision=false},
	["LissandraQShards"]={charName="Lissandra",slot=0,type="Line",delay=0.25,range=700,radius=90,speed=2200,addHitbox=true,danger=2,dangerous=false,proj="lissandraqshards",killTime=0,displayname="Ice Shard2",mcollision=false},
	["LissandraE"]={charName="Lissandra",slot=2,type="Line",delay=0.25,range=1025,radius=125,speed=850,addHitbox=true,danger=2,dangerous=false,proj="LissandraEMissile",killTime=0,displayname="",mcollision=false},
	["LucianQ"]={charName="Lucian",slot=0,type="Line",delay=0.5,range=800,radius=65,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="LucianQ",killTime=0,displayname="",mcollision=false},
	["LucianW"]={charName="Lucian",slot=1,type="Line",delay=0.2,range=1000,radius=55,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="lucianwmissile",killTime=0,displayname="",mcollision=true},
	["LucianRMis"]={charName="Lucian",slot=3,type="Line",delay=0.5,range=1400,radius=110,speed=2800,addHitbox=true,danger=2,dangerous=false,proj="lucianrmissileoffhand",killTime=0,displayname="LucianR",mcollision=true},
	["LuluQ"]={charName="Lulu",slot=0,type="Line",delay=0.25,range=950,radius=60,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LuluQMissile",killTime=0,displayname="",mcollision=false},
	["LuluQPix"]={charName="Lulu",slot=0,type="Line",delay=0.25,range=950,radius=60,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="LuluQMissileTwo",killTime=0,displayname="",mcollision=false},
	["LuxLightBinding"]={charName="Lux",slot=0,type="Line",delay=0.3,range=1300,radius=70,speed=1200,addHitbox=true,danger=3,dangerous=true,proj="LuxLightBindingMis",killTime=0,displayname="Light Binding",mcollision=true},
	["LuxLightStrikeKugel"]={charName="Lux",slot=2,type="Circle",delay=0.25,range=1100,radius=350,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="LuxLightStrikeKugel",killTime=5.25,displayname="LightStrikeKugel",mcollision=false,killName="LuxLightstrikeToggle"},
	["LuxMaliceCannon"]={charName="Lux",slot=3,type="Line",delay=1.5,range=3500,radius=190,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="LuxMaliceCannon",killTime=2,displayname="Malice Cannon",mcollision=false},
	["UFSlash"]={charName="Malphite",slot=3,type="Circle",delay=0,range=1000,radius=270,speed=1500,addHitbox=true,danger=5,dangerous=true,proj="UFSlash",killTime=0.4,displayname="",mcollision=false},
	["MalzaharQ"]={charName="Malzahar",slot=0,type="Rectangle",delay=0.75,range=900,radius2=475,radius=130,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="MalzaharQMissile",killTime=0.5,displayname="",mcollision=false},
	["DarkBindingMissile"]={charName="Morgana",slot=0,type="Line",delay=0.2,range=1300,radius=80,speed=1200,addHitbox=true,danger=3,dangerous=true,proj="DarkBindingMissile",killTime=0,displayname="Dark Binding",mcollision=true},
	["NamiQ"]={charName="Nami",slot=0,type="Circle",delay=0.95,range=1625,radius=200,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="NamiQMissile",killTime=0.35,displayname="",mcollision=false},
	["NamiR"]={charName="Nami",slot=3,type="Line",delay=0.8,range=2750,radius=260,speed=850,addHitbox=true,danger=2,dangerous=false,proj="NamiRMissile",killTime=0,displayname="",mcollision=false},
	["NautilusAnchorDrag"]={charName="Nautilus",slot=0,type="Line",delay=0.25,range=1080,radius=90,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="NautilusAnchorDragMissile",killTime=0,displayname="Anchor Drag",mcollision=true},
	["AbsoluteZero"]={charName="Nunu",slot=3,type="Circle",delay=0.25,range=0,radius=750,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=4,displayname="",mcollision=false},
	["NocturneDuskbringer"]={charName="Nocturne",slot=0,type="Line",delay=0.25,range=1125,radius=60,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="NocturneDuskbringer",killTime=0,displayname="Duskbringer",mcollision=false},
	["JavelinToss"]={charName="Nidalee",slot=0,type="Line",delay=0.25,range=1500,radius=40,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="JavelinToss",killTime=0,displayname="JavelinToss",mcollision=true},
	["OlafAxeThrowCast"]={charName="Olaf",slot=0,type="Line",delay=0.25,range=1000,radius=105,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="olafaxethrow",killTime=0,displayname="Axe Throw",mcollision=false},
	["OriannaIzunaCommand"]={charName="Orianna",slot=0,type="Line",delay=0,range=1500,radius=80,speed=1200,addHitbox=true,danger=2,dangerous=false,proj="orianaizuna",killTime=0,displayname="",mcollision=false},
	["OrianaDissonanceCommand-"]={charName="Orianna",slot=1,type="Circle",delay=0.25,range=0,radius=255,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="OrianaDissonanceCommand-",killTime=0.3,displayname="",mcollision=false},
	["OriannasE"]={charName="Orianna",slot=2,type="Line",delay=0,range=1500,radius=85,speed=1850,addHitbox=true,danger=2,dangerous=false,proj="orianaredact",killTime=0,displayname="",mcollision=false},
	["OrianaDetonateCommand-"]={charName="Orianna",slot=3,type="Circle",delay=0.7,range=0,radius=410,speed=math.huge,addHitbox=true,danger=5,dangerous=true,proj="OrianaDetonateCommand-",killTime=0.5,displayname="",mcollision=false},
	["QuinnQ"]={charName="Quinn",slot=0,type="Line",delay=0,range=1050,radius=60,speed=1550,addHitbox=true,danger=2,dangerous=false,proj="QuinnQ",killTime=0,displayname="",mcollision=true},
	["PoppyQ"]={charName="Poppy",slot=0,type="Line",delay=0.5,range=430,radius=120,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="PoppyQ",killTime=1,displayname="",mcollision=false},
	["PoppyRSpell"]={charName="Poppy",slot=3,type="Line",delay=0.3,range=1200,radius=100,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="PoppyRMissile",killTime=0,displayname="PoppyR",mcollision=false},
	["RengarE"]={charName="Rengar",slot=2,type="Line",delay=0.25,range=1000,radius=70,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="RengarEFinal",killTime=0,displayname="",mcollision=true},
	["reksaiqburrowed"]={charName="RekSai",slot=0,type="Line",delay=0.5,range=1050,radius=60,speed=1550,addHitbox=true,danger=3,dangerous=false,proj="RekSaiQBurrowedMis",killTime=0,displayname="RekSaiQ",mcollision=true},
	["RivenWindslashMissileRight"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Right",mcollision=false},
	["RivenWindslashMissileCenter"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Center",mcollision=false},
	["RivenWindslashMissileLeft"]={charName="Riven",slot=3,type="Line",delay=0.25,range=1100,radius=125,speed=1600,addHitbox=false,danger=5,dangerous=true,proj="RivenLightsaberMissile",killTime=0,displayname="WindSlash Left",mcollision=false},
	-- ["RivenMartyr"]={charName="Riven",slot=1,type="Circle",delay=0.25,range=0,radius=300,speed=math.huge,addHitbox=false,danger=5,dangerous=true,proj="nil",killTime=0.2,displayname="RivenW",mcollision=false},
	["RumbleGrenade"]={charName="Rumble",slot=2,type="Line",delay=0.25,range=850,radius=60,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="RumbleGrenade",killTime=0,displayname="Grenade",mcollision=true},
	["RumbleCarpetBombM"]={charName="Rumble",slot=3,type="Line",delay=0.4,range=1700,radius=200,speed=1600,addHitbox=true,danger=4,dangerous=false,proj="RumbleCarpetBombMissile",killTime=0,displayname="Carpet Bomb",mcollision=false}, --doesnt work
	["RyzeQ"]={charName="Ryze",slot=0,type="Line",delay=0,range=900,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="RyzeQ",killTime=0,displayname="",mcollision=true},
	["ryzerq"]={charName="Ryze",slot=0,type="Line",delay=0,range=900,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ryzerq",killTime=0,displayname="RyzeQ R",mcollision=true},
	["SejuaniArcticAssault"]={charName="Sejuani",slot=0,type="Line",delay=0,range=900,radius=70,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="ArcticAssault",mcollision=true},
	["SejuaniGlacialPrisonStart"]={charName="Sejuani",slot=3,type="Line",delay=0.25,range=1200,radius=110,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="sejuaniglacialprison",killTime=0,displayname="GlacialPrisonStart",mcollision=false},
	["SionE"]={charName="Sion",slot=2,type="Line",delay=0.25,range=800,radius=80,speed=1800,addHitbox=true,danger=3,dangerous=true,proj="SionEMissile",killTime=0,displayname="",mcollision=false},
	["SionR"]={charName="Sion",slot=3,type="Line",delay=0.5,range=20000,radius=120,speed=1000,addHitbox=true,danger=3,dangerous=true,proj="nil",killTime=0,displayname="",mcollision=false},
	["SorakaQ"]={charName="Soraka",slot=0,type="Circle",delay=0,range=950,radius=300,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.75,displayname="",mcollision=false},
	["SorakaE"]={charName="Soraka",slot=2,type="Circle",delay=0,range=925,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=2,displayname="",mcollision=false},
	["ShenE"]={charName="Shen",slot=2,type="Line",delay=0,range=650,radius=50,speed=1600,addHitbox=true,danger=3,dangerous=true,proj="ShenE",killTime=0,displayname="Shadow Dash",mcollision=false},
	["ShyvanaFireball"]={charName="Shyvana",slot=2,type="Line",delay=0.25,range=925,radius=60,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ShyvanaFireballMissile",killTime=0,displayname="Fireball",mcollision=false},
	["ShyvanaTransformCast"]={charName="Shyvana",slot=3,type="Line",delay=0.25,range=750,radius=150,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="ShyvanaTransformCast",killTime=0,displayname="Transform Cast",mcollision=false},
	["shyvanafireballdragon2"]={charName="Shyvana",slot=3,type="Line",delay=0.25,range=925,radius=70,speed=2000,addHitbox=true,danger=3,dangerous=false,proj="ShyvanaFireballDragonFxMissile",killTime=0,displayname="Fireball Dragon",mcollision=false},
	["SivirQMissileReturn"]={charName="Sivir",slot=0,type="Return",delay=0,range=1075,radius=100,speed=1350,addHitbox=true,danger=2,dangerous=false,proj="SivirQMissileReturn",killTime=0,displayname="SivirQ2",mcollision=false},
	["SivirQ"]={charName="Sivir",slot=0,type="Line",delay=0.25,range=1075,radius=90,speed=1350,addHitbox=true,danger=2,dangerous=false,proj="SivirQMissile",killTime=0,displayname="SivirQ",mcollision=false},
	["SkarnerFracture"]={charName="Skarner",slot=2,type="Line",delay=0.35,range=350,radius=70,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="SkarnerFractureMissile",killTime=0,displayname="Fracture",mcollision=false},
	["SonaR"]={charName="Sona",slot=3,type="Line",delay=0.25,range=900,radius=140,speed=2400,addHitbox=true,danger=5,dangerous=true,proj="SonaR",killTime=0,displayname="Crescendo",mcollision=false},
	["SwainShadowGrasp"]={charName="Swain",slot=1,type="Circle",delay=0.25,range=900,radius=180,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="SwainShadowGrasp",killTime=1.5,displayname="Shadow Grasp",mcollision=false},
	["SyndraQ"]={charName="Syndra",slot=0,type="Circle",delay=0.6,range=800,radius=150,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="SyndraQSpell",killTime=0.2,displayname="",mcollision=false},
	["SyndraWCast"]={charName="Syndra",slot=1,type="Circle",delay=0.25,range=950,radius=210,speed=1450,addHitbox=true,danger=2,dangerous=false,proj="syndrawcast",killTime=0.2,displayname="SyndraW",mcollision=false},
	["SyndraE"]={charName="Syndra",slot=2,type="Cone",delay=0,range=950,radius=100,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="SyndraE",killTime=0,displayname="SyndraE",mcollision=false},
	["syndrae5"]={charName="Syndra",slot=2,type="Line",delay=0,range=950,radius=100,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="syndrae5",killTime=0,displayname="SyndraE2",mcollision=false},
	["TalonRake"]={charName="Talon",slot=1,type="Cone",delay=0.25,range=800,radius=80,speed=2300,angle=45,addHitbox=true,danger=2,dangerous=true,proj="talonrakemissileone",killTime=0,displayname="Rake",mcollision=false},
	["TalonRakeMissileTwo"]={charName="Talon",slot=1,type="Cone",delay=0.25,range=800,radius=80,speed=1850,angle=45,addHitbox=true,danger=2,dangerous=true,proj="talonrakemissiletwo",killTime=0,displayname="Rake2",mcollision=false},
	["TahmKenchQ"]={charName="TahmKench",slot=0,type="Line",delay=0.25,range=951,radius=90,speed=2800,addHitbox=true,danger=3,dangerous=true,proj="tahmkenchqmissile",killTime=0,displayname="Tongue Slash",mcollision=true},
	["TaricE"]={charName="Taric",slot=2,type="follow",delay=0.25,range=750,radius=100,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="TaricE",killTime=1.25,displayname="",mcollision=false},
	["ThreshQ"]={charName="Thresh",slot=0,type="Line",delay=0.5,range=1050,radius=70,speed=1900,addHitbox=true,danger=3,dangerous=true,proj="ThreshQMissile",killTime=0,displayname="",mcollision=true},
	["ThreshEFlay"]={charName="Thresh",slot=2,type="Line",delay=0.125,range=500,radius=110,speed=2000,addHitbox=true,danger=3,dangerous=true,proj="ThreshEMissile1",killTime=0,displayname="Flay",mcollision=false},
	["RocketJump"]={charName="Tristana",slot=1,type="Circle",delay=0.5,range=900,radius=270,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="RocketJump",killTime=0.3,displayname="",mcollision=false},
	["TryndamereE"]={charName="Tryndamere",slot=2,type="Line",delay=0,range=700,radius=93,speed=1000,addHitbox=true,danger=2,dangerous=false,proj="Slash",killTime=0.5,displayname="",mcollision=false},
	["WildCards"]={charName="TwistedFate",slot=0,type="Line",delay=0.25,range=1450,radius=40,speed=1000,angle=28,addHitbox=true,danger=2,dangerous=false,proj="SealFateMissile",killTime=0,displayname="",mcollision=false},
	["TwitchVenomCask"]={charName="Twitch",slot=1,type="Circle",delay=0.25,range=900,radius=275,speed=1400,addHitbox=true,danger=2,dangerous=false,proj="TwitchVenomCaskMissile",killTime=0.3,displayname="Venom Cask",mcollision=false},
	["TwitchSprayAndPrayAttack"]={charName="Twitch",slot=3,type="Line",delay=0.1,range=1200,radius=100,speed=1800,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.5,displayname="Venom Cask",mcollision=false},
	["UrgotHeatseekingLineMissile"]={charName="Urgot",slot=0,type="Line",delay=0.125,range=1000,radius=60,speed=1600,addHitbox=true,danger=2,dangerous=false,proj="UrgotHeatseekingLineMissile",killTime=0,displayname="Heatseeking Line",mcollision=true},
	["UrgotPlasmaGrenade"]={charName="Urgot",slot=2,type="Circle",delay=0.25,range=1100,radius=210,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="UrgotPlasmaGrenadeBoom",killTime=0.3,displayname="PlasmaGrenade",mcollision=false},
	["VarusQMissile"]={charName="Varus",slot=0,type="Line",delay=0.25,range=1475,radius=70,speed=1900,addHitbox=true,danger=2,dangerous=false,proj="VarusQMissile",killTime=0,displayname="VarusQ",mcollision=false},
	["VarusE"]={charName="Varus",slot=2,type="Circle",delay=0.25,range=925,radius=235,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VarusE",killTime=2.25,displayname="",mcollision=false},
	["VarusR"]={charName="Varus",slot=3,type="Line",delay=0.25,range=800,radius=120,speed=1950,addHitbox=true,danger=3,dangerous=true,proj="VarusRMissile",killTime=0,displayname="",mcollision=false},
	["VeigarBalefulStrike"]={charName="Veigar",slot=0,type="Line",delay=0.1,range=900,radius=70,speed=1500,addHitbox=true,danger=2,dangerous=false,proj="VeigarBalefulStrikeMis",killTime=0,displayname="BalefulStrike",mcollision=false},
	["VeigarDarkMatter"]={charName="Veigar",slot=1,type="Circle",delay=1.35,range=900,radius=225,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="nil",killTime=0.5,displayname="DarkMatter",mcollision=false},
	["VeigarEventHorizon"]={charName="Veigar",slot=2,type="Ring",delay=0.5,range=700,radius=400,speed=math.huge,addHitbox=false,danger=3,dangerous=true,proj="nil",killTime=3.5,displayname="EventHorizon",mcollision=false},
	["VelkozQ"]={charName="Velkoz",slot=0,type="Line",delay=0.25,range=1100,radius=50,speed=1300,addHitbox=true,danger=2,dangerous=false,proj="VelkozQMissile",killTime=0,displayname="",mcollision=true},
	["VelkozQMissileSplit"]={charName="Velkoz",slot=0,type="Line",delay=0.25,range=1100,radius=55,speed=2100,addHitbox=true,danger=2,dangerous=false,proj="VelkozQMissileSplit",killTime=0,displayname="",mcollision=true},
	["VelkozW"]={charName="Velkoz",slot=1,type="Line",delay=0.25,range=1050,radius=88,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="VelkozWMissile",killTime=0,displayname="",mcollision=false},
	["VelkozE"]={charName="Velkoz",slot=2,type="Circle",delay=0.5,range=800,radius=225,speed=1500,addHitbox=false,danger=2,dangerous=false,proj="VelkozEMissile",killTime=0.5,displayname="",mcollision=false},
	["Vi-q"]={charName="Vi",slot=0,type="Line",delay=0.25,range=715,radius=90,speed=1500,addHitbox=true,danger=3,dangerous=true,proj="ViQMissile",killTime=0,displayname="Vi-Q",mcollision=false},
	["VladimirR"] = {charName = "Vladimir",slot=3,type="Circle",delay=0.25,range=700,radius=175,speed=math.huge,addHitbox=true,danger=4,dangerous=true,proj="nil",killTime=0,displayname = "Hemoplague",mcollision=false},
	["Laser"]={charName="Viktor",slot=2,type="Line",delay=0.25,range=1200,radius=80,speed=1050,addHitbox=true,danger=2,dangerous=false,proj="ViktorDeathRayMissile",killTime=0,displayname="",mcollision=false},
	["XerathArcanopulse2"]={charName="Xerath",slot=0,type="Line",delay=0.6,range=1600,radius=95,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="xeratharcanopulse2",killTime=0.5,displayname="Arcanopulse",mcollision=false},
	["XerathArcaneBarrage2"]={charName="Xerath",slot=1,type="Circle",delay=0.7,range=1000,radius=275,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="XerathArcaneBarrage2",killTime=0.3,displayname="ArcaneBarrage",mcollision=false},
	["XerathMageSpear"]={charName="Xerath",slot=2,type="Line",delay=0.2,range=1300,radius=60,speed=1400,addHitbox=true,danger=2,dangerous=true,proj="XerathMageSpearMissile",killTime=0,displayname="MageSpear",mcollision=true},
	["XerathLocusPulse"]={charName="Xerath",slot=3,type="Circle",delay=0.7,range=5600,radius=225,speed=math.huge,addHitbox=true,danger=3,dangerous=true,proj="XerathRMissileWrapper",killTime=0.4,displayname="",mcollision=false},
	["YasuoQ3W"]={charName="Yasuo",slot=0,type="Line",delay=0.4,range=1200,radius=90,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="YasuoQ3",killTime=0,displayname="Steel Tempest ",mcollision=false},
	["ZacQ"]={charName="Zac",slot=0,type="Line",delay=0.5,range=550,radius=120,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZacQ",killTime=0,displayname="",mcollision=false},
	["ZedQ"]={charName="Zed",slot=0,type="Line",delay=0.25,range=925,radius=50,speed=1700,addHitbox=true,danger=2,dangerous=false,proj="ZedQMissile",killTime=0,displayname="",mcollision=false},
	["ZiggsQSpell"]={charName="Ziggs",slot=0,type="Circle",delay=0.5,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell",killTime=0.2,displayname="",mcollision=false},
	["ZiggsQSpell2"]={charName="Ziggs",slot=0,type="Circle",delay=0.47,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell2",killTime=-0.23,displayname="",mcollision=true},
	["ZiggsQSpell3"]={charName="Ziggs",slot=0,type="Circle",delay=0.44,range=1100,radius=200,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsQSpell3",killTime=-0.26,displayname="",mcollision=true},
	["ZiggsW"]={charName="Ziggs",slot=1,type="Circle",delay=0.25,range=1000,radius=275,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsW",killTime=4.1,displayname="",mcollision=false,killName="ZiggsWToggle"},
	["ZiggsE"]={charName="Ziggs",slot=2,type="Circle",delay=0.5,range=900,radius=250,speed=1750,addHitbox=true,danger=2,dangerous=false,proj="ZiggsE",killTime=10,displayname="",mcollision=false},
	["ZiggsR"]={charName="Ziggs",slot=3,type="Circle",delay=0,range=5300,radius=500,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZiggsR",killTime=1.25,displayname="",mcollision=false},
	["ZileanQ"]={charName="Zilean",slot=0,type="Circle",delay=0.3,range=900,radius=210,speed=2000,addHitbox=true,danger=2,dangerous=false,proj="ZileanQMissile",killTime=1.5,displayname="",mcollision=false},
	["ZyraQ"]={charName="Zyra",slot=0,type="Rectangle",delay=0.4,range=800,radius2=400,radius=140,speed=math.huge,addHitbox=true,danger=2,dangerous=false,proj="ZyraQ",killTime=0.35,displayname="",mcollision=false},
	["ZyraE"]={charName="Zyra",slot=2,type="Line",delay=0.25,range=1100,radius=70,speed=1300,addHitbox=true,danger=3,dangerous=true,proj="ZyraE",killTime=0,displayname="Grasping Roots",mcollision=false},
	--["ZyraRSplash"]={charName="Zyra",slot=3,type="Circle",delay=0.7,range=700,radius=550,speed=math.huge,addHitbox=true,danger=4,dangerous=false,proj="ZyraRSplash",killTime=1,displayname="Splash",mcollision=false},--bugged spell
}
	
	BM.SB:Menu("Spells", "Spells")
	BM.SB:Boolean("uS","Enable",true)
	BM.SB:Slider("dV","Danger Value",2,1,5,1)
	BM.SB:Slider("hV","Humanize Value",50,0,100,1)
	BM.SB:Boolean("EC","Enable Collision", true)
	BM.SB:KeyBinding("DoD", "DodgeOnlyDangerous", string.byte(" "))
	BM.SB:KeyBinding("DoD2", "DodgeOnlyDangerous2", string.byte("V"))
	self.object = {}
	self.DoD = false
	self.fT = .75
	self.dt = nil
    DelayAction(function()
		for l,k in pairs(GetEnemyHeroes()) do
			for _,i in pairs(self.s) do
				if not self.s[_] then return end
				if i.charName == k.charName then
					if i.displayname == "" then i.displayname = _ end
					if i.danger == 0 then i.danger = 1 end
					if not BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname] then BM.SB.Spells:Menu(i.charName..""..self.str[i.slot]..""..i.displayname,""..k.charName.." | "..(self.str[i.slot] or "?").." - "..i.displayname) end
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("Dodge"..i.charName..""..self.str[i.slot]..""..i.displayname, "Enable Dodge", true)
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Boolean("IsD"..i.charName..""..self.str[i.slot]..""..i.displayname,"Dangerous", i.dangerous or false)		
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Info("Empty12"..i.charName..""..self.str[i.slot]..""..i.displayname, "")
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("radius"..i.charName..""..self.str[i.slot]..""..i.displayname,"Radius",(i.radius or 150), ((i.radius-50) or 50),((i.radius+100) or 250), 5)
						BM.SB.Spells[i.charName..""..self.str[i.slot]..""..i.displayname]:Slider("d"..i.charName..""..self.str[i.slot]..""..i.displayname,"Danger",(i.danger or 1), 1, 5, 1)	
				end
			end
		end
    end, .001)
	Callback.Add("Tick", function() self:Ti() end)
	Callback.Add("ProcessSpell", function(unit, spellProc) self:Detect(unit,spellProc) end)
	Callback.Add("CreateObj", function(obj) self:CreateObj(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DeleteObj(obj) end)
end

function HitMe:Ti()
	if BM.SB.uS:Value() then
		heroes[myHero.networkID] = nil
		for _,i in pairs(self.object) do
			if i.o and i.spell.type == "linear" and GetDistance(myHero,i.o) >= 3000 then return end
			if i and i.spell.type == "circular" and GetDistance(myHero,i.endPos) >= 3000 then return end
			i.spell.speed = i.spell.speed or math.huge
			i.spell.range = i.spell.range or math.huge
			i.spell.proj = i.spell.proj or _
			i.spell.delay = i.spell.delay or 0
			i.spell.radius = i.spell.radius or 100	
			i.spell.mcollision = i.spell.mcollision or false
			i.spell.danger = i.spell.danger or 2
			i.spell.type = i.spell.type or nil
			self.fT = BM.SB.hV:Value()
			self.YasuoWall = {}
			self:MinionCollision(_,i)
			self:HeroCollsion(_,i)
			self:WallCollision(_,i)
			if BM.SB.DoD:Value() or BM.SB.DoD2:Value() then
					self.DoD = true
				else
					self.DoD = false
			end
			for kk,k in pairs(GetEnemyHeroes()) do
				if i.o and not i.o.valid then
					self.object[_] = nil
				end
				if i then
					self.dT = i.spell.delay + GetDistance(myHero,i.startPos) / i.spell.speed
				end
				if ((not self.DoD and BM.SB.dV:Value() <= BM.SB.Spells[i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]["d"..i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]:Value()) or (self.DoD and BM.SB.Spells[i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]["IsD"..i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]:Value())) and BM.SB.Spells[i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]["Dodge"..i.spell.charName..""..self.str[i.spell.slot]..""..i.spell.displayname]:Value() then
					if (i.spell.type == "Line" or i.spell.type == "Cone") and i then
							i.startPos = Vector(i.startPos)
							i.endPos = Vector(i.endPos)
						if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero.pos)
							local v4 = Vector(i.startPos-i.endPos):perpendicular()
							local jp = Vector(VectorIntersection(i.startPos,i.endPos,v3,v4).x,myHero.pos.y,VectorIntersection(i.startPos,i.endPos,v3,v4).y)
							i.jp = jp
							if i.coll then return end
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					elseif i.spell.type == "Circle" then
						if GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
						end
					elseif i.spell.type == "Rectangle" then
						local startp = Vector(i.endPos) - (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
						local endp = Vector(i.endPos) + (Vector(i.endPos) - Vector(i.startPos)):normalized():perpendicular() * (i.spell.radius2 or 400)
						if GetDistance(startp) < i.spell.range + myHero.boundingRadius and GetDistance(endp) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero.pos)
							local v4 = Vector(startp-endp):normalized():perpendicular()
							local jp = Vector(VectorIntersection(startp,endp,v3,v4).x,myHero.pos.y,VectorIntersection(startp,endp,v3,v4).y)
							i.jp = jp
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					elseif i.spell.type == "Return" then
							i.startPos = Vector(i.p.startPos)
							i.endPos = Vector(i.caster.pos)
						if GetDistance(i.p.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero)
							local jp = VectorPointProjectionOnLineSegment(Vector(i.o.pos),i.endPos,v3)
							i.jp = jp	
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					elseif i.spell.type == "follow" then
							i.startPos = Vector(i.caster.pos)
							i.endPos = Vector(i.endPos)
						if GetDistance(i.startPos) < i.spell.range + myHero.boundingRadius and GetDistance(i.endPos) < i.spell.range + myHero.boundingRadius then
							local v3 = Vector(myHero)
							local v4 = Vector(i.caster.pos) + i.TarE
							local jp = VectorPointProjectionOnLineSegment(i.startPos,v4,v3)
							if i.jp and GetDistance(myHero,i.jp) < i.spell.radius + myHero.boundingRadius then
								_G[ChampName]:HitMe(k,i.p,self.dT*self.fT*.001,i.spell.type)
							end
						end
					end
				end
			end
		end
	end
end

function HitMe:MinionCollision(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i.p and BM.SB.EC:Value() and not i.hcoll and not i.wcoll then
		for m,p in pairs(SLM2) do
			if p and p.alive and GetDistance(p.pos,i.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,Vector(p.pos))
				if i.vP and GetDistance(i.vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.startPos,self.vP)
					i.mcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function HitMe:HeroCollsion(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i.p and BM.SB.EC:Value() and not i.mcoll and not i.wcoll then
		for m,p in pairs(heroes) do
			if p and p.alive and p.team == MINION_ALLY and GetDistance(p.pos,i.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.endPos,Vector(p.pos))
				if i.vP and GetDistance(i.vP,p.pos) < (i.spell.radius+p.boundingRadius) then
					i.spell.range = GetDistance(i.startPos,i.vP)
					i.hcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function HitMe:WallCollision(_,i)
	if i.spell.type == "Line" and i.spell.mcollision and i.p and BM.SB.EC:Value()  and not i.mcoll and not i.hcoll then
		for m,p in pairs(self.YasuoWall) do
			if p.obj and p.obj.valid and p.obj.spellOwner.team == MINION_ALLY and GetDistance(p.obj.pos,i.p.startPos) < i.range then
				i.vP = VectorPointProjectionOnLineSegment(Vector(self.opos),i.p.endPos,Vector(p.obj.pos))
				if i.vP and GetDistance(i.vP,p.obj.pos) < (i.spell.radius+p.obj.boundingRadius) then
					i.spell.range = GetDistance(i.p.startPos,i.vP)
					i.wcoll = true
				else
					i.spell.range = i.range
					i.vP = nil
				end
			end
		end
	end
end

function HitMe:CreateObj(obj)
	if obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == MINION_ENEMY then
		for _,l in pairs(self.s) do
			if obj.spellName:lower():find("attack") then return end
			if not self.object[l.charName..""..self.str[l.slot]..""..l.displayname] and self.s[_] and BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname] and BM.SB.dV:Value() <= BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname]["d"..l.charName..""..self.str[l.slot]..""..l.displayname]:Value() and (l.proj == obj.spellName or _ == obj.spellName or obj.spellName:lower():find(_:lower()) or obj.spellName:lower():find(l.proj:lower())) then
				if l.type == ("Line" or "Cone") then 
					endPos = Vector(obj.startPos)+Vector(Vector(obj.endPos)-obj.startPos):normalized()*l.range
				else
					endPos = Vector(obj.endPos)
				end			
				self.object[l.charName..""..self.str[l.slot]..""..l.displayname] = {
				o = obj,
				startPos = Vector(obj.startPos),
				endPos = endPos,
				caster = obj.spellOwner.charName,
				startTime = os.clock(),
				spell = l,
				coll = false,
				range = l.range,
				}
			end
		end
	end
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		if not self.YasuoWall[obj.spellName] then self.YasuoWall[obj.spellName] = {} end
		self.YasuoWall[obj.spellName].obj = obj
	end
end

function HitMe:Detect(unit,spellProc)
	if unit and unit.isHero and unit.team == MINION_ENEMY then
		for _,l in pairs(self.s) do
			if not self.object[l.charName..""..self.str[l.slot]..""..l.displayname] and self.s[_] and BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname] and BM.SB.dV:Value() <= BM.SB.Spells[l.charName..""..self.str[l.slot]..""..l.displayname]["d"..l.charName..""..self.str[l.slot]..""..l.displayname]:Value() and (l.proj == spellProc.name or _ == spellProc.name or spellProc.name:lower():find(_:lower()) or spellProc.name:lower():find(l.proj:lower())) then
				if l.type == ("Line" or "Cone") then 
					endPos = Vector(spellProc.startPos)+Vector(Vector(spellProc.endPos)-spellProc.startPos):normalized()*l.range
				else
					endPos = Vector(spellProc.endPos)
				end
				self.object[spellProc.name] = {
				startPos = Vector(spellProc.startPos),
				endPos = endPos,
				spell = l,
				caster = unit,
				startTime = os.clock(),
				coll = false,
				TarE = (Vector(spellProc.endPos) - Vector(unit.pos)):normalized()*l.range,
				range = l.range,
				}
				DelayAction(function() self.object[spellProc.name] = nil end, l.delay*.001 + 1.3*GetDistance(myHero.pos,spellProc.startPos)/l.speed)				
			end
		end
		for _,l in pairs(self.s) do
			if spellProc.target and spellProc.target == myHero and not spellProc.name:lower():find("attack") and BM.SB.uS:Value() then
				_G[ChampName]:HitMe(unit,spellProc,((l.delay or 0) + GetDistance(myHero,spellProc.startPos) / (l.speed or math.huge))*BM.SB.hV:Value()*.001,l.type)
			end
		end
	end
end

function HitMe:DeleteObj(obj)
	if obj and obj.isSpell and self.object[obj.spellName] then
			self.object[obj.spellName] = nil
	end	
	if (obj.spellName == "YasuoWMovingWallR" or obj.spellName == "YasuoWMovingWallL" or obj.spellName == "YasuoWMovingWallMisVis") and obj and obj.isSpell and obj.spellOwner.isHero and obj.spellOwner.team == myHero.team then
		self.YasuoWall[obj.spellName] = nil
	end
end

class 'SLTS'--Updated version of Inspired TS (credits:Inspired)

function SLTS:__init(type, m, s)
	self.dtype = type
	self.range = {}
	self.str= {[0]="Q",[1]="W",[2]="E",[3]="R"} 
	self.focusselected = true
	self.m = m or nil
	self.morganashield = false
	self.sivirshield = false
	self.nocturneshield = false
	self.item1 = false
	self.item2 = false
	self.pt1 = {"Alistar", "Amumu", "Blitzcrank", "Braum", "ChoGath", "DrMundo", "Garen", "Gnar", "Hecarim", "JarvanIV", "Leona", "Lulu", "Malphite", "Nasus", "Nautilus", "Nunu", "Olaf", "Rammus", "Renekton", "Sejuani", "Shen", "Shyvana", "Singed", "Sion", "Skarner", "Taric", "Thresh", "Volibear", "Warwick", "MonkeyKing", "Yorick", "Zac"}
	self.pt2 = {"Aatrox", "Darius", "Elise", "Evelynn", "Galio", "Gangplank", "Gragas", "Irelia", "Jax","LeeSin", "Maokai", "Morgana", "Nocturne", "Pantheon", "Poppy", "Rengar", "Rumble", "Ryze", "Swain","Trundle", "Tryndamere", "Udyr", "Urgot", "Vi", "XinZhao", "RekSai"}
	self.pt3 = {"Akali", "Diana", "Fiddlesticks", "Fiora", "Fizz", "Heimerdinger", "Janna", "Jayce", "Kassadin","Kayle", "KhaZix", "Lissandra", "Mordekaiser", "Nami", "Nidalee", "Riven", "Shaco", "Sona", "Soraka", "TahmKench", "Vladimir", "Yasuo", "Zilean", "Zyra"}
	self.pt4 = {"Ahri", "Anivia", "Annie", "Brand",  "Cassiopeia", "Ekko", "Karma", "Karthus", "Katarina", "Kennen", "LeBlanc",  "Lux", "Malzahar", "MasterYi", "Orianna", "Syndra", "Talon",  "TwistedFate", "Veigar", "VelKoz", "Viktor", "Xerath", "Zed", "Ziggs" }
	self.pt5 = {"Ashe", "Caitlyn", "Corki", "Draven", "Ezreal", "Graves", "Jinx", "Kalista", "KogMaw", "Lucian", "MissFortune", "Quinn", "Sivir", "Teemo", "Tristana", "Twitch", "Varus", "Vayne"}

	self.m:Boolean("sel", "Focus selected", self.focusselected or false)
	self.m:Boolean("dsel", "Draw current target", true)
	self.m:Boolean("sh", "Include Shields", true)
	self.m:DropDown("mode", "TargetSelector Mode:", 1, {"Normal","Less Cast", "Less Cast Priority", "Priority", "Most AP", "Most AD", "Closest", "Near Mouse", "Lowest Health", "Lowest Health Priority"})
	for i=0,3 do
		if Spell[i] and not Spell[i].ally then
			if myHero.charName ~= "Syndra" then
				self.m:Slider("range"..self.str[i], "Range to check for enemies for : "..self.str[i], Spell[i].range,0,Spell[i].range+2000,50)
			else
				if Spell[i] and Spell[2] and Spell[i].range ~= Spell[2].range then
					self.m:Slider("range"..self.str[i], "Range to check for enemies for : "..self.str[i], Spell[i].range,0,Spell[i].range+2000,50)
				elseif Spell[2] and Spell[2].range then
					self.m:Slider("range"..self.str[2], "Range to check for enemies for : "..self.str[2], Spell[2].range+Spell[-1].range,0,Spell[2].range+Spell[-1].range+2000,50)
				end
			end
		end
	end
	DelayAction(function()
		for k,m in pairs(GetEnemyHeroes()) do
			if m.type == myHero.type then 
				self.m:Slider(m.charName,"Priority for : "..m.charName,self:GetPrioritym(m), 1, 5, 1)
			end
		end
	end,.001)
	self.m:Info("1", "5 = Highest Priority")
	Callback.Add("WndMsg", function(m,k) self:FocusSelected(m,k) end)
	Callback.Add("UpdateBuff", function(u,b) self:UpdateB(u,b) end)
	Callback.Add("RemoveBuff", function(u,b) self:RemoveB(u,b) end)
	Callback.Add("Draw", function() self:Draw() for i=0,3 do if Spell[i] and not Spell[i].ally then self.range[i] = {range = self.m["range"..self.str[i]]:Value()} end end end)
end

function SLTS:UpdateB(u,b)
	if u and b and u.team ~= myHero.team and u.isHero then
		if b.Name == "BlackShield" then
			self.morganashield = true
		elseif b.Name == "SivirShield" then
			self.sivirshield = true
		elseif b.Name == "ShroudofDarkness" then
			self.item1 = true
		elseif b.Name == "BansheesVeil" then
			self.item2 = true
		end
	end
end

function SLTS:RemoveB(u,b)
	if u and b and u.team ~= myHero.team and u.isHero then
		if b.Name == "BlackShield" then
			self.morganashield = false
		elseif b.Name == "SivirShield" then
			self.sivirshield = false
		elseif b.Name == "ShroudofDarkness" then
			self.item1 = false
		elseif b.Name == "BansheesVeil" then
			self.item2 = false
		end
	end
end

function SLTS:IsShielded(i)
	if self.dtype == "AP" and self.m.sh:Value() then
		if self.morganashield or self.sivirshield or self.item1 or self.item2 then
			return true
		end
	end
	return false
end

function SLTS:GetPrioritym(i)
	if table.contains(self.pt5,i.charName) then
		return 5
	elseif table.contains(self.pt4,i.charName)  then
		return 4
	elseif table.contains(self.pt3,i.charName) then
		return 3
	elseif table.contains(self.pt2,i.charName)  then
		return 2
	elseif table.contains(self.pt1,i.charName)  then
		return 1
	else
		return 1
	end
end

function SLTS:GetPriority(i)
	return self.m[i.charName]:Value()
end

function SLTS:IsValid(t)
	if t and t.alive and t.visible and t.valid and not self:IsShielded(t) then
		return true
	else
		return false
	end
end

function SLTS:GetTarget()
	 if self.m.sel:Value() then
		if self:IsValid(self.selected) then
			return self.selected
		else
			self.selected = nil
		end
	end
	if not self.selected then
		for _,i in pairs(GetEnemyHeroes()) do
			for l = 0,3 do 
				if self.range[l] and i.distance < self.range[l].range and not i.dead and Ready(l) then
					if self.m.mode:Value() == 1 then
						local t = nil
						if self:IsValid(GetCurrentTarget()) then
							t = GetCurrentTarget()
						end
						return t 
					end
					if self.m.mode:Value() == 2 then
						local t, p = nil, math.huge
						if self:IsValid(i) and CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0) < p then
							t = i
							p = CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0)
						end
						return t
					end
					if self.m.mode:Value() == 3 then
						local t,p = nil, math.huge
						if self:IsValid(i) and CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0)*self:GetPriority(i) < p then
							t = i
							p = CalcDamage(myHero, i, self.dtype == "AD" and 100 or 0, self.dtype == "AP" and 100 or 0)*self:GetPriority(i)
						end
						return t
					end
					if self.m.mode:Value() == 4 then
						local t, p = nil, math.huge
						if self:IsValid(i) and self:GetPriority(i) < p then
							t = i
							p = self:GetPriority(i)
						end
						return t
					end
					if self.m.mode:Value() == 5 then
						local t, p = nil, -1
						if self:IsValid(i) and i.ap > p then
							t = i
							p = prio
						end
						return t
					end
					if self.m.mode:Value() == 6 then
						local t, p = nil, -1
						if self:IsValid(i) and i.totalDamage > p then
							t = i
							p = i.totalDamage
						end
						return t
					end
					if self.m.mode:Value() == 7 then
						local t, p = nil, math.huge
						if self:IsValid(i) and i.distance < p then
						  t = i
						  p = i.distance
						end
						return t
					end
				end
				if self.m.mode:Value() == 8 then
					local t, p = nil, math.huge
					if self:IsValid(i) and GetDistance(i.pos,GetMousePos()) < p then
						t = i
						p = GetDistance(i.pos,GetMousePos())
					end
					return t
				end
				if self.m.mode:Value() == 9 then
					local t, p = nil, math.huge
					if self:IsValid(i) and i.health < p then
						t = i
						p = i.health
					end
					return t
				end
				if self.m.mode:Value() == 10 then
					local t, p = nil, math.huge
					if self:IsValid(i) and i.health*self:GetPriority(i) < p then
						t = i
						p = i.health*self:GetPriority(i)
					end
					return t
				end
			end
		end
	end
end

function SLTS:FocusSelected(m,k)
	if m == 513 then
		for _,i in pairs(GetEnemyHeroes()) do 
			if GetDistance(i.pos,GetMousePos()) < i.boundingRadius*1.5 and i.alive then
				self.selected = i
			else
				self.selected = nil
			end
		end
	end
end

function SLTS:Draw()
	if self:GetTarget() and self.m.dsel:Value() and self:GetTarget().pos and self:GetTarget().boundingRadius then
		DrawCircle(self:GetTarget().pos,self:GetTarget().boundingRadius*1.35,1,20,GoS.White)
	end
end

class 'AntiChannel'

function AntiChannel:__init()
	self.CSpell = {
    ["CaitlynAceintheHole"]         = {charName = "Caitlyn"		,slot="R"},
    ["Crowstorm"]                   = {charName = "FiddleSticks",slot="R"},
    ["Drain"]                       = {charName = "FiddleSticks",slot="W"},
    ["GalioIdolOfDurand"]           = {charName = "Galio"		,slot="R"},
    ["ReapTheWhirlwind"]            = {charName = "Janna"		,slot="R"},
	["JhinR"]						= {charName = "Jhin"		,slot="R"},
    ["KarthusFallenOne"]            = {charName = "Karthus"     ,slot="R"},
    ["KatarinaR"]                   = {charName = "Katarina"    ,slot="R"},
    ["LucianR"]                     = {charName = "Lucian"		,slot="R"},
    ["AlZaharNetherGrasp"]          = {charName = "Malzahar"	,slot="R"},
    ["MissFortuneBulletTime"]       = {charName = "MissFortune"	,slot="R"},
    ["AbsoluteZero"]                = {charName = "Nunu"		,slot="R"},                       
    ["PantheonRJump"]               = {charName = "Pantheon"	,slot="R"},
    ["ShenStandUnited"]             = {charName = "Shen"		,slot="R"},
    ["Destiny"]                     = {charName = "TwistedFate"	,slot="R"},
    ["UrgotSwap2"]                  = {charName = "Urgot"		,slot="R"},
    ["VarusQ"]                      = {charName = "Varus"		,slot="Q"},
    ["VelkozR"]                     = {charName = "Velkoz"		,slot="R"},
    ["InfiniteDuress"]              = {charName = "Warwick"		,slot="R"},
    ["XerathLocusOfPower2"]         = {charName = "Xerath"		,slot="R"},
	}
	
	DelayAction(function ()
		for k,i in pairs(GetEnemyHeroes()) do
			for _,n in pairs(self.CSpell) do
				if i.charName == n.charName then
					if not BM["AC"] then
						BM:Menu("AC","AntiChannel")
						BM.AC:Info("as", "Stop Channels for : ")
						Callback.Add("ProcessSpell", function(unit,spellProc) self:CheckAC(unit,spellProc) end)
					end
					if not BM.AC[_] then
						BM.AC:Boolean(_,n.charName.." | "..n.slot, true)
					end
				end
			end
		end
	end, .001)
end

function AntiChannel:CheckAC(unit,spellProc)
	if GetTeam(unit) == MINION_ENEMY and self.CSpell[spellProc.name] and BM.AC[spellProc.name]:Value() then
		_G[ChampName]:AntiChannel(unit,GetDistance(myHero,unit))
	end
end

class 'AntiGapCloser'

function AntiGapCloser:__init()
	self.GSpells = {
    ["AkaliShadowDance"]            = {charName = "Akali",		slot="R"		},
    ["Headbutt"]                    = {charName = "Alistar",	slot="Q"		},
    ["DianaTeleport"]               = {charName = "Diana",		slot="R"		},
    ["FizzPiercingStrike"]          = {charName = "Fizz",		slot="Q"		},
    ["IreliaGatotsu"]               = {charName = "Irelia",		slot="Q"		},
    ["JaxLeapStrike"]               = {charName = "Jax",		slot="Q"		},
    ["JayceToTheSkies"]             = {charName = "Jayce",		slot="Q"		},
    ["blindmonkqtwo"]               = {charName = "LeeSin",		slot="Q"		},
    ["MonkeyKingNimbus"]            = {charName = "MonkeyKing",	slot="E"		},
    ["Pantheon_LeapBash"]           = {charName = "Pantheon",	slot="W"		},
    ["PoppyHeroicCharge"]           = {charName = "Poppy",		slot="E"		},
    ["QuinnE"]                      = {charName = "Quinn",		slot="E"		},
    ["RengarLeap"]                  = {charName = "Rengar",		slot="Passive"	},
    ["XenZhaoSweep"]                = {charName = "XinZhao",	slot="E"		},
    ["AatroxQ"]                     = {charName = "Aatrox",		slot="Q"		},
    ["GragasE"]                     = {charName = "Gragas",		slot="E"		},
    ["GravesMove"]                  = {charName = "Graves",		slot="E"		},
    ["JarvanIVDragonStrike"]        = {charName = "JarvanIV",	slot="Q"		},
    ["JarvanIVCataclysm"]           = {charName = "JarvanIV",	slot="R"		},
    ["KhazixE"]                     = {charName = "Khazix",		slot="E"		},
    ["khazixelong"]                 = {charName = "Khazix",		slot="E"		},
    ["LeblancSlide"]                = {charName = "Leblanc",	slot="W"		},
    ["LeblancSlideM"]               = {charName = "Leblanc",	slot="W"		},
    ["LeonaZenithBlade"]            = {charName = "Leona",		slot="E"		},
    ["RenektonSliceAndDice"]        = {charName = "Renekton",	slot="E"		},
    ["SejuaniArcticAssault"]        = {charName = "Sejuani",	slot="E"		},
    ["ShenShadowDash"]              = {charName = "Shen",		slot="E"		},
    ["RocketJump"]                  = {charName = "Tristana",	slot="W"		},
    ["slashCast"]                   = {charName = "Tryndamere",	slot="E"		},
	}
	
	DelayAction(function ()
		for k,i in pairs(GetEnemyHeroes()) do
			for _,n in pairs(self.GSpells) do
				if i.charName == n.charName then
					if not BM["AGC"] then
						BM:Menu("AGC","AntiGapCloser")
						BM.AGC:Info("as", "AntiGapCloser for : ")
						Callback.Add("ProcessSpell", function(unit,spellProc) self:CheckAGC(unit,spellProc) end)
					end
					if not BM.AGC[_] then
						BM.AGC:Boolean(_,n.charName.." | "..n.slot, true)
					end
				end
			end
		end
	end, .001)
end

function AntiGapCloser:CheckAGC(unit,spellProc)
	if unit.team == MINION_ENEMY and self.GSpells[spellProc.name] and BM.AGC[spellProc.name]:Value() then
		_G[ChampName]:AntiGapCloser(unit,GetDistance(myHero,unit))
	end
end