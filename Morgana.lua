if GetObjectName(myHero) ~= "Morgana" then return end



local MorgQ = {delay = 0.25, speed = 1200, width = 80, range = 1300}

local MorgW = {delay = 0.01, speed = 1200, width = 279, range = 1300}

local Move = {delay = 0.5, speed = math.huge, width = 50, range = math.huge}


require("OpenPredict")

require("DamageLib")

local MorganaMenu = Menu("Morgana", "Morgana")
MorganaMenu:SubMenu("Combo", "Combo")
MorganaMenu.Combo:Boolean("QComb", "Use Q", true)
MorganaMenu.Combo:Boolean("WComb", "Use W", true)
MorganaMenu.Combo:Boolean("RComb", "Use R", true)
MorganaMenu.Combo:Slider("MinMana", "Min Mana To Combo",50,0,100,1)

MorganaMenu:SubMenu("Harass", "Harass", true)
MorganaMenu.Harass:Boolean("WHarass", "Use W", true)
MorganaMenu.Harass:Boolean("QHarass", "Use Q", true)
MorganaMenu.Harass:Slider("MinManaHarass", "Min Mana To Harass",50,0,100,1)

MorganaMenu:SubMenu("LaneClear", "LaneClear", true)
MorganaMenu.LaneClear:Boolean("Wlc", "Use W", true)
MorganaMenu.LaneClear:Slider("MinManaLC", "Min Mana To LaneClear",50,0,100,1)

MorganaMenu:SubMenu("Misc", "Misc")
MorganaMenu.Misc:Boolean("UltX", "Auto R on X Enemies", true)
MorganaMenu.Misc:Slider("EnemieR", "Min Enemies to Auto R",3,1,6,1)
MorganaMenu.Misc:Boolean("Lvlup", "Use Auto Level", true)
MorganaMenu.Misc:Boolean("Ig", "Use Auto Ignite", true)

MorganaMenu:SubMenu("AutoE", "Auto E for cc")
MorganaMenu.AutoE:Boolean("CC", "Use E on CC", true)

MorganaMenu:SubMenu("Prediction", "Prediction Settings")
MorganaMenu.Prediction:Slider("Q", "Hit-Chance: Q" , 30, 0, 99,1)
MorganaMenu.Prediction:Slider("W", "Hit-Chance: W" , 30, 0, 99,1)

MorganaMenu:SubMenu("SkinChanger", "SkinChanger")

local skinMeta = {["Morgana"] = {"Classic", "Blade-Mistress", "Blackthorn", "Ghost-Bridge", "Exiled", "Sinful-Succulence", "Lumar-Wraith", "Bewitchintg", "Victorious"}}
MorganaMenu.SkinChanger:DropDown('skin', myHero.charName.. " Skins", 1, skinMeta[myHero.charName], HeroSkinChanger, true)
MorganaMenu.SkinChanger.skin.callback = function(model) HeroSkinChanger(myHero, model - 1) print(skinMeta[myHero.charName][model] .." ".. myHero.charName .. " Loaded!") end

MorganaMenu:SubMenu("Draw", "Drawings")
MorganaMenu.Draw:Boolean("DrawQ", "Draw Q Range", true)
MorganaMenu.Draw:Boolean("DrawW", "Draw W Range", true)
MorganaMenu.Draw:Boolean("DrawE", "Draw E Range", true)
MorganaMenu.Draw:Boolean("DrawR", "Draw R Range", true)



