--[[
╔══╦╗╔╗╔╦══╦══╦╗─╔╗
║╔═╣║║║║║╔╗╠╗╔╣╚═╝║
║╚═╣║║║║║╚╝║║║║╔╗─║
╚═╗║║║║║║╔╗║║║║║╚╗║
╔═╝║╚╝╚╝║║║╠╝╚╣║─║║
╚══╩═╝╚═╩╝╚╩══╩╝─╚╝
LoL Patch : 6.22
Script Verison : 0.02
by Shulepin
_____________________

Credits:
-Deftsu(http://gamingonsteroids.com/user/220-deftsu/)
-Zwei(http://gamingonsteroids.com/user/13058-zwei/)
-Noddy(http://gamingonsteroids.com/user/304-noddy/)
-Icesythe7(http://gamingonsteroids.com/user/5317-icesythe7/)
-jouzuna(http://gamingonsteroids.com/user/171-jouzuna/)
]]--

--Auto Update
local ver = "0.02"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("<font color=\"#FE2EC8\"><b>[Swain]: </b></font><font color=\"#FFFFFF\"> New version found!</font>")
        print("<font color=\"#FE2EC8\"><b>[Swain]: </b></font><font color=\"#FFFFFF\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Swain.lua", SCRIPT_PATH .. "Swain.lua", function() print("<font color=\"#FE2EC8\"><b>[Swain]: </b></font><font color=\"#FFFFFF\"> Update Complete, please 2x F6!</font>") return end)
    else
       print("<font color=\"#FE2EC8\"><b>[Swain]: </b></font><font color=\"#FFFFFF\"> No Updates Found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Swain.version", AutoUpdate)

--Hero
if GetObjectName(GetMyHero()) ~= "Swain" then return end

--Load OpenPredict
require("OpenPredict")

--Main Menu
SWMenu = Menu("SW", "Swain")

--Combo Menu
SWMenu:SubMenu("c", "Combo")
SWMenu.c:Boolean("Q", "Use Q", true)
SWMenu.c:Boolean("W", "Use W", true)
SWMenu.c:Boolean("E", "Use E", true)

--Ultimate Menu
SWMenu:SubMenu("u", "Ultimate")
SWMenu.u:Boolean("R", "Use Auto R", true)
SWMenu.u:Slider("RC", "Use Auto R if Enemy Count >= X", 2, 1, 5, 1)
SWMenu.u:Boolean("RZ", "Use Zhonya while Ult", true)
SWMenu.u:Slider("RZS", "Zhonya ult at Health (%)", 30, 0, 100, 1)

--Harass Menu
SWMenu:SubMenu("h", "Harass")
SWMenu.h:Boolean("Q", "Use Q", true)
SWMenu.h:Boolean("W", "Use W")
SWMenu.h:Boolean("E", "Use E", true)
SWMenu.h:Slider("mana", "Min. Mana(%) To Harass", 50, 0, 100, 1)
SWMenu.h:Boolean("AE", "Use Auto E", true)
SWMenu.h:Slider("AES", "Stop Auto E at Mana (%)", 80, 0, 100, 1)

--KS Menu
SWMenu:SubMenu("k", "KS")
SWMenu.k:Boolean("Q", "Use Q", true)
SWMenu.k:Boolean("E", "Use E", true)

--Draw Menu
SWMenu:SubMenu("d", "Draw")
SWMenu.d:Boolean("Q", "Draw Q Range", true)
SWMenu.d:Boolean("W", "Draw W Range", true)
SWMenu.d:Boolean("E", "Draw E Range", true)
SWMenu.d:Boolean("R", "Draw R Range", true)
SWMenu.d:Boolean("HP", "Draw Damage Indicator", true)

--Skin Menu
SWMenu:SubMenu("s", "Skin Changer")
SWMenu.s:Boolean("sb", "Use Skin Changer")
SWMenu.s:Slider("cs", "Choose Skin", 0, 0, 10, 1)

--Vars
RavenForm = false

--Tables
local SwainQ = { delay = 0.250, speed = math.huge, range = 700 }
local SwainW = { delay = 1.100, speed = math.huge, range = 900, radius = 180 }
local item = {3157}

--Locals
local LoL = "6.22"
local RangeQ = 700
local RangeW = 900
local RangeE = 625
local RangeR = 700
local _skin = 0

--Start
OnTick(function (myHero)
	if not IsDead(myHero) then
		--Locals
		local target = GetCurrentTarget()
		--Functions
		OnCombo(target)
		OnHarass(target)
		KillSteal()
		AutoE(target)
		AutoR(target)
		Zhonya()
		skin()
	end
end)

OnDraw(function(myHero)
	--Locals
        local rdyQ = Ready(0)
	local rdyW = Ready(1)
	local rdyE = Ready(2)
	local rdyR = Ready(3)

	--Range
	if not IsDead(myHero) then
	    if SWMenu.d.Q:Value() then DrawCircle(myHero, RangeQ, 1, 25, GoS.Green) end
	    if SWMenu.d.W:Value() then DrawCircle(myHero, RangeW, 1, 25, GoS.Blue) end
	    if SWMenu.d.E:Value() then DrawCircle(myHero, RangeE, 1, 25, GoS.Red) end
	    if SWMenu.d.R:Value() then DrawCircle(myHero, RangeR, 1, 25, GoS.Yellow) end
	end

	--Damage Bar
	for q,unit in pairs(GetEnemyHeroes()) do
		if ValidTarget(unit,2000) and SWMenu.d.HP:Value() then
			local DmgDraw=0
			if rdyQ then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, 0 ,CalcDmg(0,unit))
			end	
			if rdyW then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, 0 ,CalcDmg(1,unit))
			end	
			if rdyE then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, 0 ,CalcDmg(2,unit))
			end	
                        if rdyR then
				DmgDraw = DmgDraw + CalcDamage(myHero, unit, 0 ,CalcDmg(3,unit))
			end
			if DmgDraw > GetCurrentHP(unit) then
				DmgDraw = GetCurrentHP(unit)
			end
			DrawDmgOverHpBar(unit,GetCurrentHP(unit),0,DmgDraw,ARGB(255,255,255,0))
		end
	end	
end)

--Functions
function OnCombo(target)
	--Locals
	local rdyQ = Ready(0)
	local rdyW = Ready(1)
	local rdyE = Ready(2)

        --Main
	if IOW:Mode() == "Combo" then
		--Q
		if SWMenu.c.Q:Value() and rdyQ and ValidTarget(target, RangeQ) then
			local QPred = GetCircularAOEPrediction(target, SwainQ)
			if QPred and QPred.hitChance >= 0 then
				CastSkillShot(0, QPred.castPos)
			end
		end
		--W
		if SWMenu.c.W:Value() and rdyW and ValidTarget(target, RangeW) then
			local WPred = GetCircularAOEPrediction(target, SwainW)
			if WPred and WPred.hitChance >= 0.25 then
				CastSkillShot(1, WPred.castPos)
			end
		end
		--E
		if SWMenu.c.E:Value() and rdyE and ValidTarget(target, RangeE) then
			CastTargetSpell(target,2)
		end
	end
end

function OnHarass(target)
	--Locals
	local rdyQ = Ready(0)
	local rdyW = Ready(1)
	local rdyE = Ready(2)

    --Main
	if IOW:Mode() == "Harass" then
		--Q
		if SWMenu.h.Q:Value() and rdyQ and ValidTarget(target, RangeQ) then
			local QPred = GetCircularAOEPrediction(target, SwainQ)
			if QPred and QPred.hitChance >= 0 then
				if SWMenu.h.mana:Value() <= GetPercentMP(myHero) then
					CastSkillShot(0, QPred.castPos)
				end
			end
		end
		--W
		if SWMenu.h.W:Value() and rdyW and ValidTarget(target, RangeQ) then
			local WPred = GetCircularAOEPrediction(target, SwainW)
			if WPred and WPred.hitChance >= 0.25 then
				if SWMenu.h.mana:Value() <= GetPercentMP(myHero) then
					CastSkillShot(1, WPred.castPos)
				end
			end
		end
		--E
		if SWMenu.c.E:Value() and rdyE and ValidTarget(target, RangeE) then
			if SWMenu.h.mana:Value() <= GetPercentMP(myHero) then
				CastTargetSpell(target,2)
			end
		end
	end
end

function OnClear()
	--Soon
end

function KillSteal()
	--Locals
	local rdyQ = Ready(0)
	local rdyE = Ready(2)

        --Main
	for y,unit in pairs(GetEnemyHeroes()) do
		--Q
		if SWMenu.k.Q:Value() and rdyQ and ValidTarget(unit,RangeQ) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,CalcDmg(0,unit)) then
			local QPred = GetCircularAOEPrediction(unit, SwainQ)
			if QPred and QPred.hitChance >= 0 then
		            CastSkillShot(0, QPred.castPos)
			end
		end
		--E
		if SWMenu.k.E:Value() and rdyE and ValidTarget(unit,RangeE) and GetCurrentHP(unit) + GetDmgShield(unit) <  CalcDamage(myHero, unit, 0 ,CalcDmg(2,unit)) then
			CastTargetSpell(unit,2)
		end
	end
end

function Zhonya()
	--Main
	if SWMenu.u.RZ:Value() then
		if GetPercentHP(myHero) <= SWMenu.u.RZS:Value() then
			for y,x in pairs(item) do
				if GetItemSlot(myHero, x) > 0 and Ready(GetItemSlot(myHero, x)) then
					if RavenForm == true then
						CastSpell(GetItemSlot(myHero, x))
					end
				end
			end
		end
	end
end

function AutoR(target)
    --Locals
    local rdyR = Ready(3)

    --Main
	if SWMenu.u.R:Value() and EnemiesAround(myHero, RangeR) >= SWMenu.u.RC:Value() and rdyR then
		if RavenForm ~= true then
			CastSpell(3)
		end
	end
end

function AutoE(target)
	--Locals
	local rdyE = Ready(2)

        --Main
	if SWMenu.h.AE:Value() and SWMenu.h.AES:Value() <= GetPercentMP(myHero) and rdyE and ValidTarget(target, RangeE) then 
		CastTargetSpell(target,2)
	end
end

function skin()
	--Main
	if SWMenu.s.sb:Value() and SWMenu.s.cs:Value() ~= _skin then
		HeroSkinChanger(GetMyHero(),SWMenu.s.cs:Value()) 
		_skin = SWMenu.s.cs:Value()
	end
end

function CalcDmg(spell, target)
	local dmg = {
	[0] = (15 + 15*GetCastLevel(myHero,0) + GetBonusAP(myHero)*0.3) * 4,
	[1] = 40 + 40*GetCastLevel(myHero,1) + GetBonusAP(myHero)*0.7,
	[2] = (6 + 9*GetCastLevel(myHero,2) + GetBonusAP(myHero)*0.3) * 4,
	[3] = 30 + 20*GetCastLevel(myHero,3) + GetBonusAP(myHero)*0.2
}
return dmg[spell]
end

--Other Callbacks
OnUpdateBuff (function(unit, buff)
  if not unit or not buff then
    return
  end
  if buff.Name:lower() == "swainmetamorphism" and GetTeam(buff) ~= (GetTeam(myHero)) and myHero.type == unit.type then
        RavenForm = true
    end
end)

OnRemoveBuff (function(unit, buff)
  if not unit or not buff then
    return
  end
  if buff.Name:lower() == "swainmetamorphism" and GetTeam(buff) ~= (GetTeam(myHero)) and myHero.type == unit.type then
        RavenForm = false
    end
end)

print("<font color=\"#FE2EC8\"><b>[Swain]: Loaded</b></font> || Version: "..ver," ", "|| LoL Patch : "..LoL)
