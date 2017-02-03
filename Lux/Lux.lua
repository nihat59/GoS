--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Lux" then return end

--          [[ Updater ]]

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
LuxMenu.Combo:Slider("WM", "Use W on HP", 40, 1, 100, 1)
LuxMenu.Combo:Slider("WMA", "No Options here", 1, 1, 1, 1)
LuxMenu.Combo:Boolean("E", "Use E", true)

--          [[ Harass ]]
LuxMenu:SubMenu("Harass", "Harass Settings")
LuxMenu.Harass:Boolean("Q", "Use Q", true)
LuxMenu.Harass:Boolean("E", "Use W", true)
LuxMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ LaneClear ]]
LuxMenu:SubMenu("Farm", "Farm Settings")
LuxMenu.Farm:Boolean("Q", "Use Q", true)
LuxMenu.Farm:Boolean("E", "Use E", true)
LuxMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ KillSteal ]]
LuxMenu:SubMenu("Ks", "KillSteal Settings")
LuxMenu.Ks:Boolean("Q", "Use Q", true)
LuxMenu.Ks:Boolean("E", "Use E", true)
LuxMenu.Ks:Boolean("R", "Use R", true)

--          [[ Draw ]]
LuxMenu:SubMenu("Draw", "Drawing Settings")
LuxMenu.Draw:Boolean("Q", "Draw Q", false)
LuxMenu.Draw:Boolean("W", "Draw W", false)
LuxMenu.Draw:Boolean("E", "Draw E", false)
LuxMenu.Draw:Boolean("R", "Draw R", false)

--          [[ Spell ]]
local LuxQ = {delay = 0.25, range = 1300, width = 80, speed = 1200}
local LuxW = {delay = 0.25, range = 1075, width = 150, speed = 1200}
local LuxE = {delay = 0.25, range = 1100, radius = 275, speed = 1400}
local LuxR = {delay = 1.35, range = 3340, width = 190, speed = math.huge}

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
		if LuxMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 1300) then
			local QPred = GetPrediction(target, LuxQ)
			if QPred.hitChance > 0.2 and not QPred:mCollision(2) then
				CastSkillShot(_Q, QPred.castPos)
			end
		end
		-- [[ Use W ]]
		if Ready(_W) and GetPercentHP(myHero) <= LuxMenu.Combo.WM:Value() and LuxMenu.Combo.W:Value() and EnemiesAround(myHero, 800) >= LuxMenu.Combo.WMA:Value() then
				CastSkillShot(_W,myHero.pos)
			end
		-- [[ Use E ]]
		if LuxMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 1100) then
			local EPred = GetCircularAOEPrediction(target, LuxE)
			if EPred.hitChance > 0.2 then
				CastSkillShot(_E, EPred.castPos)
			end
		end
	end

	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= LuxMenu.Harass.Mana:Value() /100) then

			-- [[ Use Q ]]
			if LuxMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 1300) then
				local QPred = GetPrediction(target, LuxQ)
				if QPred.hitChance > 0.2 and not QPred:mCollision(2) then	
					CastSkillShot(_Q, QPred.castPos)
				end
			end

			-- [[ Use E ]]
			if LuxMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, 1100) then
				local EPred = GetCircularAOEPrediction(target, LuxE)
				if EPred.hitChance > 0.2 then
					CastSkillShot(_E, EPred.castPos)
				end
			end
		end
	end

	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= LuxMenu.Farm.Mana:Value() /100) then
			
			-- [[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if LuxMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, 1000) then
						CastSkillShot(_Q, minion)
					end
				end
			end
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if LuxMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, 1000) then
						CastSkillShot(_E, minion)
					end
				end
			end

			-- [[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if LuxMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, 1000) then
						CastSkillShot(_Q, mob)
					end
				end
			end

			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if LuxMenu.Farm.E:Value() and Ready(_E) and ValidTarget(mob, 1000) then
						CastSkillShot(_E, mob)
					end
				end
			end
		end
	end
	
	-- [[ KillSteal ]]
	for _, enemy in pairs(GetEnemyHeroes()) do
		-- Q
		if LuxMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, 1300) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				local QPred = GetPrediction(target, LuxQ)
				if QPred.hitChance > 0.8 then	
					CastSkillShot(_Q, QPred.castPos)
				end
			end
		end

		-- E
		if LuxMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, 1100) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
				local EPred = GetPrediction(target, LuxE)
				if EPred.hitChance > 0.8 then
					CastSkillShot(_E, EPred.castPos)
				end
			end
		end

		-- R
		if LuxMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, 3340) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
				local RPred = GetPrediction(target,LuxR)
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
	local mpos = GetMousePos()
		-- [[ Draw Q ]]
	if LuxMenu.Draw.Q:Value() then DrawCircle(pos, 1300, 1, 25, GoS.Red) end
		-- [[ Draw W ]]
	if LuxMenu.Draw.W:Value() then DrawCircle(pos, 1075, 1, 25, GoS.Blue) end
		-- [[ Draw E ]]
	if LuxMenu.Draw.E:Value() then DrawCircle(pos, 1100, 1, 25, GoS.Blue) end
		-- [[ Draw R ]]  
	if LuxMenu.Draw.R:Value() then DrawCircle(pos, 3340, 1, 25, GoS.Green) end
end)	
--          [[ PrintChat ]]
print ("Lux Script")