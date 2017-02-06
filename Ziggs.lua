--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Ziggs" then return end
--          [[ Updater ]]
local ver = "0.01"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Ziggs.lua", SCRIPT_PATH .. "Ziggs.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Ziggs.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local ZiggsMenu = Menu("Ziggs", "Ziggs")
--          [[ Combo ]]
ZiggsMenu:SubMenu("Combo", "Combo Settings")
ZiggsMenu.Combo:Boolean("Q", "Use Q", true)
ZiggsMenu.Combo:Boolean("W", "Use W", true)
ZiggsMenu.Combo:Boolean("E", "Use E", true)
ZiggsMenu.Combo:Boolean("R", "Use R", true)
ZiggsMenu.Harass:Slider("RC", "R Count", 3, 0, 5, 1)
--          [[ Harass ]]
ZiggsMenu:SubMenu("Harass", "Harass Settings")
ZiggsMenu.Harass:Boolean("Q", "Use Q", true)
ZiggsMenu.Harass:Boolean("E", "Use E", true)
ZiggsMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
ZiggsMenu:SubMenu("Farm", "Farm Settings")
ZiggsMenu.Farm:Boolean("Q", "Use Q", true)
ZiggsMenu.Farm:Boolean("E", "Use E", true)
ZiggsMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ Jungle ]]
ZiggsMenu:SubMenu("JG", "Jungle Settings")
ZiggsMenu.JG:Boolean("Q", "Use Q", true)
ZiggsMenu.JG:Boolean("E", "Use E", true)
--          [[ KillSteal ]]
ZiggsMenu:SubMenu("Ks", "KillSteal Settings")
ZiggsMenu.Ks:Boolean("Q", "Use Q", true)
ZiggsMenu.Ks:Boolean("E", "Use E", true)
ZiggsMenu.Ks:Boolean("R", "Use R", true)
--          [[ Draw ]]
ZiggsMenu:SubMenu("Draw", "Drawing Settings")
ZiggsMenu.Draw:Boolean("Q", "Draw Q", false)
ZiggsMenu.Draw:Boolean("W", "Draw W", false)
ZiggsMenu.Draw:Boolean("E", "Draw E", false)
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
--          [[ ZiggsQ ]]
function ZiggsQ()	
	local QPred = GetPrediction(target, Spells.Q)
	if QPred.hitChance >0.3 then
		CastSkillShot(_Q, QPred.castPos)
	end	
end   
--          [[ ZiggsW ]]
function ZiggsW()
	local WPred = GetPrediction(target, Spells.W)
	if WPred.hitChance > 0.3 then
		CastSkillShot(_W, WPred.castPos)
	end	
end 
--          [[ ZiggsE ]]
function ZiggsE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.3 then
		CastSkillShot(_E, EPred.castPos)
	end	
end  
--          [[ ZiggsR ]]
function ZiggsR()
	local RPred = GetCircularAOEPrediction(target, Spells.R)
	if RPred.hitChance > 0.8 then
		CastSkillShot(_R, RPred.castPos)
	end	
end 
--          [[ Combo ]]
function Combo()
	if Mode() == "Combo" then
-- 		[[ Use Q ]]
		if ZiggsMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			ZiggsQ()
			end
-- 		[[ Use W ]]
		if ZiggsMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			ZiggsW()
			end
-- 		[[ Use E ]]
		if ZiggsMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			ZiggsE()
			end
-- 		[[ Use R Count ]]
		if ZiggsMenu.Combo.R:Value() and Ready(_R) and ValidTarget(enemy, 1000) and EnemiesAround(enemy, 400) >= ZiggsMenu.Combo.RC:Value() then
			ZiggsR()
			end
		end
	end
--          [[ Harass ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= ZiggsMenu.Harass.Mana:Value() /100) then
-- 			[[ Use Q ]]
			if ZiggsMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				ZiggsQ()
			end
-- 			[[ Use E ]]
			if ZiggsMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
				ZiggsE()
			end
		end
	end
end
--          [[ LaneClear ]]
function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= ZiggsMenu.Farm.Mana:Value() /100) then		
-- 			[[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ Use Q ]]
					if ZiggsMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
							CastSkillShot(_Q, minion)
					    end
-- 					[[ Use E ]]
					if ZiggsMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
							CastSkillShot(_E, minion)
						end	
					end
				end	
-- 			[[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ Use Q ]]
					if ZiggsMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastSkillShot(_Q, mob)
					    end
-- 					[[ Use E ]]
					if ZiggsMenu.JG.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
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
		if ZiggsMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
					ZiggsQ()
				end
			end
--		[[ Use E ]]
		if ZiggsMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, Spells.E.range) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
					ZiggsE()
				end
			end
--		[[ Use R ]]
		if ZiggsMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
					ZiggsR()
				end
			end
		end
	end
--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if ZiggsMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 0, 25, GoS.Red) end
--  [[ Draw W ]]
	if ZiggsMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 0, 25, GoS.Blue) end
--  [[ Draw E ]]
	if ZiggsMenu.Draw.E:Value() then DrawCircle(pos, Spells.E.range, 0, 25, GoS.Green) end
end)	