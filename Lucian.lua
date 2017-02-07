local ver = "1.0"

function AutoUpdate(data)
    if tonumber(data) > tonumber(ver) then
        PrintChat("New version found! " .. data)
        PrintChat("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/UnrealSkill-VIP/Gos2017/master/UnrealSkill%20Lucian.lua", SCRIPT_PATH .. "UnrealSkill Lucian.lua", function() PrintChat("Update Complete, please 2x F6!") return end)
    else
        PrintChat("No updates found!")
    end
end
--Pega Versão Antes
GetWebResultAsync("https://raw.githubusercontent.com/UnrealSkill-VIP/Gos2017/master/Lucian.version", AutoUpdate)


--Campeão
local Hero = "Lucian"

--Crédito
local Criador = "[ US ] "

--Se for Diferente o Nome do Campeão ele retorna e não carrega o codigo adiante
if GetObjectName(myHero) ~= Hero then return end

MeuMenu = Menu(Hero, Criador.. Hero)
MeuMenu:SubMenu("Combo", Hero.."Combo")
MeuMenu.Combo:Boolean("FIXAA", Hero.." - [ AA ] Fix", true)
MeuMenu.Combo:Boolean("Q", Hero.." - [ Q ] Enemy", true)
--MeuMenu.Combo:Boolean("QX", Hero.." - [ Q ] Extend", true)
MeuMenu.Combo:Boolean("W", Hero.." - [ W ] Enemy", true)
MeuMenu.Combo:Boolean("E", Hero.." - [ E ] Select", true)
MeuMenu.Combo:DropDown("EMODE", Hero.." - [ E ] Mode", 1, {"Mouse","Enemy","Auto"})
MeuMenu.Combo:Boolean("R", Hero.." - [ R ] Enemy", true)
MeuMenu.Combo:Boolean("ItemsUse", "Use Items", true)
MeuMenu.Combo:Key('Keyyys', 'Combo Key', string.byte(' '))-- Defaut Key Space
MeuMenu.Combo:Info("zzzzz"," ", true)------------------------------------------------
MeuMenu.Combo:Boolean("FQ", Hero.." - [ Q ] Farm/Jungle", true)
MeuMenu.Combo:Boolean("FW", Hero.." - [ W ] Farm/Jungle", true)
MeuMenu.Combo:Key('KeyyysF', 'Farm Key', string.byte("C"))-- Defaut Key Space

--Mudar SkinHack SetDefaut
HeroSkinChanger(myHero, 6)
			
local Q = { range = 900 }
local W = { range = 898 }
local E = { range = myHero:GetSpellData(_E).range }
local R = { range = 1200 }

