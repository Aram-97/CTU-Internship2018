extends Node2D

onready var P1 = get_node("Points/P1")
onready var P2 = get_node("Points/P2")
onready var P3 = get_node("Points/P3")
onready var P4 = get_node("Points/P4")
onready var Paths = get_node("Paths")
onready var PathP1 = get_node("Paths/PathP1/PathFollow2D")
onready var PathP2 = get_node("Paths/PathP2/PathFollow2D")
onready var PathP3 = get_node("Paths/PathP3/PathFollow2D")
onready var BendTween = get_node("BendTween")
onready var RecoverTween = get_node("RecoverTween")

export (int) var SEGMENT_COUNT = 50
export (float) var BEND_DURATION = 3.0
export (float) var RECOVER_DURATION = 1.5

var direction = 0
var bezier_curve = PoolVector2Array()

func _ready():
	bezier_curve.resize(SEGMENT_COUNT+1)
	pass

func _process(delta):
	calculate_curve()
	update()
	
	if Input.is_action_pressed("ui_right"):
		assign_direction(1)
		if direction == 1:
			Paths.scale.x = direction
			bend([PathP1, PathP2, PathP3], BEND_DURATION)
		elif direction == -1 and Input.is_action_just_released("ui_left"):
			recover([PathP1, PathP2, PathP3], RECOVER_DURATION*2/3, Tween.EASE_IN)
	
	if Input.is_action_pressed("ui_left"):
		assign_direction(-1)
		if direction == -1:
			Paths.scale.x = direction
			bend([PathP1, PathP2, PathP3], BEND_DURATION)
		elif Input.is_action_just_released("ui_right"):
			recover([PathP1, PathP2, PathP3], RECOVER_DURATION*2/3, Tween.EASE_IN)
	
	if not (Input.is_action_pressed("ui_right") or Input.is_action_pressed("ui_left")):
		if direction != 0:
			recover([PathP1, PathP2, PathP3], RECOVER_DURATION, Tween.EASE_OUT)
	pass

func _draw():
	var prev_node = P1
	for node in [P2, P3, P4]:
		var color = Color(0.0, 0.0, 0.0)
		match node:
			P2:
				color = Color(1.0, 0.0, 0.0)
			P3:
				color = Color(0.0, 1.0, 0.0)
			P4:
				color = Color(0.0, 0.0, 1.0)
		
		draw_line(node.position, prev_node.position, color, 1.5, true)
		prev_node = node
	
	for i in range(bezier_curve.size() - 1):
		draw_line(bezier_curve[i], bezier_curve[i+1], Color(1.0, 1.0, 1.0), 1.5, true)
	pass

# Signal function connected from RecoverTween
func _on_RecoverTween_tween_completed(object, key):
	if direction != 0:
		direction = 0
	pass # replace with function body

func assign_direction(dir):
	if direction == 0:
		direction = dir
	pass

func bend(paths, duration):
	if not BendTween.is_active():
		RecoverTween.remove_all()
		for i in range(paths.size()):
			var current_offset = paths[i].unit_offset
			BendTween.interpolate_property(paths[i], "unit_offset", current_offset, 1,
							(1-current_offset) * duration, Tween.TRANS_CUBIC, Tween.EASE_OUT)
		
		BendTween.start()
	pass

func recover(paths, duration, ease_type):
	if not RecoverTween.is_active():
		BendTween.remove_all()
		for i in range(paths.size()):
			var current_offset = paths[i].unit_offset
			RecoverTween.interpolate_property(paths[i], "unit_offset", current_offset, 0,
							current_offset * duration, Tween.TRANS_CUBIC, ease_type)
		
		RecoverTween.start()
	pass

func calculate_curve():
	for i in range(SEGMENT_COUNT + 1):
		var t = float(i) / float(SEGMENT_COUNT)
		bezier_curve[i] = calculate_point(t, P1.position, P2.position, P3.position, P4.position)
	pass

func calculate_point(t, p1, p2, p3, p4):
	var u = 1 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	
	return uuu*p1 + 3*uu*t*p2 + 3*u*tt*p3 + ttt*p4
