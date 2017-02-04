--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Veigar" then return end

--          [[ Updater ]]
local LoLVer = "7.2"
local ScrVer = 1

local function Veigar_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Veigar]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Veigar]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Veigar.lua", SCRIPT_PATH .. "Veigar.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Veigar]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Jani]</b></font><font color=\"#FFA500\"><b>[Veigar]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/janilssonn/GoS/master/Version/Veigar.version", Veigar_Update)

--          [[ Lib ]]
require ("OpenPredict")
require ("DamageLib")

--          [[ Menu ]]
local VeigarMenu = Menu("Veigar", "Veigar")

--          [[ Combo ]]
VeigarMenu:SubMenu("Combo", "Combo Settings")
VeigarMenu.Combo:Boolean("Q", "Use Q", true)
VeigarMenu.Combo:Boolean("W", "Use W", true)
VeigarMenu.Combo:Boolean("E", "Use E", true)

--          [[ Harass ]]
VeigarMenu:SubMenu("Harass", "Harass Settings")
VeigarMenu.Harass:Boolean("Q", "Use Q", true)
VeigarMenu.Harass:Boolean("W", "Use W", true)
VeigarMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ LaneClear ]]
VeigarMenu:SubMenu("Farm", "Farm Settings")
VeigarMenu.Farm:Boolean("Q", "Use Q", true)
VeigarMenu.Farm:Boolean("W", "Use W", false)
VeigarMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ Jungle ]]
VeigarMenu:SubMenu("JG", "Jungle Settings")
VeigarMenu.JG:Boolean("Q", "Use Q", true)
VeigarMenu.JG:Boolean("W", "Use W", true)
VeigarMenu.JG:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ KillSteal ]]
VeigarMenu:SubMenu("Ks", "KillSteal Settings")
VeigarMenu.Ks:Boolean("Q", "Use Q", true)
VeigarMenu.Ks:Boolean("R", "Use R", true)

--          [[ Draw ]]
VeigarMenu:SubMenu("Draw", "Drawing Settings")
VeigarMenu.Draw:Boolean("Q", "Draw Q", false)
VeigarMenu.Draw:Boolean("W", "Draw W", false)
VeigarMenu.Draw:Boolean("E", "Draw E", false)
VeigarMenu.Draw:Boolean("R", "Draw R", false)

--          [[ Spell ]]
local VeigarQ = {delay = 0.25, range = 900, width = 80, speed = 2000}
local VeigarW = {delay = 0.25, range = 900, width = 150, speed = math.huge}
local VeigarE = {delay = 0.25, range = 725, radius = 275, speed = math.huge}

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
		if VeigarMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 900) then
			local QPred = GetPrediction(target, VeigarQ)
			if QPred.hitChance > 0.2 and not QPred:mCollision(2) then
				CastSkillShot(_Q, QPred.castPos)
			end
		end
		-- [[ Use W ]]
		if VeigarMenu.Combo.W:Value() and ValidTarget(target, GetCastRange(myHero, _W)) and GotBuff(target, "veigareventhorizonstun") > 0  then
			local WPred = GetCircularAOEPrediction(target, VeigarW)
			CastSkillShot(_W, WPred.castPos)
			end
		-- [[ Use E ]]
		if VeigarMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 1100) then
			local EPred = GetCircularAOEPrediction(target, VeigarE)
			if EPred.hitChance > 0.2 then
				CastSkillShot(_E, EPred.castPos)
			end
		end
	end

	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= VeigarMenu.Harass.Mana:Value() /100) then

			-- [[ Use Q ]]
			if VeigarMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 900) then
				local QPred = GetPrediction(target, VeigarQ)
				if QPred.hitChance > 0.2 and not QPred:mCollision(2) then	
					CastSkillShot(_Q, QPred.castPos)
				end
			end

			-- [[ Use W ]]
			if VeigarMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 900) then
				local WPred = GetCircularAOEPrediction(target, VeigarW)
				if WPred.hitChance > 0.2 then
					CastSkillShot(_W, EPred.castPos)
				end
			end
		end
	end

	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= VeigarMenu.Farm.Mana:Value() /100) then
			
			-- [[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if VeigarMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, 900) then
						if GetCurrentHP(minion) < getdmg("Q", minion, myHero) then
						CastSkillShot(_Q, minion)
					end
				end
			end
		end	
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if VeigarMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, 900) then
						CastSkillShot(_W, minion)
					end
				end
			end

			-- [[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if VeigarMenu.JG.Q:Value() and Ready(_Q) and ValidTarget(mob, 900) then
						CastSkillShot(_Q, mob)
					end
				end
			end

			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if VeigarMenu.JG.W:Value() and Ready(_W) and ValidTarget(mob, 900) then
						CastSkillShot(_W, mob)
					end
				end
			end
		end
	end
	
	-- [[ KillSteal ]]
	for _, enemy in pairs(GetEnemyHeroes()) do
		-- Q
		if VeigarMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, 900) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				local QPred = GetPrediction(target, VeigarQ)
				if QPred.hitChance > 0.8 then	
					CastSkillShot(_Q, QPred.castPos)
				end
			end
		end

		-- R
		if VeigarMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, 650) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
					CastTargetSpell(target, _R)
			end
		end
	end
end)
       


--          [[ Drawings ]]
OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
		-- [[ Draw Q ]]
	if VeigarMenu.Draw.Q:Value() then DrawCircle(pos, 900, 1, 25, GoS.Red) end
		-- [[ Draw W ]]
	if VeigarMenu.Draw.W:Value() then DrawCircle(pos, 900, 1, 25, GoS.Blue) end
		-- [[ Draw E ]]
	if VeigarMenu.Draw.E:Value() then DrawCircle(pos, 725, 1, 25, GoS.Blue) end
		-- [[ Draw R ]]  
	if VeigarMenu.Draw.R:Value() then DrawCircle(pos, 650, 1, 25, GoS.Green) end
end)	