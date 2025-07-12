class_name BattleData
extends RefCounted

var origin_data: CharacterData;

var name: String = "???";
var level: int = 99;

var hp_max: int = 999;
var hp_cur: int = 999;
var sp_max: int = 999;
var sp_cur: int = 999;

# PhyAtt, PhyDef, EthAtt, EthDef, Luck, Agility
var stats: Array[int] = [99, 99, 99, 99, 99, 99];
var arts: Array[BattleArt] = [null, null, null, null, null, null, null, null];
var ult_art: BattleArt = null;
