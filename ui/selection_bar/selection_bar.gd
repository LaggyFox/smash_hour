class_name SelectionBar extends HBoxContainer

var _curr_selected_idx : int = 0

func _ready() -> void:
	MaskState.mask_changed.connect(_handle_mask_changed_input)
	
func _handle_mask_changed_input(_mask_type: MaskState.MaskType, _amount: int) -> void:

	var idx : int = MaskState.current_mask_idx
	# was anything changed?
	if(idx == _curr_selected_idx) : return
	
	_deselect_old()
	_curr_selected_idx = idx
	_select_new(idx)

func _deselect_old() -> void:
	var old_child := get_child(_curr_selected_idx)
	if(old_child.has_method("deselect_this")):
		old_child.deselect_this()

func _select_new(idx : int)->void:
	var new_child : Node = get_child(idx)
	if(new_child.has_method("select_this")):
		new_child.select_this()
	