local CC = {
-- Aatrox
["AatroxQ"] 					= 	{ slot = _Q , champName = "Aatrox"				, spellType = "circular" 	, projectileSpeed = 2000		, spellDelay = 600	, spellRange = 650		, spellRadius = 285		, collision = false	}, 
["AatroxE"] 					= 	{ slot = _E , champName = "Aatrox"				, spellType = "line" 		, projectileSpeed = 1250		, spellDelay = 250	, spellRange = 1075		, spellRadius = 100		, collision = false	, projectileName = "AatroxBladeofTorment_mis.troy"}, 
-- Ahri
["AhriSeduce"] 					= 	{ slot = _E , champName = "Ahri"				, spellType = "line" 	 	, projectileSpeed = 1550		, spellDelay = 250	, spellRange = 1000		, spellRadius = 60		, collision = true	, projectileName = "Ahri_Charm_mis.troy"}, 
-- Alistar
["Pulverize"] 					= 	{ slot = _Q , champName = "Alistar"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 365		, spellRadius = 365		, collision = false	},
["Headbutt"] 					= 	{ slot = _W , champName = "Alistar"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 50	, spellRange = 800		, spellRadius = 50		, collision = false	},
-- Amumu
["BandageToss"] 				= 	{ slot = _Q , champName = "Amumu"				, spellType = "line" 	 	, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 1100		, spellRadius = 80		, collision = true	, projectileName = "Bandage_beam.troy"}, 
["CurseoftheSadMummy"] 			= 	{ slot = _R , champName = "Amumu"				, spellType = "aoe" 	 	, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 560		, spellRadius = 560		, collision = false	},
-- Anivia
["FlashFrostSpell"] 			= 	{ slot = _Q , champName = "Anivia"				, spellType = "line" 	 	, projectileSpeed = 850			, spellDelay = 250	, spellRange = 1250		, spellRadius = 110		, collision = false	, projectileName = "cryo_FlashFrost_mis.troy"}, 
-- Ashe
["EnchantedCrystalArrow"] 		= 	{ slot = _R , champName = "Ashe"				, spellType = "line" 	 	, projectileSpeed = 1600		, spellDelay = 250	, spellRange = 20000	, spellRadius = 130		, collision = false	, projectileName = "EnchantedCrystalArrow_mis.troy"},
-- Bard
["BardQ"] 						= 	{ slot = _Q , champName = "Bard"				, spellType = "line" 	 	, projectileSpeed = 1600		, spellDelay = 250	, spellRange = 950		, spellRadius = 60		, collision = true	, projectileName = "Bard_Base_Q_Missile_mis.troy"},
-- Blitzcrank
["RocketGrab"] 					= 	{ slot = _Q , champName = "Blitzcrank"			, spellType = "line" 	 	, projectileSpeed = 1800		, spellDelay = 250	, spellRange = 1050		, spellRadius = 70		, collision = true	, projectileName = "FistGrab_mis.troy"},
["PowerFistAttack"] 			= 	{ slot = _E , champName = "Blitzcrank"			, spellType = "target" 	 	, projectileSpeed = math.huge	, spellDelay = 50	, spellRange = 500		, spellRadius = 70		, collision = false	},
-- Braum
["BraumQ"] 						= 	{ slot = _Q , champName = "Braum"				, spellType = "line" 	 	, projectileSpeed = 1200		, spellDelay = 250	, spellRange = 1000		, spellRadius = 100		, collision = true	, projectileName = ""},
["BraumRWrapper"] 				= 	{ slot = _R , champName = "Braum"				, spellType = "line" 	 	, projectileSpeed = 1125		, spellDelay = 500	, spellRange = 1250		, spellRadius = 100		, collision = false	, projectileName = ""},
-- Cassiopeia
["CassiopeiaPetrifyingGaze"]	= 	{ slot = _R , champName = "Cassiopeia"			, spellType = "line" 	 	, projectileSpeed = math.huge	, spellDelay = 500	, spellRange = 825		, spellRadius = 150		, collision = false	, projectileName = ""},
-- Chogath
["Rupture"] 					= 	{ slot = _Q , champName = "Chogath"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 1200	, spellRange = 950		, spellRadius = 250		, collision = false },
-- Darius
["DariusAxeGrabCone"] 			= 	{ slot = _E , champName = "Darius"				, spellType = "line" 		, projectileSpeed = math.huge	, spellDelay = 320	, spellRange = 570		, spellRadius = 150		, collision = false , projectileName = ""},
-- Diana
["DianaVortex"] 				= 	{ slot = _E , champName = "Diana"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 350		, spellRadius = 350		, collision = false	},
-- DrMundo
["InfectedCleaverMissileCast"] 	= 	{ slot = _Q , champName = "DrMundo"				, spellType = "line" 		, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 1050		, spellRadius = 60		, collision = true	, projectileName = "DrMundo_Base_Q_mis.troy"},
-- Draven
["DravenDoubleShot"] 			= 	{ slot = _E , champName = "Draven"				, spellType = "line" 		, projectileSpeed = 1400		, spellDelay = 250	, spellRange = 1100		, spellRadius = 130		, collision = false	, projectileName = "Draven_E_mis.troy"},
-- Elise
["EliseHumanE"] 				= 	{ slot = _E , champName = "Elise"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 250	, spellRange = 1100		, spellRadius = 70		, collision = true	, projectileName = "Elise_human_E_mis.troy"},
-- Evelynn
["EvelynnR"] 					= 	{ slot = _R , champName = "Evelynn"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 650		, spellRadius = 350		, collision = false },
-- FiddleSticks
["Terrify"] 					= 	{ slot = _Q , champName = "FiddleSticks"		, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 575		, spellRadius = 0		, collision = false },
-- Fizz
["FizzMarinerDoom"] 			= 	{ slot = _R , champName = "Fizz"				, spellType = "line" 		, projectileSpeed = 1350		, spellDelay = 250	, spellRange = 1275		, spellRadius = 120		, collision = false , projectileName = "Fizz_UltimateMissile.troy"}, --Test
-- Galio
["GalioResoluteSmite"] 			= 	{ slot = _Q , champName = "Galio"				, spellType = "circular" 	, projectileSpeed = 1200		, spellDelay = 250	, spellRange = 1040		, spellRadius = 235		, collision = false },
["GalioIdolOfDurand"] 			= 	{ slot = _R , champName = "Galio"				, spellType = "aoe" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 600		, spellRadius = 600		, collision = false },
-- Gnar
["gnarbigq"] 					= 	{ slot = _Q , champName = "Gnar"				, spellType = "line" 		, projectileSpeed = 2000		, spellDelay = 500	, spellRange = 1150		, spellRadius = 90		, collision = true  , projectileName = ""},
["GnarQ"] 						= 	{ slot = _Q , champName = "Gnar"				, spellType = "line" 		, projectileSpeed = 2400		, spellDelay = 250	, spellRange = 1185		, spellRadius = 60		, collision = true  , projectileName = ""},
["gnarbigw"] 					= 	{ slot = _W , champName = "Gnar"				, spellType = "line" 		, projectileSpeed = math.huge	, spellDelay = 600	, spellRange = 600		, spellRadius = 100		, collision = false , projectileName = ""},
["GnarR"] 						= 	{ slot = _R , champName = "Gnar"				, spellType = "aoe" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 500		, spellRadius = 500		, collision = false },
-- Gragas
["GragasE"] 					= 	{ slot = _E , champName = "Gragas"				, spellType = "line" 		, projectileSpeed = 1200		, spellDelay = 0	, spellRange = 950		, spellRadius = 200		, collision = true  , projectileName = ""},
["GragasR"] 					= 	{ slot = _R , champName = "Gragas"				, spellType = "circular" 	, projectileSpeed = 1750		, spellDelay = 250	, spellRange = 1050		, spellRadius = 350		, collision = false },
-- Hecarim
["HecarimUlt"] 					= 	{ slot = _R , champName = "Hecarim"				, spellType = "circular" 	, projectileSpeed = 1100		, spellDelay = 10	, spellRange = 1500		, spellRadius = 300		, collision = false },
-- Heimerdinger
["HeimerdingerE"] 				= 	{ slot = _E , champName = "Heimerdinger"		, spellType = "circular" 	, projectileSpeed = 1750		, spellDelay = 350	, spellRange = 925		, spellRadius = 135		, collision = false },
-- Irelia
["IreliaEquilibriumStrike"] 	= 	{ slot = _E , champName = "Irelia"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 425		, spellRadius = 0		, collision = false },
-- Janna
["HowlingGale"] 				= 	{ slot = _Q , champName = "Janna"				, spellType = "line" 		, projectileSpeed = 900			, spellDelay = 0	, spellRange = 1700		, spellRadius = 120		, collision = false , projectileName = "HowlingGale_mis.troy"},
["SowTheWind"] 					= 	{ slot = _W , champName = "Janna"				, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 600		, spellRadius = 0		, collision = false },
-- JarvanIV
["JarvanIVDragonStrike2"] 		= 	{ slot = _Q , champName = "JarvanIV"			, spellType = "line" 		, projectileSpeed = 1800		, spellDelay = 250	, spellRange = 845		, spellRadius = 120		, collision = false	, projectileName = ""},
-- Jayce
["JayceToTheSkies"] 			= 	{ slot = _Q , champName = "Jayce"				, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 600		, spellRadius = 100		, collision = false	},
["JayceThunderingBlow"] 		= 	{ slot = _E , champName = "Jayce"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 240		, spellRadius = 0		, collision = false	},
-- Karma
["KarmaQMissileMantra"] 		= 	{ slot = _Q , champName = "Karma"				, spellType = "line" 		, projectileSpeed = 1700		, spellDelay = 250	, spellRange = 1050		, spellRadius = 90		, collision = true	, projectileName = ""},
["KarmaQ"] 						= 	{ slot = _Q , champName = "Karma"				, spellType = "line" 		, projectileSpeed = 1700		, spellDelay = 250	, spellRange = 1050		, spellRadius = 90		, collision = true	, projectileName = ""},
["KarmaW"] 						= 	{ slot = _W , champName = "Karma"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 1000		, spellRadius = 0		, collision = false	}, -- Check spellname
-- Kassadin
["ForcePulse"] 					= 	{ slot = _E , champName = "Kassadin"			, spellType = "line" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 700		, spellRadius = 100		, collision = false	, projectileName = ""},
-- Kayle
["JudicatorReckoning"] 			= 	{ slot = _Q , champName = "Kayle"				, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 650		, spellRadius = 50		, collision = false	},
-- KhaZix
["KhazixW"] 					= 	{ slot = _W , champName = "KhaZix"				, spellType = "line" 		, projectileSpeed = 1700		, spellDelay = 250	, spellRange = 1100		, spellRadius = 70		, collision = true	, projectileName = "Khazix_W_mis_enhanced.troy"},
["khazixwlong"] 				= 	{ slot = _W , champName = "KhaZix"				, spellType = "line" 		, projectileSpeed = 1700		, spellDelay = 250	, spellRange = 1025		, spellRadius = 70		, collision = true	, projectileName = "Khazix_W_mis_enhanced.troy"},
-- KogMaw
["KogMawVoidOoze"] 				= 	{ slot = _E , champName = "KogMaw"				, spellType = "line" 		, projectileSpeed = 1400		, spellDelay = 250	, spellRange = 1360		, spellRadius = 120		, collision = false	, projectileName = "KogMawVoidOoze_mis.troy"},
-- LeBlanc
["LeblancSoulShackle"] 			= 	{ slot = _E , champName = "Leblanc"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 250	, spellRange = 960		, spellRadius = 70		, collision = true	, projectileName = "leBlanc_shackle_mis.troy"},
["LeblancSoulShackleM"] 		= 	{ slot = _R , champName = "Leblanc"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 250	, spellRange = 960		, spellRadius = 70		, collision = true	, projectileName = "leBlanc_shackle_mis_ult.troy"},
-- LeeSin
["BlindMonkQOne"] 				= 	{ slot = _Q , champName = "LeeSin"				, spellType = "line" 		, projectileSpeed = 1800		, spellDelay = 250	, spellRange = 1100		, spellRadius = 60		, collision = true	, projectileName = "blindMonk_Q_mis_01.troy"},
["BlindMonkRKick"] 				= 	{ slot = _R , champName = "LeeSin"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 375		, spellRadius = 0		, collision = false	},
-- Leona
["LeonaSolarFlare"] 			= 	{ slot = _R , champName = "Leona"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 1000	, spellRange = 1200		, spellRadius = 300		, collision = false	},
-- Lissandra
["LissandraW"] 					= 	{ slot = _W , champName = "Lissandra"			, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 450		, spellRadius = 450		, collision = false	},
["LissandraR"] 					= 	{ slot = _R , champName = "Lissandra"			, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 550		, spellRadius = 550		, collision = false	},
-- Lulu
["LuluQ"] 						= 	{ slot = _Q , champName = "Lulu"				, spellType = "line" 		, projectileSpeed = 1450		, spellDelay = 250	, spellRange = 950		, spellRadius = 80		, collision = false	, projectileName = "Lulu_Q_Mis.troy"},
["LuluW"] 						= 	{ slot = _W , champName = "Lulu"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 925		, spellRadius = 450		, collision = false	}, -- check spellname
-- Lux
["LuxLightBinding"] 			= 	{ slot = _Q , champName = "Lux"					, spellType = "line" 		, projectileSpeed = 1200		, spellDelay = 250	, spellRange = 1300		, spellRadius = 70		, collision = true	, projectileName = "LuxLightBinding_mis.troy"},
-- Malphite
["SeismicShard"] 				= 	{ slot = _Q , champName = "Malphite"			, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 625		, spellRadius = 0		, collision = false	},
["UFSlash"] 					= 	{ slot = _R , champName = "Malphite"			, spellType = "circular" 	, projectileSpeed = 2000		, spellDelay = 0	, spellRange = 1000		, spellRadius = 300		, collision = false	},
-- Malzahar
["AlZaharNetherGrasp"] 			= 	{ slot = _R , champName = "Malzahar"			, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 700		, spellRadius = 0		, collision = false	},
-- Maokai
["MaokaiTrunkLine"] 			= 	{ slot = _Q , champName = "Maokai"				, spellType = "line" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 600		, spellRadius = 100		, collision = false	, projectileName = ""},
["MaokaiW"] 					= 	{ slot = _W , champName = "Maokai"				, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 600		, spellRadius = 0		, collision = false	}, -- check spellname
-- Morgana
["DarkBindingMissile"] 			= 	{ slot = _Q , champName = "Morgana"				, spellType = "line" 		, projectileSpeed = 1200		, spellDelay = 250	, spellRange = 1300		, spellRadius = 80		, collision = true	, projectileName = "DarkBinding_mis.troy"},
["SoulShackles"] 				= 	{ slot = _R , champName = "Morgana"				, spellType = "aoe" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 600		, spellRadius = 600		, collision = false	},
-- Nami
["NamiQ"] 						= 	{ slot = _Q , champName = "Nami"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 1000	, spellRange = 875		, spellRadius = 200		, collision = false	},
["NamiR"] 						= 	{ slot = _R , champName = "Nami"				, spellType = "line" 		, projectileSpeed = 850			, spellDelay = 500	, spellRange = 2750		, spellRadius = 250		, collision = false	, projectileName = ""},
-- Nasus
["NasusW"] 						= 	{ slot = _W , champName = "Nasus"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 600		, spellRadius = 0		, collision = false	},
-- Nautilus
["NautilusAnchorDrag"] 			= 	{ slot = _Q , champName = "Nautilus"			, spellType = "line" 		, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 1250		, spellRadius = 90		, collision = true	, projectileName = "Nautilus_Q_mis.troy"},
["NautilusR"] 					= 	{ slot = _R , champName = "Nautilus"			, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 825		, spellRadius = 0		, collision = false	}, -- check spellname
-- Nocturne
["NocturneUnspeakableHorror"]	= 	{ slot = _E , champName = "Nocturne"			, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 425		, spellRadius = 0		, collision = false	},
-- Nunu
["IceBlast"]					= 	{ slot = _E , champName = "Nunu"				, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 400	, spellRange = 425		, spellRadius = 0		, collision = false	},
-- Olaf
["OlafAxeThrowCast"]			= 	{ slot = _Q , champName = "Olaf"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 250	, spellRange = 100		, spellRadius = 90		, collision = false	, projectileName = "olaf_axe_mis.troy"},
-- Orianna
--0
-- Pantheon
["PantheonW"]					= 	{ slot = _W , champName = "Pantheon"			, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 600		, spellRadius = 0		, collision = false	}, -- check spellname
-- Poppy
["PoppyHeroicCharge"]			= 	{ slot = _E , champName = "Poppy"				, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 600		, spellRadius = 0		, collision = false	},
-- Quinn
["QuinnQ"]						= 	{ slot = _Q , champName = "Quinn"				, spellType = "line" 		, projectileSpeed = 1550		, spellDelay = 250	, spellRange = 1050		, spellRadius = 80		, collision = true	, projectileName = "Quinn_Q_missile.troy"},
["QuinnE"]						= 	{ slot = _E , champName = "Quinn"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 700		, spellRadius = 0		, collision = false	},
-- Rammus
["PuncturingTaunt"]				= 	{ slot = _E , champName = "Rammus"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 325		, spellRadius = 0		, collision = false	},
-- Rengar
["RengarE"]						= 	{ slot = _E , champName = "Rengar"				, spellType = "line" 		, projectileSpeed = 1500		, spellDelay = 250	, spellRange = 1000		, spellRadius = 70		, collision = true	, projectileName = ""},
-- Riven
["RivenMartyr"]					= 	{ slot = _W , champName = "Riven"				, spellType = "aoe" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 280		, spellRadius = 280		, collision = false	},
-- Rumble
["RumbleGrenade"]				= 	{ slot = _E , champName = "Rumble"				, spellType = "line" 		, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 950		, spellRadius = 90		, collision = true	, projectileName = "rumble_taze_mis.troy"},
-- Ryze
["RyzeW"]						= 	{ slot = _W , champName = "Ryze"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 600		, spellRadius = 0		, collision = false	},
-- Sejuani
["SejuaniArcticAssault"]		= 	{ slot = _Q , champName = "Sejuani"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 0	, spellRange = 900		, spellRadius = 70		, collision = false	, projectileName = ""},
["SejuaniGlacialPrisonCast"]	= 	{ slot = _R , champName = "Sejuani"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 250	, spellRange = 1200		, spellRadius = 110		, collision = false	, projectileName = ""},
-- Shaco
["TwoShivPoison"]				= 	{ slot = _E , champName = "Shaco"				, spellType = "target" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 625		, spellRadius = 0		, collision = false	},
-- Shen
["ShenShadowDash"]				= 	{ slot = _E , champName = "Shen"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 0	, spellRange = 650		, spellRadius = 50		, collision = false	, projectileName = ""},
-- Shyvana
["ShyvanaTransformCast"]		= 	{ slot = _R , champName = "Shyvana"				, spellType = "line" 		, projectileSpeed = 1100		, spellDelay = 10	, spellRange = 1000		, spellRadius = 160		, collision = false	, projectileName = ""},
-- Singed
["Fling"]						= 	{ slot = _E , champName = "Singed"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 125		, spellRadius = 0		, collision = false	},
-- Skarner
["SkarnerFracture"]				= 	{ slot = _E , champName = "Skarner"				, spellType = "line" 		, projectileSpeed = 1400		, spellDelay = 250	, spellRange = 1000		, spellRadius = 60		, collision = false	, projectileName = ""},
["SkarnerImpale"]				= 	{ slot = _R , champName = "Skarner"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 350		, spellRadius = 0		, collision = false	}, -- check spellname
-- Sona
["SonaR"]						= 	{ slot = _R , champName = "Sona"				, spellType = "line" 		, projectileSpeed = 2400		, spellDelay = 250	, spellRange = 1000		, spellRadius = 140		, collision = false	, projectileName = ""},
-- Swain
["SwainQ"]						= 	{ slot = _Q , champName = "Swain"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 625		, spellRadius = 0		, collision = false	}, -- check spellname
["SwainShadowGrasp"]			= 	{ slot = _W , champName = "Swain"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 1100	, spellRange = 900		, spellRadius = 250		, collision = false	},
-- Syndra
["syndrawcast"]					= 	{ slot = _W , champName = "Syndra"				, spellType = "circular" 	, projectileSpeed = 1450		, spellDelay = 250	, spellRange = 925		, spellRadius = 220		, collision = false	},
["SyndraE"]						= 	{ slot = _E , champName = "Syndra"				, spellType = "line" 		, projectileSpeed = 1500		, spellDelay = 250	, spellRange = 800		, spellRadius = 150		, collision = false	, projectileName = ""},
-- TahmKench
["TahmKenchQ"]					= 	{ slot = _Q , champName = "TahmKench"			, spellType = "line" 		, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 950		, spellRadius = 90		, collision = true	, projectileName = ""},
["TahmKenchE"]					= 	{ slot = _E , champName = "TahmKench"			, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 250		, spellRadius = 0		, collision = false	}, -- check spellname
-- Teemo
["BlindingDart"]				= 	{ slot = _Q , champName = "Teemo"				, spellType = "target" 		, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 580		, spellRadius = 0		, collision = false	},
-- Thresh
["ThreshQ"]						= 	{ slot = _Q , champName = "Thresh"				, spellType = "line" 		, projectileSpeed = 1900		, spellDelay = 500	, spellRange = 1100		, spellRadius = 70		, collision = true	, projectileName = ""},
["ThreshE"]						= 	{ slot = _E , champName = "Thresh"				, spellType = "line" 		, projectileSpeed = 2000		, spellDelay = 0	, spellRange = 1075/2	, spellRadius = 110		, collision = false	, projectileName = ""},
-- Tristana
["TristanaR"]					= 	{ slot = _R , champName = "Tristana"			, spellType = "target" 		, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 669		, spellRadius = 0		, collision = false	},
-- Tryndamere
["MockingShout"] 				= 	{ slot = _W , champName = "Tryndamere"			, spellType = "aoe" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 400		, spellRadius = 400		, collision = false	},
-- Urgot
["UrgotR"]						= 	{ slot = _R , champName = "Urgot"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 850		, spellRadius = 0		, collision = false	}, -- check spellName
-- Varus
["VarusR"]						= 	{ slot = _R , champName = "Varus"				, spellType = "line" 		, projectileSpeed = 1950		, spellDelay = 250	, spellRange = 1200		, spellRadius = 100		, collision = false	, projectileName = ""},
-- Vayne
["VayneCondemn"]				= 	{ slot = _E , champName = "Vayne"				, spellType = "target" 		, projectileSpeed = 2000		, spellDelay = 250	, spellRange = 550		, spellRadius = 0		, collision = false	},
-- Veigar
["VeigarEventHorizon"]			= 	{ slot = _E , champName = "Veigar"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 500	, spellRange = 700		, spellRadius = 425		, collision = false	},
-- VelKoz
["VelkozQMissile"]				= 	{ slot = _Q , champName = "Velkoz"				, spellType = "line" 		, projectileSpeed = 1300		, spellDelay = 250	, spellRange = 1250		, spellRadius = 50		, collision = true	, projectileName = ""},
["VelkozQMissileSplit"]			= 	{ slot = _Q , champName = "Velkoz"				, spellType = "line" 		, projectileSpeed = 2100		, spellDelay = 0	, spellRange = 1100		, spellRadius = 45		, collision = true	, projectileName = ""},
["VelkozE"]						= 	{ slot = _E , champName = "Velkoz"				, spellType = "circular" 	, projectileSpeed = 1500		, spellDelay = 0	, spellRange = 950		, spellRadius = 225		, collision = false	},
-- Vi
["ViQMissile"]					= 	{ slot = _Q , champName = "Vi"					, spellType = "line" 		, projectileSpeed = 1500		, spellDelay = 0	, spellRange = 725		, spellRadius = 90		, collision = false	, projectileName = ""},
["ViR"]							= 	{ slot = _R , champName = "Vi"					, spellType = "line" 		, projectileSpeed = 1000		, spellDelay = 250	, spellRange = 800		, spellRadius = 0		, collision = false	, projectileName = ""}, -- check spellname
-- Viktor
["ViktorGravitonField"]			= 	{ slot = _W , champName = "Viktor"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 1500	, spellRange = 625		, spellRadius = 300		, collision = false	},
-- Warwick
["InfiniteDuress"]				= 	{ slot = _R , champName = "Warwick"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 0	, spellRange = 700		, spellRadius = 0		, collision = false	}, -- check spellname
-- Xerath
["XerathArcaneBarrage2"]		= 	{ slot = _W , champName = "Xerath"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 250	, spellRange = 1125		, spellRadius = 60		, collision = false	},
["XerathMageSpear"]				= 	{ slot = _E , champName = "Xerath"				, spellType = "line" 		, projectileSpeed = 1600		, spellDelay = 750	, spellRange = 1100		, spellRadius = 280		, collision = true	, projectileName = ""},
-- Yasou
["yasuoq3w"]					= 	{ slot = _Q , champName = "Yasou"				, spellType = "line" 		, projectileSpeed = 1200		, spellDelay = 250	, spellRange = 1025		, spellRadius = 90		, collision = false	, projectileName = ""},
-- Zac
["ZacQ"]						= 	{ slot = _Q , champName = "Zac"					, spellType = "line" 		, projectileSpeed = math.huge	, spellDelay = 500	, spellRange = 550		, spellRadius = 120		, collision = false	, projectileName = ""},
["ZacE"]						= 	{ slot = _E , champName = "Zac"					, spellType = "circular" 	, projectileSpeed = 1500		, spellDelay = 0	, spellRange = 1800		, spellRadius = 300		, collision = false	}, -- check spellname, projectileSpeed
-- Ziggs
["ZiggsW"]						= 	{ slot = _W , champName = "Ziggs"				, spellType = "circular" 	, projectileSpeed = 3000		, spellDelay = 250	, spellRange = 2000		, spellRadius = 275		, collision = false	},
-- Zilean
["ZileanQ"]						= 	{ slot = _Q , champName = "Zilean"				, spellType = "circular" 	, projectileSpeed = 2000		, spellDelay = 300	, spellRange = 900		, spellRadius = 250		, collision = false	},
["TimeWarp"]					= 	{ slot = _E , champName = "Zilean"				, spellType = "target" 		, projectileSpeed = math.huge	, spellDelay = 0	, spellRange = 550		, spellRadius = 0		, collision = false	},
-- Zyra
["ZyraGraspingRoots"]			= 	{ slot = _E , champName = "Zyra"				, spellType = "line" 		, projectileSpeed = 1400		, spellDelay = 250	, spellRange = 1150		, spellRadius = 70		, collision = false	, projectileName = ""},
["ZyraBrambleZone"]				= 	{ slot = _R , champName = "Zyra"				, spellType = "circular" 	, projectileSpeed = math.huge	, spellDelay = 500	, spellRange = 700		, spellRadius = 525		, collision = false	}
}

