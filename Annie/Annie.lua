--          [[ Champion ]]
if GetObjectName(GetMyHero()) ~= "Annie" then return end

--          [[ Updater ]]

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
AnnieMenu.Farm:Boolean("W", "Use W", true)
AnnieMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

--          [[ KillSteal ]]
AnnieMenu:SubMenu("Ks", "KillSteal Settings")
AnnieMenu.Ks:Boolean("Q", "Use Q", true)
AnnieMenu.Ks:Boolean("W", "Use W", true)
AnnieMenu.Ks:Boolean("R", "Use R", true)
--          [[ Misc ]]
--[[AnnieMenu:SubMenu("Misc", "Misc Settings")
AnnieMenu.Misc:Boolean("E", "Auto Stun E", true) ]]

--          [[ Draw ]]
AnnieMenu:SubMenu("Draw", "Drawing Settings")
AnnieMenu.Draw:Boolean("Q", "Draw Q", false)
AnnieMenu.Draw:Boolean("W", "Draw W", false)
AnnieMenu.Draw:Boolean("E", "Draw E", false)
AnnieMenu.Draw:Boolean("R", "Draw R", false)

--          [[ Spell ]]
local AnnieW = {delay = 0.25, range = 576, width = 150, speed = 1200}
local AnnieR = {delay = 0.75, range = 600, width = 150, speed = math.huge}

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
		if AnnieMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 625) then
				CastTargetSpell(target, _Q)
		end
		-- [[ Use W ]]
		if AnnieMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 576) then
			local WPred = GetCircularAOEPrediction(target, AnnieW)
			if WPred.hitChance > 0.2 then
				CastSkillShot(_W, WPred.castPos)
			end
		end
		-- [[ Use E ]]
		if AnnieMenu.Combo.E:Value() and Ready(_E) then
			CastSpell(_E)
		end
		-- [[ Use R
		if AnnieMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 600) then
			local RPred = GetCircularAOEPrediction(target,AnnieR)
			if RPred.hitChance > 0.2 then
				CastSkillShot(_R, RPred.castPos)
			end	
		end	
	end

	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= AnnieMenu.Harass.Mana:Value() /100) then

			-- [[ Use Q ]]
			if AnnieMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 625) then
					CastTargetSpell(target, _Q)
			end

			-- [[ Use W ]]
			if AnnieMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 576) then
				local WPred = GetCircularAOEPrediction(target, AnnieW)
				if WPred.hitChance > 0.2 then
					CastSkillShot(_W, WPred.castPos)
				end
			end
		end
	end

	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= AnnieMenu.Farm.Mana:Value() /100) then
			
			-- [[ Lane ]]
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if AnnieMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, 625) then
						CastTargetSpell(minion, _Q)
					end
				end
			end
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if AnnieMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, 576) then
						CastSkillShot(_W, minion)
					end
				end
			end

			-- [[ Jungle ]]
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if AnnieMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, 625) then
						CastTargetSpell(mob, _Q)
					end
				end
			end

			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if AnnieMenu.Farm.W:Value() and Ready(_W) and ValidTarget(mob, 576) then
						CastSkillShot(_W, mob)
					end
				end
			end
		end
	end
	
	-- [[ KillSteal ]]
	for _, enemy in pairs(GetEnemyHeroes()) do
		-- Q
		if AnnieMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, 625) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
					CastTargetSpell(target, _Q)
			end
		end

		-- R
		if AnnieMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, 600) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
				local RPred = GetCircularAOEPrediction(target,AnnieR)
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
	if AnnieMenu.Draw.Q:Value() then DrawCircle(pos, 1300, 1, 25, GoS.Red) end
		-- [[ Draw W ]]
	if AnnieMenu.Draw.W:Value() then DrawCircle(pos, 1075, 1, 25, GoS.Blue) end
		-- [[ Draw E ]]
	if AnnieMenu.Draw.E:Value() then DrawCircle(pos, 1100, 1, 25, GoS.Blue) end
		-- [[ Draw R ]]  
	if AnnieMenu.Draw.R:Value() then DrawCircle(pos, 3340, 1, 25, GoS.Green) end
end)	
--          [[ PrintChat ]]
print ("Annie By Jani")