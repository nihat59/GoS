if GetObjectName(GetMyHero()) ~= "Kayle" then return end
--
local UK_Print = function(text) PrintChat(string.format("<font color=\"#1E90FF\"><b>[UselessKayle]:</b></font><font color=\"#FFFFFF\"> %s</font>", tostring(text))) end
--
--AutoUpdate
local ver = "0.01"

function AutoUpdate(data)
    if GetUser() ~= "rektgiver24" and tonumber(data) > tonumber(ver) then
        UK_Print("New version found! " .. data)
        UK_Print("Downloading update, please wait...")
        DownloadFileAsync("https://raw.githubusercontent.com/rektgiver24/GoS/master/UselessKayle.lua", SCRIPT_PATH .. "UselessKayle.lua", function() UK_Print("Update Complete, please 2x F6!") return end)
    else
        DelayAction(function()UK_Print("Version "..ver.." Loaded!Have fun!")end,1)
    end
end

GetWebResultAsync("https://raw.githubusercontent.com/rektgiver24/GoS/master/UselessKayle.version", AutoUpdate)
--
require ("DamageLib")
require ("OpenPredict")

if FileExist(COMMON_PATH.."MixLib.lua") then
 require('MixLib')
else
 UK_Print("MixLib not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/NEET-Scripts/master/MixLib.lua", COMMON_PATH.."MixLib.lua", function() UK_Print("Downloaded MixLib. Please 2x F6!") return end)
end

if FileExist(COMMON_PATH.."DeathPredictor.lua") then
 require('DeathPredictor')
else
 UK_Print("DeathPredictor not found. Please wait for download.")
 DownloadFileAsync("https://raw.githubusercontent.com/rektgiver24/GoS/master/DeathPredictor.lua", COMMON_PATH .. "DeathPredictor.lua", function() UK_Print("Updated DeathPredictor!Please press F6 twice to reload.") return end)
end
--MENU
local KayleMenu = Menu("Kayle", "Kayle")
KayleMenu:SubMenu("Combo", "Combo")
KayleMenu.Combo:Boolean("CQ","Use Q",true)--
KayleMenu.Combo:Boolean("CE","Use E",true)--

KayleMenu:SubMenu("DeathPredictor", "DeathPredictor")
KayleMenu.DeathPredictor:Boolean("AD","AvoidDeath",true)--
KayleMenu.DeathPredictor:Info("infox6","*Alpha Version!!")
KayleMenu.DeathPredictor:Info("info-","-----------------")
KayleMenu.DeathPredictor:Info("info3","This will turn off:")
KayleMenu.DeathPredictor:Info("info4","^The simple AutoUlt@%HP")
KayleMenu.DeathPredictor.AD.callback = function ()
	if KayleMenu.DeathPredictor.AD:Value() then
		KayleMenu.Misc.MAU:Value(false)
	end
end

KayleMenu:SubMenu("Misc", "Misc")
KayleMenu.Misc:Boolean("MAHAU","AutoHeal After Ult",true)--
KayleMenu.Misc:Boolean("MAH","AutoHeal",true)--
KayleMenu.Misc:Slider("MAHP", "AutoHeal Under %HP",20,5,70,5)--
KayleMenu.Misc:Boolean("MAU","AutoUlt",false)--
KayleMenu.Misc:Slider("MAUP", "AutoUlt Under %HP",10,5,70,5)--
KayleMenu.Misc:Info("info","^This Will turn off:")
KayleMenu.Misc:Info("info2","^DeathPredictor!!")
KayleMenu.Misc.MAU.callback = function ()
	if KayleMenu.Misc.MAU:Value() then
		KayleMenu.DeathPredictor.AD:Value(false)
	end
end

KayleMenu:SubMenu("GC", "GapClose")
KayleMenu.GC:Boolean("GCQ","Use Q",true)--

KayleMenu:SubMenu("KS", "KillSecure")
KayleMenu.KS:Boolean("KSQ","Use Q",true)--

KayleMenu:SubMenu("Draw", "Draw")
KayleMenu.Draw:Boolean("DUT","Ultimate Time",true)--
KayleMenu.Draw:Boolean("DHA","Heal Ammount",true)--
KayleMenu.Draw:Boolean("DHI","Heal Indicator OHB", true)--
KayleMenu.Draw:Boolean("DAHI","AutoHeal Indicator OHB", true)--
KayleMenu.Draw:Boolean("DUI","Ultimate Indicator OHB", false)--
KayleMenu.Draw:ColorPick("wcolor", "Heal Color", {255,0,255,0})--
KayleMenu.Draw:ColorPick("awcolor", "AutoHeal Color", {255,0,0,255})--
KayleMenu.Draw:ColorPick("rcolor", "Ultimate Color", {255,255,0,0})--
KayleMenu.Draw:Info("Info","OHB=OverHpBar")--
KayleMenu.Draw.DAHI.callback = function ()
	if KayleMenu.Draw.DAHI:Value() then
		KayleMenu.Draw.DUI:Value(false)
	end
end
KayleMenu.Draw.DUI.callback = function ()
	if KayleMenu.Draw.DUI:Value() then
		KayleMenu.Draw.DAHI:Value(false)
	end