----------------------------------------------------------------
----------------------------------------------------------------

local function VectorWay(A,B)
WayX = B.x - A.x
WayY = B.y - A.y
WayZ = B.z - A.z
return Vector(WayX, WayY, WayZ)
end

local incSpells = {}
local myTeam = {}

OnLoad(function()
    myTeam[GetNetworkID(myHero)] = myHero
    for i,v in pairs(GetAllyHeroes()) do
    	myTeam[GetNetworkID(v)] = v
    end
end)

OnProcessSpell(function(unit,spell)
  if unit.team ~= myHero.team then
	-- if unit.charName == "Kayle" then
		-- print(spell.name)
	-- end
    if CC[spell.name] ~= nil then
      local skill = CC[spell.name]
      if skill.spellType == "target" and spell.target.team == myHero.team and GetObjectType(spell.target) == Obj_AI_Hero then
         if skill.projectileSpeed < 1500 then
			incSpells[spell.name] = {sType = skill.spellType, sPos = spell.startPos, ePos = spell.target, delay = skill.spellDelay or 250, radius = skill.spellRadius, speed = skill.projectileSpeed or math.huge, createTime = GetTickCount()}	
		 else
			if CanUseSpell(myHero,_E) == READY and GetDistance(spell.target) < 850 then
				CastTargetSpell(spell.target,_E)
			end
		 end
      elseif skill.spellType == "line" then
			incSpells[spell.name] = {sType = skill.spellType, sPos = spell.startPos, ePos = (spell.startPos + (VectorWay(spell.startPos, spell.endPos)):normalized() * skill.spellRange), delay = skill.spellDelay or 250, radius = skill.spellRadius, speed = skill.projectileSpeed, createTime = GetTickCount()}
      elseif skill.spellType == "circular" then
			incSpells[spell.name] = {sType = skill.spellType, sPos = spell.startPos, ePos = spell.endPos, delay = skill.spellDelay or 250, radius = skill.spellRadius, speed = skill.projectileSpeed or math.huge, createTime = GetTickCount()}	
      end
    end
  end
end)

