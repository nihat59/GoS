if myHero.charName ~= "Gnar" then return end

require('DamageLib')
require('OpenPredict')
require('ChallengerCommon')
require('MapPositionGOS') 
if FileExist(COMMON_PATH.."\\MixLib.lua") then
	require('MixLib')
else
    PrintChat("[Gnar] Downloading required lib, please wait...")
	DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/GoS/master/MixLib.lua", COMMON_PATH .. "MixLib.lua", function() PrintChat("[Gnar] Download Completed x2 F6") return end)
	return
end

local LoLVer = "7.1"
local ScrVer = 6

local function Gnar_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#FFA500\"><b>[Gnar]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#FFA500\"><b>[Gnar]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Gnar.lua", SCRIPT_PATH .. "Gnar.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#FFA500\"><b>[Gnar]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#FFA500\"><b>[Gnar]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Gnar.version", Gnar_Update)

local Skin = {["Gnar"] = {"Classic", "Dino", "Gentleman", "Snow Day", "El Leon"}}

OnLoad(function()
	Gnar()
end)

function Gnar()
	Gnar_LoadMenu()
	Gnar_Spells()
	Gnar_Interrupter()
	Gnar_AntiGapCloser()

	QCast, WCast, ECast, RCast = 0, 0, 0, 0
	WBuff = {}
	Ignite = Mix:GetSlotByName("summonerdot", 4, 5)
	for _,i in pairs(GetEnemyHeroes()) do
		WBuff[GetObjectName(i)] = 0
	end
	for _, unit in pairs(GetEnemyHeroes()) do
        Config.A.S.I:Boolean(unit.name, "Use Ignite On: "..unit.charName, true)
        end

	Callback.Add("Tick",function() Gnar_Tick() end)
	Callback.Add("Draw",function() Gnar_Draw() end)
	Callback.Add("UpdateBuff", function(u, b) Gnar_UpdateBuff(u, b) end)
	Callback.Add("RemoveBuff", function(u, b) Gnar_RemoveBuff(u, b) end)

	print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#FFA500\"><b>[Gnar]</b></font><font color=\"#E8E8E8\"> Successfully Loaded!</font>")
	print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#FFA500\"><b>[Gnar]</b></font><font color=\"#E8E8E8\"> Current Version: </font>"..LoLVer)
	print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#FFA500\"><b>[Gnar]</b></font><font color=\"#E8E8E8\"> Have Fun, </font>"..GetUser().."<font color=\"#E8E8E8\"> !</font>")
end

