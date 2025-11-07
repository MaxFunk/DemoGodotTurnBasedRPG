class_name LevelUp

# TODO: Save differently lol?
const levelup_data_arts: Array[Dictionary] = [
	{0: 4, 1: 1, 2: 7, 4: 13, 7: 17, 11: 21, 13: 8, 15: 20},
	{1: 5, 2: 18, 3: 10, 7: 14, 11: 22, 14: 16},
	{1: 1, 2: 6, 3: 11, 6: 15, 11: 23, 13: 24},
	{1: 3, 2: 7, 3: 9, 4: 12, 10: 8, 11: 11, 13: 16},
	{1: 0},
	{1: 0},
	{1: 0},
	{1: 0}];


static func get_levelup_art(id: int, level: int) -> int:
	if levelup_data_arts[id].has(level):
		return int(levelup_data_arts[id].get(level, -1));
	return -1
