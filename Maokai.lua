--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Maokai" then return end
--          [[ Updater ]]
local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Maokai.lua", SCRIPT_PATH .. "Maokai.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Maokai.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local MaokaiMenu = Menu("Maokai", "Maokai")
--          [[ Combo ]]
MaokaiMenu:SubMenu("Combo", "Combo Settings")
MaokaiMenu.Combo:Boolean("Q", "Use Q", true)
MaokaiMenu.Combo:Boolean("W", "Use W", true)
MaokaiMenu.Combo:Boolean("E", "Use E", true)
--          [[ Harass ]]
MaokaiMenu:SubMenu("Harass", "Harass Settings")
MaokaiMenu.Harass:Boolean("Q", "Use Q", true)
MaokaiMenu.Harass:Boolean("E", "Use E", true)
MaokaiMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
MaokaiMenu:SubMenu("Farm", "Farm Settings")
MaokaiMenu.Farm:Boolean("Q", "Use Q", true)
MaokaiMenu.Farm:Boolean("E", "Use E", true)
MaokaiMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ Jungle ]]
MaokaiMenu:SubMenu("JG", "Jungle Settings")
MaokaiMenu.JG:Boolean("Q", "Use Q", true)
MaokaiMenu.JG:Boolean("W", "Use W", true)
MaokaiMenu.JG:Boolean("E", "Use E", true)
--          [[ KillSteal ]]
MaokaiMenu:SubMenu("KS", "KillSteal Settings")
MaokaiMenu.KS:Boolean("Q", "Use Q", true)
MaokaiMenu.KS:Boolean("W", "Use W", true)
MaokaiMenu.KS:Boolean("E", "Use E", true)
--          [[ Draw ]]
MaokaiMenu:SubMenu("Draw", "Drawing Settings")
MaokaiMenu.Draw:Boolean("Q", "Draw Q", false)
MaokaiMenu.Draw:Boolean("W", "Draw W", false)
MaokaiMenu.Draw:Boolean("E", "Draw E", false)
--          [[ Spell ]]
local Spells = {
 Q = {range = 600, delay = 0.25, speed = 1700, width = 100},
 W = {range = 525, delay = 0.25, speed = 1300, width = 10},
 E = {range = 1100 , delay = 1.75, speed = 1300, radius = 250},
 R = {range = 475}
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
	--[[VengefulMaelstrom]]
	KS()
	target = GetCurrentTarget()
	         Combo()
	         Harass()
	         Farm()
	    end)  
--          [[ MaokaiQ ]]
function MaokaiQ()	
	local QPred = GetPrediction(target, Spells.Q)
	if QPred.hitChance >0.3 then
		CastSkillShot(_Q, QPred.castPos)
	end	
end   
--          [[ MaokaiW ]]
function MaokaiW()
		CastTargetSpell(target, _W)
	end	
--          [[ MaokaiE ]]
function MaokaiE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.5 then
		CastSkillShot(_E, EPred.castPos)
	end	
end  
--          [[ MaokaiR ]]
function MaokaiR()
		CastSpell(_R)
	end
--          [[ Combo ]]
function Combo()
	if Mode() == "Combo" then
-- 		[[ Use E ]]
		if MaokaiMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			MaokaiE() 
			end
-- 		[[ Use W ]]
		if MaokaiMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			MaokaiW()
			end
-- 		[[ Use Q ]]
		if MaokaiMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then 
			MaokaiQ()
			end 
-- 		[[ Use R Count ]] 
		--if MaokaiMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.range) and EnemiesAround(GetOrigin(myHero), Spells.R.range) >= MaokaiMenu.Combo.RC:Value() then
			--MaokaiR()
			--end
		end
	end
--          [[ Harass ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= MaokaiMenu.Harass.Mana:Value() /100) then
-- 			[[ Use Q ]]
			if MaokaiMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				MaokaiQ()
			end
-- 			[[ Use E ]]
			if MaokaiMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
				MaokaiE()
			end
		end
	end
end
--          [[ LaneClear ]]
function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= MaokaiMenu.Farm.Mana:Value() /100) then		
-- 			[[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ Use Q ]]
					if MaokaiMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSkillShot(_Q, minion)
					    end
-- 					[[ Use E ]]
					if MaokaiMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
							CastSkillShot(_E, minion)
						end	
					end
				end	
-- 			[[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ Use Q ]]
					if MaokaiMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSkillShot(_Q, mob)
					    end
-- 					[[ Use W ]]
					if MaokaiMenu.JG.W:Value() and Ready(_W) and ValidTarget(mob, Spells.W.range) then
							CastTargetSpell(mob, _W)
					    end
-- 					[[ Use E ]]
					if MaokaiMenu.JG.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
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
--		[[ Use Q ]]
		if MaokaiMenu.KS.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
					MaokaiQ()
				end
			end
--		[[ Use W ]]
		if MaokaiMenu.KS.W:Value() and Ready(_W) and ValidTarget(enemy, Spells.W.range) then
			if GetCurrentHP(enemy) < getdmg("W", enemy, myHero) then
					MaokaiW()
				end
			end
--		[[ Use E ]]
		if MaokaiMenu.KS.E:Value() and Ready(_E) and ValidTarget(enemy, Spells.E.range) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
					MaokaiE()
				end
			end
		end
	end
--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if MaokaiMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Red) end
--  [[ Draw W ]]
	if MaokaiMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
--  [[ Draw E ]]
	if MaokaiMenu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Green) end
end)	