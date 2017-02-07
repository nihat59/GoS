if GetObjectName(GetMyHero()) ~= "Tryndamere" then return end
--
local UT_Print = function(text) PrintChat(string.format("<font color=\"#1E90FF\"><b>[UselessTryndamere]:</b></font><font color=\"#FFFFFF\"> %s</font>", tostring(text))) end
--AutoUpdate
local ver = "0.02"

function AutoUpdate(data)
    if GetUser() ~= "rektgiver24" and tonumber(data) > tonumber(ver) then
        UT_Print("New version found! " .. data)
        UT_Print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/rektgiver24/GoS/master/UselessTryndamere.lua", SCRIPT_PATH .. "UselessTryndamere.lua", function() UT_Print("Update Complete, please 2x F6!") return end)
    else
        DelayAction(function()UT_Print("Version "..ver.." Loaded!Have fun!")end,1)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/rektgiver24/GoS/master/UselessTryndamere.version", AutoUpdate)
--
require ("DamageLib")
require ("OpenPredict")

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 UT_Print("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() UT_Print("Downloaded MixLib. Please 2x F6!") return end)
end

if FileExist(COMMON_PATH.."DeathPredictor.lua") then
 require('DeathPredictor')
else
 UT_Print("DeathPredictor not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/rektgiver24/GoS/master/DeathPredictor.lua", COMMON_PATH .. "DeathPredictor.lua", function() UT_Print("Updated DeathPredictor!Please press F6 twice to reload.") return end)
end
--MENU
local TryndamereMenu = Menu("Tryndamere", "Tryndamere")
TryndamereMenu:SubMenu("Combo", "Combo")
TryndamereMenu.Combo:Boolean("CW", "Use W To Reduce AD", true)--

TryndamereMenu:SubMenu("Ultimate", "Ultimate")
TryndamereMenu.Ultimate:Boolean("UA", "AutoUlt", true)--
TryndamereMenu.Ultimate:Slider("UAP", "AutoUlt under %HP",15,5,70,5)--
TryndamereMenu.Ultimate:Info("info","This will turn off:")
TryndamereMenu.Ultimate:Info("info","^DeathPrediction!!")
TryndamereMenu.Ultimate.UA.callback = function ()
	if TryndamereMenu.Ultimate.UA:Value() then
		TryndamereMenu.DP.DPA:Value(false)
	end
end

TryndamereMenu:SubMenu("DP", "DeathPredictor")
TryndamereMenu.DP:Boolean("DPA", "AvoidDeath", false)
TryndamereMenu.DP:Info("infox6","*Alpha Version!!")
TryndamereMenu.DP:Info("info-","-----------------")
TryndamereMenu.DP:Info("info3","This will turn off:")
TryndamereMenu.DP:Info("info4","^The simple AutoUlt@%HP")
TryndamereMenu.DP:Info("info5","^The simple AutoHeal@15%HP")
TryndamereMenu.DP.DPA.callback = function ()
	if TryndamereMenu.DP.DPA:Value() then
		TryndamereMenu.Ultimate.UA:Value(false)
		TryndamereMenu.Misc.MAG:Value(false)
	end
end

TryndamereMenu:SubMenu("KillSecure", "KillSecure")
TryndamereMenu.KillSecure:Boolean("KSE", "KillSecure with E", true)--

TryndamereMenu:SubMenu("Misc", "Misc")
TryndamereMenu.Misc:Boolean("MBQ", "Block Q while in Ult", true)--
TryndamereMenu.Misc:Boolean("MAH", "AutoHeal After Ult", true)--
TryndamereMenu.Misc:Boolean("MAG", "AutoHeal Under 15%Hp", true)--
TryndamereMenu.Misc:Info("info3","^This will turn off:")
TryndamereMenu.Misc:Info("info4","^DeathPrediction!!")
TryndamereMenu.Misc.MAG.callback = function ()
	if TryndamereMenu.Misc.MAG:Value() then
		TryndamereMenu.DP.DPA:Value(false)
	end
end

TryndamereMenu:SubMenu("GC", "GapClose")
TryndamereMenu.GC:Boolean("GCW", "Use W To Slow", true)--
TryndamereMenu.GC:Boolean("GCE", "Use E", true)--

TryndamereMenu:SubMenu("Draw", "Draw")
TryndamereMenu.Draw:Boolean("DT", "Ultimate Time", true)--
TryndamereMenu.Draw:Boolean("DQ", "Q Heal Ammount", true)--
TryndamereMenu.Draw:Boolean("DUI", "Ultimate Indicator OHB", true)--
TryndamereMenu.Draw:Boolean("DHI", "Heal Indicator OHB", true)--
TryndamereMenu.Draw:ColorPick("qcolor", "Q Color", {255,0,255,0})--
TryndamereMenu.Draw:ColorPick("rcolor", "Ultimate Color", {255,255,0,0})--
TryndamereMenu.Draw:Info("Info","OHB=OverHpBar")--

TryndamereMenu:SubMenu("SkinChanger", "SkinChanger")--
local skinList = {["Tryndamere"] = {"Classic", "Highland", "King", "Viking", "DemonBlade", "Sultan", "Warring Kingdoms", "Nightmare", "Beast Hunter"}}
TryndamereMenu.SkinChanger:DropDown('skin', "Tryndamere Skins", 1, skinList[myHero.charName], HeroSkinChanger, true)
TryndamereMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) UT_Print(skinList[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end
--Methods
function IsFacing(unit)--By Salami
	if ValidTarget(unit, 840) then
		if AngleBetween(Vector(GetDirection(unit)), Vector(myHero)-Vector(unit)) < 90 and AngleBetween(Vector(GetDirection(myHero)), Vector(unit)-Vector(myHero)) < 70 then
  			return true
  		else
			return false
		end
	end
end
function AngleBetween(p1, p2)
  local theta = p1:polar() - p2:polar()
  if theta < 0 then
    theta = theta + 360
  end
  if theta > 180 then
    theta = 360 - theta
  end
  return theta
end
function calcHP()
	local HP = GetMaxHP(myHero)*(TryndamereMenu.Ultimate.UAP:Value()*0.01)
	return HP
end
function calcQHealing()
	heal=((20+(GetCastLevel(myHero, _Q)*10))+(myHero.ap*0.3))+((0.05+(GetCastLevel(myHero, _Q)*0.45)+(myHero.ap*0.12))*GetCurrentMana(myHero))
	return heal
end
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
--
local UltOn=false
local stopTime=GetGameTimer()-1
local currentTime=stopTime-GetGameTimer()
local EData = {delay = 0.050, range = 660, radius = 225, speed = 1300}
--
OnDraw(function ()
	if Ready(_R) and TryndamereMenu.Ultimate.UA:Value() and TryndamereMenu.Draw.DUI:Value() then
		myHero:DrawDmg(calcHP(), TryndamereMenu.Draw.rcolor:Value(), calcHP()+10)
	end
	if Ready(_Q) and TryndamereMenu.Draw.DHI:Value() and (GetCurrentHP(myHero)+calcQHealing() <= GetMaxHP(myHero)) then
		myHero:DrawDmg(calcQHealing(), TryndamereMenu.Draw.qcolor:Value(), GetCurrentHP(myHero)+calcQHealing())
	end
	if currentTime >= 0 and TryndamereMenu.Draw.DT:Value() then
		DrawText(round(currentTime,1),30,myHero.pos2D.x,myHero.pos2D.y+20,FF)
	end
	if TryndamereMenu.Draw.DQ:Value() and Ready(_Q) then
		DrawText("Q Heal= "..round(calcQHealing()),20,myHero.pos2D.x,myHero.pos2D.y,GG)
	end
end)
--
OnTick(function ()
--Helps
local target = GetCurrentTarget()
currentTime=stopTime-GetGameTimer()
local pE = GetPrediction(target,EData)
--
	if TryndamereMenu.DP.DPA:Value() and DeathIsComing() and Ready(_R) and not UltOn then
		CastSpell(_R)
	elseif TryndamereMenu.DP.DPA:Value() and (GetCurrentHP(myHero) < GetIncomingDamage()) and IsObjectAlive(myHero) and not Ready(_R) and not UltOn and ((calcQHealing()+GetCurrentHP(myHero)) > GetIncomingDamage()) then
		CastSpell(_Q)
	end
	if TryndamereMenu.Ultimate.UA:Value() and Ready(_R) and not UltOn then
		if GetCurrentHP(myHero) <= calcHP() then
			CastSpell(_R)
		end
	elseif TryndamereMenu.Misc.MAG:Value() and Ready(_Q) and not UltOn and not Ready(_R) and GetCurrentMana(myHero) == 100 then
		if GetCurrentHP(myHero) <= (GetMaxHP(myHero)*0.15) then
			CastSpell(_Q)
		end
	end
	if Mix:Mode() == "Combo" then
		if TryndamereMenu.Combo.CW:Value() and Ready(_W) and ValidTarget(target,GetRange(myHero)+50) then
			if IsFacing(target) then
				CastSpell(_W)
			end
		end
		if TryndamereMenu.GC.GCW:Value() and Ready(_W) and not ValidTarget(target,GetRange(myHero)+50) and ValidTarget(target,800) then
			if not IsFacing(target) then
				CastSpell(_W)
			end
		end
		if TryndamereMenu.GC.GCE:Value() and Ready(_E) then
			if ValidTarget(target, 660) and not ValidTarget(target, GetRange(myHero)+200) and pE and pE.hitChance >= 0.25 then
				CastSkillShot(_E, pE.castPos)
			end
		end
	end
	if TryndamereMenu.KillSecure.KSE:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if (GetCurrentHP(enemy)-30 <= getdmg("E",enemy)) and ValidTarget(enemy, 650) and pE and pE.hitChance >= 0.25 then
				CastSkillShot(_E, pE.castPos)
			end 
		end
	end
end)
OnSpellCast(function(spell)
	if (spell["spellID"] == 0) and UltOn and TryndamereMenu.Misc.MBQ:Value() then
		BlockCast()
	end
end)
OnProcessSpell(function(unit,spell)
	if unit.isMe and spell.name == GetCastName(myHero, _R) then
		UltOn=true
		stopTime=GetGameTimer()+5
	end
end)
--[[OnUpdateBuff(function(unit,buff) 
	if unit.isMe and buff.Name:lower():find("undyingrage") then
		UltOn=true
		stopTime=GetGameTimer()+5
	end
end)]]
OnRemoveBuff(function(unit,buff)
	if unit.isMe and buff.Name:lower():find("undyingrage") then
		UltOn=false
		if TryndamereMenu.Misc.MAH:Value() then
		 	CastSpell(_Q)
		end 
	end
end)

