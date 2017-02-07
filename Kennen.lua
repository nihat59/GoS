PrintChat(string.format("<font color='#f580f5'>Electric Ninja - Kennen:</font>"))

if GetObjectName(GetMyHero()) ~= "Kennen" then return end

require'DamageLib'
require 'OpenPredict'

--local QShuriken = { name = "KennenShurikenHurlMissile1", speed = 1700, delay = 0.180, range = 1050, width = 70, collision = true, aoe = false, type = "linear"}
--QShuriken.pred = IPrediction.Prediction(QShuriken)

Kennen = Menu("Kennen", "Kennen")
Kennen:Menu("Combo", "Combo")
--------------------------------------------------------------
Kennen.Combo:Key("Q", "SkillShot Q", string.byte(" "));
--------------------------------------------------------------
Kennen.Combo:Boolean("W", "Auto stun if mark 2", true)
--------------------------------------------------------------
Kennen.Combo:Boolean("R1", "Slicing Maelstrom on/off", true)
Kennen.Combo:Key("EE", "Use E + R # of enemies", string.byte("T"));
Kennen.Combo:Slider("R2", "Use R number enemies", 2, 0, 5, 1)

Kennen:Menu("Harass", "Harass")
Kennen.Harass:Key("Q", "SkillShot Q", string.byte("C"));
Kennen.Harass:Key("W", "use W",  string.byte("C"));

Kennen:Menu("Mana", "stop when enegry %")
Kennen.Mana:Slider("QEnergy", "Combo Q Energy", 65, 1, 100, 1)
Kennen.Mana:Slider("QeLC", "LaneClear Q Energy", 65, 1, 100, 1)

Kennen:Menu("Farm", "Minion/Jungle")
Kennen.Farm:Boolean("Q", "Last Hit with Q", true)
Kennen.Farm:Boolean("QLC", "Lane Clear Q", true) 

Kennen:Menu("Killable", "Auto Killsteal")
Kennen.Killable:Boolean("Q", "Kill with Q", true)
Kennen.Killable:Boolean("W", "Kill with W", false)

Kennen:Menu("Drawings", "Kennen Drawings")
Kennen.Drawings:Boolean("Q", "Draw Q Range", false)

Kennen:Menu("Escape", "Escape")
Kennen.Escape:KeyBinding("EE1", "Use Escape", string.byte("E"));

local KennenQ = { delay = 0.16, speed = 1650, width = 65, range = 1060}

OnTick(function(myHero)
if IsDead(myHero) then return end
CastQ()
CastW()
HarassQ()
HarassW()
KillSteal()
KillSteal2()
CastR()
Escape()
LaneClear()
LastHit()
end)

function CastQ()
local targetQ = GetCurrentTarget()
if IOW:Mode() == "Combo" and Kennen.Combo.Q:Value() then
	if Ready(_Q) and ValidTarget(targetQ, GetCastRange(myHero,_Q)) and GetPercentMP(myHero) >= Kennen.Mana.QEnergy:Value() then
		local Q = GetPrediction(targetQ, KennenQ)
		if Q and Q.hitChance >= 0.16 and not Q:mCollision(1) then
			myHero:CastSpell(_Q, Q.castPos)end
		end
	end
end

function CastW()
local targetW = GetCurrentTarget()
if IOW:Mode() == "Combo" and Kennen.Combo.W:Value() then
	if Ready(_W) and ValidTarget(targetW, GetCastRange(myHero,_W)) then 
	if GotBuff(targetW, "kennenmarkofstorm") == 2 then
		CastTargetSpell(targetW, _W)end
		end
	end
end

function HarassQ()
local targetQ = GetCurrentTarget()
if IOW:Mode() == "Harass" and Kennen.Harass.Q:Value() then
	if Ready(_Q) and ValidTarget(targetQ, GetCastRange(myHero,_Q)) then
	local Q = GetPrediction(targetQ, KennenQ)
		if Q and Q.hitChance >= 0.16 and not Q:mCollision(1) then
		myHero:CastSpell(_Q, Q.castPos)end
		end
	end
end

function HarassW()
local targetW = GetCurrentTarget()
if IOW:Mode() == "Harass" and Kennen.Harass.W:Value() then
	if ValidTarget(targetW, GetCastRange(myHero,_W)) and Ready(_W) then 
		CastTargetSpell(targetW, _W)end
	end
end

--GetCurrentHP(minion) < CalcDamage(myHero, minion, 0, 45 + 35*GetCastLevel(myHero,_Q) + 0.75*GetBonusAP(myHero))
function LastHit()
if IOW:Mode() == "LastHit" then
for _,minion in pairs (minionManager.objects) do
	if GetTeam(minion) ~= MINION_ALLY then
		if ValidTarget(minion, GetCastRange(myHero,_Q)) and GetHP(minion) < getdmg("Q",minion) then
			if IsReady(_Q) then 
				CastSkillShot(_Q, GetOrigin(minion))end
				end
			end
		end
	end
end

function LaneClear()
if IOW:Mode() == "LaneClear" then
	for _,minion in pairs (minionManager.objects) do
		if GetTeam(minion) ~= MINION_ALLY then
			if ValidTarget(minion, GetCastRange(myHero,_Q)) and Kennen.Farm.QLC:Value() then
				if Ready(_Q) and GetPercentMP(myHero) >= Kennen.Mana.QeLC:Value() then
				CastSkillShot(_Q, GetOrigin(minion))end
				end
			end
		end
	end
end

function KillSteal()
if Kennen.Killable.Q:Value() then
	for _, target in pairs(GetEnemyHeroes()) do
		if Ready(_Q) and ValidTarget(target, GetCastRange(myHero,_Q)) and GetCurrentHP(target) <= getdmg("Q", target) then
			local Q = GetPrediction(target, KennenQ)
			if Q and Q.hitChance >= 0.16 then
			myHero:CastSpell(_Q, Q.castPos)end
			end
		end
	end
end

function KillSteal2()
if Kennen.Killable.W:Value() then
	for _, target in pairs(GetEnemyHeroes()) do
		if ValidTarget(target, GetCastRange(myHero,_W)) and Ready(_W) and GetCurrentHP(target) <= getdmg("W", target) then
			CastTargetSpell(target, _W)end
		end
	end
end

function CastR()
for _, target in pairs(GetEnemyHeroes()) do
	if Ready(_R) and GetDistance(myHero, target) <= 550 and Kennen.Combo.R1:Value() then
		if EnemiesAround(GetOrigin(target), 550) >= Kennen.Combo.R2:Value() and Kennen.Combo.EE:Value() and GotBuff(myHero, "KennenLightningRush") == 1 then
			target:Cast(_R, GetOrigin(target))end
		end
	end
end

function Escape()
if (Kennen.Combo.EE:Value() or Kennen.Escape.EE1:Value() ) then
if IsReady(_E)  and GotBuff(myHero, "kennenlightningrushbuff") == 0 then
    myHero:Cast(_E, myHero)
else
MoveToXYZ(GetMousePos())
    end
end
end

OnDraw(function(myHero)
if Kennen.Drawings.Q:Value() then DrawCircle(myHeroPos().x,myHeroPos().y,myHeroPos().z,GetCastRange(myHero,_Q),1,200,0xffff00ff) end
end)
