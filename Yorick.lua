if myHero.charName ~= "Yorick" then return end

function ElAlerte(text)
	PrintChat("<b><font color=\"#F5D76E\">></font></b> <font color=\"#FEFEE2\"> " .. text .. "</font>")
end

if FileExist(COMMON_PATH.."\\Putin.lua") then
	require("Putin")
else
	ElAlerte("[Yorick] Downloading required lib, please wait...")
	DownloadFileAsync("https://raw.githubusercontent.com/BluePrinceEB/GoS/master/Common/Putin.lua", COMMON_PATH .. "Putin.lua", function() ElAlerte("[Yorick] Download Completed! x2 F6") return end)
	return
end

if FileExist(COMMON_PATH.."\\GPrediction.lua") then
	require("GPrediction")
else
	ElAlerte("[Yorick] Downloading required lib, please wait...")
	DownloadFileAsync("https://raw.githubusercontent.com/KeVuong/GoS/master/Common/GPrediction.lua", COMMON_PATH .. "GPrediction.lua", function() ElAlerte("[Yorick] Download Completed! x2 F6") return end)
	return
end
if FileExist(COMMON_PATH.."\\MixLib.lua") then
	require("MixLib")
else
	ElAlerte("[Yorick] Downloading required lib, please wait...")
	DownloadFileAsync("https://raw.githubusercontent.com/VTNEETS/GoS/master/MixLib.lua", COMMON_PATH .. "MixLib.lua", function() ElAlerte("[Yorick] Download Completed! x2 F6") return end)
	return
end

local Graves = {}
local Ghouls = {}

local SheenBuff = false
local SheenTick = 0

local Q = { range = 225                                                              }
local W = { range = 600 , delay = .75, radius = 75 , speed = 1200, type = "circular" }
local E = { range = 1000, delay = .5 , radius = 100, speed = 1200, type = "line"     }
local R = { range = 600 , delay = .5 , radius = 100, speed = 1800, type = "circular" }

local Config = MenuConfig("Yorick", "Yorick")
Config:SubMenu("Combo", "Combo")
Config.Combo:Boolean("Q", "Use Q", true)
Config.Combo:DropDown("QMode", "Q Mode:", 2, { "Always", "After Attack" })
Config.Combo:Boolean("Q2", "Use Q2", true)
Config.Combo:Boolean("W", "Use W", true)
Config.Combo:Boolean("E", "Use E", true)
Config.Combo:DropDown("EMode", "E Mode:", 2, { "Always", "Ghouls Check" })
Config.Combo:Boolean("R", "Use R", true)
Config.Combo:Slider("HP", "Use R if Enemy HP(%) < X", 50, 0, 100, 5)
Config:SubMenu("Harass", "Harass")
Config.Harass:Boolean("Q", "Use Q", true)
Config.Harass:Boolean("Q2", "Use Q2", true)
Config.Harass:Boolean("E", "Use E", true)
Config.Harass:Slider("Mana", "Min Mana(%) to Harass", 40, 0, 100, 5)
Config:SubMenu("LastHit", "LastHit")
Config.LastHit:Boolean("Q", "Use Q", true)
Config.LastHit:Slider("Mana", "Min Mana(%) to LastHit", 40, 0, 100, 5)
Config:SubMenu("LaneClear", "LaneClear")
Config.LaneClear:Boolean("Q", "Use Q", true)
Config.LaneClear:Slider("Mana", "Min Mana(%) to LaneClear", 40, 0, 100, 5)
Config:SubMenu("Draw", "Drawings")
Config.Draw:Boolean("Disable", "Disable All Drawings")
Config.Draw:Boolean("Q", "Draw Q Range", true)
Config.Draw:Boolean("W","Draw W Range", true)
Config.Draw:Boolean("E","Draw E Range", true)
Config.Draw:Boolean("R","Draw R Range", true)
Config:SubMenu("Skin", "Skin Changer")
Config.Skin:DropDown("select", "Select A Skin:", 1, { "Classic", "Undertaker", "Pentakill" }, function(model) HeroSkinChanger(myHero, model - 1) end, true)

