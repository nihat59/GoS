if myHero.charName ~= "Corki" then return end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

local LoLVer = "6.24.0.0"
local ScrVer = 1

local function Corki_Update(data)
    if tonumber(data) > ScrVer then
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Corki]</b></font><font color=\"#E8E8E8\"> New version found!</font> " .. data)
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Corki]</b></font><font color=\"#E8E8E8\"> Downloading update, please wait...</font>")
        DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Corki.lua", SCRIPT_PATH .. "Corki.lua", function() PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Corki]</b></font><font color=\"#E8E8E8\"> Update Complete, please 2x F6!</font>") return end)  
    else
        PrintChat("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Corki]</b></font><font color=\"#E8E8E8\"> No updates found!</font>")
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Corki.version", Corki_Update)

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

require("GPrediction")
local GPred = _G.gPred
local S     = {[1]="Q",[2]="W",[3]="E",[4]="R"}

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "Corki"

function Corki:__init()
	self:InitMenu()
	self:Variables()
	Callback.Add("Tick", function() self:Tick() end)
	Callback.Add("Draw", function() self:Draw() end)
	Callback.Add("UpdateBuff", function(unit, buff) self:UpdateBuff(unit, buff) end)
	Callback.Add("RemoveBuff", function(unit, buff) self:RemoveBuff(unit, buff) end)
end

function Corki:InitMenu()
	Config = MenuConfig("Corki", "Corki | The Daring Bombardier")
	Config:SubMenu("C", "Combat Settings")
    Config.C:Boolean("Q", "Use Q", true)
    Config.C:Boolean("W", "Use W")
    Config.C:Boolean("E", "Use E", true)
    Config.C:Boolean("R", "Use R", true)
    Config.C:KeyBinding("CKey", "Combat Key", string.byte(" "))
    Config.C:SubMenu("AS", "Advanced Settings")
    Config.C.AS:Boolean("S", "Sheen Waving", true)
    Config.C.AS:Boolean("Q", "Use Q on Immobile", true)
    Config.C.AS:Slider("RStack", "Keep R Stacks", 0, 0, 7, 1)

    Config:SubMenu("M", "Mixed Settings")
    Config.M:Boolean("Q", "Use Q", true)
    Config.M:Boolean("E", "Use E")
    Config.M:Boolean("R", "Use R")
    Config.M:Slider("Mana", "Min. Mana(%) For Mixed Mode", 50, 0, 100, 1)
    Config.M:KeyBinding("MKey", "Mixed Key", string.byte("C"))

    Config:SubMenu("L", "LastHit Settings")
    Config.L:Boolean("Q", "Use Q", true)
    Config.L:Slider("KQ", "Killable Minions with Q", 2, 1, 5, 1)
    Config.L:Slider("Mana", "Min. Mana(%) For LastHit Mode", 50, 0, 100, 1)
    Config.L:KeyBinding("LKey", "LastHit Key", string.byte("X"))

    Config:SubMenu("W", "WaveClear Settings")
    Config.W:Boolean("Q", "Use Q", true)
    Config.W:Slider("KQ", "Killable Minions with Q", 2, 1, 5, 1)
    Config.W:Boolean("E", "Use E", true)
    Config.W:Boolean("R", "Use R", true)
    Config.W:Slider("KR", "Killable Minions with R", 2, 1, 5, 1)
    Config.W:Slider("RStack", "Keep R Stacks", 0, 0, 7, 1)
    Config.W:Slider("Mana", "Min. Mana(%) For WaveClear Mode", 50, 0, 100, 1)
    Config.W:KeyBinding("WKey", "WaveClear Key", string.byte("V"))

    Config:SubMenu("K", "KillSteal Settings")
    Config.K:Boolean("Q", "Use Q", true)
    Config.K:Boolean("R", "Use R", true)

    Config:SubMenu("D", "Draw Settings")
    Config.D:Boolean("Q", "Draw Q Range", true)
    Config.D:Boolean("W", "Draw W Range")
    Config.D:Boolean("E", "Draw E Range", true)
    Config.D:Boolean("R", "Draw R Range", true)

    Config:SubMenu("H", "Hit Chance")
    for s = 1, 4, 1 do
    	if s == 1 or s == 4 then
    		Config.H:DropDown("H"..S[s], "Spell: "..S[s], 3, {"Low","Medium","High"})
    	end
    end

    Config:SubMenu("Skin", "Skin Changer")
    Config.Skin:DropDown("select", "Select A Skin:", 1, {"Classic", "UFO", "Ice Toboggan", "Red Baron", "Hot Rod", "Urf Rider", "DragonWing", "Fnatic", "Arcade"}, function(model) HeroSkinChanger(GetMyHero(), model - 1) end, true)

    Config:Info("i", "Script Version: "..LoLVer)
