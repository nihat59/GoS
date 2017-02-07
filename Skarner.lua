if GetObjectName(GetMyHero()) ~= "Skarner" then return end

require("DamageLib")
require("OpenPredict")

-- Spells
local Spells = {
		E = {range = 1000, delay = 0.25, speed = 1500,  width = 70},
		R = {range = 350, delay = 1.75, speed = math.huge}
}

-- Menu
local SMenu = Menu("Skarner", "Skarner")

-- Combo
SMenu:SubMenu("Combo", "Combo Settings")
SMenu.Combo:Boolean("Q", "Use Q", true)
SMenu.Combo:Boolean("W", "Use W", true)
SMenu.Combo:Boolean("E", "Use E", true)
SMenu.Combo:Boolean("R", "Use R", true)

-- Harass
SMenu:SubMenu("Harass", "Harass Settings")
SMenu.Harass:Boolean("E", "Use E", true)
SMenu.Harass:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- Farm
SMenu:SubMenu("Farm", "Farm Settings")
SMenu.Farm:Boolean("Q", "Use Q", true)
SMenu.Farm:Boolean("W", "Use W", true)
SMenu.Farm:Boolean("E", "Use E", true)
SMenu.Farm:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- LastHit
SMenu:SubMenu("LastHit", "LastHit Settings")
SMenu.LastHit:Boolean("E", "Use E", true)
SMenu.LastHit:Slider("Mana", "Min. Mana", 40, 0, 100, 1)

-- Flash + R
--SMenu:SubMenu("FlashR", "Flash + R Settings")
--SMenu.FlashR:Key("Enabled", "Flash + R", string.byte("G"))
--SMenu.FlashR:DropDown("FlashR", "Flash + R - Settings", 1, {"Only Flash + R", "Standard Flash Combo", "Advanced Flash Combo", "Can't Escape Combo"})

-- Ks
SMenu:SubMenu("Ks", "KillSteal Settings")
SMenu.Ks:Boolean("E", "Use E", true)
SMenu.Ks:Boolean("Recall", "Don't Ks during Recall", true)
SMenu.Ks:Boolean("Disabled", "Don't Ks", false)

-- Draw
SMenu:SubMenu("Draw", "Drawing Settings")
SMenu.Draw:Boolean("Q", "Use Q", true)
SMenu.Draw:Boolean("E", "Use E", true)
SMenu.Draw:Boolean("R", "Use R", true)

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

-- Tick | KillSteal | Cast

OnTick(function(myHero)
	--FlashR()
	Ks()
	target = GetCurrentTarget()
	         Combo()
	         Harass()
	         Farm()
	         LastHit()
end)

function Ks()
	if SMenu.Ks.Disabled:Value() or (IsRecalling(myHero) and SMenu.Ks.Recall:Value()) then return end
	for _, enemy in pairs(GetEnemyHeroes()) do
		-- E
		if SMenu.Ks.E:Value() and Ready(_E) and ValidTarget(enemy, 1000) then
			if GetCurrentHP(enemy) < getdmg("E", enemy, myHero) then
				local EPred = GetPrediction(target, Spells.E)
				if EPred.hitChance > 0.2 then
					CastSkillShot(_E, EPred.castPos)
				end
			end
		end
	end
end

function CastQ()
	CastSpell(_Q)
end

function CastW()
	CastSpell(_W)
end

function CastE()
	local EPred = GetPrediction(target, Spells.E)
	if EPred.hitChance > 0.2 then
		CastSkillShot(_E, EPred.castPos)
	end
end

function CastR()
	CastTargetSpell(target, _R)
end

-- Combo | Harass | Farm | LastHit

function Combo()
	if Mode() == "Combo" then
		if SMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
			CastE()
		end
		if SMenu.Combo.W:Value() and Ready(_W) and ValidTarget(target, GetRange(myHero) + GetHitBox(target)) then
			CastW()
		end
		if SMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, GetRange(myHero) + GetHitBox(target)) then
			CastQ()
		end
		if SMenu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 350 + GetHitBox(target)) then
			CastR()
		end
	end
end

function Harass()
	if Mode() == "Harass" then
		if (myHero.mana/myHero.maxMana >= SMenu.Harass.Mana:Value() /100) then
			if SMenu.Harass.E:Value() and Ready(_E) and ValidTarget(target, Spells.E.range) then
				CastE()
			end
		end
	end
end

function Farm()
	if Mode() == "LaneClear" then
		if (myHero.mana/myHero.maxMana >= SMenu.Farm.Mana:Value() /100) then

			-- Lane
			for _, minion in pairs(minionManager.objects) do
				if GetTeam(minion) == MINION_ENEMY then
					if SMenu.Farm.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
						local EPred = GetPrediction(minion, Spells.E)
						if EPred.hitChance > 0.2 then
							CastSkillShot(_E, EPred.castPos)
						end
					end
					if SMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(minion, GetRange(myHero) + GetHitBox(target)) then
						CastSpell(_Q)
					end
					if SMenu.Farm.W:Value() and Ready(_W) and ValidTarget(minion, GetRange(myHero) + GetHitBox(target)) then
						CastSpell(_W)
					end
				end
			end

			-- Jungle
			for _, mob in pairs(minionManager.objects) do
				if GetTeam(mob) == MINION_JUNGLE then
					if SMenu.Farm.E:Value() and Ready(_E) and ValidTarget(mob, Spells.E.range) then
						local EPred = GetPrediction(mob, Spells.E)
						if EPred.hitChance > 0.2 then
							CastSkillShot(_E, EPred.castPos)
						end
					end
					if SMenu.Farm.Q:Value() and Ready(_Q) and ValidTarget(mob, GetRange(myHero) + GetHitBox(target)) then
						CastSpell(_Q)
					end
					if SMenu.Farm.W:Value() and Ready(_W) and ValidTarget(mob, GetRange(myHero) + GetHitBox(target)) then
						CastSpell(_W)
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
					if SMenu.LastHit.E:Value() and Ready(_E) and ValidTarget(minion, Spells.E.range) then
						if GetCurrentHP(minion) < getdmg("E", minion, myHero) then
							CastSkillShot(_E, minion)
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
		DrawCircle(GetOrigin(myHero), 350, 0, 150, GoS.White)
	end
	if SMenu.Draw.E:Value() then
		DrawCircle(GetOrigin(myHero), 1000, 0, 150, GoS.White)
	end
	if SMenu.Draw.R:Value() then
		DrawCircle(GetOrigin(myHero), 350, 0, 150, GoS.White)
	end
end)

print("Thank you for using my Skarner script, I love you<3")