function GhoulsInRange(range)
	local Count = 0
	for key, Ghoul in pairs(Ghouls) do
		if Ghoul and not Ghoul.dead and Ghoul:DistanceTo(myHero) <= range then
			Count = Count + 1
		end
	end
	return Count
end

function LastRitesDamage()
	local Q = 5 + 25 * myHero:GetSpellData(_Q).level + myHero.totalDamage * 1.4
	local Sheen = GetBaseDamage(myHero)
	local TOD   = GetBaseDamage(myHero) * 2
	local TotalDamage

	if GetItemSlot(myHero, 3057) < 1 or GetItemSlot(myHero, 3078) < 1 then
		TotalDamage = Q
	end
	if GetItemSlot(myHero, 3057) > 0 then
		TotalDamage = Q
		if SheenBuff == true then
			TotalDamage = Q + Sheen
		end
		if SheenBuff == false and SheenTick+1500 < GetTickCount() then
			TotalDamage = Q + Sheen
		end
	end
	if GetItemSlot(myHero, 3078) > 0 then
		TotalDamage = Q
		if SheenBuff == true then
			TotalDamage = Q + TOD
		end
		if SheenBuff == false and SheenTick+1500 < GetTickCount() then
			TotalDamage = Q + TOD
		end
	end
	return TotalDamage
end

OnTick(function()
	if not IsDead(myHero) then
		local target = GetCurrentTarget()

		if Mix:Mode() == "Combo" then
			if myHero:CanUseSpell(_Q) == READY then
				if Config.Combo.Q:Value() and Config.Combo.QMode:Value() == 1 then
					if myHero:GetSpellData(_Q).toggleState == 0 then
						if ValidTarget(target, Q.range) then
							CastSpell(_Q)
						end
					end
				end
				if Config.Combo.Q2:Value() then
					if myHero:GetSpellData(_Q).toggleState == 2 then
						if ValidTarget(target, 850) then
							CastSpell(_Q)
						end
					end
				end
			end
			if myHero:CanUseSpell(_W) == READY then
				if Config.Combo.W:Value() then
					if ValidTarget(target, W.range) then
						local Prediction = _G.gPred:GetPrediction(target, myHero, W, true, false)
		                                if Prediction and Prediction.HitChance >= 3 then
			                                CastSkillShot(_W, Prediction.CastPosition)
		                                end
					end
				end
			end
			if myHero:CanUseSpell(_E) == READY then
				if Config.Combo.E:Value() and ValidTarget(target, E.range) then
					if Config.Combo.EMode:Value() == 1 then
					        local Prediction = _G.gPred:GetPrediction(target, myHero, E, true, false)
		                                if Prediction and Prediction.HitChance >= 0 then
			                                CastSkillShot(_E, Prediction.CastPosition)
		                                end
					elseif Config.Combo.EMode:Value() == 2 and GhoulsInRange(E.range) > 0 then
						local Prediction = _G.gPred:GetPrediction(target, myHero, E, true, false)
		                                if Prediction and Prediction.HitChance >= 0 then
			                                CastSkillShot(_E, Prediction.CastPosition)
		                                end
					end
				end
			end
			if myHero:CanUseSpell(_R) == READY then 
				if Config.Combo.R:Value() and ValidTarget(target, R.range) then
					if GetPercentHP(target) <= Config.Combo.HP:Value() then
						CastSkillShot(_R, target)
					end
				end
			end
		elseif Mix:Mode() == "Harass" and GetPercentMP(myHero) >= Config.Harass.Mana:Value() then
			if myHero:CanUseSpell(_Q) == READY then
				if Config.Harass.Q:Value() then
					if myHero:GetSpellData(_Q).toggleState == 0 then
						if ValidTarget(target, Q.range) then
							CastSpell(_Q)
						end
					end
				end
				if Config.Harass.Q2:Value() then
					if myHero:GetSpellData(_Q).toggleState == 2 then
						if ValidTarget(target, 850) then
							CastSpell(_Q)
						end
					end
				end
			end
			if myHero:CanUseSpell(_E) == READY then
				if Config.Combo.E:Value() and ValidTarget(target, E.range) then
					local Prediction = _G.gPred:GetPrediction(target, myHero, E, true, false)
		                        if Prediction and Prediction.HitChance >= 0 then
			                        CastSkillShot(_E, Prediction.CastPosition)
		                        end
				end
			end
		elseif Mix:Mode() == "LastHit" and GetPercentMP(myHero) >= Config.LastHit.Mana:Value() then 
			for _, Minion in pairs(Minions.Enemy) do
				if myHero:CanUseSpell(_Q) == READY then
				        if Config.LastHit.Q:Value() then
					        if myHero:GetSpellData(_Q).toggleState == 0 then
						        if ValidTarget(Minion, Q.range+50) then
							        if LastRitesDamage() > Minion.health then
							        	CastSpell(_Q)
							        	Mix:ForceTarget(Minion)
							        end
						        end
					        end
				        end
			        end
			end
		elseif Mix:Mode() == "LaneClear" and GetPercentMP(myHero) >= Config.LastHit.Mana:Value() then
			for _, Minion in pairs(Minions.Enemy) do
				if myHero:CanUseSpell(_Q) == READY then
				        if Config.LaneClear.Q:Value() then
					        if myHero:GetSpellData(_Q).toggleState == 0 then
						        if ValidTarget(Minion, Q.range+50) then
							        if LastRitesDamage() > Minion.health then
							        	CastSpell(_Q)
							        	Mix:ForceTarget(Minion)
							        end
						        end
					        end
				        end
			        end
			end
			for _, Minion in pairs(Minions.Jungle) do
				if myHero:CanUseSpell(_Q) == READY then
				        if Config.LaneClear.Q:Value() then
					        if myHero:GetSpellData(_Q).toggleState == 0 then
						        if ValidTarget(Minion, Q.range+50) then
							        CastSpell(_Q)
						        end
					        end
				        end
			        end
			end
		end
	end
end)

