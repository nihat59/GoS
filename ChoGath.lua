--Hero
if GetObjectName(GetMyHero()) ~= "Chogath" then return end

--[[
╔══╦╗╔╦══╦═══╦══╦════╦╗╔╗  
║╔═╣║║║╔╗║╔══╣╔╗╠═╗╔═╣║║║    
║║─║╚╝║║║║║╔═╣╚╝║─║║─║╚╝║
║║─║╔╗║║║║║╚╗║╔╗║─║║─║╔╗║
║╚═╣║║║╚╝║╚═╝║║║║─║║─║║║║
╚══╩╝╚╩══╩═══╩╝╚╝─╚╝─╚╝╚╝ 
LoL Patch : 6.22
Script Verison : 0.03
By Shulepin
_________________________

Credits:
-Deftsu(http://gamingonsteroids.com/user/220-deftsu/)
-Zwei(http://gamingonsteroids.com/user/13058-zwei/)
-Noddy(http://gamingonsteroids.com/user/304-noddy/)
-Icesythe7(http://gamingonsteroids.com/user/5317-icesythe7/)
-jouzuna(http://gamingonsteroids.com/user/171-jouzuna/)
]]--

--Auto Update
local ver = "0.03"
local DmgHPBar = { }

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("<font color=\"#FE2EC8\"><b>[Cho'Gath]: </b></font><font color=\"#FFFFFF\"> New version found!</font>")
        print("<font color=\"#FE2EC8\"><b>[Cho'Gath]: </b></font><font color=\"#FFFFFF\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/ChoGath.lua", SCRIPT_PATH .. "ChoGath.lua", function() print("<font color=\"#FE2EC8\"><b>[Cho'Gath]: </b></font><font color=\"#FFFFFF\"> Update Complete, please 2x F6!</font>") return end)
    else
       print("<font color=\"#FE2EC8\"><b>[Cho'Gath]: </b></font><font color=\"#FFFFFF\"> No Updates Found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/ChoGath.version", AutoUpdate)

--Load Libs
require('OpenPredict')
require('MixLib')
require('ChallengerCommon')

--Main Menu
ChoMenu = Menu("Cho", "Cho'Gath")

--Combo Menu
ChoMenu:SubMenu("c", "Combo")
ChoMenu.c:Boolean("Q", "Use Q", true)
ChoMenu.c:Boolean("W", "Use W", true)

--Ultimate Menu
ChoMenu:SubMenu("u", "Ultimate")
ChoMenu.u:Boolean("R", "Use R", true)

--Harass Menu
ChoMenu:SubMenu("h", "Harass")
ChoMenu.h:Boolean("Q", "Use Q", true)
ChoMenu.h:Boolean("W", "Use W")
ChoMenu.h:Slider("mana", "Min. Mana(%) To Harass",60,0,100,1)

--Clear Menu
ChoMenu:SubMenu("l", "Clear")
ChoMenu.l:Boolean("Q", "Use Q", true)
ChoMenu.l:Boolean("W", "Use W", true)
ChoMenu.l:Slider("mana", "Min. Mana(%) To Clear",65,0,100,1)
ChoMenu.l:Slider("limQ", "Use Q if Minions Around >= X",3,1,10,1)
ChoMenu.l:Slider("limW", "Use W if Minions Around >= X",2,1,10,1)

--KS
ChoMenu:SubMenu("k", "Kill Steal")
ChoMenu.k:Boolean("Q", "Use Q", true)
ChoMenu.k:Boolean("W", "Use W", true)
ChoMenu.k:Boolean("I", "Use Ignite", true)

--Pred Menu
ChoMenu:SubMenu("p", "Prediction")
ChoMenu.p:Slider("Qh", "HitChance Q", 50, 0, 100, 1)
ChoMenu.p:Slider("Wh", "HitChance W", 50, 0, 100, 1)

--AGC
ChoMenu:SubMenu("AGC", "Anti-GapCloser")
ChoMenu.AGC:Boolean("Q", "Use Q", true)
ChoMenu.AGC:Boolean("W", "Use W", true)

--Interr
ChoMenu:SubMenu("Interrupter", "Interrupter")
ChoMenu.Interrupter:Boolean("Q", "Use Q", true)
ChoMenu.Interrupter:Boolean("W", "Use W", true)

--Draw Menu
ChoMenu:SubMenu("dr", "Draw")
OnLoad(function()
	for i, enemy in pairs(GetEnemyHeroes()) do
		ChoMenu.dr:SubMenu("HPBar_"..enemy.charName, "Draw DmgHPBar On "..enemy.charName)
		DmgHPBar[i] = DrawDmgHPBar(ChoMenu.dr["HPBar_"..enemy.charName], {ARGB(200, 89, 0 ,179), ARGB(200, 0, 245, 255), ARGB(200, 186, 85, 211)}, {"R", "Q", "W"})
	end

	Interrupter()
	AntiGapCloser()
end)
ChoMenu.dr:Boolean("KillRtext", "Draw text", true)
ChoMenu.dr:Boolean("DrRanQ", "Draw Q Range", true)
ChoMenu.dr:Boolean("DrRanW", "Draw W Range", true)
ChoMenu.dr:Boolean("DrRanR", "Draw R Range")

--Misc Menu
ChoMenu:SubMenu("m", "Misc")
ChoMenu.m:SubMenu("s", "Skin Changer")
ChoMenu.m.s:Boolean("sb", "Use Skin Changer")
ChoMenu.m.s:Slider("cs", "Choose Skin", 0, 0, 10, 1)

--Locals
local LoL = "6.22"
local _skin = 0
local RangeQ = 950
local RangeW = 650
local RangeR = 250
local Ignite = (GetCastName(GetMyHero(),SUMMONER_1):lower():find("summonerdot") and SUMMONER_1 or (GetCastName(GetMyHero(),SUMMONER_2):lower():find("summonerdot") and SUMMONER_2 or nil))

--Tables
local ChoQ = { delay = 1.200, speed = math.huge , width = 100, range = RangeQ }
local ChoW = { delay = 0.250, speed = math.huge, range = RangeW, angle = 60}

--Start
OnTick(function(myHero)
	if not IsDead(myHero) then
		--Locals
		local target = GetCurrentTarget()
		--Functions
		OnCombo(target)
		OnHarass(target)
		OnClear()
		OnKillSteal()
		CastR()
		skin()
		UpdateDmgHPBar()
	end
end)

OnDraw(function(myHero)
    --Locals
	local qRdy = Ready(0)
	local wRdy = Ready(1)
	local eRdy = Ready(2)
	local rRdy = Ready(3)

	--Text
	for x,unit in pairs(GetEnemyHeroes()) do 
		if WorldToScreen(0,unit.pos).flag and ChoMenu.dr.KillRtext:Value() and rRdy and ValidTarget(unit,1500) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDmg(3,unit) then
			DrawText(unit.charName.." R Killable", 20, GetHPBarPos(unit).x, GetHPBarPos(unit).y+150, GoS.Red)
		end
	end

    --Range
	if ChoMenu.dr.DrRanQ:Value() then DrawCircle(myHero, RangeQ, 1, 25, GoS.Green) end
	if ChoMenu.dr.DrRanW:Value() then DrawCircle(myHero, RangeW, 1, 25, GoS.Yellow) end
	if ChoMenu.dr.DrRanR:Value() then DrawCircle(myHero, RangeR, 1, 25, GoS.Red) end

    --Damage
	for i, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, 2000) and DmgHPBar[i] then
			DmgHPBar[i]:Draw()
		end
	end	
end)

--Functions
function OnCombo(target)
	--Locals
	local qRdy = Ready(0)
	local wRdy = Ready(1)
	local eRdy = Ready(2)
	local rRdy = Ready(3)

	--Main
	if Mix:Mode() == "Combo" then
		--Q
		if ChoMenu.c.Q:Value() and qRdy and ValidTarget(target, RangeQ) then
			local QPred = GetCircularAOEPrediction(target, ChoQ)
			if QPred and QPred.hitChance >= (ChoMenu.p.Qh:Value()/100) then
				CastSkillShot(0, QPred.castPos)
			end
		end
		--W
		if ChoMenu.c.W:Value() and wRdy and ValidTarget(target, RangeW) then
			local WPred = GetConicAOEPrediction(target, ChoW)
			if WPred and WPred.hitChance >= (ChoMenu.p.Wh:Value()/100) then
				CastSkillShot(1, WPred.castPos)
			end
		end
	end
end

function OnHarass(target)
	--Locals
	local qRdy = Ready(0)
	local wRdy = Ready(1)

	--Main
	if Mix:Mode() == "Harass" then
		--Q
		if ChoMenu.h.Q:Value() and qRdy and ValidTarget(target, RangeQ) then
			local QPred = GetCircularAOEPrediction(target, ChoQ)
			if QPred and QPred.hitChance >= (ChoMenu.p.Qh:Value()/100) then
				if ChoMenu.h.mana:Value() <= GetPercentMP(myHero) then
					CastSkillShot(0, QPred.castPos)
				end
			end
		end
		--W
		if ChoMenu.h.W:Value() and wRdy and ValidTarget(target, RangeW) then
			local WPred = GetConicAOEPrediction(target, ChoW)
			if WPred and WPred.hitChance >= (ChoMenu.p.Wh:Value()/100) then
				if ChoMenu.h.mana:Value() <= GetPercentMP(myHero) then
					CastSkillShot(1, WPred.castPos)
				end
			end
		end
	end
end

function OnClear(target)
	--Locals
	local qRdy = Ready(0)
	local wRdy = Ready(1)

	--Main
	if Mix:Mode() == "LaneClear" then
		for x, minion in pairs(minionManager.objects) do
			if GetTeam(minion) ~= MINION_ALLY then
		    --Q
			local QPred = GetCircularAOEPrediction(minion, ChoQ)
			if ChoMenu.l.Q:Value() and qRdy and ValidTarget(minion, RangeQ) and MinionsAround(minion, 950) >= ChoMenu.l.limQ:Value() then
				if ChoMenu.l.mana:Value() <= GetPercentMP(myHero) then
					CastSkillShot(0, QPred.castPos)
				end
			end
			--W
			local WPred = GetConicAOEPrediction(minion, ChoW)
			if ChoMenu.l.W:Value() and wRdy and ValidTarget(minion, RangeW) and MinionsAround(minion, 650) >= ChoMenu.l.limW:Value() then
				if ChoMenu.l.mana:Value() <= GetPercentMP(myHero) then
					CastSkillShot(1, WPred.castPos)
				end
			end
			end
		end
	end
end

function OnKillSteal()
	--Locals
	local qRdy = Ready(0)
	local wRdy = Ready(1)

	--Main
	for t,unit in pairs(GetEnemyHeroes()) do
		--Q
		if ChoMenu.k.Q:Value() and qRdy and ValidTarget(unit,RangeQ) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,CalcDmg(0,unit)) then
			local QPred = GetCircularAOEPrediction(unit, ChoQ)
			if QPred and QPred.hitChance >= (ChoMenu.p.Qh:Value()/100) then
				CastSkillShot(0, QPred.castPos)
			end
		end
		--W
		if ChoMenu.k.W:Value() and wRdy and ValidTarget(unit,RangeW) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,CalcDmg(1,unit)) then
			local WPred = GetConicAOEPrediction(unit, ChoW)
			if WPred and WPred.hitChance >= (ChoMenu.p.Wh:Value()/100) then
				CastSkillShot(1, WPred.castPos)
			end
		end

		--Ignite
		if ChoMenu.k.I:Value() and Ready(Ignite) and ValidTarget(unit, 660) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDmg(Ignite,unit) then
			CastTargetSpell(unit, Ignite)
		end
	end
end

function CastR()
	local rRdy = Ready(3)
	for t,unit in pairs(GetEnemyHeroes()) do
		if ChoMenu.u.R:Value() and rRdy and ValidTarget(unit,RangeR) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDmg(3,unit) then
			CastTargetSpell(unit,3)
		end
	end
end

function CalcDmg(spell, target)
	local dmg={
	[0] = 25 + 55*GetCastLevel(myHero,0) + GetBonusAP(myHero),
	[1] = 25 + 50*GetCastLevel(myHero,1) + GetBonusAP(myHero)*0.7,
	[3] = 125 + 175*GetCastLevel(myHero,3) + GetBonusAP(myHero)*0.7,
	[Ignite] = 70 + 20*GetLevel(myHero)
}
return dmg[spell]
end

function skin()
	if ChoMenu.m.s.sb:Value() and ChoMenu.m.s.cs:Value() ~= _skin then
		HeroSkinChanger(GetMyHero(),ChoMenu.m.s.cs:Value()) 
		_skin = ChoMenu.m.s.cs:Value()
	end
end

function UpdateDmgHPBar()
	for i, enemy in pairs(GetEnemyHeroes()) do
		if ValidTarget(enemy, 2000) and DmgHPBar[i] then
			DmgHPBar[i]:SetValue(1, enemy, CalcDmg(3, enemy), IsReady(_R))
			DmgHPBar[i]:SetValue(2, enemy, CalcDmg(0, enemy), IsReady(_Q))
			DmgHPBar[i]:SetValue(3, enemy, CalcDmg(1, enemy), IsReady(_W))
			DmgHPBar[i]:CheckValue()
		end
	end
end

function Interrupter()
	ChallengerCommon.Interrupter(ChoMenu.Interrupter, function(unit, spell)
		--Q
		if ChoMenu.Interrupter.Q:Value() and unit.team == MINION_ENEMY and Ready(0) and GetDistance(myHero, unit) <= 950 and unit.valid then
			local QPred = GetCircularAOEPrediction(unit, ChoQ)
			if QPred and QPred.hitChance >= 0.10 then
				CastSkillShot(0, QPred.castPos)
			end
		end

		--W
		if ChoMenu.Interrupter.W:Value() and unit.team == MINION_ENEMY and Ready(1) and GetDistance(myHero, unit) <= 650 and unit.valid then
			local WPred = GetConicAOEPrediction(unit, ChoW)
			if WPred and WPred.hitChance >= 0 then
				CastSkillShot(1, WPred.castPos)
			end
		end
	end)
end

function AntiGapCloser()
	ChallengerCommon.AntiGapcloser(ChoMenu.AGC, function(unit, spell)
		--Q
		if ChoMenu.AGC.Q:Value() and unit.team == MINION_ENEMY and Ready(0) and GetDistance(myHero, unit) <= 950 and unit.valid then
			local QPred = GetCircularAOEPrediction(unit, ChoQ)
			if QPred and QPred.hitChance >= 0.10 then
				CastSkillShot(0, QPred.castPos)
			end
		end

		--W
		if ChoMenu.AGC.W:Value() and unit.team == MINION_ENEMY and Ready(1) and GetDistance(myHero, unit) <= 650 and unit.valid then
			local WPred = GetConicAOEPrediction(unit, ChoW)
			if WPred and WPred.hitChance >= 0 then
				CastSkillShot(1, WPred.castPos)
			end
		end
	end)
end

print("<font color=\"#FE2EC8\"><b>[Cho'Gath]: Loaded</b></font> || Version: "..ver," ", "|| LoL Patch : "..LoL)