Config:Info("i", "By Shulepin")
end

function Corki:Variables()
	self.Q  = { range = 825, radius = 125 , speed = 1000, delay = .35, type = "circular", col = {"minion","champion","yasuowall"}}
	self.W  = { range = 525 }
	self.E  = { range = 600, radius = (45 * math.pi / 180)/2 , speed = 1500, delay = .0, type = "cone", col = {"minion","champion","yasuowall"}}
	self.R  = { range = 1300, radius = 20, speed = 2000, delay = .2, type = "line", col = {"minion","champion","yasuowall"}}
	self.CCType = { [5] = "Stun", [8] = "Taunt", [11] = "Snare", [21] = "Fear", [22] = "Charm", [24] = "Suppression", }
	self.BigR = false
	self.Sheen  = GetItemSlot(myHero, 3057)
	self.SheenB = false
	self.SheenT = 0
    self.TOD    = GetItemSlot(myHero, 3078)
end

function Corki:Checks()
	self.Q.ready = myHero:CanUseSpell(_Q) == READY
	self.W.ready = myHero:CanUseSpell(_W) == READY
	self.E.ready = myHero:CanUseSpell(_E) == READY
	self.R.ready = myHero:CanUseSpell(_R) == READY
end

function Corki:Tick()
	if not IsDead(myHero) then
		local target = GetCurrentTarget()
		self:Checks()
		self:Combo(target)
		self:Mixed(target)
		self:LastHit()
		self:Clear()
		self:KillSteal()
	end
end

function Corki:Combo(target)
	if Mode() == "Combo" or Config.C.CKey:Value() then
		if Config.C.W:Value() then self:CastW(target) end
		if self.Sheen > 0 or self.TOD > 0 and Config.C.AS.S:Value() then
			if Config.C.Q:Value() then self:CastQ(target) end
			if self.SheenB == false and self.SheenT+1500 < GetTickCount() and GetDistanceSqr(target) < math.pow(self.E.range, 2) then
				if Config.C.E:Value() then self:CastE(target) end
				if Config.C.R:Value() and myHero:GetSpellData(_R).ammo > Config.C.AS.RStack:Value() then self:CastR(target) end
			elseif GetDistanceSqr(target) > math.pow(self.E.range, 2) then
				if Config.C.R:Value() and myHero:GetSpellData(_R).ammo > Config.C.AS.RStack:Value() then self:CastR(target) end
			end
		else
			if Config.C.Q:Value() then self:CastQ(target) end
			if Config.C.E:Value() then self:CastE(target) end
			if Config.C.R:Value() and myHero:GetSpellData(_R).ammo > Config.C.AS.RStack:Value() then self:CastR(target) end
		end
	end
end

function Corki:Mixed(target)
	if (Mode() == "Harass" or Config.M.MKey:Value()) and GetPercentMP(myHero) >= Config.M.Mana:Value() then
		if Config.M.Q:Value() then self:CastQ(target) end
		if Config.M.E:Value() then self:CastE(target) end
		if Config.M.R:Value() then self:CastR(target) end
	end
end

function Corki:LastHit()
	if (Mode() == "LastHit" or Config.L.LKey:Value()) and GetPercentMP(myHero) >= Config.L.Mana:Value() then
		for _, M in pairs(MinionManager.Minions.Enemy) do
		    if GetDistance(myHero, M.pos) <= self.Q.range and KillMinAround(_Q, M.pos, self.Q.radius) >= Config.L.KQ:Value() then
			    if Config.L.Q:Value() then CastSkillShot(_Q, M.pos) end
		    end
	    end
	end
end

function Corki:Clear()
	if (Mode() == "LaneClear" or Config.W.WKey:Value()) and GetPercentMP(myHero) >= Config.W.Mana:Value() then
		for _, M in pairs(MinionManager.Minions.Enemy) do
		    if GetDistance(myHero, M.pos) <= self.Q.range and KillMinAround(_Q, M.pos, self.Q.radius) >= Config.W.KQ:Value() then
			    if Config.W.Q:Value() then CastSkillShot(_Q, M.pos) end
		    end
		    if GetDistance(myHero, M.pos) <= self.E.range and MinAround(myHero.pos, self.E.range) > 2 then
			    if Config.W.E:Value() then CastSkillShot(_E, M.pos) end
		    end
		    if self.BigR == false then
		    	if GetDistance(myHero, M.pos) <= self.R.range and KillMinAround(_R, M.pos, self.R.radius+100) >= Config.W.KR:Value() then
			        if myHero:GetSpellData(_R).ammo > Config.W.RStack:Value() and Config.W.R:Value() then CastSkillShot(_R, M.pos) end
		        end
		    else
		    	if GetDistance(myHero, M.pos) <= self.R.range+200 and KillMinAround("R", M.pos, self.R.radius+125) >= Config.W.KR:Value() then
			        if myHero:GetSpellData(_R).ammo > Config.W.RStack:Value() and Config.W.R:Value() then CastSkillShot(_R, M.pos) end
		        end
		    end
	    end
	end
