--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Annie" then return end
--          [[ Updater ]]
local ver = "0.02"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        print("New version found! " .. data)
        print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Annie.lua", SCRIPT_PATH .. "Annie.lua", function() print("Update Complete, please 2x F6!") return end)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Annie.version", AutoUpdate)
--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")
--          [[ Menu ]]
local AnnieMenu = Menu("Annie", "Annie")
--          [[ Combo ]]
AnnieMenu:SubMenu("Combo", "Combo Settings")
AnnieMenu.Combo:Boolean("Q", "Use Q", true)
AnnieMenu.Combo:Boolean("W", "Use W", true)
AnnieMenu.Combo:Boolean("E", "Use E", true)
AnnieMenu.Combo:Boolean("R", "Use R", true)
--          [[ Harass ]]
AnnieMenu:SubMenu("Harass", "Harass Settings")
AnnieMenu.Harass:Boolean("Q", "Use Q", true)
AnnieMenu.Harass:Boolean("W", "Use W", true)
AnnieMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)
--          [[ LaneClear ]]
AnnieMenu:SubMenu("Farm", "Farm Settings")
AnnieMenu.Farm:Boolean("Q", "Use Q", true)
AnnieMenu.Farm:Boolean("W", "Use W", false)
AnnieMenu.Farm:Slider("Mana", "Min. Mana", 0, 0, 100, 1)
--          [[ Jungle ]]
AnnieMenu:SubMenu("JG", "Jungle Settings")
AnnieMenu.JG:Boolean("Q", "Use Q", true)
AnnieMenu.JG:Boolean("W", "Use W", true)
--          [[ KillSteal ]]
AnnieMenu:SubMenu("KS", "KillSteal Settings")
AnnieMenu.KS:Boolean("Q", "Use Q", true)
AnnieMenu.KS:Boolean("W", "Use W", true)
AnnieMenu.KS:Boolean("R", "Use R", true)
--          [[ Misc ]]
--[[AnnieMenu:SubMenu("Misc", "Misc Settings")
AnnieMenu.Misc:Boolean("E", "Auto E", true)]]
--          [[ Draw ]]
AnnieMenu:SubMenu("Draw", "Drawing Settings")
AnnieMenu.Draw:Boolean("Q", "Draw Q", false)
AnnieMenu.Draw:Boolean("W", "Draw W", false)
AnnieMenu.Draw:Boolean("R", "Draw R", false)
--          [[ Spell ]]
local Spells = {
 Q = {range = 625, delay = 0.25, speed = 2000, width = 30},
 W = {range = 576, delay = 0.25, speed = 1300, width = 50},
 R = {range = 650, delay = 0.25, speed = math.huge, width = 200}
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
--          [[ AnnieQ ]]
function AnnieQ()	
		CastTargetSpell(target, _Q)
	end	
--          [[ AnnieW ]]
function AnnieW()
		local WPred = GetCircularAOEPrediction(target, Spells.W)
		if WPred.hitChance > 0.2 then
			CastSkillShot(_W, WPred.castPos)
	end	
end	
--          [[ AnnieE ]]
function AnnieE()
		CastSpell(_E)
	end	 
--          [[ AnnieR ]]
function AnnieR()
	local RPred = GetCircularAOEPrediction(target, Spells.R)
	if RPred.hitChance > 0.8 then
		CastSkillShot(_R, RPred.castPos)
	end	
end 
--          [[ Combo ]]
function Combo()
	if Mode() == "Combo" then
-- 		[[ Use Q ]]
		if AnnieMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
			AnnieQ()
		end
-- 		[[ Use W ]]
		if AnnieMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			AnnieW()
		end
-- 		[[ Use E ]]
		if AnnieMenu.Combo.E:Value() and Ready(_E) then
			AnnieE()
		end
-- 		[[ Use R ]]
		if AnnieMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, Spells.R.range) then
			AnnieR()
		end	
	end	
end
--          [[ Harass ]]
function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= AnnieMenu.Harass.Mana:Value() /100) then

-- 			[[ Use Q ]]
			if AnnieMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, Spells.Q.range) then
				AnnieQ()
			end

-- 			[[ Use W ]]
			if AnnieMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
				AnnieW()
			end
		end
	end
end
--          [[ LaneClear ]]
function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= AnnieMenu.Farm.Mana:Value() /100) then
-- 			[[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
-- 					[[ Use Q ]]
					if AnnieMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, Spells.Q.range) then
						if GetCurrentHP(minion) < getdmg("Q", minion, myHero) then
							CastTargetSpell(minion, _Q)
					    end
					end    
-- 					[[ Use W ]]
					if AnnieMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, Spells.W.range) then
							CastSkillShot(_W, minion)
						end	
					end
				end	
-- 			[[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
-- 					[[ Use Q ]]
					if AnnieMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, Spells.Q.range) then
							CastTargetSpell(mob, _Q)
					    end
-- 					[[ Use W ]]
					if AnnieMenu.JG.W:Value() and Ready(_W) and ValidTarget(mob, Spells.W.range) then
							CastSkillShot(_W, mob)
						end	
					end
				end
			end
		end
	end
--          [[ KillSteal ]]
function KS()
	for _, enemy in pairs(GetEnemyHeroes()) do
-- 	    [[ Use Q ]]
		if AnnieMenu.KS.Q:Value() and Ready(_Q) and ValidTarget(enemy, Spells.Q.range) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
					AnnieQ()
				end
			end
-- 	    [[ Use R ]]
		if AnnieMenu.KS.R:Value() and Ready(_R) and ValidTarget(enemy, Spells.R.range) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
					AnnieR()
				end
			end
		end
	end
--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
--  [[ Draw Q ]]
	if AnnieMenu.Draw.Q:Value() then DrawCircle(pos, Spells.Q.range, 1, 25, GoS.Red) end
--  [[ Draw W ]]
	if AnnieMenu.Draw.W:Value() then DrawCircle(pos, Spells.W.range, 1, 25, GoS.Blue) end
--  [[ Draw W ]]
	if AnnieMenu.Draw.R:Value() then DrawCircle(pos, Spells.R.range, 1, 25, GoS.Green) end
end)	