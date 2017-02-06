--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Lux" then return end
--          [[ Updater ]]
local ver = "0.02"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Lux.lua", SCRIPT_PATH .. "Lux.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Lux.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local LuxMenu = Menu("Lux", "Lux")
--          [[ Combo ]]
LuxMenu:SubMenu("Combo", "Combo Settings")
LuxMenu.Combo:Boolean("Q", "Use Q", true)
LuxMenu.Combo:Boolean("W", "Use W", true)
LuxMenu.Combo:Boolean("WA", "Use W on Ally", false)
LuxMenu.Combo:Slider("WM", "Use W on HP", 50, 1, 100, 1)
LuxMenu.Combo:Slider("WMA", "No Options here", 1, 1, 5, 1)
LuxMenu.Combo:Boolean("E", "Use E", true)
--          [[ Harass ]]
LuxMenu:SubMenu("Harass", "Harass Settings")
LuxMenu.Harass:Boolean("Q", "Use Q", true)
LuxMenu.Harass:Boolean("E", "Use E", true)
LuxMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
LuxMenu:SubMenu("Farm", "Farm Settings")
LuxMenu.Farm:Boolean("Q", "Use Q", false)
LuxMenu.Farm:Boolean("E", "Use E", true)
LuxMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ Jungle ]]
LuxMenu:SubMenu("JG", "Jungle Settings")
LuxMenu.JG:Boolean("Q", "Use Q", true)
LuxMenu.JG:Boolean("E", "Use E", true)
--          [[ KillSteal ]]
LuxMenu:SubMenu("KS", "KillSteal Settings")
LuxMenu.KS:Boolean("Q", "Use Q", true)
LuxMenu.KS:Boolean("E", "Use E", true)
LuxMenu.KS:Boolean("R", "Use R", true)
--          [[ Draw ]]
LuxMenu:SubMenu("Draw", "Drawing Settings")
LuxMenu.Draw:Boolean("Q", "Draw Q", false)
LuxMenu.Draw:Boolean("W", "Draw W", false)
LuxMenu.Draw:Boolean("E", "Draw E", false)
--          [[ Spell ]]
local Spells = {
 Q = {range = 1175, delay = 0.25, speed = 1200, width = 70},
 W = {range = 1075, delay = 0.25, speed = 1300, width = 95},
 E = {range = 1100, delay = 0.25, speed = 1300, radius = 330},
 R = {range = 3340, delay = 1.0, speed = math.huge, width = 190}
}
--          [[ Orbwalker ]]
function Mode()
	if _G.IOW_Loaded and IOW:Mode() then
		return IOW:Mode()
	elseif _G.PW_Loaded and PW:Mode() then
		return PW:Mode()
	elseif _G.DAC_Loaded and DAC:Mode() then
		return DAC:Mode()
	elseif _G.AutoCarry_Loaded and DACR:Mode() then
		return DACR:Mode()
	elseif _G.SLW_Loaded and SLW:Mode() then
		return SLW:Mode()
	end
end
--          [[ Tick ]]
OnTick(function()
	KS()
	target = GetCurrentTarget()
	         Combo()
	         Harass()
	         Farm()
	    end)  
--          [[ LuxQ ]]
function LuxQ()	
	local QPred = GetPrediction(target, Spells.Q)
	if QPred.hitChance > 0.3 then
		CastSkillShot(_Q, QPred.castPos)
	end	
end   
--          [[ LuxW ]]
function LuxW()
		CastSkillShot(_W, myHero.pos)
	end	
--          [[ LuxE ]]
function LuxE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		CastSkillShot(_E, EPred.castPos)
	end	
end  
--          [[ LuxR ]]
function LuxR()
	local RPred = GetPrediction(target, Spells.R)
	if RPred.hitChance > 0.8 then
		CastSkillShot(_R, RPred.castPos)
	end	
end  
--          [[ Combo ]]
function Combo()
	if Mode() == "Combo" then
--		[[ Use Q ]]
		if LuxMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			LuxQ()
		end	
--		[[ Use W ]]
		if Ready(_W) and GetPercentHP(myHero) <= LuxMenu.Combo.WM:Value() and LuxMenu.Combo.W:Value() and EnemiesAround(myHero, Spells.W.range) >= LuxMenu.Combo.WMA:Value() then
			LuxW()
			end
-- 		[[ Use E ]]
		if LuxMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			LuxE()
		end
-- 		[[ Use R ]]
		--[[if LuxMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.range) then
			LuxR()
		end]]
	end
end
--          [[ Harass ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= LuxMenu.Harass.Mana:Value() /100) then
-- 			[[ Use Q ]]
			if LuxMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				LuxQ()
			end
-- 			[[ Use E ]]
			if LuxMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
				LuxE()
			end
		end
	end
end
--          [[ LaneClear ]]
function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= LuxMenu.Farm.Mana:Value() /100) then
-- 			[[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ Use Q ]]
					if LuxMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSkillShot(_Q, minion)
					    end
-- 					[[ Use E ]]
					if LuxMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
							CastSkillShot(_E, minion)
						end	
					end
				end	
-- 			[[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ Use Q ]]
					if LuxMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSkillShot(_Q, mob)
						end
-- 					[[ Use E ]]
					if LuxMenu.JG.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
							CastSkillShot(_E, mob)
						end	
					end
				end
			end
		end
	end
--          [[ KillSteal ]]
function KS()
	for _, enemy in pairs(GetEnemyHeroes()) do
-- 		[[ Use Q ]]
		if LuxMenu.KS.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				LuxQ()
				end
			end

-- 		[[ Use E ]]
		if LuxMenu.KS.E:Value() and Ready(_E) and ValidTarget(enemy, Spells.E.range) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
				LuxE()
				end
			end

--		[[ Use R ]]
		if LuxMenu.KS.R:Value() and Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
					LuxR()
				end
			end
		end
	end
--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if LuxMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Red) end
--  [[ Draw W ]]
	if LuxMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
--  [[ Draw E ]]
	if LuxMenu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Green) end
end)		