end

function Corki:KillSteal()
	for _, target in pairs(GetEnemyHeroes()) do
		if GetCurrentHP(target) + GetDmgShield(target) < CalcDamage(myHero, target, 0 ,self:CalcDmg(_Q)) and Config.K.Q:Value() then self:CastQ(target) end
		if Config.K.R:Value() then
			if self.BigR == false then
				if GetCurrentHP(target) + GetDmgShield(target) < CalcDamage(myHero, target, 0 ,self:CalcDmg(_R)) then
					self:CastR(target)
				end
			else
				if GetCurrentHP(target) + GetDmgShield(target) < CalcDamage(myHero, target, 0 ,self:CalcDmg("R")) then
					self:CastR(target)
				end
			end
		end
		if Config.K.R:Value() and Config.K.R:Value() and self.Q.ready then
			if self.BigR == false then
				if GetCurrentHP(target) + GetDmgShield(target) < (CalcDamage(myHero, target, 0 ,self:CalcDmg(_Q)) + CalcDamage(myHero, target, 0 ,self:CalcDmg(_R))) then
					self:CastR(target)
					self:CastQ(target)
				end
			else
				if GetCurrentHP(target) + GetDmgShield(target) < (CalcDamage(myHero, target, 0 ,self:CalcDmg(_Q)) + CalcDamage(myHero, target, 0 ,self:CalcDmg("R"))) then
					self:CastR(target)
					self:CastQ(target)
				end
			end
		end
	end
end

function Corki:CastQ(target)
	if self.Q.ready and ValidTarget(target, self.Q.range) then
		local Prediction = GPred:GetPrediction(target,myHero,self.Q,true,false)
		if Prediction and Prediction.HitChance >= HitChance(Config.H, 1) then
			CastSkillShot(_Q, Prediction.CastPosition)
		end
	end
end

function Corki:CastW(target)
	if self.W.ready and ValidTarget(target, self.W.Range) and GetDistance(target) < self.W.range then
		local pos = myHero.pos + (target.pos - myHero.pos):normalized() * self.W.range
		if not UnderTurret(pos, enemyTurret) then
			CastSkillShot(_W, pos)
		end
	end
end

function Corki:CastE(target)
	if self.E.ready and ValidTarget(target, self.E.range) then
		CastSkillShot(_E, target.pos)
	end
end

function Corki:CastR(target)
	if self.R.ready then
		if self.BigR == false then
			if ValidTarget(target, self.R.range) then
				local Prediction = GPred:GetPrediction(target,myHero,self.R,false,true)
				if Prediction and Prediction.HitChance >= HitChance(Config.H, 4) then
					CastSkillShot(_R, Prediction.CastPosition)
				end
			end
		else
			if ValidTarget(target, self.R.range+200) then
				local Prediction = GPred:GetPrediction(target,myHero,self.R,false,true)
				if Prediction and Prediction.HitChance >= HitChance(Config.H, 4) then
					CastSkillShot(_R, Prediction.CastPosition)
				end
			end
		end
	end
end

function Corki:UpdateBuff(unit, buff)
	if unit.isMe and buff.Name == "mbcheck2" then
		self.BigR = true
	end
	if unit.isMe and buff.Name == "sheen" then
		self.SheenB = true
		self.SheenT = 0
	end
	if not unit.isMe and unit.team ~= myHero.team and unit.isHero and self.CCType[buff.Type] then
		if self.Q.ready and GetDistance(unit) <= self.Q.range and Config.C.AS.Q:Value() then CastSkillShot(_Q, unit) end
	end
end

function Corki:RemoveBuff(unit, buff)
	if unit.isMe and buff.Name == "mbcheck2" then
		self.BigR = false
	end
	if unit.isMe and buff.Name == "sheen" then
		self.SheenB = false
		self.SheenT = GetTickCount()
	end
end

function Corki:CalcDmg(spell)
	local dmg = {
	[_Q] = 30+50*GetCastLevel(myHero, _Q) + GetBonusDmg(myHero)*.5 + GetBonusAP(myHero)*.5,
	[_R] = 20+80*GetCastLevel(myHero, _R) + GetBonusAP(myHero)*.3 + GetBonusDmg(myHero)*((10+10*GetCastLevel(myHero, _R))/100),
	["R"] = 30+120*GetCastLevel(myHero, _R) + GetBonusAP(myHero)*.45 + GetBonusDmg(myHero)*((15+15*GetCastLevel(myHero, _R))/100)
}
return dmg[spell]
end