OnDraw(function()
    for i,v in pairs(incSpells) do
		if v ~= nil then
			for _,a in pairs(myTeam) do
				if GetDistance(a) < 875 then
					TargetSkillBlock(i,v,_E)
					LineSkillshotBlock(i,v,a,_E)
					CircularSkillshotBlock(i,v,a,_E)
				end
			end
		end
    end
end)

function TargetSkillBlock(i,v,cast)
	if v.sType == "target" then
		local spellPos = v.sPos
		if GetTickCount()-v.createTime > v.delay then
			spellPos = v.sPos + VectorWay(v.sPos,v.ePos.pos):normalized() * (v.speed/1000*(GetTickCount()-v.createTime - v.delay))
		end
		local timeToDodge = 50
		local dodgeHere = spellPos + VectorWay(v.sPos,v.ePos.pos):normalized() * (v.speed*(timeToDodge + v.delay)/1000)
		if GetDistance(v.ePos.pos,spellPos) <= GetDistance(dodgeHere,spellPos) and GetDistance(v.ePos.pos, v.sPos) - v.radius - GetHitBox(v.ePos) <= GetDistance(v.sPos,v.ePos.pos) then
			if CanUseSpell(myHero,cast) then
				CastTargetSpell(v.ePos,cast)
			end
		end
		if GetDistance(spellPos,v.sPos) > GetDistance(v.ePos.pos,v.sPos) then
			incSpells[i] = nil
		end
	end
