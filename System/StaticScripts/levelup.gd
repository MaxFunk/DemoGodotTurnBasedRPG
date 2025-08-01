class_name LevelUp

const levelup_data_arts: Array[Dictionary] = [
	{2: 2, 3: 8, 5: 10, 8: 11, 10: 13, 11: 14},
	{3: 5, 5: 4, 6: 12, 8: 15, 11: 6},
	{5: 2, 7: 4, 10: 9, 11: 13},
	{1: 0},
	{1: 0},
	{1: 0},
	{1: 0},
	{1: 0}];


static func get_levelup_art(id: int, level: int) -> int:
	if levelup_data_arts[id].has(level):
		return int(levelup_data_arts[id].get(level, -1));
	return -1