function Corki:Draw()
	if not IsDead(myHero) then
		local Hero = GetOrigin(myHero) 
		if self.Q.ready and Config.D.Q:Value() then DrawCircle(Hero,self.Q.range,1,255,ARGB(80,220,220,220)) end 
		if self.W.ready and Config.D.W:Value() then DrawCircle(Hero,self.W.range,1,255,ARGB(80,220,220,220)) end
		if self.E.ready and Config.D.E:Value() then DrawCircle(Hero,self.E.range,1,255,ARGB(80,220,220,220)) end
		if self.R.ready and Config.D.R:Value() then 
			if self.BigR == false then
				DrawCircle(Hero,self.R.range,1,255,ARGB(80,220,220,220)) 
			else
				DrawCircle(Hero,self.R.range+200,1,255,ARGB(80,220,220,220)) 
			end
		end
	end
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

class "MinionManager"

function MinionManager:__init()
	MinionManager.Minions = {
	    All = {},
	    Enemy = {},
	    Ally = {},
	    Jungle = {}	
	}
	
	Callback.Add("CreateObj", function(obj) self:CreateObj(obj) end)
	Callback.Add("ObjectLoad", function(obj) self:CreateObj(obj) end)
	Callback.Add("DeleteObj", function(obj) self:DeleteObj(obj) end)
end

function MinionManager:CreateObj(obj)
	if obj.isMinion and not obj.dead and not obj.charName:find("Plant") then
		if obj.charName:find("Minion") or obj.team == MINION_JUNGLE then
			table.insert(MinionManager.Minions.All, obj)
			if obj.team == MINION_ENEMY then
				table.insert(MinionManager.Minions.Enemy, obj)
			elseif obj.team == MINION_ALLY then
				table.insert(MinionManager.Minions.Ally, obj)
			elseif obj.team == MINION_JUNGLE then
				table.insert(MinionManager.Minions.Jungle, obj)
			end
		end
	end		
end

function MinionManager:DeleteObj(obj)
	if obj.isMinion then
		for _, k in pairs(MinionManager.Minions.All) do
			if k == obj then
				table.remove(MinionManager.Minions.All, _)
			end
		end
		
		if obj.team == MINION_ENEMY then
			for _, k in pairs(MinionManager.Minions.Enemy) do
				if k == obj then
					table.remove(MinionManager.Minions.Enemy, _)
				end
			end
		elseif obj.team == MINION_JUNGLE then
			for _, k in pairs(MinionManager.Minions.Jungle, _) do
				if k == obj then
					table.remove(MinionManager.Minions.Jungle, _)
				end
			end
		elseif obj.team == MINION_ALLY then
			for _, k in pairs(MinionManager.Minions.Ally) do
				if k == obj then
					table.remove(MinionManager.Minions.Ally, _)
				end
			end
		end		
	end	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

function Mode()
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

function MinAround(pos, range)
	local C = 0
	if pos == nil then return 0 end
	for _, M in pairs(MinionManager.Minions.Enemy) do
		if pos and range then
			if ValidTarget(M) and GetDistance(M.pos, pos) then
			    C = C + 1
		    end
		end
	end
	return C
end

function KillMinAround(spell, pos, range)
	local C = 0
	if pos == nil then return 0 end
	for _, M in pairs(MinionManager.Minions.Enemy) do
		if spell and pos and range then
			if ValidTarget(M) and GetDistance(M.pos, pos) <= range and GetCurrentHP(M) < Corki:CalcDmg(spell) then
			    C = C + 1
		    end
		end
	end
	return C
end

function HitChance(m, s)
	if m["H"..S[s]]:Value() == 1 then
		return 0
	elseif m["H"..S[s]]:Value() == 2 then
		return .45
	elseif m["H"..S[s]]:Value() == 3 then
		return .7
	end
	
end

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------

Corki()
MinionManager()

print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Corki]</b></font><font color=\"#E8E8E8\"> Successfully Loaded!</font>")
print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Corki]</b></font><font color=\"#E8E8E8\"> Current Version: </font>"..LoLVer)
print("<font color=\"#1E90FF\"><b>[Shulepin]</b></font><font color=\"#8B0000\"><b>[Corki]</b></font><font color=\"#E8E8E8\"> Have Fun, </font>"..GetUser().."<font color=\"#E8E8E8\"> !</font>")

----------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------------
