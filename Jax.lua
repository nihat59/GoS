local ver = "0.12"


if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 PrintChat("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() PrintChat("Downloaded MixLib. Please 2x F6!") return end)
end


if GetObjectName(GetMyHero()) ~= "Jax" then return end

require("DamageLib")


local SetDCP, SkinChanger = 0

local menu = Menu("Jax", "Jax")

menu:SubMenu("Combo", "Combo")

menu.Combo:Boolean("Q", "Use Q in combo", true)
menu.Combo:Boolean("W", "Use W in combo", true)
menu.Combo:Boolean("E", "Use E in combo", true)
menu.Combo:Boolean("R", "Use R in combo", true)
menu.Combo:Slider("RX", "X Enemies to Cast R",3,1,5,1)
menu.Combo:Boolean("Cutlass", "Use Cutlass", true)
menu.Combo:Boolean("Tiamat", "Use Tiamat", true)
menu.Combo:Boolean("BOTRK", "Use BOTRK", true)
menu.Combo:Boolean("RHydra", "Use RHydra", true)
menu.Combo:Boolean("YGB", "Use GhostBlade", true)
menu.Combo:Boolean("Gunblade", "Use Gunblade", true)
menu.Combo:Boolean("Randuins", "Use Randuins", true)


menu:SubMenu("AutoMode", "AutoMode")
menu.AutoMode:Boolean("Ghost", "Auto Ghost", false)
menu.AutoMode:Boolean("Q", "Auto Q", false)
menu.AutoMode:Boolean("W", "Auto W", false)
menu.AutoMode:Boolean("E", "Auto E", false)
menu.AutoMode:Boolean("R", "Auto R", false)

menu:SubMenu("LaneClear", "LaneClear")
menu.LaneClear:Boolean("Q", "Use Q", true)
menu.LaneClear:Boolean("W", "Use W", true)
menu.LaneClear:Boolean("E", "Use E", true)
menu.LaneClear:Boolean("RHydra", "Use RHydra", true)
menu.LaneClear:Boolean("Tiamat", "Use Tiamat", true)

menu:SubMenu("Harass", "Harass")
menu.Harass:Boolean("Q", "Use Q", true)
menu.Harass:Boolean("W", "Use W", true)

menu:SubMenu("KillSteal", "KillSteal")
menu.KillSteal:Boolean("Q", "KS w Q", true)
menu.KillSteal:Boolean("E", "KS w E", true)

menu:SubMenu("AutoIgnite", "AutoIgnite")
menu.AutoIgnite:Boolean("Ignite", "Ignite if killable", true)

menu:SubMenu("SkinChanger", "SkinChanger")
menu.SkinChanger:Boolean("Skin", "UseSkinChanger", true)
menu.SkinChanger:Slider("SelectedSkin", "Select A Skin:", 1, 0, 4, 1, function(SetDCP) HeroSkinChanger(myHero, SetDCP)  end, true)

OnTick(function (myHero)
	local target = GetCurrentTarget()
        local YGB = GetItemSlot(myHero, 3142)
	local RHydra = GetItemSlot(myHero, 3074)
	local Tiamat = GetItemSlot(myHero, 3077)
        local Gunblade = GetItemSlot(myHero, 3146)
        local BOTRK = GetItemSlot(myHero, 3153)
        local Cutlass = GetItemSlot(myHero, 3144)
        local Randuins = GetItemSlot(myHero, 3143)
        
        --Harass
          if Mix:Mode() == "Harass" then
            if menu.Harass.Q:Value() and Ready(_Q) and ValidTarget(target, 700) then
				if target ~= nil then 
                                      CastTargetSpell(target, _Q)
                                end
            end

            if menu.Harass.W:Value() and Ready(_W) and ValidTarget(target, 700) then
				CastSpell(_W)
            end     
          end

	--COMBO
	  if Mix:Mode() == "Combo" then
            if menu.Combo.YGB:Value() and YGB > 0 and Ready(YGB) and ValidTarget(target, 700) then
			CastSpell(YGB)
            end

            if menu.Combo.Randuins:Value() and Randuins > 0 and Ready(Randuins) and ValidTarget(target, 500) then
			CastSpell(Randuins)
            end

            if menu.Combo.BOTRK:Value() and BOTRK > 0 and Ready(BOTRK) and ValidTarget(target, 550) then
			 CastTargetSpell(target, BOTRK)
            end

            if menu.Combo.Cutlass:Value() and Cutlass > 0 and Ready(Cutlass) and ValidTarget(target, 700) then
			 CastTargetSpell(target, Cutlass)
            end

            if menu.Combo.E:Value() and Ready(_E) and ValidTarget(target, 700) then
			 CastSpell(_E)
	    end

            if menu.Combo.Q:Value() and Ready(_Q) and ValidTarget(target, 700) then
		     if target ~= nil then 
                         CastTargetSpell(target, _Q)
                     end
            end

            if menu.Combo.Tiamat:Value() and Tiamat > 0 and Ready(Tiamat) and ValidTarget(target, 350) then
			CastSpell(Tiamat)
            end

            if menu.Combo.Gunblade:Value() and Gunblade > 0 and Ready(Gunblade) and ValidTarget(target, 700) then
			CastTargetSpell(target, Gunblade)
            end

            if menu.Combo.RHydra:Value() and RHydra > 0 and Ready(RHydra) and ValidTarget(target, 400) then
			CastSpell(RHydra)
            end

	    if menu.Combo.W:Value() and Ready(_W) and ValidTarget(target, 700) then
			CastSpell(_W)
	    end
	    
	    
            if menu.Combo.R:Value() and Ready(_R) and ValidTarget(target, 700) and (EnemiesAround(myHeroPos(), 700) >= menu.Combo.RX:Value()) then
			CastSpell(_R)
            end

          end

         --AUTO IGNITE
	for _, enemy in pairs(GetEnemyHeroes()) do
		
		if GetCastName(myHero, SUMMONER_1) == 'SummonerDot' then
			 Ignite = SUMMONER_1
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end

		elseif GetCastName(myHero, SUMMONER_2) == 'SummonerDot' then
			 Ignite = SUMMONER_2
			if ValidTarget(enemy, 600) then
				if 20 * GetLevel(myHero) + 50 > GetCurrentHP(enemy) + GetHPRegen(enemy) * 3 then
					CastTargetSpell(enemy, Ignite)
				end
			end
		end

	end

        for _, enemy in pairs(GetEnemyHeroes()) do
                
                if IsReady(_Q) and ValidTarget(enemy, 700) and menu.KillSteal.Q:Value() and GetHP(enemy) < getdmg("Q",enemy) then
		         if target ~= nil then 
                                      CastTargetSpell(target, _Q)
		         end
                end 

                if IsReady(_E) and ValidTarget(enemy, 187) and menu.KillSteal.E:Value() and GetHP(enemy) < getdmg("E",enemy) then
		                      CastSpell(_E)
  
                end
      end

      if Mix:Mode() == "LaneClear" then
      	  for _,closeminion in pairs(minionManager.objects) do
	        if menu.LaneClear.Q:Value() and Ready(_Q) and ValidTarget(closeminion, 700) then
	        	CastTargetSpell(closeminion, _Q)
                end

                if menu.LaneClear.W:Value() and Ready(_W) and ValidTarget(closeminion, 700) then
	        	CastSpell(_W)
	        end

                if menu.LaneClear.E:Value() and Ready(_E) and ValidTarget(closeminion, 187) then
	        	CastSpell(_E)
	        end

                if menu.LaneClear.Tiamat:Value() and ValidTarget(closeminion, 350) then
			CastSpell(Tiamat)
		end
	
		if menu.LaneClear.RHydra:Value() and ValidTarget(closeminion, 400) then
                        CastTargetSpell(closeminion, RHydra)
      	        end
          end
      end
        --AutoMode
        if menu.AutoMode.Q:Value() then        
          if Ready(_Q) and ValidTarget(target, 700) then
		      CastTargetSpell(target, _Q)
          end
        end 
        if menu.AutoMode.W:Value() then        
          if Ready(_W) and ValidTarget(target, 700) then
	  	      CastSpell(_W)
          end
        end
        if menu.AutoMode.E:Value() then        
	  if Ready(_E) and ValidTarget(target, 125) then
		      CastSpell(_E)
	  end
        end
        if menu.AutoMode.R:Value() then        
	  if Ready(_R) and ValidTarget(target, 700) then
		      CastSpell(_R)
	  end
        end
                
	--AUTO GHOST
	if menu.AutoMode.Ghost:Value() then
		if GetCastName(myHero, SUMMONER_1) == "SummonerHaste" and Ready(SUMMONER_1) then
			CastSpell(SUMMONER_1)
		elseif GetCastName(myHero, SUMMONER_2) == "SummonerHaste" and Ready(SUMMONER_2) then
			CastSpell(Summoner_2)
		end
	end
end)

OnProcessSpell(function(unit, spell)
	local target = GetCurrentTarget()        
       
        if unit.isMe and spell.name:lower():find("jaxempowertwo") then 
		Mix:ResetAA()	
	end        

        if unit.isMe and spell.name:lower():find("itemtiamatcleave") then
		Mix:ResetAA()
	end	
               
        if unit.isMe and spell.name:lower():find("itemravenoushydracrescent") then
		Mix:ResetAA()
	end

end) 


local function SkinChanger()
	if menu.SkinChanger.UseSkinChanger:Value() then
		if SetDCP >= 0  and SetDCP ~= GlobalSkin then
			HeroSkinChanger(myHero, SetDCP)
			GlobalSkin = SetDCP
		end
        end
end


print('<font color = "#01DF01"><b>Jax</b> <font color = "#01DF01">by <font color = "#01DF01"><b>Allwillburn</b> <font color = "#01DF01">Loaded!')





