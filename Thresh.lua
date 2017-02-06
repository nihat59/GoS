--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Thresh" then return end
--          [[ Updater ]]
local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Thresh.lua", SCRIPT_PATH .. "Thresh.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Thresh.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local ThreshMenu = Menu("Thresh", "Thresh")
--          [[ Combo ]]
ThreshMenu:SubMenu("Combo", "Combo Settings")
ThreshMenu.Combo:Boolean("Q", "Use Q", true)
ThreshMenu.Combo:Boolean("W", "Use W", true)
ThreshMenu.Combo:Boolean("E", "Use E", true)
ThreshMenu.Combo:Boolean("R", "Use R", true)
ThreshMenu.Harass:Slider("RC", "R Count", 3, 0, 5, 1)
--          [[ Harass ]]
ThreshMenu:SubMenu("Harass", "Harass Settings")
ThreshMenu.Harass:Boolean("Q", "Use Q", true)
ThreshMenu.Harass:Boolean("E", "Use E", true)
ThreshMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
ThreshMenu:SubMenu("Farm", "Farm Settings")
ThreshMenu.Farm:Boolean("Q", "Use Q", true)
ThreshMenu.Farm:Boolean("E", "Use E", true)
ThreshMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ Jungle ]]
ThreshMenu:SubMenu("JG", "Jungle Settings")
ThreshMenu.JG:Boolean("Q", "Use Q", true)
ThreshMenu.JG:Boolean("E", "Use E", true)
--          [[ KillSteal ]]
ThreshMenu:SubMenu("Ks", "KillSteal Settings")
ThreshMenu.Ks:Boolean("Q", "Use Q", true)
ThreshMenu.Ks:Boolean("E", "Use E", true)
ThreshMenu.Ks:Boolean("R", "Use R", true)
--          [[ Draw ]]
ThreshMenu:SubMenu("Draw", "Drawing Settings")
ThreshMenu.Draw:Boolean("Q", "Draw Q", false)
ThreshMenu.Draw:Boolean("W", "Draw W", false)
ThreshMenu.Draw:Boolean("E", "Draw E", false)
--          [[ Spell ]]
local Spells = {
 Q = {range = 1100, delay = 0.25, speed = 1700, width = 30},
 W = {range = 1000, delay = 0.25, speed = 1300, width = 100},
 E = {range = 900 , delay = 0.25, speed = 1300, radius = 100},
 R = {range = 5000, delay = 0.25, speed = math.huge, width = 550}
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
--          [[ ThreshQ ]]
function ThreshQ()	
	local QPred = GetPrediction(target, Spells.Q)
	if QPred.hitChance >0.3 then
		CastSkillShot(_Q, QPred.castPos)
	end	
end   
--          [[ ThreshW ]]
function ThreshW()
	local WPred = GetPrediction(target, Spells.W)
	if WPred.hitChance > 0.3 then
		CastSkillShot(_W, WPred.castPos)
	end	
end 
--          [[ ThreshE ]]
function ThreshE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		CastSkillShot(_E, EPred.castPos)
	end	
end  
--          [[ ThreshR ]]
function ThreshR()
	local RPred = GetCircularAOEPrediction(target, Spells.R)
	if RPred.hitChance > 0.8 then
		CastSkillShot(_R, RPred.castPos)
	end	
end 
--          [[ Combo ]]
function Combo()
	if Mode() == "Combo" then
-- 		[[ Use Q ]]
		if ThreshMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			ThreshQ()
			end
-- 		[[ Use W ]]
		if ThreshMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			ThreshW()
			end
-- 		[[ Use E ]]
		if ThreshMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			ThreshE()
			end
-- 		[[ Use R Count ]]
		if ThreshMenu.Combo.R:Value() and Ready(_R) and ValidTarget(enemy, 1000) and EnemiesAround(enemy, 400) >= ThreshMenu.Combo.RC:Value() then
			ThreshR()
			end
		end
	end
--          [[ Harass ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= ThreshMenu.Harass.Mana:Value() /100) then
-- 			[[ Use Q ]]
			if ThreshMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				ThreshQ()
			end
-- 			[[ Use E ]]
			if ThreshMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
				ThreshE()
			end
		end
	end
end
--          [[ LaneClear ]]
function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= ThreshMenu.Farm.Mana:Value() /100) then		
-- 			[[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ Use Q ]]
					if ThreshMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSkillShot(_Q, minion)
					    end
-- 					[[ Use E ]]
					if ThreshMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
							CastSkillShot(_E, minion)
						end	
					end
				end	
-- 			[[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ Use Q ]]
					if ThreshMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSkillShot(_Q, mob)
					    end
-- 					[[ Use E ]]
					if ThreshMenu.JG.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
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
		if ThreshMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
					ThreshQ()
				end
			end
--		[[ Use E ]]
		if ThreshMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, Spells.E.range) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
					ThreshE()
				end
			end
--		[[ Use R ]]
		if ThreshMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
					ThreshR()
				end
			end
		end
	end
--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if ThreshMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Red) end
--  [[ Draw W ]]
	if ThreshMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
--  [[ Draw E ]]
	if ThreshMenu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Green) end
end)	