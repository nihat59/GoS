--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Ziggs" then return end

--          [[ Updater ]]
local LoLVer = "7.2"
local ScrVer = 1

local function Ziggs_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Ziggs]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Ziggs]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Ziggs.lua", SCRIPT_PATH .. "Ziggs.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Ziggs]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Ziggs]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Ziggs.version", Ziggs_Update)
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
ZiggsMenu.JG:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

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
local ZiggsQ = {delay = 0.25, range = 850, width = 100, speed = 1700}
local ZiggsW = {delay = 0.25, range = 1000, width = 100, speed = 1500}
local ZiggsE = {delay = 0.25, range = 900, radius = 100, speed = 1300}
local ZiggsR = {delay = 1.35, range = 5000, radius = 550, speed = 2000}

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

	local target = GetCurrentTarget()
	if Mode() == "Combo" then
		-- [[ Use Q ]]
		if ZiggsMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 850) then
			local QPred = GetPrediction(target, ZiggsQ)
			if QPred.hitChance > 0.2 then
				CastSkillShot(_Q, QPred.castPos)
			end
		end
		-- [[ Use W ]]
		if ZiggsMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 850) then
			local WPred = GetPrediction(target, ZiggsW)
			if WPred.hitChance > 0.2 then
				CastSkillShot(_W, WPred.castPos)
			end
		end	
		-- [[ Use E ]]
		if ZiggsMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 900) then
			local EPred = GetCircularAOEPrediction(target, ZiggsE)
			if EPred.hitChance > 0.2 then
				CastSkillShot(_E, EPred.castPos)
			end
		end
	end

	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= ZiggsMenu.Harass.Mana:Value() /100) then

			-- [[ Use Q ]]
			if ZiggsMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 850) then
				local QPred = GetPrediction(target, ZiggsQ)
				if QPred.hitChance > 0.2 then
					CastSkillShot(_Q, QPred.castPos)
				end
			end

			-- [[ Use E ]]
			if ZiggsMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, 900) then
				local EPred = GetCircularAOEPrediction(target, ZiggsE)
				if EPred.hitChance > 0.2 then
					CastSkillShot(_E, EPred.castPos)
				end
			end
		end
	end

	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= ZiggsMenu.Farm.Mana:Value() /100) then
			
			-- [[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if ZiggsMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, 800) then
						CastSkillShot(_Q, minion)
					end
				end
			end
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if ZiggsMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, 800) then
						CastSkillShot(_E, minion)
					end
				end
			end

			-- [[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if ZiggsMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, 800) then
						CastSkillShot(_Q, mob)
					end
				end
			end

			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if ZiggsMenu.JG.E:Value() and Ready(_E) and ValidTarget(mob, 800) then
						CastSkillShot(_E, mob)
					end
				end
			end
		end
	end
	
	-- [[ KillSteal ]]
	for _, enemy in pairs(GetEnemyHeroes()) do
		-- Q
		if ZiggsMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, 850) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				local QPred = GetPrediction(target, ZiggsQ)
				if QPred.hitChance > 0.8  then
					CastSkillShot(_Q, QPred.castPos)
				end
			end
		end

		-- E
		if ZiggsMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, 900) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
				local EPred = GetCircularAOEPrediction(target, ZiggsE)
				if EPred.hitChance > 0.8 then
					CastSkillShot(_E, EPred.castPos)
				end
			end
		end

		-- R
		if ZiggsMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, 5000) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
				local RPred = GetCircularAOEPrediction(target,ZiggsR)
				if RPred.hitChance > 0.8 then
					CastSkillShot(_R, RPred.castPos)
				end
			end
		end
	end
end)
       


--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
		-- [[ Draw Q ]]
	if ZiggsMenu.Draw.Q:Value() then DrawCircle(pos, 850, 1, 25, GoS.Red) end
		-- [[ Draw W ]]
	if ZiggsMenu.Draw.W:Value() then DrawCircle(pos, 1000, 1, 25, GoS.Blue) end
		-- [[ Draw E ]]
	if ZiggsMenu.Draw.E:Value() then DrawCircle(pos, 900, 1, 25, GoS.Green) end
end)	