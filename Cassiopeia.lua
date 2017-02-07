
if GetObjectName(GetMyHero()) ~= "Cassiopeia" then return end

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end 

require("DamageLib")
require('OpenPredict')

local ver = 2.0

local CM = Menu('Cassiopeia', 'Cassiopeia')
CM:SubMenu('C', 'Combo')
CM.C:Boolean('Q', 'Use Q', true)
CM.C:Boolean('W', 'Use W', true)
CM.C:Boolean('E', 'Use E', true)
CM.C:Boolean('EP', 'Only Use E if enemy poisoned', true)
CM.C:Menu('R', 'R menu')
CM.C.R:Boolean("R",'Use R')
CM.C.R:Slider('MR','Minimun enemies facing to ult',3,1,5,1)

CM:SubMenu('KS', 'Kill Steal')
CM.KS:Boolean('KSQ', 'Killsteal with Q', true)
CM.KS:Boolean('KSE', 'Killsteal with E', true)
CM.KS:Boolean('KSR', 'Killsteal with R', true)

CM:SubMenu('AL', 'Auto level')
CM.AL:Boolean('ALV', 'Auto level spells')
CM.AL:Boolean('EQE', 'E->Q->E Order')
CM.AL:Boolean('EQW', 'E->Q->W Order', true)

CM:SubMenu('LC', 'Lane Clear')
CM.LC:Boolean('Q', 'Use Q', true)
CM.LC:Boolean('E', 'Use E', true)
CM.LC:Boolean('ALH', 'Auto Last Hit with E', true)
CM.LC:Slider('ALHM', 'Minimun mana to auto last hit %', 60, 0, 100, 2)

CM:SubMenu('M', 'Misc')
CM.M:Boolean('AS', 'Auto stack tear', false)

CM:SubMenu('HC', 'Spells Hit Chance')
CM.HC:Slider('QHC', 'Q hit chance %', 60, 0, 100, 2)
CM.HC:Slider('WHC', 'W hit chance %', 60, 0, 100, 2)
CM.HC:Slider('RHC', 'R hit chance %', 60, 0, 100, 2)

CM:SubMenu('DR', 'Drawnings')
CM.DR:Boolean("Q", "Draw Q range", true)
CM.DR:Boolean("W", "Draw W range", true)
CM.DR:Boolean("E", "Draw E range", true)
CM.DR:Boolean("R", "Draw R range", true)
CM.DR:Boolean("ODR", "Only draw when skills are ready")

local CassioQ = {delay = 0.6, range = 850, radius = 75, speed = math.huge}
local CassioW = {delay = 0.5, range = 900, radius = 160, speed = 2500}
local CassioR = {delay = 0.6, range = 825, angle = 80, speed = math.huge}
local mybase = 0
qTime = 0

DelayAction(function()
	if GetTeam(myHero) == 100 then
		mybase = Vector(396, 182.132507, 462)
	elseif GetTeam(myHero) == 200 then
		mybase = Vector(14340, 171.977722, 14390)
	end
end)

OnDraw(function()
	
	if CM.DR.ODR:Value() then

		if Ready(_Q) and CM.DR.Q:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_Q),1,25,GoS.Blue)
		end

		if Ready(_W) and CM.DR.W:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_W),1,25,GoS.Pink)
		end

		if Ready(_E) and CM.DR.E:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_E),1,25,GoS.Green)
		end

		if Ready(_R) and CM.DR.R:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_R),1,25,GoS.Yellow)
		end

	else

		if CM.DR.Q:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_Q),1,25,GoS.Blue)
		end

		if CM.DR.W:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_W),1,25,GoS.Pink)
		end

		if CM.DR.E:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_E),1,25,GoS.Green)
		end

		if CM.DR.R:Value() then
			DrawCircle(myHero,GetCastRange(myHero,_R),1,25,GoS.Yellow)
		end
	end
end)

OnTick(function(myHero)

	target = GetCurrentTarget()
		
		enemiesFacing()

		Combo()
		 
		LaneClear()

		KillSteal()

		AutoLvl()

		AutoLastHit()

		AutoStackTear()
end)

function AngleBetween(p1, p2)
  local theta = p1:polar() - p2:polar()
  if theta < 0 then
    theta = theta + 360
  end
  if theta > 180 then
    theta = 360 - theta
  end
  return theta
end

function IsFacing(unit)
	if ValidTarget(unit, 825) then
		if AngleBetween(Vector(GetDirection(unit)), Vector(myHero)-Vector(unit)) < 90 and AngleBetween(Vector(GetDirection(myHero)), Vector(unit)-Vector(myHero)) < 70 then
  			return true
  		else
			return false
		end
	end
end

function enemiesFacing()
	count = 0
	for x,enemy in pairs(GetEnemyHeroes()) do
		if IsFacing(enemy) then
			count = count + 1
		end
	end
	return count
end

function Combo()
	if Mix:Mode() == "Combo" then

		if CM.C.Q:Value() and ValidTarget(target, 850) and Ready(_Q) then
			CastQ(target)
		end

		if CM.C.W:Value() and ValidTarget(target, 900) and Ready(_W) and qTime < (GetGameTimer() - 1) and not target.isPoisoned then
			CastW(target)
		end

		if CM.C.E:Value() and ValidTarget(target, GetCastRange(myHero, _E)) and Ready(_E) then
			CastE(target)
		end

		if CM.C.R.R:Value() and Ready(_R) then
			if count >= CM.C.R.MR:Value() then
				CastR(target)
			end
		end
	end
