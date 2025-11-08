class_name ScrollControl
extends Control

@export var max_displayed_elements: int = 0;
@export var element_size := Vector2(0, 0);
@export var scrollbar: ScrollBar;

var elements: Array[Control] = [];
var elem_container: Control;
var idx_selected: int = 0;


func _ready() -> void:
	clip_contents = true;
	elem_container = Control.new();
	elem_container.name = "ElemContainer";
	add_child(elem_container);
	return


func reset() -> void:
	elem_container.position.y = 0;
	idx_selected = 0;
	if scrollbar:
		scrollbar.value = 0;
	clear_elements();
	return


func add_element(elem: Control) -> void:
	elem_container.add_child(elem);
	elem.position.y = element_size.y * elements.size();
	elements.append(elem);
	
	if scrollbar:
		if elements.size() <= max_displayed_elements:
			scrollbar.visible = false;
		else:
			scrollbar.visible = true;
			scrollbar.max_value = elements.size() - 1;
			scrollbar.page = max_displayed_elements - 1;
	
	if idx_selected >= elements.size():
		idx_selected = elements.size() - 1;
	return


func get_current_element() -> Control:
	if idx_selected >= elements.size():
		return null
	return elements[idx_selected];


func clear_elements() -> void:
	for elem in elements:
		if elem.is_inside_tree():
			elem_container.remove_child(elem);
		elem.queue_free();
	elements.clear();
	return


func change_index(amount: int) -> void:
	idx_selected = clampi(idx_selected + amount, 0, elements.size() - 1);
	if elements.size() <= max_displayed_elements: return
	
	if amount > 0:
		if idx_selected - roundi(scrollbar.value) > max_displayed_elements - 1:
			scrollbar.value += amount;
			elem_container.position.y = -element_size.y * scrollbar.value;
	
	if amount < 0:
		var cond_1: bool = idx_selected < roundi(scrollbar.value);
		var cond_2: bool = !is_zero_approx(scrollbar.value);
		if cond_1 and cond_2:
			scrollbar.value += amount;
			elem_container.position.y = -element_size.y * scrollbar.value;
	return

# TODO: SOMEHOW ALSO GET RIGHT SCROLL
func set_index(value) -> void:
	idx_selected = clampi(value, 0, elements.size() - 1);
	if elements.size() <= max_displayed_elements:
		scrollbar.value = 0.0;
		return
	
	scrollbar.value = idx_selected - scrollbar.page;
	elem_container.position.y = -element_size.y * scrollbar.value;
	return