end

KayleMenu:SubMenu("SkinChanger", "SkinChanger")--
local skinList = {["Kayle"] = {"Classic", "Silver", "Viridian", "Unmasked", "Battleborn", "Judgment", "Aether Wing", "Riot", "Iron Inquisitor"}}
KayleMenu.SkinChanger:DropDown('skin', "Kayle Skins", 1, skinList[myHero.charName], HeroSkinChanger, true)
KayleMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) UK_Print(skinList[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end
--Funcs
function round(num, idp)
  local mult = 10^(idp or 0)
  return math.floor(num * mult + 0.5) / mult
end
function calcHPToUlt()
	local HP = GetMaxHP(myHero)*(KayleMenu.Misc.MAUP:Value()*0.01)
	return HP
end
function calcHPToHeal()
	local HP = GetMaxHP(myHero)*(KayleMenu.Misc.MAHP:Value()*0.01)
	return HP
end
function calcWHealing()
	heal=((15+(GetCastLevel(myHero, _W)*45))+(myHero.ap*0.45))
	return heal
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
function IsFacing(unit)
	if ValidTarget(unit, 840) then
		if AngleBetween(Vector(GetDirection(unit)), Vector(myHero)-Vector(unit)) < 90 and AngleBetween(Vector(GetDirection(myHero)), Vector(unit)-Vector(myHero)) < 70 then
  			return true
  		else
			return false
		end
	end
end
--
local UltOn=false
local stopTime=GetGameTimer()-1
local currentTime=stopTime-GetGameTimer()
--
OnDraw(function ()
	if Ready(_R) and KayleMenu.Misc.MAU:Value() and KayleMenu.Draw.DUI:Value() then
		myHero:DrawDmg(calcHPToUlt(), KayleMenu.Draw.rcolor:Value(), calcHPToUlt()+10)
	end
	if Ready(_W) and KayleMenu.Misc.MAH:Value() and KayleMenu.Draw.DAHI:Value() then
		myHero:DrawDmg(calcHPToHeal(), KayleMenu.Draw.awcolor:Value(), calcHPToHeal()+10)
	end
	if Ready(_W) and KayleMenu.Draw.DHI:Value() and (GetCurrentHP(myHero)+calcWHealing() <= GetMaxHP(myHero)) then
		myHero:DrawDmg(calcWHealing(), KayleMenu.Draw.wcolor:Value(), GetCurrentHP(myHero)+calcWHealing())
	end
	if currentTime >= 0 and KayleMenu.Draw.DUT:Value() then
		DrawText(round(currentTime,1),30,myHero.pos2D.x,myHero.pos2D.y+20,FF)
	end
	if KayleMenu.Draw.DHA:Value() and Ready(_W) then
		DrawText("Heal= "..round(calcWHealing()),20,myHero.pos2D.x,myHero.pos2D.y,GG)
	end
end)
--
OnTick(function()
	--
	local target = GetCurrentTarget()
	currentTime=stopTime-GetGameTimer()
	--
	if KayleMenu.DeathPredictor.AD:Value() then
		if DeathIsComing() and not UltOn then
			if GetIncomingDamage()<GetCurrentHP(myHero)+calcWHealing() and Ready(_W) then
				CastTargetSpell(myHero, _W)
			elseif Ready(_R) then
				CastTargetSpell(myHero, _R)
			end
		end
	end
	if KayleMenu.Misc.MAH:Value() and Ready(_W) then
		if GetCurrentHP(myHero) < calcHPToHeal() then
			CastTargetSpell(myHero, _W)
		end
	end
	if KayleMenu.Misc.MAU:Value() and Ready(_R) then
		if GetCurrentHP(myHero) < calcHPToUlt() then
			CastTargetSpell(myHero, _R)
		end
	end
	if Mix:Mode() == "Combo" then
		if ValidTarget(target, 500) and KayleMenu.Combo.CE:Value() and Ready(_E) then
			CastSpell(_E)
		end
		if ValidTarget(target, 650) and KayleMenu.Combo.CQ:Value() and Ready(_Q) then
			CastTargetSpell(target, _Q)
		end
		if KayleMenu.GC.GCQ:Value() and ValidTarget(target, 650) and not ValidTarget(target,250) and not IsFacing(target) then
			CastTargetSpell(target, _Q)
		end
	end
	if KayleMenu.KS.KSQ:Value() then
		for _, enemy in pairs(GetEnemyHeroes()) do
			if (GetCurrentHP(enemy) <= getdmg("Q",enemy)) and ValidTarget(enemy, 650) then
				CastTargetSpell(target, _Q)
			end 
		end
	end
end)
--
OnProcessSpell(function(unit,spell)
	if unit.isMe and spell.name == GetCastName(myHero, _R) then
		UltOn=true
		stopTime=GetGameTimer()+(1.5+(GetCastLevel(myHero, _R)*0.5))
	end
end)
--
OnRemoveBuff(function(unit,buff)
	if unit.isMe and buff.Name:lower():find("judicatorintervention") then
		UltOn=false
		if KayleMenu.Misc.MAHAU:Value() then
		 	CastTargetSpell(myHero,_W)
		end 
	end
end)