end

function LineSkillshotBlock(i,v,who,cast)
	if v.sType == "line" then
		local spellOnMe = v.sPos + VectorWay(v.sPos,v.ePos):normalized() * GetDistance(who.pos,v.sPos)
		local spellPos = v.sPos
		if GetTickCount()-v.createTime > v.delay then
			spellPos = v.sPos + VectorWay(v.sPos,v.ePos):normalized() * (v.speed/1000*(GetTickCount()-v.createTime - v.delay))
		end
		local timeToDodge = 100
		local dodgeHere = spellPos + VectorWay(v.sPos,v.ePos):normalized() * (v.speed*(timeToDodge + v.delay)/1000)
			if GetDistance(spellOnMe,spellPos) <= GetDistance(dodgeHere,spellPos) and GetDistance(spellOnMe, v.sPos) - v.radius - GetHitBox(who) <= GetDistance(v.sPos,v.ePos) then
				if GetDistance(who,spellOnMe) < v.radius + GetHitBox(who) then
					if CanUseSpell(myHero,cast) == READY then
						CastTargetSpell(who,cast)
					end
				end
			end
		if GetDistance(spellPos,v.sPos) >= GetDistance(v.sPos,v.ePos) then
			incSpells[i] = nil
		end
	end
end

function CircularSkillshotBlock(i,v,who,cast)
	if v.sType == "circular" then
		DrawCircle(v.ePos,v.radius,2,1,ARGB(255,255,200,0)); --draw starting pos
		local timeToDodge = ((v.radius + GetHitBox(who) - GetDistance(who,v.ePos))/GetMoveSpeed(who))*1000
		local timeToHit = (GetDistance(v.ePos,v.sPos)/v.speed)*1000 + v.createTime - GetTickCount() + v.delay
		if GetDistance(v.ePos,who) < v.radius + GetHitBox(who) then
			if timeToHit < timeToDodge and timeToHit > 0.05 then
				if CanUseSpell(myHero,cast) == READY then
					CastTargetSpell(who,cast)
				end
			end
		end
		if timeToHit <= 0 then
			incSpells[i] = nil
		end
	end
