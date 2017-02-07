if myHero.charName ~= "Talon" then return end

local LoLVer = "7.1"
local ScrVer = 4

local function Talon_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Talon]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Talon]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Talon.lua", SCRIPT_PATH .. "Talon.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Talon]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Talon]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Talon.version", Talon_Update)

local summonerNameOne = myHero:GetSpellData(SUMMONER_1).name 
local summonerNameTwo = myHero:GetSpellData(SUMMONER_2).name
local Ignite          = (summonerNameOne:lower():find("summonerdot") and SUMMONER_1 or (summonerNameTwo:lower():find("summonerdot") and SUMMONER_2 or nil))
local Stealth         = false
local Skin_Table      = { ["Talon"] = {"Classic", "Renegade", "Crimson Elite", "Dragonblade", "SSW"} }
local Config          = MenuConfig("Talon", "Talon")

Config:SubMenu("C", "Combo")
Config.C:Boolean("I", "Use Items", true)
Config.C:Boolean("Q", "Use Q", true)
Config.C:Boolean("W", "Use W", true)
Config.C:Boolean("R", "Use R", true)
Config.C:DropDown("RMode", "R Mode:", 1, { "Check Target HP(%)", "Check Killable Q + W + R" })
Config.C:Slider("RHP", "(*) Min. Target HP(%) for Use R", 35, 0, 100, 1)
Config.C:Boolean("S", "Don't Use Spells in Stealth", true)

Config:SubMenu("L", "Last Hit")
Config.L:Boolean("Q", "Use Q", true)
Config.L:Slider("Mana", "Min. Mana(%) For Use Q", 50, 0, 100, 1)

Config:SubMenu("H", "Harass")
Config.H:Boolean("Q", "Use Q")
Config.H:Boolean("W", "Use W", true)
Config.H:Slider("Mana", "Min. Mana(%) For Harass", 50, 0, 100, 1)

Config:SubMenu("CL", "Clear")
Config.CL:Boolean("Q", "Use Q", true)
Config.CL:Boolean("W", "Use W", true)
Config.CL:Slider("Mana", "Min. Mana(%) For Clear", 50, 0, 100, 1)

Config:SubMenu("K", "Kill Steal")
Config.K:Boolean("Q", "Use Q", true)
Config.K:Boolean("W", "Use W", true)
Config.K:Boolean("I", "Use Ignite", true)

Config:SubMenu("D", "Drawings")
Config.D:Boolean("HP", "Draw Damage Bar", true)
Config.D:Boolean("Q", "Draw Q Range", true)
Config.D:Boolean("W", "Draw W Range", true)
Config.D:Boolean("E", "Draw E Range")
Config.D:Boolean("R", "Draw R Range")

Config:SubMenu("Skin", "Skin Changer")

