if GetObjectName(GetMyHero()) ~= "Janna" then return end
require 'OpenPredict'
if FileExist(COMMON_PATH.."MixLib.lua") then
	require('MixLib')
else
PrintChat("MixLib not found. Please wait for download.")
DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua",function() 
	require('MixLib')
	end)
end
local version = 1
local qrange1 = 850
local qrange2 = 1730
local qrange3 = 120
local wrange = 600
local erange = 800
local rrange = 875 
local rrange = 725
local mode = nil
local jaq = {delay = 0.1, speed = 625, width = 100, range = qrange1}
local move = {delay = 0.5, speed = math.huge, width = 50, range = math.huge}
local autolevel = {[1] = {_Q, _W, _E, _W, _W, _R, _W, _E, _W, _E, _R, _E, _E, _Q, _Q, _Q, _R, _Q}}

menu = Menu("Janna", "Janna")
menu:SubMenu("c", "Combo")
menu.c:Boolean("cqu", "Use Q ?", true)
menu.c:Boolean("cwu", "Use W ?", true)
menu.c:Boolean("cru", "Use R ?", true)
menu:SubMenu("s", "E Settings")
menu.s:Boolean("shj", "Shield Janna", true)
menu.s:Slider("sjhp", "Janna's HP Percentage", 50, 0, 100, 1)
menu.s:Boolean("sha", "Shield Allies", true)
menu.s:Slider("shp", "Ally's HP Percentage", 50, 0, 100, 1)
menu.s:Boolean("sot", "Shield when targetted", true)
menu.s:Boolean("se", "Emergency Shield", true)
menu:SubMenu("r", "R Settings")
menu.r:Boolean("ru", "Use R ?", true)
menu.r:Boolean("ruj", "Use R for Janna ?", true)
menu.r:Slider("rujh", "Janna's HP Percentage", 50, 0, 100, 1)
menu.r:Boolean("rua", "Use R for ally ?", true)
menu.r:Slider("ruah", "Ally's HP Percentage", 50, 0, 100, 1)
menu.r:SubMenu("rd", "drive away enemy settings")
menu.r.rd:Boolean("rdh", "Drive away for HP difference", false)
menu.r.rd:Boolean("rdnd", "Drive away for Number difference", false)
menu.r.rd:Boolean("rdn", "Drive away for Number", false)
menu.r.rd:Boolean("rdas", "Advanced Drive Away System", true)
menu.r.rd:Slider("rdhp", "HP difference", 50, 0, 100, 1)
menu.r.rd:Slider("rdndd", "Number difference", 2, 0, 4, 1)
menu.r.rd:Slider("rdns", "Number for R", 2 , 0 , 5, 1)
menu:Boolean("al", "Use Auto Level spell", true)
OnTick(function()
	if not IsDead(myHero) then
		mode = Mix:Mode()
		local unit = GetCurrentTarget()
		als()
		if mode == "Combo" then 
			nsph(unit)
			ntb(unit)
			if menu.r.ru:Value() and Ready(_R) then 
				Rlogic()
			end
		end
		shi()
		if menu.s.se:Value() then
			eshi()
		end
	end
end)

function nsph(unit)
	if menu.c.cqu:Value() and Ready(_Q) and ValidTarget(unit, qrange2) then 
		local qpred = GetPrediction(unit, jaq)
		if qpred and qpred.hitChance >= 0.9 then
			CastSkillShot(_Q, qpred.castPos)
		end
	end
end

function ntb(unit)
	if menu.c.cwu:Value() and Ready(_W) and ValidTarget(unit, wrange) then 
		CastTargetSpell(unit, _W)
	end
end

function als()
	if menu.al:Value() and GetLevelPoints(myHero) >= 1 then
		LevelSpell(autolevel[1][GetLevel(myHero) - GetLevelPoints(myHero) + 1])
	end
end

function shi()
DelayAction(function()
	for _, ally in pairs(GetAllyHeroes()) do
		if Ready(_E) and GetDistance(myHero, ally) <= 800 and GetPercentHP(ally) <= menu.s.shp:Value() and menu.s.sha:Value() then
			ally:Cast(_E, ally)
		end
	end
	if Ready(_E) and GetPercentHP(myHero) <= menu.s.sjhp:Value() and menu.s.shj:Value() then
		myHero:Cast(_E, myHero)
	end
end, GetWindUp(myHero))
end

function eshi()
	if GetPercentHP(myHero) < 8 then
		myHero:Cast(_E, myHero)
	end
end  
function Rlogic(unit)
DelayAction(function()
	local anum = 1
	for _, allies in pairs(GetAllyHeroes()) do
		if GetDistance(myHero, allies) <= rrange then
			anum = anum + 1
		end
	end
	local enum = 0
	local enemytotalhp = 0
	for _, ally in pairs(GetAllyHeroes()) do
		if GetDistance(myHero, ally) <= rrange and GetPercentHP(ally) <= menu.r.ruah:Value() and menu.r.rua:Value() and ValidTarget(unit, 2500) then
			CastSpell(_R)
		end
		for _, enemy in pairs(GetEnemyHeroes()) do 
			if GetDistance(myHero, enemy) <= rrange then 
				enum = enum + 1
				enemytotalhp = enemytotalhp + GetCurrentHP(enemy)
			end
		end
		if menu.r.rd.rdn:Value() and enum >= menu.r.rd.rdns:Value() then 
			CastSpell(_R)
		end
		if menu.r.rd.rdh:Value() and GetCurrentHP(ally) <= (enemytotalhp * (menu.r.rd.rdhp:Value() / 100)) then
			CastSpell(_R)
		end
		if menu.r.rd.rdnd:Value() and enum - anum >= menu.r.rd.rdndd:Value() then
			CastSpell(_R)
		end
	end
	if GetPercentHP(myHero) <= menu.r.rujh:Value() and menu.r.ruj:Value() and ValidTarget(unit, 2500) then
		CastSpell(_R)
	end
end, GetWindUp(myHero))
end
PrintChat("Janna Lee loaded")