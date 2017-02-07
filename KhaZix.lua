if GetObjectName(GetMyHero()) ~= "Khazix" then return end

require("DamageLib")
require("OpenPredict")

-- Spells
local Spells = {
		W = {range = 1000, delay = 0.25, speed = 1650,  width = 70},
		E = {range = 700, delay = 0.25, speed = 2000,  width = 70}
}

-- Khazix Evo E
if GetCastName(myHero, _E) == "KhazixELong" then            
    Spells.E.range = 900
end

-- Menu
local SMenu = Menu("KhaZix", "KhaZix")

-- Combo
SMenu:SubMenu("Combo", "Combo Settings")
SMenu.Combo:Boolean("Q", "Use Q", true)
SMenu.Combo:Boolean("W", "Use W", true)
SMenu.Combo:Boolean("E", "Use E", true)
SMenu.Combo:Boolean("I", "Use Items", true)

-- Harass
SMenu:SubMenu("Harass", "Harass Settings")
SMenu.Harass:Boolean("Q", "Use Q", true)
SMenu.Harass:Boolean("W", "Use W", true)
SMenu.Harass:Boolean("AW", "Auto W", true)
SMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- Farm
SMenu:SubMenu("Farm", "LaneClear Settings")
SMenu.Farm:Boolean("Q", "Use Q", true)
SMenu.Farm:Boolean("W", "Use W", true)
SMenu.Farm:Boolean("E", "Use E", false)
SMenu.Farm:Boolean("I", "Use Items", true)
SMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- Jungle
SMenu:SubMenu("Jungle", "JungleClear Settings")
SMenu.Jungle:Boolean("Q", "Use Q", true)
SMenu.Jungle:Boolean("W", "Use W", true)
SMenu.Jungle:Boolean("E", "Use E", false)
SMenu.Jungle:Boolean("I", "Use Items", true)
SMenu.Jungle:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- LastHit
SMenu:SubMenu("LastHit", "LastHit Settings")
SMenu.LastHit:Boolean("Q", "Use Q", true)
SMenu.LastHit:Boolean("W", "Use W", true)
SMenu.LastHit:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- Ks
SMenu:SubMenu("Ks", "KillSteal Settings")
SMenu.Ks:Boolean("Q", "Use Q", true)
SMenu.Ks:Boolean("W", "Use W", true)
SMenu.Ks:Boolean("E", "Use E", true)
SMenu.Ks:Boolean("EQ", "Use EQ", true)
SMenu.Ks:Boolean("Recall", "Don't Ks during Recall", true)
SMenu.Ks:Boolean("Disabled", "Don't Ks", false)

-- Doble Jump
SMenu:SubMenu("Dj", "Jump Settings")
SMenu.Dj:Boolean("Enabled", "Double Jump Enabled")
SMenu.Dj:DropDown("Return", "Double Jump Logic", 1, {"Script Logic", "To Mouse", "Off"})

-- Draw
SMenu:SubMenu("Draw", "Drawing Settings")
SMenu.Draw:Boolean("Q", "Draws Q", true)
SMenu.Draw:Boolean("W", "Draws W", true)
SMenu.Draw:Boolean("E", "Draws E", true)

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

-- Tick | KillSteal | Cast | Double Jump

OnTick(function(myHero)
	AutoW()
	Ks()
	DoubleJump()
	target = GetCurrentTarget()
	         Combo()
	         Harass()
	         Farm()
	         LastHit()
end)

function Ks()
	if SMenu.Ks.Disabled:Value() or (IsRecalling(myHero) and SMenu.Ks.Recall:Value()) then return end
	for _, enemy in pairs(GetEnemyHeroes()) do
		if SMenu.Ks.Q:Value() and Ready(_Q) and ValidTarget(enemy, GetRange(myHero) + GetHitBox(enemy)) then
			if getdmg("Q", enemy, myHero) > GetCurrentHP(enemy) then
				CastQ()
			end
		end
		if SMenu.Ks.W:Value() and Ready(_W) and ValidTarget(enemy, Spells.W.range) then
			if getdmg("W", enemy, myHero) > GetCurrentHP(enemy) then
				CastW()
			end
		end
		if SMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, Spells.E.range) then
			if getdmg("E", enemy, myHero) > GetCurrentHP(enemy) then
				CastE()
			end
		end
		if SMenu.Ks.EQ:Value() and Ready(_E) and Ready(_Q) and ValidTarget(enemy, Spells.E.range) then
			if getdmg("Q", enemy, myHero) + getdmg("E", enemy, myHero) > GetCurrentHP(enemy) then
				local EPred = GetCircularAOEPrediction(enemy, Spells.E)
				if EPred.hitChance > 0.2 then
					CastSkillShot(_E, EPred.castPos)
					DelayAction(function() CastTargetSpell(target, _Q)end, 0.25)
				end
			end
		end
	end