end




function Mode()
    if _G.IOW_Loaded and IOW:Mode() then
        return IOW:Mode()
        elseif _G.PW_Loaded and PW:Mode() then
        return PW:Mode()
        elseif _G.DAC_Loaded and DAC:Mode() then
        return DAC:Mode()
        elseif _G.AutoCarry_Loaded and DACR:Mode() then
        return DACR:Mode()
        elseif _G.SLW_Loaded and SLW:Mode() then
        return SLW:Mode()
    end
end

OnTick(function ()
	
	local Ig = (50 + (20 * GetLevel(myHero)))
	local RStats = {delay = 0.050, range = 1000, radius = 300, speed = 1500 + GetMoveSpeed(myHero)}
	local GetPercentMana = (GetCurrentMana(myHero) / GetMaxMana(myHero)) * 100
	local target = GetCurrentTarget()
	local movePos = GetPrediction(target,Move).castPos


local myHeroPos = GetOrigin(myHero)

	
	if MorganaMenu.Misc.Lvlup:Value() then
		spellorder = {_Q, _W, _E, _Q, _Q, _R, _Q, _W, _Q, _W, _R, _W, _W, _E, _E, _R, _E, _E}	
		if GetLevelPoints(myHero) > 0 then
			LevelSpell(spellorder[GetLevel(myHero) + 1 - GetLevelPoints(myHero)])
		end
	end

	if Mode() == "Combo" then
		
		if MorganaMenu.Combo.QComb:Value() and Ready(_Q) and ValidTarget(target, 1175) then
				if MorganaMenu.Combo.MinMana:Value() <= GetPercentMana then 
				local Qpred = GetPrediction(target, MorgQ)
				if Qpred.hitChance >= (MorganaMenu.Prediction.Q:Value() * 0.01) and not Qpred:mCollision(1) then
					CastSkillShot(_Q,Qpred.castPos)	
				end
			end
		end
		

		if MorganaMenu.Combo.WComb:Value() and Ready(_W) and ValidTarget(target, 700) then
			if MorganaMenu.Combo.MinMana:Value() <= GetPercentMana then
				local Wpred = GetLinearAOEPrediction(target, MorgW)
				if Wpred.hitChance >= (MorganaMenu.Prediction.W:Value() * 0.01) then
			  	CastSkillShot(_W,Wpred.castPos)
			end
		end
	end
	
					if MorganaMenu.Combo.RComb:Value() and Ready(_R) and ValidTarget(target, 500) then
				if MorganaMenu.Combo.MinMana:Value() <= GetPercentMana then 
					CastTargetSpell(target, _R)	
			end
		end
	end
	
	if Mode() == "Harass" then
		
		if MorganaMenu.Harass.WHarass:Value() and Ready(_W) and ValidTarget(target, 900) then
			if MorganaMenu.Harass.MinManaHarass:Value() <= GetPercentMana then
				local Wpredd = GetLinearAOEPrediction(target, MorgW)
				if Wpredd.hitChance >= (MorganaMenu.Prediction.W:Value() * 0.01) then
				CastSkillShot(_W,Wpredd.castPos)
			end
		end
	end

			if MorganaMenu.Harass.QHarass:Value() and Ready(_Q) and ValidTarget(target, 1125) then
			if MorganaMenu.Harass.MinManaHarass:Value() <= GetPercentMana then
				local Qpredd = GetPrediction(target, MorgQ)
				if Qpredd.hitChance >= (MorganaMenu.Prediction.Q:Value() * 0.01) and not Qpredd:mCollision(1) then
				CastSkillShot(_Q,Qpredd.castPos)
			end
		end
	end
	
	end

if Mode() == "LaneClear" then
		
		for _, closeminion in pairs(minionManager.objects) do
			if MorganaMenu.LaneClear.Wlc:Value() and ValidTarget(closeminion, 900) then
				if GetPercentMP(myHero) >= MorganaMenu.LaneClear.MinManaLC:Value() then
					CastSkillShot(_W, closeminion)
				end
			end
		end
		
end

function DistanceBetween(p1,p2)
return  math.sqrt(math.pow((p2.x - p1.x),2) + math.pow((p2.y - p1.y),2) + math.pow((p2.z - p1.z),2))
end


	for _, enemy in pairs(GetEnemyHeroes()) do
			--AutoR
		if MorganaMenu.Misc.UltX:Value() and Ready(_R) and ValidTarget(enemy, 600) and EnemiesAround(enemy, 300) >= MorganaMenu.Misc.EnemieR:Value() then
				CastTargetSpell(enemy, _R)
			end	
			--Auto Ignite 
		if GetCastName(myHero, SUMMONER_1):lower():find("summonerdot") then
			if MorganaMenu.Misc.Ig:Value() and Ready(SUMMONER_1) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < Ig then
					CastTargetSpell(enemy, SUMMONER_1)
				end
			end
		end
	
		if GetCastName(myHero, SUMMONER_2):lower():find("summonerdot") then
			if MorganaMenu.Misc.Ig:Value() and Ready(SUMMONER_2) and ValidTarget(enemy, 600) then
				if GetCurrentHP(enemy) < Ig then
					CastTargetSpell(enemy, SUMMONER_2)
				end
			end
		end
	end
end)


OnDraw(function(myHero)
	local pos = GetOrigin(myHero)
	local mpos = GetMousePos()
	if MorganaMenu.Draw.DrawQ:Value() then DrawCircle(pos, 1125, 1, 25, GoS.Red) end
	if MorganaMenu.Draw.DrawW:Value() then DrawCircle(pos, 900, 1, 25, GoS.Blue) end
	if MorganaMenu.Draw.DrawE:Value() then DrawCircle(pos, 600, 1, 25, GoS.Blue) end
	if MorganaMenu.Draw.DrawR:Value() then DrawCircle(pos, 600, 1, 25, GoS.Green) end
end)



print("Morgana injected , dominate the rift. Have fun!")