Config.Skin:DropDown('skin', myHero.charName.. " Skins", 1, Skin_Table[myHero.charName], 
function(model) HeroSkinChanger(myHero, model - 1) print(Skin_Table[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end, true)

local Q  = { delay = .25, speed = math.huge , width = nil, range = 550 }
local W  = { delay = .25, speed = 1850      , width = 60 , range = 750 }
local E  = { delay = .25, speed = math.huge , width = nil, range = 700 }
local R  = { delay = .25, speed = math.huge , width = nil, range = 500 }

local function Mode()
    if IOW_Loaded then 
        return IOW:Mode()
    elseif DAC_Loaded then 
        return DAC:Mode()
    elseif PW_Loaded then 
        return PW:Mode()
    elseif GoSWalkLoaded and GoSWalk.CurrentMode then 
        return ({"Combo", "Harass", "LaneClear", "LastHit"})[GoSWalk.CurrentMode+1]
    elseif AutoCarry_Loaded then 
        return DACR:Mode()
    elseif _G.SLW_Loaded then 
        return SLW:Mode()
    elseif EOW_Loaded then 
        return EOW:Mode()
    end
    return ""
end


local function CalcDmg(spell, target)
	local dmg={
	[_Q] = 60+20*GetCastLevel(myHero, _Q)+GetBonusDmg(myHero),
	[_W] = 40+10*GetCastLevel(myHero, _W)+GetBonusDmg(myHero)*.4+30+30*GetCastLevel(myHero, _W)+GetBonusDmg(myHero)*.6,
	[_R] = 40+40*GetCastLevel(myHero, _R)+GetBonusDmg(myHero)*.8
}
return dmg[spell]
end

local function Talon_GetHPBarPos(enemy)
  local barPos = GetHPBarPos(enemy) 
  local BarPosOffsetX = -50
  local BarPosOffsetY = 46
  local CorrectionY = 39
  local StartHpPos = 31 
  local StartPos = Vector(barPos.x , barPos.y, 0)
  local EndPos = Vector(barPos.x + 108 , barPos.y , 0)    
  return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

local function Talon_DrawLineHPBar(damage, text, unit, team)
  if unit.dead or not unit.visible then return end
  local p = WorldToScreen(0, Vector(unit.x, unit.y, unit.z))
  local thedmg = 0
  local line = 2
  local linePosA  = { x = 0, y = 0 }
  local linePosB  = { x = 0, y = 0 }
  local TextPos   = { x = 0, y = 0 }

  if damage >= unit.health then
    thedmg = unit.health - 1
    text = "KILLABLE!"
  else
    thedmg = damage
    text = "Possible Damage"
  end

  thedmg = math.round(thedmg)

  local StartPos, EndPos = Talon_GetHPBarPos(unit)
  local Real_X = StartPos.x + 24
  local Offs_X = (Real_X + ((unit.health - thedmg) / unit.maxHealth) * (EndPos.x - StartPos.x - 2))
  if Offs_X < Real_X then Offs_X = Real_X end 
  local mytrans = 350 - math.round(255*((unit.health-thedmg)/unit.maxHealth))
  if mytrans >= 255 then mytrans=254 end
  local my_bluepart = math.round(400*((unit.health-thedmg)/unit.maxHealth))
  if my_bluepart >= 255 then my_bluepart=254 end

  if team then
    linePosA.x = Offs_X - 24
    linePosA.y = (StartPos.y-(30+(line*15)))    
    linePosB.x = Offs_X - 24 
    linePosB.y = (StartPos.y+10)
    TextPos.x = Offs_X - 20
    TextPos.y = (StartPos.y-(30+(line*15)))
  else
    linePosA.x = Offs_X-125
    linePosA.y = (StartPos.y-(30+(line*15)))    
    linePosB.x = Offs_X-125
    linePosB.y = (StartPos.y-15)

    TextPos.x = Offs_X-122
    TextPos.y = (StartPos.y-(30+(line*15)))
  end

  DrawLine(linePosA.x, linePosA.y, linePosB.x, linePosB.y , 2, ARGB(mytrans, 255, my_bluepart, 0))
  DrawText(tostring(thedmg).." "..tostring(text), 15, TextPos.x, TextPos.y , ARGB(mytrans, 255, my_bluepart, 0))
end

local function Talon_ProcessSpellComplete(unit, spell)
	if not unit or not spell then return end

	if unit.isMe and spell.name:lower():find("attack") and (Mode() == "Combo" or Mode() == "LaneClear") and Config.C.I:Value() then
		if GetItemSlot(myHero, 3077) > 0 and Ready(GetItemSlot(myHero,3077)) then
			CastSpell(GetItemSlot(myHero,3077))
		end
		if GetItemSlot(myHero, 3074) > 0 and Ready(GetItemSlot(myHero,3074)) then
			CastSpell(GetItemSlot(myHero,3074))
		end
		if GetItemSlot(myHero, 3748) > 0 and Ready(GetItemSlot(myHero,3748)) then
			CastSpell(GetItemSlot(myHero,3748))
		end
	end
end

local function Talon_UpdateBuff(unit, buff)
	if not unit or not buff then return end

	if unit.isMe and buff.Name:lower() == "talonrstealth" then
		Stealth = true
	end
end

local function Talon_RemoveBuff(unit, buff)
	if not unit or not buff then return end

	if unit.isMe and buff.Name:lower() == "talonrstealth" then
		Stealth = false
	end
end

local function Talon_Draw()
	if Config.D.Q:Value() and Ready(_Q) then DrawCircle(GetOrigin(myHero),Q.range,1,1,ARGB(80,220,220,220)) end
	if Config.D.W:Value() and Ready(_W) then DrawCircle(GetOrigin(myHero),W.range,1,1,ARGB(80,220,220,220)) end
	if Config.D.E:Value() and Ready(_E) then DrawCircle(GetOrigin(myHero),E.range,1,1,ARGB(80,220,220,220)) end
	if Config.D.R:Value() and Ready(_R) then DrawCircle(GetOrigin(myHero),R.range,1,1,ARGB(80,220,220,220)) end

      for i, HPbarEnemyChamp in pairs(GetEnemyHeroes()) do
      if not HPbarEnemyChamp.dead and HPbarEnemyChamp.visible and Config.D.HP:Value() then
      local dmg =  GetBonusDmg(myHero)+GetBaseDamage(myHero)
      if Ready(_Q) and not HPbarEnemyChamp.dead then
        dmg = dmg + CalcDmg(_Q, HPbarEnemyChamp)
      end
      if Ready(_W) and not HPbarEnemyChamp.dead then
        dmg = dmg + CalcDmg(_W, HPbarEnemyChamp)
      end
      if Ready(_R) and not HPbarEnemyChamp.dead then
        dmg = dmg + CalcDmg(_R, HPbarEnemyChamp)*2
      end
      Talon_DrawLineHPBar(dmg, "", HPbarEnemyChamp, HPbarEnemyChamp.team)
    end
  end
end

local function Talon_CastQ(target)
	if Ready(_Q) and ValidTarget(target, Q.range) then
		CastTargetSpell(target, _Q)
	end
end

local function Talon_CastW(target)
	if Ready(_W) and ValidTarget(target, W.range) then
		local Prediction = GetPredictionForPlayer(myHero,target,GetMoveSpeed(target),W.speed,W.delay,W.range,W.width,false,true)
		if Prediction.HitChance == 1 then CastSkillShot(_W, Prediction.PredPos) end
	end
end

local function Talon_CastR(target)
	if Ready(_R) and ValidTarget(target, R.range) then
		CastSpell(_R)
	end
end

local function Talon_Combo(target)
	if Mode() == "Combo" then
		if Config.C.S:Value() then
			if Stealth == false then
			if Config.C.W:Value() then Talon_CastW(target) end
		        if Config.C.Q:Value() then Talon_CastQ(target) end
		        if Config.C.R:Value() and Config.C.RMode:Value() == 1 and GetPercentHP(target) + GetDmgShield(target) < Config.C.RHP:Value() then Talon_CastR(target) end
		        if Config.C.R:Value() and Config.C.RMode:Value() == 2 and GetCurrentHP(target) + GetDmgShield(target) < (CalcDmg(_Q, target) + CalcDmg(_W, target) + CalcDmg(_R, target)*2) then Talon_CastR(target) end
			end
		else
		    if Config.C.W:Value() then Talon_CastW(target) end
		    if Config.C.Q:Value() then Talon_CastQ(target) end
		    if Config.C.R:Value() and Config.C.RMode:Value() == 1 and GetPercentHP(target) + GetDmgShield(target) < Config.C.RHP:Value() then Talon_CastR(target) end
		    if Config.C.R:Value() and Config.C.RMode:Value() == 2 and GetCurrentHP(target) + GetDmgShield(target) < (CalcDmg(_Q, target) + CalcDmg(_W, target) + (CalcDmg(_R, target)*2)) then Talon_CastR(target) end
		end
	end
end

local function Talon_LastHit(target)
	if Mode() == "LastHit" then
		if target.team ~= myHero.team and ValidTarget(target, Q.range) then
			if Config.C.Q:Value() and GetPercentMP(myHero) >= Config.L.Mana:Value() then  
				if GetDistance(target) > 250 and GetCurrentHP(target) < CalcDmg(_Q, target) then Talon_CastQ(target) elseif GetDistance(target) < 250 and GetCurrentHP(target) < CalcDmg(_Q, target)*1.5 then Talon_CastQ(target) end
			end
		end
	end
end

local function Talon_Harass(target)
	if Mode() == "Harass" then
		if GetPercentMP(myHero) >= Config.H.Mana:Value() then
		    if Config.H.W:Value() then Talon_CastW(target) end
		    if Config.H.Q:Value() then Talon_CastQ(target) end
		end
	end
end

local function Talon_Clear(target)
	if Mode() == "LaneClear" then
		if target.team ~= myHero.team and ValidTarget(target, W.range) then
			if GetPercentMP(myHero) >= Config.CL.Mana:Value() then
			   if Config.CL.Q:Value() then Talon_CastQ(target) end
			   if Config.CL.W:Value() and MinionsAround(myHero, W.range) >= 2 then CastSkillShot(_W, target.pos) end
			end
		end
	end
end

local function Talon_KillSteal(target)
	if Config.K.Q:Value() and GetCurrentHP(target) + GetDmgShield(target) < CalcDmg(_Q, target) then Talon_CastQ(target) end
	if Config.K.W:Value() and GetCurrentHP(target) + GetDmgShield(target) < CalcDmg(_W, target) then Talon_CastW(target) end
	
	if Ignite and Ready(Ignite) and Config.K.I:Value() then
		for _, unit in pairs(GetEnemyHeroes()) do
			local IgniteDmg = 70+20*GetLevel(myHero)
			if ValidTarget(unit, 660) and GetCurrentHP(unit) + GetDmgShield(unit) <= IgniteDmg then
				CastTargetSpell(unit, Ignite)
			end
		end
	end
end

local function Talon_Item()
	if GetItemSlot(myHero, 3142) > 0 and Ready(GetItemSlot(myHero,3142)) and EnemiesAround(myHero, 1000) > 0 and Config.C.I:Value() then
		CastSpell(GetItemSlot(myHero,3142))
	end
end

local function Talon_Tick()
	if not myHero.dead then
		local target = GetCurrentTarget()

		Talon_Combo(target)
		Talon_Harass(target)
		Talon_Item()

		for _, target in pairs(minionManager.objects) do Talon_LastHit(target) Talon_Clear(target) end
		for _, target in pairs(GetEnemyHeroes()) do Talon_KillSteal(target) end
	end
end

OnLoad(function()
	OnTick(Talon_Tick)
	OnDraw(Talon_Draw)
	OnProcessSpellComplete(Talon_ProcessSpellComplete)
	OnUpdateBuff(Talon_UpdateBuff)
	OnRemoveBuff(Talon_RemoveBuff)
		
	print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Talon]</b></font><font color=\"#E8E8E8\"> Successfully Loaded!</font>")
        print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Talon]</b></font><font color=\"#E8E8E8\"> Current Version: </font>"..LoLVer)
        print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Talon]</b></font><font color=\"#E8E8E8\"> Have Fun, </font>"..GetUser().."<font color=\"#E8E8E8\"> !</font>")

end)