end

function CastQ()
	CastTargetSpell(target, _Q)
end

function CastW()
	local WPred = GetPrediction(target, Spells.W)
	if WPred.hitChance > 0.2 and not WPred:mCollision(1) then
		CastSkillShot(_W, WPred.castPos)
	end
end

function CastE()
	local EPred = GetCircularAOEPrediction(target, Spells.E)
	if EPred.hitChance > 0.2 then
		CastSkillShot(_E, EPred.castPos)
	end
end

function CastR()
	CastSpell(_R)
end

function DoubleJump()
	if SMenu.Dj.Enabled:Value() and Mode() == "Combo" then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if GetCastName(myHero, _E) == "KhazixELong" then
				if Ready(_E) and Ready(_Q) and ValidTarget(enemy, Spells.E.range) then
					if GetCurrentHP(enemy) < getdmg("Q", enemy, myHero) + getdmg("E", enemy, myHero) then
						local EPred = GetCircularAOEPrediction(enemy, Spells.E)
						if EPred.hitChance > 0.2 then
							CastSkillShot(_E, EPred.castPos)
							DelayAction(function() CastTargetSpell(target, _Q)end, 0.25)
						end
					end
				elseif SMenu.Dj.Return:Value() == 1 then
					if not ValidTarget(enemy, Spells.E.range) and Ready(_E) and IsDead(enemy) then
						local EPred = GetPrediction(enemy, Spells.E)
						if EPred.hitChance > 0.2 then
							CastSkillShot(_E, GetOrigin(EPred.castPos))
						end
					end
				elseif SMenu.Dj.Return:Value() == 2 then
					if not ValidTarget(enemy, Spells.E.range) and Ready(_E) and IsDead(enemy) then
						CastSkillShot(_E, mousePos)
					end
				end
			end
		end
	end
end

-- Combo | Harass | Auto W | Farm | LastHit

function Combo()
	if Mode() == "Combo" then
		if SMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) and not DoubleJump() then
			CastE()
		end
		if SMenu.Combo.I:Value() and ValidTarget(target, GetRange(myHero)) then
			if GetItemSlot(myHero, 3077) > 0 and Ready(GetItemSlot(myHero, 3077)) then
				CastSpell(GetItemSlot(myHero, 3077))
			end
			if GetItemSlot(myHero, 3074) > 0 and Ready(GetItemSlot(myHero, 3074)) then
				CastSpell(GetItemSlot(myHero, 3074))
			end
			if GetItemSlot(myHero, 3748) > 0 and Ready(GetItemSlot(myHero, 3748)) then
				CastSpell(GetItemSlot(myHero, 3748))
			end
		elseif SMenu.Combo.I:Value() and ValidTarget(target, GetRange(myHero) + 400) then
			if GetItemSlot(myHero, 3142) > 0 and Ready(GetItemSlot(myHero, 3142)) then
				CastSpell(GetItemSlot(myHero, 3142))
			end
		end
		if SMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, GetRange(myHero)) then
			CastQ()
		end
		if SMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			CastW()
		end
	end
end

function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= SMenu.Harass.Mana:Value() /100) then
			if SMenu.Harass.W:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
				CastW()
			end
			if SMenu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, GetRange(myHero) + GetHitBox(target)) then
				CastQ()
			end
		end
	end
end

function AutoW()
	if (myHero.mana/myHero.maxMana >= SMenu.Harass.Mana:Value() /100) then
		if SMenu.Harass.AW:Value() and Ready(_W) and ValidTarget(target, Spells.W.range) then
			CastW()
		end
	end
end

