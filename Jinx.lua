--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Jinx" then return end
--          [[ Updater ]]
local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Jinx.lua", SCRIPT_PATH .. "Jinx.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Jinx.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local JinxMenu = Menu("Jinx", "Jinx")
--          [[ Combo ]]
JinxMenu:SubMenu("Combo", "Combo Settings")
JinxMenu.Combo:Boolean("Q", "Use Q", true)
JinxMenu.Combo:Boolean("W", "Use W", true)
JinxMenu.Combo:Boolean("E", "Use E", true)
JinxMenu.Combo:Boolean("R", "Use R", true)
JinxMenu.Harass:Slider("RC", "R Count", 3, 0, 5, 1)
--          [[ Harass ]]
JinxMenu:SubMenu("Harass", "Harass Settings")
JinxMenu.Harass:Boolean("Q", "Use Q", true)
JinxMenu.Harass:Boolean("E", "Use E", true)
JinxMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
JinxMenu:SubMenu("Farm", "Farm Settings")
JinxMenu.Farm:Boolean("Q", "Use Q", true)
JinxMenu.Farm:Boolean("E", "Use E", true)
JinxMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ Jungle ]]
JinxMenu:SubMenu("JG", "Jungle Settings")
JinxMenu.JG:Boolean("Q", "Use Q", true)
JinxMenu.JG:Boolean("E", "Use E", true)
--          [[ KillSteal ]]
JinxMenu:SubMenu("Ks", "KillSteal Settings")
JinxMenu.Ks:Boolean("Q", "Use Q", true)
JinxMenu.Ks:Boolean("E", "Use E", true)
JinxMenu.Ks:Boolean("R", "Use R", true)
--          [[ Draw ]]
JinxMenu:SubMenu("Draw", "Drawing Settings")
JinxMenu.Draw:Boolean("Q", "Draw Q", false)
JinxMenu.Draw:Boolean("W", "Draw W", false)
JinxMenu.Draw:Boolean("E", "Draw E", false)
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
--          [[ JinxQ ]]
function JinxQ()	
	local QPred = GetPrediction(target, Spells.Q)
	if QPred.hitChance >0.3 then
		CastSkillShot(_Q, QPred.castPos)
	end	
end   
--          [[ JinxW ]]
function JinxW()
	local WPred = GetPrediction(target, Spells.W)
	if WPred.hitChance > 0.3 then
		CastSkillShot(_W, WPred.castPos)
	end	
end 
--          [[ JinxE ]]
function JinxE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		CastSkillShot(_E, EPred.castPos)
	end	
end  
--          [[ JinxR ]]
function JinxR()
	local RPred = GetCircularAOEPrediction(target, Spells.R)
	if RPred.hitChance > 0.8 then
		CastSkillShot(_R, RPred.castPos)
	end	
end 
--          [[ Combo ]]
function Combo()
	if Mode() == "Combo" then
-- 		[[ Use Q ]]
		if JinxMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			JinxQ()
			end
-- 		[[ Use W ]]
		if JinxMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			JinxW()
			end
-- 		[[ Use E ]]
		if JinxMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			JinxE()
			end
-- 		[[ Use R Count ]]
		if JinxMenu.Combo.R:Value() and Ready(_R) and ValidTarget(enemy, 1000) and EnemiesAround(enemy, 400) >= JinxMenu.Combo.RC:Value() then
			JinxR()
			end
		end
	end
--          [[ Harass ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= JinxMenu.Harass.Mana:Value() /100) then
-- 			[[ Use Q ]]
			if JinxMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				JinxQ()
			end
-- 			[[ Use E ]]
			if JinxMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
				JinxE()
			end
		end
	end
end
--          [[ LaneClear ]]
function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= JinxMenu.Farm.Mana:Value() /100) then		
-- 			[[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ Use Q ]]
					if JinxMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSkillShot(_Q, minion)
					    end
-- 					[[ Use E ]]
					if JinxMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
							CastSkillShot(_E, minion)
						end	
					end
				end	
-- 			[[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ Use Q ]]
					if JinxMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSkillShot(_Q, mob)
					    end
-- 					[[ Use E ]]
					if JinxMenu.JG.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
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
		if JinxMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
					JinxQ()
				end
			end
--		[[ Use E ]]
		if JinxMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, Spells.E.range) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
					JinxE()
				end
			end
--		[[ Use R ]]
		if JinxMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
					JinxR()
				end
			end
		end
	end
--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if JinxMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Red) end
--  [[ Draw W ]]
	if JinxMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
--  [[ Draw E ]]
	if JinxMenu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Green) end
end)	