local function STick()
		Passiva = GotBuff(myHero,"LucianPassiveBuff") == 0 --Verificar Passiva
		
		------------------------Check---------------------------
		WCD = CanUseSpell(myHero,_W) == 32
		QCD = CanUseSpell(myHero,_Q) == 32
		------------------------Check---------------------------
	
		
		
	if MeuMenu.Combo.Keyyys:Value() then
		MeuRange = GetRange(myHero)
		UsarItems() --Usat Items em Combo
		
		local mousepos = GetMousePos() --Usado No E & R
		local MeuInimigo = GetCurrentTarget()	
		local Dash = Vector(myHero) - (Vector(myHero) - Vector(mousePos)):normalized() * 425
		
		if ValidTarget(MeuInimigo, Q.range) and CanUseSpell(myHero,_Q) == READY and MeuMenu.Combo.Q:Value() and Passiva then
			DelayAction( function() CastTargetSpell(MeuInimigo, _Q) end, .1)
						if ValidTarget(MeuInimigo, MeuRange) and MeuMenu.Combo.FIXAA:Value() then AttackUnit(MeuInimigo) end
		end 
	
		if ValidTarget(MeuInimigo, W.range) and CanUseSpell(myHero,_W) == READY and MeuMenu.Combo.W:Value() and Passiva then
			 DelayAction( function() CastSkillShot(_W, MeuInimigo) end, .1)
						if ValidTarget(MeuInimigo, MeuRange) and MeuMenu.Combo.FIXAA:Value() then AttackUnit(MeuInimigo) end
		end 
		
		------------------------------------------------E MODE ---------------------------------------------------------------------
		if MeuMenu.Combo.EMODE:Value() == 1 then --Modo Mouse Position
			if ValidTarget(MeuInimigo, E.range) and CanUseSpell(myHero,_E) == READY and MeuMenu.Combo.E:Value() and Passiva and WCD and QCD then
				DelayAction( function() CastSkillShot(_E, mousepos) end, .1)
				if ValidTarget(MeuInimigo, MeuRange) and MeuMenu.Combo.FIXAA:Value() then AttackUnit(MeuInimigo) end
			end
		
		elseif MeuMenu.Combo.EMODE:Value() == 2 then --Modo Mouse no Inimigo
			if ValidTarget(MeuInimigo, 1100) and CanUseSpell(myHero,_E) == READY and MeuMenu.Combo.E:Value() then
				DelayAction( function() CastSkillShot(_E, MeuInimigo) end, .1)
				if ValidTarget(MeuInimigo, MeuRange) and MeuMenu.Combo.FIXAA:Value() then AttackUnit(MeuInimigo) end			
				elseif  ValidTarget(MeuInimigo, 600) and CanUseSpell(myHero,_E) == READY and MeuMenu.Combo.E:Value() then
				DelayAction( function() CastSkillShot(_E, Dash) end, .1)
				if ValidTarget(MeuInimigo, MeuRange) and MeuMenu.Combo.FIXAA:Value() then AttackUnit(MeuInimigo) end
							
			end
		elseif MeuMenu.Combo.EMODE:Value() == 3 then -- Modo Auto
			if ValidTarget(MeuInimigo, E.range) and CanUseSpell(myHero,_E) == READY and MeuMenu.Combo.E:Value() and Passiva and WCD and QCD then
				DelayAction( function() CastSkillShot(_E, Dash) end, .1)
				if ValidTarget(MeuInimigo, MeuRange) and MeuMenu.Combo.FIXAA:Value() then AttackUnit(MeuInimigo) end
			end 
		end
		------------------------------------------------FIM MODE -------------------------------------------------------------------
		
		local pe = GetPredictionForPlayer(GetOrigin(GetMyHero()), MeuInimigo, GetMoveSpeed(MeuInimigo), 2000, 300, 1000, 80, true, true)
		if ValidTarget(MeuInimigo, R.range) and CanUseSpell(myHero,_R) == READY and MeuMenu.Combo.R:Value() and GetCastName(myHero,_R) == "LucianR" then
			if pe.HitChance == 1 then
				CastSkillShot(_R, pe.PredPos.x, pe.PredPos.y, pe.PredPos.z)
			end
		end 
		if GetCastName(myHero,_R) ~= "LucianR" then MoveToXYZ(mousepos) end --Desbuga Movimento de perto da Ult
	end

end

local function STick2()
Farm()
end



function Farm()
	Passiva = GotBuff(myHero,"LucianPassiveBuff") == 0 --Verificar Passiva
	for _,gold in pairs(minionManager.objects) do
		if MeuMenu.Combo.KeyyysF:Value() then
			if MeuMenu.Combo.FQ:Value() and Ready(_Q) and ValidTarget(gold, Q.range) and Passiva  then
				CastTargetSpell(gold, _Q)
			end
			if MeuMenu.Combo.FW:Value() and Ready(_W) and ValidTarget(gold, 600) and Passiva  then
				CastSkillShot(_W, gold)
			end
		end
	end	
end

--Terceiro
OnLoad(function()
	OnTick(STick)
	OnTick(STick2)
end)	
 
 function UsarItems()
	local MeuInimigo = GetCurrentTarget()
	  --Blade of the Ruined King
    if GetItemSlot(myHero, 3153) > 0 and IsReady(GetItemSlot(myHero, 3153)) and MeuMenu.Combo.ItemsUse:Value() and ValidTarget(MeuInimigo,GetRange(myHero)) then
       CastTargetSpell(MeuInimigo, GetItemSlot(myHero, 3153))
      end
	  --Yummus
    if GetItemSlot(myHero, 3142) > 0 and IsReady(GetItemSlot(myHero, 3142)) and MeuMenu.Combo.ItemsUse:Value()  and ValidTarget(MeuInimigo,GetRange(myHero)) then
       CastSpell(GetItemSlot(myHero, 3142))
      end    
	  --Bilgewater Cutlass
    if GetItemSlot(myHero, 3144) > 0 and IsReady(GetItemSlot(myHero, 3144)) and MeuMenu.Combo.ItemsUse:Value() and ValidTarget(MeuInimigo,GetRange(myHero)) then
       CastTargetSpell(MeuInimigo, GetItemSlot(myHero, 3144)) 
     end
end
 
PrintChat('<font color = \"#aa00ff\">UnrealSkill</font> <font color = \"#0094ff\"> '.. Hero.. ' Script V1 BETA - Thanks for Use </font> <font color = \"#ff49f8\">'..GetUser()..'</font>')
PrintChat('<font color = \"#aa00ff\">Script Work </font> <font color = \"#0094ff\"> ALL </font> <font color = \"#ff49f8\"> OrbWalker</font>')
PrintChat('<font color = \"#aa00ff\">Thanks Especial </font> <font color = \"#0094ff\">[ Devs Gos ]</font> <font color = \"#ff49f8\"> For Codes Import</font>')