end

function CastQ(unit)
	local predQ = GetCircularAOEPrediction(unit, CassioQ)
	if Mix:Mode() ~= "LaneClear" then
		if predQ.hitChance >= (CM.HC.QHC:Value()*0.01) then
			CastSkillShot(_Q, predQ.castPos)
		end
	elseif Mix:Mode() == "LaneClear" then
		local farmpos = GetFarmPosition(CassioQ.range, CassioQ.radius *2,GetTeam(unit))
		CastSkillShot(_Q, farmpos)

	end
end

function CastW(unit)

	local predW = GetCircularAOEPrediction(unit, CassioW)

	if predW.hitChance >= (CM.HC.WHC:Value()*0.01) and unit.distance > 500 then
		CastSkillShot(_W, predW.castPos)
	end
end

function CastE(unit)
	if CM.C.EP:Value() then

		if Ready(_E) and ValidTarget(unit, GetCastRange(myHero, _E)) and unit.isPoisoned then
			CastTargetSpell(unit, _E)
		end

	else

		if Ready(_E) and ValidTarget(unit, GetCastRange(myHero, _E)) then
			CastTargetSpell(unit, _E)
		end
	end
end

function CastR(unit)
	local predR = GetConicAOEPrediction(unit, CassioR)

	if CM.C.R.R:Value() then
		if predR.hitChance >= (CM.HC.RHC:Value()*0.01) then
			CastSkillShot(_R, predR.castPos)
		end
	end
end

function KillSteal()
	for _, enemy in pairs(GetEnemyHeroes()) do

		if CM.KS.KSQ:Value() and Ready(_Q) and ValidTarget(enemy, 850) and GetCurrentHP(enemy) < getdmg("Q", enemy) then
			CastQ(enemy)
		end

		if CM.KS.KSE:Value() and Ready(_E) and ValidTarget(enemy, 850) and GetCurrentHP(enemy) < getdmg("E", enemy) then
			CastE(enemy)
		end

		if CM.KS.KSR:Value() and Ready(_R) and ValidTarget(enemy, 825) and GetCurrentHP(enemy) < getdmg("R", enemy) then

			local predR = GetConicAOEPrediction(enemy, CassioR)

			if predR.hitChance >= (CM.HC.RHC:Value()*0.01) then -- slider
				CastSkillShot(_R, predR.castPos)
			end
		end
	end
end

function AutoLastHit()
	if Mix:Mode() ~= "Combo" then
	  	if Ready(_E) and CM.LC.ALH:Value() then 
	  		if GetCurrentMana(myHero) > CM.LC.ALHM:Value() * GetMaxMana(myHero) * 0.01 then
	  			for _, minion in pairs(minionManager.objects) do
	  				if IsObjectAlive(minion) and GetTeam(minion) ~= MINION_ALLY and GetDistance(minion) <= 700 and GetCurrentHP(minion) < getdmg("E", minion) then
	  					CastTargetSpell(minion, _E)
	  				end
	  			end
	  		end
	  	end
	end
end

function AutoLvl()

	-------{ 1  2  3  4  5  6  7  8  9 10 11 12 13 14 15 16 17 18}
	EQEt = {_E,_Q,_E,_W,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}
	EQWt = {_E,_Q,_W,_E,_E,_R,_E,_Q,_E,_Q,_R,_Q,_Q,_W,_W,_R,_W,_W}

	if CM.AL.EQE:Value() then
		CM.AL.EQW:Value(false)
	end

	if CM.AL.EQW:Value() then
		CM.AL.EQE:Value(false)
	end


	if CM.AL.ALV:Value() and GetLevelPoints(myHero) > 0 then

		if CM.AL.EQE:Value() and not CM.AL.EQW:Value() then
			LevelSpell(EQEt[GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end

		if CM.AL.EQW:Value() and not CM.AL.EQE:Value() then
			LevelSpell(EQWt[GetLevel(myHero)-GetLevelPoints(myHero)+1])
		end
	end
end

function LaneClear()
	if Mix:Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) ~= MINION_ALLY then
				if CM.LC.Q:Value() and Ready(_Q) and ValidTarget(minion, 850) then
					CastQ(minion)
				end
				if CM.LC.E:Value() and Ready(_E) and ValidTarget(minion, GetCastRange(myHero, _E)) then
					CastE(minion)
				end
			end
		end
	end	
end

function AutoStackTear()
	local gota = GetItemSlot(myHero, 3070)
	local abrasso = GetItemSlot(myHero, 3003)
	if gota > 1 or abrasso > 1 then
		if CM.M.AS:Value() then
			if GetDistance(mybase, myHero) < 1000 then
				if Ready(_Q) then
					CastSpell(_Q)
				end
			end
		end
	end
end

OnProcessSpell(function(unit,spell)
	if unit == myHero and spell.owner == myHero then
 		if spell.name:lower():find("cassiopeiae") then
 			DelayAction(function()
				CastEmote(EMOTE_DANCE)	
			end, spell.windUpTime - GetLatency() * 0.001)
		end
	end

	if spell.name:lower():find("cassiopeiaq") then
		qTime = GetGameTimer()
	end
end)

PrintChat("<font color=\"#adff2f\">[Salami Series]:</font> <font color=\"#00FFFF\">Cassiopeia</font> <font color=\"#adff2f\">Injected successfully!</font>")

---- Thanks to deftsu, zwei/Logge <3, and tosh
