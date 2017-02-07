if GetObjectName(GetMyHero()) ~= "Xerath" then return end

if FileExist(COMMON_PATH.."MixLib.lua") then
	require('MixLib')
else
	PrintChat("MixLib not found. Please wait for download.")
 	DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end 

require('DamageLib')
require('OpenPredict')
require('ChallengerCommon')

local XM = Menu('Xerath', 'Xerath')
XM:SubMenu('C', 'Combo')
XM.C:Boolean('Q','Use Q',true)									 
XM.C:Boolean('W','Use W',true) 									 
XM.C:Boolean('E','Use E',true)									 

XM:SubMenu('R', 'Ult Menu')
XM.R:Slider('Slider','TARGET DISTANCE TO CURSOR',1000,0,9000,100)
XM.R:KeyBinding('SAK','Key', string.byte('T'))
XM.R:DropDown('MODE', 'Ult Mode', 1, {'Automatic', 'Manual'})

XM:SubMenu('KS', 'KillSteal')
XM.KS:Boolean('Q', 'Kill steal with Q',true)				
XM.KS:Boolean('W', 'Kill steal with W',true)				
XM.KS:Boolean('E', 'Kill steal with E',true)

XM:SubMenu('HC', 'Spells Hit Chance')
XM.HC:Slider('QHC', 'Q hit chance %', 70, 0, 100, 2)         
XM.HC:Slider('WHC', 'W hit chance %', 70, 0, 100, 2)		 
XM.HC:Slider('EHC', 'E hit chance %', 70, 0, 100, 2)         
XM.HC:Slider('RHC', 'R hit chance %', 70, 0, 100, 2)         

XM:SubMenu('DR', 'Drawings')
XM.DR:Boolean("CQ", "Draw Current Q range", true)			 
XM.DR:Boolean("MQ", "Draw Q Max range", true)				 
XM.DR:Boolean("W", "Draw W range", true)					 
XM.DR:Boolean("E", "Draw E range", true)					 
XM.DR:Boolean("R", "Draw R range on minimap", true)			 
XM.DR:Boolean('DRK','Draw Killable enemies with R', true)    
XM.DR:Boolean('DCR','Draw Enemy finder for R', true) 		 
XM.DR:Boolean('DRT','Draw circle on R target',true)			 
XM.DR:Boolean('Dev','Dev mode')

XM:SubMenu('M','Misc')										 

OnLoad(function()
	ChallengerCommon.Interrupter(XM.M, function(unit, spell)
		if GetTeam(myHero) ~= GetTeam(unit) then
			CastE(unit)
		end
	end)
	
	ChallengerCommon.AntiGapcloser(XM.M, function(unit, spell)
		if GetTeam(myHero) ~= GetTeam(unit) then
			CastE(unit)
		end
	end)
end) 

local castingQ = false
local castingR = false
local StartQtime = 0
local Rtarget = nil
local ripfag = nil
local KillableTable = {}
local Q = {BuffName = "XerathArcanopulseChargeUp", speed = math.huge, delay = 0.6, width = 145, minRange = 750, maxRange = 1500, range = 0}
local W = {speed = math.huge, delay = 0.7, radius = 200, range = 1200}
local E = {speed = 1400, delay = 0.2, radius = 60, range = 1000}
local R = {BuffName = "XerathLocusOfPower2",speed = math.huge, delay = 0.75, radius = 130, range = 0, maxStacks = 0}

OnUpdateBuff(function(unit,buff)
	if unit == myHero then
		if buff.Name == Q.BuffName then
			castingQ = true
			StartQtime = buff.StartTime
		end
		if buff.Name == R.BuffName then
			castingR = true
		end
	end
end)

OnRemoveBuff(function(unit,buff) 
	if unit == myHero then
		if buff.Name == Q.BuffName then
			castingQ = false
			StartQtime = GetGameTimer()
		end
		if buff.Name == R.BuffName then
			castingR = false
		end
	end
end)

function currentQRange()
	range1 = Q.minRange + ((GetGameTimer() - StartQtime)*500)
		if castingQ then
			if range1 > 1500 then
				range1 = 1500
			else
				range1 = range1
			end
		elseif not castingQ then
			range1 = Q.minRange
		end
  	Q.range = range1
	return range1
end

function CastQ(unit)
	if not castingR then
		if Ready(_Q) and ValidTarget(unit, Q.maxRange) then
			if not castingQ then
				CastSkillShot(_Q, GetMousePos())
			else
				local Qpred = GetLinearAOEPrediction(unit, Q)
				if Qpred.hitChance >= (XM.HC.QHC:Value()*0.01) then
					CastSkillShot2(_Q, Qpred.castPos)
				end
			end
		end
	end
end

function CastW(unit)
	if not castingQ and not castinR then
		if Ready(_W) and ValidTarget(unit, W.range) then
			local Wpred = GetCircularAOEPrediction(unit, W)
			if Wpred.hitChance >= (XM.HC.QHC:Value()*0.01) then
				CastSkillShot(_W, Wpred.castPos)
			end
		end
	end
end

function CastE(unit)
	if not castingQ and not castingR then
		if Ready(_E) and ValidTarget(unit, E.range) then
			local Epred = GetPrediction(unit, E)
			if Epred.hitChance >= (XM.HC.QHC:Value()*0.01) and not Epred:mCollision(1) then
				CastSkillShot(_E, Epred.castPos)
			end
		end
	end
end

function CastR(unit)
	local Rpred = GetCircularAOEPrediction(unit, R)
	if Rpred.hitChance >= (XM.HC.RHC:Value()*0.01) then
		CastSkillShot(_R, Rpred.castPos)
	end