OnCreateObj(function(Obj)
	if Obj and Obj.valid then
		if Obj.name:lower() == "yorickmarker" then
			table.insert(Graves, Obj)
		end
		if Obj.name:lower() == "yorickghoulmelee" or Obj.name:lower() == "yorickbigghoul" then
			table.insert(Ghouls, Obj)
		end
	end
end)

OnDeleteObj(function(Obj)
	for key, Grave in pairs(Graves) do
		if Grave == Obj then
			table.remove(Graves, key)
		end
	end
	for key, Ghoul in pairs(Ghouls) do
		if Ghoul == Obj then
			table.remove(Ghouls, key)
		end
	end
end)

OnUpdateBuff(function(unit, buff)
	if unit.isMe then
		if buff.Name == "sheen" then
			SheenBuff = true
		        SheenTick = 0
		end
	end
end)

OnRemoveBuff(function(unit, buff)
	if unit.isMe then
		if buff.Name == "sheen" then
			SheenBuff = false
		        SheenTick = GetTickCount()
		end
	end
end)

OnProcessSpellComplete(function(unit, spell)
	if unit.isMe then
		if spell.name:lower():find("attack") then
			if Mix:Mode() == "Combo" and Config.Combo.QMode:Value() == 2 then
				if myHero:CanUseSpell(_Q) == READY and Config.Combo.Q:Value() then
					CastSpell(_Q)
				end
			end
		end
	end
end)

OnSpellCast(function(spell)
	if spell.spellID == _Q and myHero:GetSpellData(_Q).toggleState == 0 then
		Mix:ResetAA()
	end
end)

OnDraw(function()
	if Config.Draw.Disable:Value() or myHero.dead then return end

	if myHero:CanUseSpell(_Q) == READY and Config.Draw.Q:Value() then
		DrawCircle(GetOrigin(myHero), Q.range, 1, 1, GoS.Red)
	end
        if myHero:CanUseSpell(_W) == READY and Config.Draw.W:Value() then
        	DrawCircle(GetOrigin(myHero), W.range, 1, 1, GoS.Cyan)
        end
        if myHero:CanUseSpell(_E) == READY and Config.Draw.E:Value() then
        	DrawCircle(GetOrigin(myHero), E.range, 1, 1, GoS.White)
        end
        if myHero:CanUseSpell(_R) == READY and Config.Draw.R:Value() then
        	DrawCircle(GetOrigin(myHero), R.range, 1, 1, GoS.Green)
        end

end)
