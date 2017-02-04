--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Heimerdinger" then return end

--          [[ Updater ]]
local LoLVer = "7.2"
local ScrVer = 1

local function Heimerdinger_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Heimerdinger]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Heimerdinger]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Heimerdinger.lua", SCRIPT_PATH .. "Heimerdinger.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Heimerdinger]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Heimerdinger]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Heimerdinger.version", Heimerdinger_Update)

--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")

--          [[ Menu ]]
local HeimerdingerMenu = Menu("Heimerdinger", "Heimerdinger")

--          [[ Combo ]]
HeimerdingerMenu:SubMenu("Combo", "Combo Settings")
HeimerdingerMenu.Combo:Boolean("W", "Use W", true)
HeimerdingerMenu.Combo:Boolean("E", "Use E", true)

--          [[ Harass ]]
HeimerdingerMenu:SubMenu("Harass", "Harass Settings")
HeimerdingerMenu.Harass:Boolean("Q", "Use Q", true)
HeimerdingerMenu.Harass:Boolean("W", "Use W", true)
HeimerdingerMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ LaneClear ]]
HeimerdingerMenu:SubMenu("Farm", "Farm Settings")
HeimerdingerMenu.Farm:Boolean("Q", "Use Q", false)
HeimerdingerMenu.Farm:Boolean("W", "Use W", true)
HeimerdingerMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ KillSteal ]]
HeimerdingerMenu:SubMenu("Ks", "KillSteal Settings")
HeimerdingerMenu.Ks:Boolean("W", "Use W", true)
HeimerdingerMenu.Ks:Boolean("E", "Use E", true)


--          [[ Draw ]]
HeimerdingerMenu:SubMenu("Draw", "Drawing Settings")
HeimerdingerMenu.Draw:Boolean("Q", "Draw Q", false)
HeimerdingerMenu.Draw:Boolean("W", "Draw W", false)
HeimerdingerMenu.Draw:Boolean("E", "Draw E", false)
HeimerdingerMenu.Draw:Boolean("R", "Draw R", false)

--          [[ Spell ]]
local HeimerdingerQ = {delay = 0.25, range = 350, width = 90, speed = 2000}
local HeimerdingerW = {delay = 0.25, range = 1325, width = 40, speed = 2000}
local HeimerdingerE = {delay = 0.25, range = 970, radius = 120, speed = 2000}

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
		if HeimerdingerMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 300) then
			local QPred = GetCircularAOEPrediction(target, HeimerdingerQ)
			if QPred.hitChance > 0.2 then
				CastTargetSpell(enemy, _Q)
			end
		end	
		-- [[ Use QR ]]
		--[[if Ready(_Q) and Ready(_R) and EnemiesAround(Enemy, 300) >= HeimerdingerMenu.Combo.QRC:Value() and HeimerdingerMenu.Combo.QR:Value() then
				CastSkillShot(_Q, CastPos)
			end	
		-- [[ Use E ]]
		if HeimerdingerMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 925) then
			local EPred = GetCircularAOEPrediction(target, HeimerdingerE)
			if EPred.hitChance > 0.5 then
				CastSkillShot(_E, EPred.castPos)
			end
		end
		-- [[ Use ER ]]
		--[[if Ready(_E) and Ready(_R) and EnemiesAround(Enemy, 1100) >= HeimerdingerMenu.Combo.ERC:Value() and HeimerdingerMenu.Combo.ER:Value() then
			local EPred = GetCircularAOEPrediction(target, HerimeerdingerE)
			if EPred.hitChance > 0.2 and not EPred:mCollision(1) then
				CastSkillShot(_E, EPred.castPos)
			end	
		end	]]
        -- [[ Use W ]]
		if HeimerdingerMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 1100) then
			local WPred = GetLinearAOEPrediction(target, HeimerdingerW)
			if WPred.hitChance > 0.2 and not WPred:mCollision(1) then
				CastSkillShot(_W, WPred.castPos)
			end
		end
	end

	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= HeimerdingerMenu.Harass.Mana:Value() /100) then

			-- [[ Use W ]]
			if HeimerdingerMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 1100) then
				local WPred = GetLinearAOEPrediction(target, HeimerdingerW)
				if WPred.hitChance > 0.2 and not WPred:mCollision(1) then	
					CastSkillShot(_W, QPred.castPos)
				end
			end

			-- [[ Use E ]]
			if HeimerdingerMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, 925) then
				local EPred = GetCircularAOEPrediction(target, HeimerdingerE)
				if EPred.hitChance > 0.5 then
					CastSkillShot(_E, EPred.castPos)
				end
			end
		end
	end

	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= HeimerdingerMenu.Farm.Mana:Value() /100) then
			
			-- [[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if HeimerdingerMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, 600) then
						CastSkillShot(_Q, minion)
					end
				end
			end
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if HeimerdingerMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, 1000) then
						CastSkillShot(_W, minion)
					end
				end
			end

			-- [[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if HeimerdingerMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, 600) then
						CastSkillShot(_Q, mob)
					end
				end
			end

			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if HeimerdingerMenu.Farm.W:Value() and Ready(_W) and ValidTarget(mob, 1000) then
						CastSkillShot(_W, mob)
					end
				end
			end
		end
	end
	
	-- [[ KillSteal ]]
	for _, enemy in pairs(GetEnemyHeroes()) do
		-- W
		if HeimerdingerMenu.Ks.W:Value() and Ready(_W) and ValidTarget(enemy, 1100) then
			if GetCurrentHP(enemy) < getdmg("W", enemy, myHero) then
				local WPred = GetPrediction(target, HeimerdingerQ)
				if WPred.hitChance > 0.8 and not WPred:mCollision(1) then
					CastSkillShot(_Q, QPred.castPos)
				end
			end
		end

		-- E
		if HeimerdingerMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, 925) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
				local EPred = GetPrediction(target, HeimerdingerE)
				if EPred.hitChance > 0.8 then
					CastSkillShot(_E, EPred.castPos)
				end
			end
		end 

		-- R W
		--[[if HeimerdingerMenu.Ks.WR:Value() and Ready(_R) and Ready(_W) and ValidTarget(enemy, 1100) then
			if GetCurrentHP(enemy) < getdmg("W2", enemy, myHero) then
				local WPred = GetPrediction(target,HeimerdingerW)
				if WPred.hitChance > 0.8 then
					CastSkillShot(_W, WPred.castPos)
				end
			end
		end]]
	end
end)
       


--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
	local mpos = GetMousePos()
		-- [[ Draw Q ]]
	if HeimerdingerMenu.Draw.Q:Value() then DrawCircle(pos, 350, 1, 25, GoS.Red) end
		-- [[ Draw W ]]
	if HeimerdingerMenu.Draw.W:Value() then DrawCircle(pos, 1100, 1, 25, GoS.Blue) end
		-- [[ Draw E ]]
	if HeimerdingerMenu.Draw.E:Value() then DrawCircle(pos, 925, 1, 25, GoS.Blue) end
		-- [[ Draw R ]]  
	if HeimerdingerMenu.Draw.R:Value() then DrawCircle(pos, 1, 1, 25, GoS.Green) end
end)	