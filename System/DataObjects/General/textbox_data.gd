class_name TextboxData
extends RefCounted

var id: int = -1;
var next_id_1: int = -1;
var next_id_2: int = -1;

var next_td_1: TextboxData;
var next_td_2: TextboxData;

var is_question: bool = false;
var text: String = "";
var answer_1: String = "";
var answer_2: String = "";
var speaker_name: String = "";
var speaker_icon: String = "";
