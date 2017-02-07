if GetObjectName(GetMyHero()) ~= "Ezreal" then return end

require ("DamageLib")

-- Menu
local EzrealMenu = Menu("Ezreal", "Ezreal")

-- Combo
EzrealMenu:SubMenu("Combo", "Combo Settings")
EzrealMenu.Combo:Boolean("Q", "Use Q", true)
EzrealMenu.Combo:Boolean("W", "Use W", true)
EzrealMenu.Combo:Boolean("R", "Use R - NOT AVAILABLE", false)

-- Harass
EzrealMenu:SubMenu("Harass", "Harass Settings")
EzrealMenu.Harass:Boolean("Q", "Use Q", true)
EzrealMenu.Harass:Boolean("W", "Use W", true)
EzrealMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- LaneClear and JungleClear
EzrealMenu:SubMenu("Farm", "Farm Settings")
EzrealMenu.Farm:Boolean("Q", "Use Q", true)
EzrealMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- LastHit
EzrealMenu:SubMenu("LastHit", "LastHit Settings")
EzrealMenu.LastHit:Boolean("Q", "Use Q", true)
EzrealMenu.LastHit:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- Ks
EzrealMenu:SubMenu("Ks", "KillSteal Settings")
EzrealMenu.Ks:Boolean("Q", "Use Q", true)
EzrealMenu.Ks:Boolean("W", "Use W", true)
EzrealMenu.Ks:Boolean("R", "Use R", true)

-- Draw
EzrealMenu:SubMenu("Draw", "Drawing Settings")
EzrealMenu.Draw:Boolean("Q", "Draw Q", true)
EzrealMenu.Draw:Boolean("W", "Draw W", true)

-- Orbwalker's
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

-- Tick
OnTick(function()

	local target = GetCurrentTarget()
	if Mode() == "Combo" then
		-- Q
		if EzrealMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 1150) then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 2000, 0.25, 1150, 30, true, true)
			if QPred.HitChance == 1 then	
				CastSkillShot(_Q, QPred.PredPos)
			end
		end
		-- W
		if EzrealMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 1000) then
			local WPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 1550, 0.25, 1000, 40, false, true)
			if WPred.HitChance == 1 then
				CastSkillShot(_W, WPred.PredPos)
			end
		end
		-- R
		--if EzrealMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 20000) then
	end

	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= EzrealMenu.Harass.Mana:Value() /100) then

			--Q
			if EzrealMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 1150) then
				local QPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 2000, 0.25, 1150, 30, true, true)
				if QPred.HitChance == 1 then	
					CastSkillShot(_Q, QPred.PredPos)
				end
			end

			--W
			if EzrealMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 1000) then
				local WPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 1550, 0.25, 1000, 40, false, true)
				if WPred.HitChance == 1 then
					CastSkillShot(_W, WPred.PredPos)
				end
			end
		end
	end

	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= EzrealMenu.Farm.Mana:Value() /100) then
			
			--Lane
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if EzrealMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, 1150) then
						CastSkillShot(_Q, minion)
					end
				end
			end

			--Jungle
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if EzrealMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, 1150) then
						CastSkillShot(_Q, mob)
					end
				end
			end
		end
	end

	if Mode() == "LastHit" then
		if (myHero.mana/myHero.maxMana >= EzrealMenu.LastHit.Mana:Value() /100) then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if EzrealMenu.LastHit.Q:Value() and Ready(_Q) and ValidTarget(minion, 1150) then
						if GetCurrentHP(minion) < getdmg("Q", minion, myHero) then
							CastSkillShot(_Q, minion)
						end
					end
				end
			end
		end
	end
	
	-- KS
	for _, enemy in pairs(GetEnemyHeroes()) do
		-- Q
		if EzrealMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, 1550) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				local QPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 2000, 0.25, 1150, 30, true, true)
				if QPred.HitChance == 1 then	
					CastSkillShot(_Q, QPred.PredPos)
				end
			end
		end

		-- W
		if EzrealMenu.Ks.W:Value() and Ready(_W) and ValidTarget(enemy, 1000) then
			if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) then
				local WPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 1550, 0.25, 1000, 40, false, true)
				if WPred.HitChance == 1 then
					CastSkillShot(_W, QPred.PredPos)
				end
			end
		end

		-- R
		if EzrealMenu.Ks.R:Value() and Ready(_R) and ValidTarget(enemy, 3000) then
			if GetCurrentHP(enemy) < getdmg("R", enemy, myHero) then
				local RPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 2000, 1, 20000, 80, false, true)
				if RPred.HitChance == 1 then
					CastSkillShot(_R, RPred.PredPos)
				end
			end
		end
	end
end)

-- Drawings 2
OnDraw(function (myHero)
	if EzrealMenu.Draw.Q:Value() then
		DrawCircle(GetOrigin(myHero), 1150, 0, 150, GoS.White)
	end
	if EzrealMenu.Draw.W:Value() then
		DrawCircle(GetOrigin(myHero), 1000, 0, 150, GoS.White)
	end
end)

print("Thank you for using my Ezreal script, I love you<3") 
