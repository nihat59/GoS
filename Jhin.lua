if myHero.charName ~= "Jhin" then return end


local LoLVer = "7.1"
local ScrVer = 5

local function Jhin_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Jhin]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Jhin]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Jhin.lua", SCRIPT_PATH .. "Jhin.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Jhin]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Jhin]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Jhin.version", Jhin_Update)

require("GPrediction")
local GPred = _G.gPred

local Config     = MenuConfig("Jhin", "Jhin | Artisan Killer")
local sp         = {[0]="Q",[1]="W",[2]="E",[3]="R"}
local CCType     = { [5] = "Stun", [8] = "Taunt", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression", }
local Mark       = false
local Reload     = false
local UltOn      = false 
local Minions    = {}
local Skin_Table = {["Jhin"] = {"Classic", "High Noon"}}
local LvL_Table  = { [1] = {_Q,_E,_W,_Q,_Q,_R,_Q,_E,_Q,_E,_R,_E,_E,_W,_W,_R,_W,_W}, [2] = {_Q,_W,_E,_Q,_Q,_R,_Q,_W,_Q,_W,_R,_W,_W,_E,_E,_R,_E,_E} }

local Q = { range = 600 }
local W = { range = 2550, radius = 20 , speed = 5000, delay = 0.75, type = "line", col = {"minion","champion"}}
local E = { range = 750 , radius = 150 , speed = 1600, delay = 0.85, type = "circular", col = {"minion","champion"}}
local R = { range = 3500 , radius = 40 , speed = 4500, delay = 0.2, type = "line", col = {"minion","champion"}}

Config:SubMenu("C", "Combat Settings")
Config.C:Boolean("Q", "Use Q", true)
Config.C:Boolean("W", "Use W", true)
Config.C:Boolean("E", "Use E", true)
Config.C:KeyBinding("CKey", "Combat Key", string.byte(" "))
Config.C:SubMenu("AS", "Advanced Settings")
Config.C.AS:Boolean("W", "Use W on Immobile", true)
Config.C.AS:Boolean("E", "Use E on Immobile", true)
Config.C.AS:DropDown("QMode", "Q Cast Mode", 2, {"Always", "After Attack"})

Config:SubMenu("U", "Ultimate Settings")
Config.U:KeyBinding("TapKey", "R Tap Key", string.byte("T"))
Config.U:KeyBinding("CancelKey", "R Cancel Key", string.byte("G"))

Config:SubMenu("M", "Mixed Settings")
Config.M:Boolean("Q", "Use Q", true)
Config.M:Boolean("W", "Use W", true)
Config.M:Boolean("E", "Use E", true)
Config.M:Slider("Mana", "Min. Mana(%) For Mixed Mode", 50, 0, 100, 1)
Config.M:KeyBinding("MKey", "Mixed Key", string.byte("C"))

Config:SubMenu("L", "LastHit Settings")
Config.L:Boolean("Q", "Use Q", true)
Config.L:Slider("Mana", "Min. Mana(%) For LastHit Mode", 50, 0, 100, 1)
Config.L:KeyBinding("LKey", "LastHit Key", string.byte("X"))

Config:SubMenu("W", "WaveClear Settings")
Config.W:Boolean("Q", "Use Q", true)
Config.W:Boolean("E", "Use E", true)
Config.W:Slider("Mana", "Min. Mana(%) For WaveClear Mode", 50, 0, 100, 1)
Config.W:KeyBinding("WKey", "WaveClear Key", string.byte("V"))

Config:SubMenu("E", "Extra Settings")
Config.E:SubMenu("K", "KillSteal Settings")
Config.E.K:Boolean("Q", "Use Q", true)
Config.E.K:Boolean("W", "Use W", true)
Config.E:SubMenu("D", "Drawings")
Config.E.D:Boolean("Q", "Draw Q Range", true)
Config.E.D:Boolean("W", "Draw W Range", true)
Config.E.D:Boolean("E", "Draw E Range", true)
Config.E.D:Boolean("R", "Draw R Range", true)
Config.E.D:Boolean("RM", "Draw R Range on Minimap", true)
Config.E.D:Boolean("HP", "Draw Damage Indicator", true)
Config.E:SubMenu("Skin", "Skin Changer")
Config.E.Skin:DropDown('skin',"Select A Skin:", 1, Skin_Table[myHero.charName], 
function(model) HeroSkinChanger(myHero, model - 1) print(Skin_Table[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end, true)
Config.E:SubMenu("H", "Hit Chance")
for s = 1, 3, 1 do
	Config.E.H:DropDown("H"..sp[s], "Spell: "..sp[s], 1, {"Low","Medium","High"})
end
Config.E:SubMenu("LvL", "Auto LvLUp")
Config.E.LvL:Boolean("E", "Enabled")
Config.E.LvL:Slider("SL", "Start at X LvL", 2, 1, 18)
Config.E.LvL:DropDown("S", "Sequence", 2, {"Q-E-W", "Q-W-E"})
Config:Info("i", "Script Version: "..LoLVer)
Config:Info("i", "By Shulepin")

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

local function Jhin_CalcDmg(spell, target)
	local dmg = {
	[_Q] =  25+25*GetCastLevel(myHero, _Q) + GetBonusDmg(myHero)*((25+5*GetCastLevel(myHero, _Q))/100) + GetBonusAP(myHero)*.6,
	[_W] =  15+35*GetCastLevel(myHero, _W) + GetBonusDmg(myHero)*.5,
	[_E] = -40+60*GetCastLevel(myHero, _E) + GetBonusDmg(myHero)*1.2 + GetBonusAP(myHero),
	["R1"] = -20+60*GetCastLevel(myHero, _R) + GetBonusDmg(myHero)*.2*(1 +(100 - GetPercentHP(target))),
	["R2"] = -20+60*GetCastLevel(myHero, _R) + GetBonusDmg(myHero)*.2*(1 +(100 - GetPercentHP(target)))*2
}
return dmg[spell]
end

local function Jhin_LvL()
	if GetLevelPoints(myHero) > 0 and Config.E.LvL.E:Value() and GetLevel(myHero) >= Config.E.LvL.SL:Value() then
		DelayAction(function() LevelSpell(LvL_Table[Config.E.LvL.S:Value()][GetLevel(myHero)+1-GetLevelPoints(myHero)]) end, math.random(0.250, 0.850))
	end
end

local function Jhin_GetHPBarPos(enemy)
  local barPos = GetHPBarPos(enemy) 
  local BarPosOffsetX = -50
  local BarPosOffsetY = 46
  local CorrectionY = 39
  local StartHpPos = 31 
  local StartPos = Vector(barPos.x , barPos.y, 0)
  local EndPos = Vector(barPos.x + 108 , barPos.y , 0)    
  return Vector(StartPos.x, StartPos.y, 0), Vector(EndPos.x, EndPos.y, 0)
end

local function Jhin_DrawLineHPBar(damage, text, unit, team)
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

  local StartPos, EndPos = Jhin_GetHPBarPos(unit)
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

local function Jhin_HitChance(m, s)
	if m["H"..sp[s]]:Value() == 1 then
		return 0
	elseif m["H"..sp[s]]:Value() == 2 then
		return .45
	elseif m["H"..sp[s]]:Value() == 3 then
		return .7
	end
	
end

local function Jhin_IssueOrder(Order)
	if (Order.flag == 2 or Order.flag == 3) and UltOn == true then
		BlockOrder()
	end
end

local function Jhin_SpellCast(spell)
	for i = 0, 2, 1 do
		if UltOn == true and spell.spellID == i then
			BlockCast()
		end
	end
end

local function Jhin_PS(unit, spell)
	if not unit or not spell then return end

	if unit.isMe and spell.name == "JhinR" then
		UltOn = true
	end
end

local function Jhin_UpdateBuff(unit, buff)
    if not unit or not buff then return end

	if unit.isMe and buff.Name == "JhinPassiveReload" then
		Reload = true
	end

	if not unit.isMe and unit.team ~= myHero.team and CCType[buff.Type] then
		if myHero:CanUseSpell(_W) == READY and GetDistance(unit) <= W.range and Config.C.AS.W:Value() then CastSkillShot(_W, unit) end
		if myHero:CanUseSpell(_E) == READY and GetDistance(unit) <= E.range and Config.C.AS.E:Value() then CastSkillShot(_E, unit) end
	end
end

local function Jhin_RemoveBuff(unit, buff)
    if not unit or not buff then return end

	if unit.isMe and buff.Name == "JhinPassiveReload" then
		Reload = false
	end
end

local function Jhin_CastQ(target, range)
	if myHero:CanUseSpell(_Q) == READY and ValidTarget(target, range) then
		CastTargetSpell(target, _Q)
	end
end

local function Jhin_CastW(target, range)
	if myHero:CanUseSpell(_W) == READY and ValidTarget(target, range) and GotBuff(target, "jhinespotteddebuff") > 0 then
		local P = GPred:GetPrediction(target,myHero,W,false,false)
		if P and P.HitChance >= Jhin_HitChance(Config.E.H, 1) then
			CastSkillShot(_W, P.CastPosition)
		end
	end
end

local function Jhin_CastW2(target, range)
	if myHero:CanUseSpell(_W) == READY and ValidTarget(target, range) then
		local P = GPred:GetPrediction(target,myHero,W,false,false)
		if P and P.HitChance >= Jhin_HitChance(Config.E.H, 1) then
			CastSkillShot(_W, P.CastPosition)
		end
	end
end

local function Jhin_CastE(target, range)
	if myHero:CanUseSpell(_E) == READY and ValidTarget(target, range) then
		local P = GPred:GetPrediction(target,myHero,E,false,false)
		if P and P.HitChance >= Jhin_HitChance(Config.E.H, 2) then
			CastSkillShot(_E, P.CastPosition)
		end
	end
end

local function Jhin_CastR(target, range)
	if myHero:CanUseSpell(_R) == READY and myHero:GetSpellData(_R).name == "JhinR" and ValidTarget(target, range) then
		CastSkillShot(_R, target)
	end
end

local function Jhin_CastRMis(target, range)
	if myHero:CanUseSpell(_R) == READY and myHero:GetSpellData(_R).name == "JhinRShot" and ValidTarget(target, range) then
		local P = GPred:GetPrediction(target,myHero,R,false,false)
		if P and P.HitChance >= Jhin_HitChance(Config.E.H, 3) then
			CastSkillShot(_R, P.CastPosition)
		end
	end
end

local function Jhin_PSC(unit, spell)
	if not unit or not spell then return end

	if unit.isMe and spell.name:lower():find("attack") and (Mode() == "Combo" or Config.C.CKey:Value()) then
		local target = GetCurrentTarget()
		if Config.C.AS.QMode:Value() == 2 and Config.C.Q:Value() then Jhin_CastQ(target, Q.range) end
		if Config.C.E:Value() then Jhin_CastE(target, E.range) end
	end
end

local function EnemyMinionsAround(range, pos)
	local Count = 0
	if pos == nil then return 0 end
	for _, M in pairs(Minions) do
		if GetDistance(pos, M) < range then
			Count = Count + 1
		end
	end
	return Count
end

local function Jhin_Update()
	Jhin_LvL()
    if myHero:GetSpellData(_R).name == "JhinRShot" then
    	UltOn = true
    else
    	UltOn = false
    end

    if Config.U.CancelKey:Value() then UltOn = false DelayAction(function() MoveToXYZ(GetMousePos()) end, 0.050) end

	if Reload == true and (Mode() == "Combo" or Config.C.CKey:Value()) then
		local target = GetCurrentTarget()
		Jhin_CastQ(target, Q.range)
	end

	for _, M in pairs(minionManager.objects) do
		if M.valid and M.alive and M.team == MINION_ENEMY and GetDistance(myHero, M) < W.range then
			Minions[M.networkID] = M
		else
			Minions[M.networkID] = nil
		end
	end
end

local function Jhin_Combo(target)
	if Mode() == "Combo" or Config.C.CKey:Value() then
		if Config.C.Q:Value() and Config.C.AS.QMode:Value() == 1 then Jhin_CastQ(target, Q.range) end
		if Config.C.W:Value() then Jhin_CastW(target, W.range) end
	end
end

local function Jhin_Mixed(target)
	if (Mode() == "Harass" or Config.M.MKey:Value()) and GetPercentMP(myHero) >= Config.M.Mana:Value() then
		if Config.M.Q:Value() then Jhin_CastQ(target, Q.range) end
		if Config.M.W:Value() then Jhin_CastW(target, W.range) end
		if Config.M.E:Value() then Jhin_CastE(target, E.range) end
	end
end

local function Jhin_WaveClear()
	if (Mode() == "LaneClear" or Config.W.WKey:Value()) and GetPercentMP(myHero) >= Config.W.Mana:Value() then
		for _, M in pairs(Minions) do
			if GetDistance(M) < Q.range and Config.W.Q:Value() then CastTargetSpell(M, _Q) end
			if EnemyMinionsAround(300, M) > 3 and GetDistance(M) < E.range and Config.W.E:Value() then CastSkillShot(_E, M) end
		end
	end
end

local function Jhin_KillSteal()
	for _, target in pairs(GetEnemyHeroes()) do
		if GetCurrentHP(target) + GetDmgShield(target) < CalcDamage(myHero, target, Jhin_CalcDmg(_Q, target) ,0) and Config.E.K.Q:Value() then Jhin_CastQ(target, Q.range) end
		if GetCurrentHP(target) + GetDmgShield(target) < CalcDamage(myHero, target, Jhin_CalcDmg(_W, target) ,0) and Config.E.K.W:Value() then Jhin_CastW2(target, W.range) end
	end
end

local function Jhin_LastHit()
	if (Mode() == "LastHit" or Config.L.LKey:Value()) and GetPercentMP(myHero) >= Config.L.Mana:Value() then
		for _, M in pairs(Minions) do
			if GetDistance(M) < Q.range and Config.L.Q:Value() and GetCurrentHP(M) < Jhin_CalcDmg(_Q, M) then CastTargetSpell(M, _Q) end
		end
	end
end
 
local function Jhin_TapKey(target, KeyMenu)
	if KeyMenu then
        Jhin_CastR(target, R.range)
		Jhin_CastRMis(target, R.range)
	end
end

local function Jhin_Draw() 
	if not myHero.dead then
		local Hero = GetOrigin(myHero) 
		if myHero:CanUseSpell(_Q) == READY and Config.E.D.Q:Value() then DrawCircle(Hero,Q.range,1,255,ARGB(80,220,220,220)) end 
		if myHero:CanUseSpell(_W) == READY and Config.E.D.W:Value() then DrawCircle(Hero,W.range,1,255,ARGB(80,220,220,220)) end
		if myHero:CanUseSpell(_E) == READY and Config.E.D.E:Value() then DrawCircle(Hero,E.range,1,255,ARGB(80,220,220,220)) end
		if myHero:CanUseSpell(_R) == READY and Config.E.D.R:Value() then DrawCircle(Hero,R.range,1,255,ARGB(80,220,220,220)) end
	end

	for i, Enemy in pairs(GetEnemyHeroes()) do
        if not Enemy.dead and Enemy.visible and Config.E.D.HP:Value() then
            local dmg =  GetBonusDmg(myHero)+GetBaseDamage(myHero)
            if myHero:CanUseSpell(_Q) == READY and not Enemy.dead then
                dmg = dmg + CalcDamage(myHero, Enemy, Jhin_CalcDmg(_Q, Enemy), 0)
            end
            if myHero:CanUseSpell(_W) == READY and not Enemy.dead then
                dmg = dmg + CalcDamage(myHero, Enemy, Jhin_CalcDmg(_W, Enemy), 0)
            end
            if myHero:CanUseSpell(_E) == READY and not Enemy.dead then
                dmg = dmg + CalcDamage(myHero, Enemy, Jhin_CalcDmg(_E, Enemy), 0)
            end
            if Ready(_R) and not Enemy.dead then
                dmg = dmg + CalcDamage(myHero, Enemy, Jhin_CalcDmg("R1", Enemy)*3, 0) + CalcDamage(myHero, Enemy, Jhin_CalcDmg("R2", Enemy), 0)
            end
            Jhin_DrawLineHPBar(dmg, "", Enemy, Enemy.team)
        end 
    end
end

local function Jhin_Draw2()
	if not myHero.dead then
		local Hero = GetOrigin(myHero) 
		if myHero:CanUseSpell(_R) == READY and Config.E.D.RM:Value() then DrawCircleMinimap(Hero,R.range,1,10,GoS.White) end
	end
end

local function Jhin_Tick()
	if not myHero.dead then
		local target = GetCurrentTarget()
		Jhin_Update()
		Jhin_Combo(target)
		Jhin_Mixed(target)
		Jhin_WaveClear()
		Jhin_LastHit()
		Jhin_KillSteal()
		Jhin_TapKey(target, Config.U.TapKey:Value())
	end
end

OnLoad(function()
	OnTick(Jhin_Tick)
	OnIssueOrder(Jhin_IssueOrder)
	OnSpellCast(Jhin_SpellCast)
	OnProcessSpell(Jhin_PS)
	OnUpdateBuff(Jhin_UpdateBuff)
	OnRemoveBuff(Jhin_RemoveBuff)
	OnProcessSpellComplete(Jhin_PSC)
	OnDraw(Jhin_Draw)
	OnDrawMinimap(Jhin_Draw2)

	  print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Jhin]</b></font><font color=\"#E8E8E8\"> Successfully Loaded!</font>")
    print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Jhin]</b></font><font color=\"#E8E8E8\"> Current Version: </font>"..LoLVer)
    print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Jhin]</b></font><font color=\"#E8E8E8\"> Have Fun, </font>"..GetUser().."<font color=\"#E8E8E8\"> !</font>")
end)