function Farm()
	if Mode() == "LaneClear" then
		for _, minion in pairs(minionManager.objects) do
			if GetTeam(minion) == MINION_ENEMY then
				if SMenu.Farm.I:Value() and ValidTarget(minion, GetRange(myHero) + GetHitBox(minion)) then
					if GetItemSlot(myHero, 3077) > 0 and Ready(GetItemSlot(myHero, 3077)) then
						CastSpell(GetItemSlot(myHero, 3077))
					end
					if GetItemSlot(myHero, 3074) > 0 and Ready(GetItemSlot(myHero, 3074)) then
						CastSpell(GetItemSlot(myHero, 3074))
					end
					if GetItemSlot(myHero, 3748) > 0 and Ready(GetItemSlot(myHero, 3748)) then
						CastSpell(GetItemSlot(myHero, 3748))
					end
				end
				if (myHero.mana/myHero.maxMana >= SMenu.Farm.Mana:Value() /100) then
					if SMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
						local EPred = GetCircularAOEPrediction(minion, Spells.E)
						if EPred.hitChance > 0.2 then
							CastSkillShot(_E, EPred.castPos)
						end
					end
					if SMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, Spells.W.range) then
						local WPred = GetPrediction(minion, Spells.W)
						if WPred.hitChance > 0.2 then
							CastSkillShot(_W, WPred.castPos)
						end
					end
					if SMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, GetRange(myHero) + GetHitBox(minion)) then
						CastTargetSpell(minion, _Q)
					end
				end
			end
		end

		for _, mob in pairs(minionManager.objects) do
			if GetTeam(mob) == MINION_JUNGLE then
				if SMenu.Jungle.I:Value() and ValidTarget(mob, GetRange(myHero) + GetHitBox(mob)) then
					if GetItemSlot(myHero, 3077) > 0 and Ready(GetItemSlot(myHero, 3077)) then
						CastSpell(GetItemSlot(myHero, 3077))
					end
					if GetItemSlot(myHero, 3074) > 0 and Ready(GetItemSlot(myHero, 3074)) then
						CastSpell(GetItemSlot(myHero, 3074))
					end
					if GetItemSlot(myHero, 3748) > 0 and Ready(GetItemSlot(myHero, 3748)) then
						CastSpell(GetItemSlot(myHero, 3748))
					end
				end
				if (myHero.mana/myHero.maxMana >= SMenu.Jungle.Mana:Value() /100) then
					if SMenu.Jungle.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
						local EPred = GetCircularAOEPrediction(mob, Spells.E)
						if EPred.hitChance > 0.2 then
							CastSkillShot(_E, EPred.castPos)
						end
					end
					if SMenu.Jungle.W:Value() and Ready(_W) and ValidTarget(mob, Spells.W.range) then
						local WPred = GetPrediction(mob, Spells.W)
						if WPred.hitChance > 0.2 then
							CastSkillShot(_W, WPred.castPos)
						end
					end
					if SMenu.Jungle.Q:Value() and Ready(_Q) and ValidTarget(mob, GetRange(myHero) + GetHitBox(mob)) then
						CastTargetSpell(mob, _Q)
					end
				end
			end
		end
	end
end

function LastHit()
	if Mode() == "LastHit" then
		if (myHero.mana/myHero.maxMana >= SMenu.LastHit.Mana:Value() /100) then
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if SMenu.LastHit.Q:Value() and Ready(_Q) and ValidTarget(minion, 325) then
						if GetCurrentHP(minion) < getdmg("Q", minion, myHero) then
							CastTargetSpell(minion, _Q)
						end
					end
					if SMenu.LastHit.W:Value() and Ready(_W) and ValidTarget(minion, 1000) then
						local WPred = GetPrediction(minion, Spells.W)
						if WPred.hitChance > 0.2 and not WPred:hCollision(1) and not WPred:mCollision(1) then
							if GetCurrentHP(minion) < getdmg("W", minion, myHero) then
								CastSkillShot(_W, WPred.castPos)
							end
						end
					end
				end
			end
		end
	end
end

-- Drawings
OnDraw(function (myHero)
	if SMenu.Draw.Q:Value() then
		DrawCircle(GetOrigin(myHero), 324, 0, 150, GoS.White)
	end
	if SMenu.Draw.W:Value() then
		DrawCircle(GetOrigin(myHero), 1000, 0, 150, GoS.White)
	end
	if SMenu.Draw.E:Value() then
		DrawCircle(GetOrigin(myHero), Spells.E.range, 0, 150, GoS.White)
	end
end)

print("Thanks "..GetUser().." for using my Kha'Zix script, I love you<3")
