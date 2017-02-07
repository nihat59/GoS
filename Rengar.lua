if myHero.charName ~= "Rengar" then return end

local LoLVer = "7.1"
local ScrVer = 6

local function Rengar_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Rengar]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Rengar]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Rengar.lua", SCRIPT_PATH .. "Rengar.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Rengar]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Rengar]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Rengar.version", Rengar_Update)


local UltActive  = false 
local Dash       = false
local Tick       = 0
local Config     = MenuConfig("Rengar", "Rengar")
local CCType     = { [5] = "Stun", [8] = "Taunt", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression", }
local Skin_Table = { ["Rengar"] = {"Classic", "Headhunter", "Night Hunter", "SSW"} }

Config:SubMenu("P", "Priority Config")
Config.P:DropDown("P", "Prioritize", 1, {"Q","E"})
Config.P:KeyBinding("K", "Priority Switcher", string.byte("T"))

Config:SubMenu("C", "Combo")
Config.C:Boolean("I", "Use Items", true)
Config.C:Boolean("Q", "Use Q", true)
Config.C:Boolean("W", "Use W", true)
Config.C:Boolean("E", "Use E", true)

Config:SubMenu("H", "Harass")
Config.H:Boolean("Q", "Use Q", true)
Config.H:Boolean("W", "Use W", true)
Config.H:Boolean("E", "Use E", true)

Config:SubMenu("L", "LastHit")
Config.L:Boolean("Q", "Use Q", true)

Config:SubMenu("J", "Clear")
Config.J:Boolean("Q", "Use Q", true)
Config.J:Boolean("W", "Use W", true)
Config.J:Boolean("E", "Use E", true)

Config:SubMenu("_C", "Cleanse")
DelayAction(function()
	for n,m in pairs(CCType) do
		Config._C:Boolean(n,"Cleanse "..m, true)
	end
end, 0.1)

Config:SubMenu("Skin", "Skin Changer")

Config.Skin:DropDown('skin', myHero.charName.. " Skins", 1, Skin_Table[myHero.charName], 
function(model) HeroSkinChanger(myHero, model - 1) print(Skin_Table[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end, true)

Config:SubMenu("D", "Draw Config")
Config.D:Boolean("HP", "Draw Damage Indicator", true)
Config.D:Boolean("Q", "Draw Q Range", true)
Config.D:Boolean("W", "Draw W Range", true)
Config.D:Boolean("E", "Draw E Range", true)


local Q  = { delay = .25, speed = 1500      , width = 70  , range = 525  }
local W  = { delay = .25, speed = math.huge , width = nil , range = 500  }
local E  = { delay = .25, speed = 1500      , width = 70  , range = 1000 }
local R  = { delay = .25, speed = math.huge , width = nil , range = 500  }

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

local function Rengar_CalcDmg(i, target)
	local dmg={
	["Q"]  = 20+20*GetCastLevel(myHero, _Q)+GetBonusDmg(myHero)*((20+10*GetCastLevel(myHero, _Q))/100),
	["QE"] = 104+16*GetLevel(myHero)+GetBonusDmg(myHero)*2.4,
	["W"]  = 20+30*GetCastLevel(myHero, _W)+GetBonusAP(myHero)*.8,
	["WE"] = 40+10*GetLevel(myHero),
	["E"]  = 0+50*GetCastLevel(myHero, _E)+GetBonusDmg(myHero)*.7,
	["EE"] = 35+15*GetLevel(myHero)
}
return dmg[i]
end

local function Rengar_WndMsg(msg, key)
	if msg == WM_LBUTTONDOWN and not myHero.dead then
		for _, Enemy in ipairs(GetEnemyHeroes()) do
			if GetDistance(GetMousePos(), Enemy) <= 150 and ValidTarget(Enemy) and not Enemy.dead then
				if Focus ~= Enemy then
					Focus = Enemy
				    print("Target Selected: "..Enemy.charName)
			    else
				    Focus = nil
				    print("Target Unselected: "..Enemy.charName)
				end
			end
		end
	end
end

local function Rengar_GetTarget(range)
	local SelectedTarget = Focus
	if SelectedTarget ~= nil then
		if SelectedTarget.type == myHero.type and SelectedTarget.team ~= myHero.team and ValidTarget(SelectedTarget, range+100) and not SelectedTarget.dead then
			return SelectedTarget
		end
	end
	local GetTarget, LC = nil, 0
	for i = 1, #GetEnemyHeroes() do
		local Enemy = GetEnemyHeroes()[i]
		if ValidTarget(Enemy, range) then
			local A = (Enemy.armor+100)/100
			local K = A*Enemy.health
			if K <= LC or LC == 0 then
				GetTarget = Enemy
				LC        = K 
			end
		end
	end
	return GetTarget
end

local function Rengar_UpdateBuff(unit, buff)
    if not unit or not buff then return end

    local target = GetCurrentTarget()

	if unit.isMe and buff.Name:lower() == "rengarr" then
		UltActive = true 
	end

	if unit.isMe and buff.Name == "rengarpassivebuff" then
		Dash = true
	end

	if unit.isMe and CCType[buff.Type] and Config._C[buff.Type]:Value() then
		if Ready(_W) and GetCurrentMana(myHero) == 4 then CastSpell(_W) end
	end
end

local function Rengar_RemoveBuff(unit, buff)
	if unit.isMe and buff.Name:lower() == "rengarr" then
		UltActive = false
	end

	if unit.isMe and buff.Name == "rengarpassivebuff" then
		Dash = false
	end
end


local function Rengar_GetHPBarPos(enemy)
  local barPos = GetHPBarPos(enemy) 
  local BarPosOffsetX = -50
  local BarPosOffsetY = 46
  local CorrectionY = 39
  local StartHpPos = 31 
  local StartPos = Vector(barPos.x , barPos.y, 0)
  local EndPos = Vector(barPos.x + 108 , barPos.y , 0)    
  return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

local function Rengar_DrawLineHPBar(damage, text, unit, team)
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

  local StartPos, EndPos = Rengar_GetHPBarPos(unit)
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

local function Rengar_OnProcessSpellComplete(unit, spell)
	if not unit or not spell then return end

	if unit.isMe and spell.name:lower():find("attack") and (Mode() == "Combo" or Mode() == "LaneClear") and Config.C.I:Value() then
		if GetItemSlot(myHero, 3748) > 0 and Ready(GetItemSlot(myHero,3748)) then
			CastSpell(GetItemSlot(myHero,3748))
		end
	end
end

local function Rengar_Draw()	

        if Config.D.Q:Value() and Ready(_Q) then DrawCircle(GetOrigin(myHero),Q.range,1,255,ARGB(80,220,220,220)) end
	if Config.D.W:Value() and Ready(_W) then DrawCircle(GetOrigin(myHero),W.range,1,255,ARGB(80,220,220,220)) end
	if Config.D.E:Value() and Ready(_E) then DrawCircle(GetOrigin(myHero),E.range,1,255,ARGB(80,220,220,220)) end

      if not myHero.dead then if Config.P.P:Value() == 1 then DrawText("Prioritize: Q",22,GetHPBarPos(myHero).x,GetHPBarPos(myHero).y+180,GoS.White) else DrawText("Prioritize: E",22,GetHPBarPos(myHero).x,GetHPBarPos(myHero).y+180,GoS.White) end end

      for i, Enemy in pairs(GetEnemyHeroes()) do
      if not Enemy.dead and Enemy.visible and Config.D.HP:Value() then
      local dmg =  GetBonusDmg(myHero)+GetBaseDamage(myHero)
      if Ready(_Q) and not Enemy.dead then
        dmg = dmg + Rengar_CalcDmg("Q", Enemy)
      end
      if Ready(_Q) and not Enemy.dead and GetCurrentMana(myHero) == 4 then
        dmg = dmg + Rengar_CalcDmg("QE", Enemy)
      end
      if Ready(_W) and not Enemy.dead then
        dmg = dmg + Rengar_CalcDmg("W", Enemy)
      end
      if Ready(_E) and not Enemy.dead then
        dmg = dmg + Rengar_CalcDmg("E", Enemy)
      end
      Rengar_DrawLineHPBar(dmg, "", Enemy, Enemy.team)
    end end 

    local target = Focus
	if target == nil or target.dead then return end
	if target.type == myHero.type and target.team ~= myHero.team then
		DrawCircle(GetOrigin(target),75,1,255,GoS.White)
	end
end

local function Rengar_CastQ(target)
	if Config.P.P:Value() == 2 and GetCurrentMana(myHero) == 4 then return end
	if Ready(_Q) and ValidTarget(target, Q.range) then
		local Prediction = GetPredictionForPlayer(myHero,target,GetMoveSpeed(target),Q.speed,Q.delay,Q.range,Q.width,false,true)
		if Prediction.HitChance == 1 then CastSkillShot(_Q, Prediction.PredPos) IOW:ResetAA() end
	end
end

local function Rengar_CastW(target)
	if Ready(_W) and ValidTarget(target, W.range) then
		if GetCurrentMana(myHero) == 4 then return end
		CastSpell(_W)
	end
end

local function Rengar_CastE(target)
	if Config.P.P:Value() == 1 and GetCurrentMana(myHero) == 4 then return end
	if Ready(_E) and ValidTarget(target, E.range) then
		local Prediction = GetPredictionForPlayer(myHero,target,GetMoveSpeed(target),E.speed,E.delay,E.range,E.width,true,true)
		if Prediction.HitChance == 1 then CastSkillShot(_E, Prediction.PredPos) end
	end
end

local function Rengar_Items()
	if Config.C.I:Value() then
	if GetItemSlot(myHero, 3142) > 0 and Ready(GetItemSlot(myHero,3142)) and EnemiesAround(myHero, 1000) > 0 then
		CastSpell(GetItemSlot(myHero,3142))
	end
	if GetItemSlot(myHero, 3077) > 0 and Ready(GetItemSlot(myHero,3077)) then
		CastSpell(GetItemSlot(myHero,3077))
	end
	if GetItemSlot(myHero, 3074) > 0 and Ready(GetItemSlot(myHero,3074)) then
		CastSpell(GetItemSlot(myHero,3074))
	end end
end

local function Rengar_Switch()
	if Config.P.K:Value() then
		if Tick+200 < GetTickCount() then
			if Config.P.P:Value() == 1 then
				Config.P.P:Value(2)
			elseif Config.P.P:Value() == 2 then
				Config.P.P:Value(1)
			end
			Tick = GetTickCount()
		end
	end
end

local function Rengar_Combo(target)
	if UltActive == true or Dash == true then return end
	if Mode() == "Combo" then
		if ValidTarget(target, 200) then Rengar_Items() end
		if Config.C.Q:Value() then Rengar_CastQ(target) end
		if Config.C.W:Value() then Rengar_CastW(target) end
		if Config.C.E:Value() then Rengar_CastE(target) end
	end
end

local function Rengar_Harass(target)
	if UltActive == true or GetCurrentMana(myHero) == 4 then return end
	if Mode() == "Harass" then
		if Config.H.Q:Value() then Rengar_CastQ(target) end
	    if Config.H.W:Value() then Rengar_CastW(target) end
	    if Config.H.E:Value() then Rengar_CastE(target) end
	end
end

local function Rengar_LastHit(target)
	if UltActive == true then return end
	if Mode() == "LastHit" then
		if target.team ~= myHero.team and ValidTarget(target, Q.range) and GetCurrentHP(target) < Rengar_CalcDmg("Q", target) then
			if Config.L.Q:Value() then CastSkillShot(_Q, target) end
		end
	end
end

local function Rengar_Clear(target)
	if UltActive == true or GetCurrentMana(myHero) == 4	then return end
	if Mode() == "LaneClear" then
		if target.team ~= myHero.team and ValidTarget(target, E.range) then
			if Config.J.Q:Value() then CastSkillShot(_Q, target) end
			if Config.J.W:Value() and MinionsAround(myHero, W.range) >= 3 then Rengar_CastW(target) end
			if Config.J.E:Value() then CastSkillShot(_E, target) end
		end
	end
end

local function Rengar_Dash(target)
	if UltActive == true then return end
	if Mode() == "Combo" and Dash == true then
		if Config.C.E:Value() then Rengar_CastE(target) end
		if ValidTarget(target, 200) then Rengar_Items() end
		if Config.C.W:Value() then Rengar_CastW(target) end
		if Config.C.Q:Value() then Rengar_CastQ(target) end
	end
end

local function Rengar_Tick()
	if not myHero.dead then
        local target = Rengar_GetTarget(E.range+250)

		Rengar_Combo(target)
		Rengar_Harass(target)
		for _, target in pairs(minionManager.objects) do Rengar_LastHit(target) Rengar_Clear(target) end
		Rengar_Dash(target)
		Rengar_Switch()
	end
end

OnLoad(function()
	OnTick(Rengar_Tick) 
	OnWndMsg(Rengar_WndMsg)
	OnDraw(Rengar_Draw)
	OnUpdateBuff(Rengar_UpdateBuff)
	OnRemoveBuff(Rengar_RemoveBuff)
	OnProcessSpellComplete(Rengar_OnProcessSpellComplete)
	
	print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Rengar]</b></font><font color=\"#E8E8E8\"> Successfully Loaded!</font>")
    print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Rengar]</b></font><font color=\"#E8E8E8\"> Current Version: </font>"..LoLVer)
    print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Rengar]</b></font><font color=\"#E8E8E8\"> Have Fun, </font>"..GetUser().."<font color=\"#E8E8E8\"> !</font>")
end)