function Gnar_LoadMenu()
	Config = Menu("Gnar", "[Shulepin] Gnar")

	Config:SubMenu("QT", "(Q) Boomerang Throw")
	Config.QT:DropDown("QTMode", "(Q) Current Mode:", 1, { "Always", "Target Has 2 W Stacks"})

	Config:SubMenu("R", "(R) GNAR! Settings")
	Config.R:DropDown("RMode", "(R) Current Mode:", 1, { "Killable", "Combo", "Auto" })
	Config.R:SubMenu("RModeCombo", "(R) Mode - Combo")
	Config.R.RModeCombo:Slider("RCount", "Min. Enemies", 1, 0, 5, 1)
	Config.R.RModeCombo:Slider("RHP", "Min HP (%) Enemies", 100, 0, 100, 1)
	Config.R:SubMenu("RModeAuto", "(R) Mode - Auto")
	Config.R.RModeAuto:Slider("RCount", "Min. Enemies", 3, 0, 5, 1)

	Config:SubMenu("C", "Combo Settings")

	Config.C:SubMenu("Tiny", "Tiny Gnar")
	Config.C.Tiny:Boolean("Q", "Use Q", true)
	Config.C.Tiny:Boolean("E", "Use E", true)

	Config.C:SubMenu("Mega", "Mega Gnar")
	Config.C.Mega:Boolean("Q", "Use Q", true)
	Config.C.Mega:Boolean("W", "Use W", true)
	Config.C.Mega:Boolean("E", "Use E", true)
	Config.C.Mega:Boolean("R", "Use R", true)

	Config:SubMenu("H", "Harass Settings")

	Config.H:SubMenu("Tiny", "Tiny Gnar")
	Config.H.Tiny:Boolean("Q", "Use Q", true)

	Config.H:SubMenu("Mega", "Mega Gnar")
	Config.H.Mega:Boolean("Q", "Use Q", true)

	Config:SubMenu("CL", "Clear Settings")

	Config.CL:SubMenu("Tiny", "Tiny Gnar")
	Config.CL.Tiny:Boolean("Q", "Use Q", true)

	Config.CL:SubMenu("Mega", "Mega Gnar")
	Config.CL.Mega:Boolean("Q", "Use Q", true)
	Config.CL.Mega:Boolean("W", "Use W", true)

	Config:SubMenu("K", "Kill Steal Settings")

	Config.K:SubMenu("Tiny", "Tiny Gnar")
	Config.K.Tiny:Boolean("Q", "Use Q", true)
	Config.K.Tiny:Boolean("E", "Use E")

	Config.K:SubMenu("Mega", "Mega Gnar")
	Config.K.Mega:Boolean("Q", "Use Q", true)
	Config.K.Mega:Boolean("W", "Use W", true)
	Config.K.Mega:Boolean("E", "Use E", true)
	Config.K.Mega:Boolean("R", "Use R", true)

	Config:SubMenu("F", "Flee Settings")
	Config.F:Boolean("E", "Use E", true)

	Config:SubMenu("P", "Prediction Settings")

	Config.P:SubMenu("Tiny", "Tiny Gnar")
	Config.P.Tiny:Slider("Q", "(Q) HitChance:", 25, 0, 100, 5)

	Config.P:SubMenu("Mega", "Mega Gnar") 
        Config.P.Mega:Slider("Q", "(Q) HitChance:", 25, 0, 100, 5)
        Config.P.Mega:Slider("W", "(W) HitChance:", 25, 0, 100, 5)

        Config:SubMenu("D", "Draw Settings")
        Config.D:Boolean("Q", "Draw (QT/QM) Range", true)
        Config.D:Boolean("W", "Draw (WM) Range", true)
        Config.D:Boolean("E", "Draw (ET/EM) Range", true)
        Config.D:Boolean("R", "Draw (R) Range")
        Config.D:Boolean("N", "Draw Current (R) Mode", true)

        Config:SubMenu("Key", "Key Settings")
        Config.Key:KeyBinding("CK",  "Combo" , 32)
        Config.Key:KeyBinding("HK",  "Harass", 67)
        Config.Key:KeyBinding("CLK", "Clear" , 86)
        Config.Key:KeyBinding("FK",  "Flee"  , 90)

        Config:SubMenu("A", "Activator")

        Config.A:SubMenu("OI", "Offensive")
        Config.A.OI:SubMenu("YGB", "Youmuu's Ghostblade")
        Config.A.OI.YGB:Boolean("C", "Use on Combo", true)
        Config.A.OI:SubMenu("BOTRK", "Blade of the Ruined King")
        Config.A.OI.BOTRK:Boolean("C", "Use on Combo", true)
        Config.A.OI.BOTRK:Slider("MinHP", "Min. HP(%)", 50, 0, 100, 1)
        Config.A.OI.BOTRK:Slider("MinEnemyHP", "Min. Enemy HP(%)", 50, 0, 100, 1)
        Config.A.OI:SubMenu("BC", "Bilgewater Cutlass")
        Config.A.OI.BC:Boolean("C", "Use on Combo", true)

        Config.A:SubMenu("DI", "Defensive")
        Config.A.DI:SubMenu("RO", "Randuin's Omen")
        Config.A.DI.RO:Boolean("C", "Use on Combo", true)

        Config.A:SubMenu("S", "Summoners")
        Config.A.S:SubMenu("I", "Ignite")
  
        Config:SubMenu("Interrupter", "Interrupter")
        Config.Interrupter:Boolean("W", "Use W (Mega Gnar)", true)

        Config:SubMenu("AGC", "Anti-GapCloser")
        Config.AGC:Boolean("W", "Use W (Mega Gnar)", true)

        Config:SubMenu("Skin", "Skin Changer")
        Config.Skin:DropDown('skin', myHero.charName.. " Skins", 1, Skin[myHero.charName], 
	function(model)
        HeroSkinChanger(myHero, model - 1) print(Skin[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") 
        end, true)
end

function Gnar_Spells()
    Gnar_Vars = {
    QT = { delay = 0.250 , speed = 1200      , width = 60  , range = 1100 },
    ET = { delay = 0     , speed = 2100      , width = 150 , range = 475  },
    QM = { delay = 0.250 , speed = 1200      , width = 80  , range = 1100 },
    WM = { delay = 0.500 , speed = math.huge , width = 80  , range = 550  },
    EM = { delay = 0     , speed = 2100      , width = 300 , range = 475  },
    R  = { delay = 0.500 , speed = math.huge , width = 400 , range = 400  }
    }
end

function Gnar_Tick()
	local target = GetCurrentTarget()

	Gnar_Combo(target)
	Gnar_Harass(target)
	Gnar_Clear()
        Gnar_CastRAuto()
        Gnar_Activator(target)
	Gnar_Flee()
end

function Gnar_Draw()
	if not myHero.dead then
	    if Config.D.N:Value() then
	    if Config.R.RMode:Value() == 1 then DrawText("Current R Mode: Killable",20,GetHPBarPos(myHero).x-30,GetHPBarPos(myHero).y+150,GoS.White) end
	    if Config.R.RMode:Value() == 2 then DrawText("Current R Mode: Combo"   ,20,GetHPBarPos(myHero).x-30,GetHPBarPos(myHero).y+150,GoS.White) end
	    if Config.R.RMode:Value() == 3 then DrawText("Current R Mode: Auto"    ,20,GetHPBarPos(myHero).x-30,GetHPBarPos(myHero).y+150,GoS.White) end
	    end

	    if Config.D.Q:Value() and Ready(_Q) then DrawCircle(GetOrigin(myHero),Gnar_Vars.QT.range,1,1, ARGB(40,220,220,220)) end
	    if Config.D.W:Value() and Ready(_W) then DrawCircle(GetOrigin(myHero),Gnar_Vars.WM.range,1,1, ARGB(40,220,220,220)) end
	    if Config.D.E:Value() and Ready(_E) then DrawCircle(GetOrigin(myHero),Gnar_Vars.ET.range,1,1, ARGB(40,220,220,220)) end
	    if Config.D.R:Value() and Ready(_R) then DrawCircle(GetOrigin(myHero),Gnar_Vars.R.range, 1,1, ARGB(40,220,220,220)) end
	end
end

function Gnar_UpdateBuff(u, b)
	if not u.isMe and u.type == myHero.type and b.Name:lower() == "gnarwproc" then
		WBuff[GetObjectName(u)] = b.Count
	end
end

function Gnar_RemoveBuff(u, b)
	if not u.isMe and u.type == myHero.type and b.Name:lower() == "gnarwproc" then
		WBuff[GetObjectName(u)] = 0
	end
end

function Gnar_Combo(target)
	local POS = GetOrigin(target) + (GetOrigin(target) - myHero.pos):normalized()*Gnar_Vars.ET.range
	if Mix:Mode() == "Combo" or Config.Key.CK:Value() then
		if Config.C.Tiny.E:Value() and GetCurrentHP(target) < (getdmg("Q", myHero, target)*3) and not UnderTurret(POS, enemyTurret) then Gnar_CastET(target) end
		if Config.C.Mega.E:Value() and GetDistance(myHero, target) >= ((Gnar_Vars.EM.range/2) - 25) then Gnar_CastEM(target) if not UnderTurret(POS, enemyTurret) then Gnar_CastEM2(target) end end
		if Config.C.Tiny.Q:Value() and Config.QT.QTMode:Value() == 1 then Gnar_CastQT(target) end
		if Config.C.Tiny.Q:Value() and Config.QT.QTMode:Value() == 2 and WBuff[GetObjectName(target)] > 1 then Gnar_CastQT(target) end
		if Config.C.Mega.Q:Value() then Gnar_CastQM(target) end
		if Config.C.Mega.W:Value() then Gnar_CastWM(target) end
		if Config.C.Mega.R:Value() and Config.R.RMode:Value() == 2 then for _, enemy in pairs(GetEnemyHeroes()) do if GetPercentHP(enemy) < Config.R.RModeCombo.RHP:Value() then Gnar_CastR(Config.R.RModeCombo.RCount:Value(), enemy) end end end
	end
end

function Gnar_Harass(target)
	if Mix:Mode() == "Harass" or Config.Key.HK:Value() then
		if Config.H.Tiny.Q:Value() then Gnar_CastQT(target) end
		if Config.H.Mega.Q:Value() then Gnar_CastQM(target) end 
	end
end

function Gnar_Clear()
	if Mix:Mode() == "LaneClear" or Config.Key.CLK:Value() then
		for _, target in pairs(minionManager.objects) do
			if target.team ~= myHero.team and not target.dead then
			    if Config.CL.Tiny.Q:Value() then Gnar_CastQT(target) end
			    if Config.CL.Mega.Q:Value() then Gnar_CastQM(target) end
			    if Config.CL.Mega.W:Value() then Gnar_CastWM(target) end
			end
		end
	end
end

function Gnar_KillSteal()
	for _, target in pairs(GetEnemyHeroes()) do
		if Config.K.Tiny.Q:Value() and GetCurrentHP(target) + GetDmgShield(target) < getdmg("Q", target, myHero)  then Gnar_CastQT(target) end
		if Config.K.Tiny.E:Value() and GetCurrentHP(target) + GetDmgShield(target) < getdmg("E", target, myHero)  then Gnar_CastET(target) end
		if Config.K.Mega.Q:Value() and GetCurrentHP(target) + GetDmgShield(target) < getdmg("QM", target, myHero) then Gnar_CastQM(target) end
		if Config.K.Mega.W:Value() and GetCurrentHP(target) + GetDmgShield(target) < getdmg("WM", target, myHero) then Gnar_CastWM(target) end
		if Config.K.Mega.E:Value() and GetCurrentHP(target) + GetDmgShield(target) < getdmg("EM", target, myHero) then Gnar_CastEM(target) end
	end
	        if Config.K.Mega.R:Value() and GetCurrentHP(target) + GetDmgShield(target) < getdmg("R", target, myHero)  then Gnar_CastRKill()    end
end

function Gnar_Flee()
	if Config.Key.FK:Value() then
	    Mix:Move()
	    for _, minion in pairs(minionManager.objects) do
		    if myHero:GetSpellData(_E).name:lower() == "gnare" and minion.valid and minion ~= nil then if GetDistanceSqr(minion, GetMousePos()) <= Gnar_Vars.WM.range * Gnar_Vars.WM.range and GetDistanceSqr(minion, myHero) <= Gnar_Vars.ET.range * Gnar_Vars.ET.range then
			    if Config.F.E:Value() then CastSkillShot(_E, minion.x, myHero.y, minion.z) end
		    end end
		end
	end
end

function Gnar_Interrupter()
	ChallengerCommon.Interrupter(Config.Interrupter, function(unit, spell)
		if Config.Interrupter.W:Value() and unit.team == MINION_ENEMY and Ready(_W) and GetDistance(myHero, unit) <= Gnar_Vars.WM.range and unit.valid then Gnar_CastWM(unit) print("InterKappa") end
	end)
end

function Gnar_AntiGapCloser()
	ChallengerCommon.AntiGapcloser(Config.AGC, function(unit, spell)
		if Config.AGC.W:Value() and unit.team == MINION_ENEMY and Ready(_W) and GetDistance(myHero, unit) <= Gnar_Vars.WM.range and unit.valid then Gnar_CastWM(unit) print("AGCKappa") end
	end)
end

function Gnar_CastQT(target)
	if myHero:GetSpellData(_Q).name:lower() == "gnarq" and Ready(_Q) and ValidTarget(target, Gnar_Vars.QT.range) then
	    local Prediction = GetPrediction(target, Gnar_Vars.QT)
	    if Prediction.hitChance >= Config.P.Tiny.Q:Value()/100 and not Prediction:mCollision(1) then
		    CastSkillShot(_Q, Prediction.castPos)
	    end
	end
end

function Gnar_CastET(target)
	if myHero:GetSpellData(_E).name:lower() == "gnare" and Ready(_E) and ValidTarget(target, Gnar_Vars.ET.range) then
	    local Prediction = GetPrediction(target, Gnar_Vars.ET)
	    if Prediction.hitChance >= 0.25 then
		    CastSkillShot(_E, Prediction.castPos)
	    end
	end
end

function Gnar_CastQM(target)
	if myHero:GetSpellData(_Q).name:lower() == "gnarbigq" and Ready(_Q) and ValidTarget(target, Gnar_Vars.QM.range) then
	    local Prediction = GetPrediction(target, Gnar_Vars.QM)
	    if Prediction.hitChance >= Config.P.Mega.Q:Value()/100 and not Prediction:mCollision(1) then
		    CastSkillShot(_Q, Prediction.castPos)
	    end
	end
end

function Gnar_CastWM(target)
	if myHero:GetSpellData(_W).name:lower() == "gnarbigw" and Ready(_W) and ValidTarget(target, Gnar_Vars.WM.range) then
	    local Prediction = GetPrediction(target, Gnar_Vars.WM)
	    if Prediction.hitChance >= Config.P.Mega.W:Value()/100 and RCast+1000 < GetTickCount() then
		    CastSkillShot(_W, Prediction.castPos)
	    end
	end
end

function Gnar_CastEM(target)
	if myHero:GetSpellData(_E).name:lower() == "gnarbige" and Ready(_E) and ValidTarget(target, Gnar_Vars.EM.range) then
	    local Prediction = GetCircularAOEPrediction(target, Gnar_Vars.WM)
	    if Prediction.hitChance >= 0 then
		    CastSkillShot(_E, Prediction.castPos)
	    end
        end
end

function Gnar_CastEM2(target)
	if GetCurrentMana(myHero) == 100 and myHero:GetSpellData(_E).name:lower() == "gnare" and Ready(_E) and ValidTarget(target, Gnar_Vars.EM.range) then
	    local Prediction = GetPrediction(target, Gnar_Vars.EM)
	    if Prediction.hitChance >= 0 then
		    CastSkillShot(_E, Prediction.castPos)
	    end
	end
end

function Gnar_CastR(count, target)
	if Gnar_CountEnemiesNearUnit(myHero, 400) >= count and Ready(_R) and ValidTarget(target, 400) then Gnar_CastRToCollision() end
end

function Gnar_CastRAuto()
	if Config.C.Mega.R:Value() and Config.R.RMode:Value() == 3 then for _, enemy in pairs(GetEnemyHeroes()) do Gnar_CastR(Config.R.RModeAuto.RCount:Value(), enemy) end end
end

function Gnar_CastRKill()
	if Config.C.Mega.R:Value() and Config.R.RMode:Value() == 1 then for _, enemy in pairs(GetEnemyHeroes()) do if GetCurrentHP(enemy) < (getdmg("R", myHero, enemy) + getdmg("Q", myHero, enemy)) then Gnar_CastR(1, enemy) end end end
end

function Gnar_CastRToCollision()
	local c = myHero
	local p = 36
	local r = 300
	local s = 2 * math.pi / p

	for i = 0, p, 1 do
		local angle = s * i
		local _X = c.x + r * math.cos(angle)
		local _Z = c.z + r * math.sin(angle)
		local pos = Vector(_X, 0, _Z)

		if MapPosition:inWall(pos) then CastSkillShot(_R, pos.x, myHero.y, pos.z) RCast = GetTickCount() end
	end
end

function Gnar_CountEnemiesNearUnit(unit, range)
	local count = 0
	for i = 1, heroManager.iCount do
		local enemy = heroManager:GetHero(i)	
		if enemy.team ~= myHero.team and enemy.type == myHero.type then
			if GetDistanceSqr(enemy, unit) <= range * range and not enemy.dead then
				count = count + 1
			end
		end
	end
	return count
end

function Gnar_Activator(target)
	if Mix:Mode() == "Combo" then
	if Config.A.OI.YGB.C:Value() and GetItemSlot(myHero, 3142) > 0 and Ready(GetItemSlot(myHero,3142)) and EnemiesAround(myHero, 1000) > 0 then
		CastSpell(GetItemSlot(myHero,3142))
	end
	if Config.A.OI.BOTRK.C:Value() and ValidTarget(target, 650) and GetItemSlot(myHero, 3153) > 0 and Ready(GetItemSlot(myHero,3153)) and GetPercentHP(target) <= Config.A.OI.BOTRK.MinEnemyHP:Value() and GetPercentHP(myHero) <= Config.A.OI.BOTRK.MinHP:Value() then
		CastTargetSpell(target, GetItemSlot(myHero, 3153))
	end
	if Config.A.OI.BC.C:Value() and ValidTarget(target, 650) and GetItemSlot(myHero, 3144) > 0 and Ready(GetItemSlot(myHero,3144)) then
		CastTargetSpell(target, GetItemSlot(myHero, 3144))
	end
	if Config.A.DI.RO.C:Value() and GetItemSlot(myHero, 3143) > 0 and Ready(GetItemSlot(myHero,3143)) and ValidTarget(target, 450) then
		CastSpell(GetItemSlot(myHero,3143))
	end
	end

	if Ignite and Ready(Ignite) then
		for _, unit in pairs(GetEnemyHeroes()) do
			local IgniteDmg = 70+20*GetLevel(myHero)
			if ValidTarget(unit, 660) and GetCurrentHP(unit) + GetDmgShield(unit) <= IgniteDmg then
				if Config.A.S.Ignite[unit.name]:Value() then
					CastTargetSpell(unit, Ignite)
				end
			end
		end
	end
end