end

function Ulterino()
	if castingR and Rtarget ~= nil then
		if XM.R.MODE:Value() == 1 then
			CastR(Rtarget)
		elseif XM.R.MODE:Value() == 2 then
			if XM.R.SAK:Value() then
				CastR(Rtarget)
			end
		end
	end		
end

function currentRtarget()
	if castingR then
		for x, enemy in pairs(GetEnemyHeroes()) do
			if ValidTarget(enemy, R.range) and GetDistance(enemy, GetMousePos()) <= XM.R.Slider:Value() then
				if Rtarget == nil then
					Rtarget = enemy
				elseif Rtarget ~= nil then
					if GetCurrentHP(enemy) - (getdmg('R', enemy) * R.maxStacks) < GetCurrentHP(Rtarget) - (getdmg('R', enemy) * R.maxStacks) then
						RTarget = enemy
					end
				elseif Rtarget ~= nil and IsDead(Rtarget) then
					Rtarget = nil
				end
			end
		end
	else
		Rtarget = nil	
	end	
end

function currentRrange()
	if Ready(_R) then
		range3 = 2000 + 1200*GetCastLevel(myHero, _R)
		stacks = 2 + GetCastLevel(myHero, _R)
		R.range = range3
		R.maxStacks = stacks
	else
		R.range = 0
		RmaxStacks = 0
	end
end

function Combo()
	if Mix:Mode() == "Combo" then
		if XM.C.Q:Value() then
			CastQ(target)
		end
		if XM.C.W:Value() then
			CastW(target)
		end
		if XM.C.E:Value() then
			CastE(target)
		end
	end
end

function KillSteal()
	for x, enemy in pairs(GetEnemyHeroes()) do
		if not castingR then
			if XM.KS.Q:Value() and GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy) < getdmg('Q', enemy) then
				CastQ(enemy)
			end
			if XM.KS.W:Value() and GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy) < getdmg('W', enemy) then
				CastW(enemy)
			end
			if XM.KS.E:Value() and GetCurrentHP(enemy) + GetDmgShield(enemy) + GetMagicShield(enemy) < getdmg('E', enemy) then
				CastE(enemy)
			end
		end
	end
end

OnTick(function(myHero)
	target = GetCurrentTarget()
	Combo()
	currentQRange()
	currentRrange()
	currentRtarget()
	Ulterino()
	KillSteal()
end)

OnDraw(function(myHero)
	if XM.DR.Dev:Value() then
 		DrawText("Q range: "..Q.range, 20, 50, 280, GoS.White)
 		if castingQ then
 			DrawText("Casting Q: ".."true", 20, 50, 240, GoS.Green)
 		else 
 			DrawText("Casting Q: ".."false", 20, 50, 240, GoS.Red)
 		end
	  	if castingR then
 			DrawText("Casting R: ".."true", 20, 50, 260, GoS.Green)
 		else 
 			DrawText("Casting R: ".."false", 20, 50, 260, GoS.Red)
		end

		if target ~= nil then
			DrawText("QDMG :"..getdmg("Q", target), 20, 50, 220, GoS.White)
			DrawText("WDMG :"..getdmg("W", target), 20, 50, 200, GoS.White)
			DrawText("EDMG :"..getdmg("E", target), 20, 50, 180, GoS.White)
			DrawText("RDMG :"..getdmg("R", target), 20, 50, 140, GoS.White)
			DrawText('Rrange :'..R.range,20,50,120, GoS.White)
			DrawText('Rstacks :'..R.maxStacks,20,50,100, GoS.White)
		end

		if Rtarget ~= nil then
			DrawText('Rtarget :'..Rtarget.charName,20,50,80, GoS.Green)
		else
			DrawText('Rtarget : nil',20,50,80, GoS.Red)
		end
	end

	if XM.DR.DCR:Value() then
		DrawCircle(GetMousePos(),XM.R.Slider:Value(),1,25,ARGB(255,0,77,255))
	end

	if XM.DR.DRK:Value() then
		for a, enemy in pairs(GetEnemyHeroes()) do
			if GetCurrentHP(enemy) < getdmg("R", enemy) * R.maxStacks and IsObjectAlive(enemy) then
				DrawText(enemy.charName.." is Killable",20,1200,100 + (20*a),GoS.Cyan)
			end
		end
	end

	if XM.DR.DRT:Value() and Rtarget ~= nil then
		DrawCircle(Rtarget.pos, GetHitBox(Rtarget), 1, 25, GoS.Cyan)
	end

	if XM.DR.E:Value() and Ready(_E) then
		DrawCircle(myHero.pos,E.range,1,25,GoS.Cyan)
	end

	if XM.DR.W:Value() and Ready(_W) then
		DrawCircle(myHero.pos,W.range,1,25,GoS.Cyan)
	end
	if XM.DR.CQ:Value() and Ready(_Q) then
		DrawCircle(myHero.pos,Q.range,1,25,GoS.Cyan)
	end

	if XM.DR.MQ:Value() and Ready(_Q) then
		DrawCircle(myHero.pos,Q.maxRange,1,25,GoS.Cyan)
	end
end)

OnDrawMinimap(function()
	if XM.DR.R:Value() then
		DrawCircleMinimap(GetMyHero().pos,R.range,1,25,GoS.White)
	end
end)

PrintChat("<font color=\"#adff2f\">[Salami Series]:</font> <font color=\"#00FFFF\">Xerath</font> <font color=\"#adff2f\">Injected successfully!</font>")
