if GetObjectName(GetMyHero()) ~= "Amumu" then return end

require ("DamageLib")

-- Menu
local AmumuMenu = Menu("Amumu", "Amumu")
AmumuMenu:Menu("Misc", "Misc")
AmumuMenu.Misc:DropDown("S", "Skin Changer", 1, {"Classic", "Pharaoh", "Vancouver", "Emumu", "Re-Gifted", "Almost-Prom King", "Little Knight", "Sad Robot", "Surprised Party"}, function() AmumuSkinsChange() end)

-- Combo
AmumuMenu:SubMenu("Combo", "Combo Settings")
AmumuMenu.Combo:Boolean("Q", "Use Q", true)
AmumuMenu.Combo:Boolean("W", "Use W", true)
AmumuMenu.Combo:Boolean("E", "Use E", true)
AmumuMenu.Combo:Boolean("R", "Use R", true)
AmumuMenu.Combo:Slider("Mana", "Min. Mana For W", 50, 0, 100, 1)
AmumuMenu.Combo:Slider("MR", "Min. Enemy For R", 2, 1, 5, 1)

-- Draw
AmumuMenu:SubMenu("Draw", "Drawings Settings")
AmumuMenu.Draw:Boolean("Q", "Draw Q", true)
AmumuMenu.Draw:Boolean("W", "Draw W", true)
AmumuMenu.Draw:Boolean("E", "Draw E", true)
AmumuMenu.Draw:Boolean("R", "Draw R", true)

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
		if AmumuMenu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 1100) then
			local QPred = GetPredictionForPlayer(GetOrigin(myHero), target, GetMoveSpeed(target), 2000, 0.25, 1100, 30, true, true)
			if QPred.HitChance == 1 then	
				CastSkillShot(_Q, QPred.PredPos)
			end
		end	
			-- E
		if AmumuMenu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 350) then	
        	CastTargetSpell(target , _E)
		end
		
		-- W
		if (myHero.mana/myHero.maxMana >= AmumuMenu.Combo.Mana:Value() /100) then
		
				if ValidTarget(target, 300) and Ready(_W)  then
			CastSpell(_W)
		        end
		end
		-- R
				if Ready(_R) and EnemiesAround(myHero, 560) >= AmumuMenu.Combo.MR:Value() and AmumuMenu.Combo.R:Value() then
			CastSpell(_R)
		        end
		
    end
end)

function AmumuSkinsChange()
	HeroSkinChanger(myHero, AmumuMenu.Misc.S:Value() - 1)
end
AmumuSkinsChange()


OnDraw(function (myHero)
	if AmumuMenu.Draw.Q:Value() then
		DrawCircle(GetOrigin(myHero), 1100, 0, 150, GoS.Blue)
	end
	if AmumuMenu.Draw.W:Value() then
		DrawCircle(GetOrigin(myHero), 300, 0, 150, GoS.Blue)
	end
		if AmumuMenu.Draw.E:Value() then
		DrawCircle(GetOrigin(myHero), 350, 0, 150, GoS.Blue)
	end
		if AmumuMenu.Draw.R:Value() then
		DrawCircle(GetOrigin(myHero), 550, 0, 150, GoS.Red)
	end
end)

     PrintChat ("<font color=\"#66FFFF\">Beta's Amumu Has Been Loaded <font color=\"#FF0000\"> Have <font color=\"#FFFFFF\"> Fun ")