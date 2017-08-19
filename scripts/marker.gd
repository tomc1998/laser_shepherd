extends Node2D

const SHOW_TIMER_MAX = 1.5
var show_timer = 0.0

func _fixed_process(delta):
	if Input.is_action_pressed("command"):
		set_global_pos(get_global_mouse_pos())
		show_timer = SHOW_TIMER_MAX
		show()
	if show_timer > 0:
		show_timer -= delta
		if show_timer <= 0:
			show_timer = 0
			hide()

func _ready():
	hide()
	set_fixed_process(true)
