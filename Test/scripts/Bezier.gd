extends Node2D

onready var P1 = get_node("P1")
onready var P2 = get_node("P2")
onready var P3 = get_node("P3")
onready var P4 = get_node("P4")
onready var FollowP1 = get_node("Path P1/PathFollow2D")
onready var FollowP2 = get_node("Path P2/PathFollow2D")
onready var FollowP3 = get_node("Path P3/PathFollow2D")
onready var Tween = get_node("Tween")

export var SEGMENT_COUNT = 50
export var BEND_DURATION = 3.0
export var RECOVER_DURATION = 1.5

var bezier_curve = PoolVector2Array()

func _ready():
	bezier_curve.resize(SEGMENT_COUNT+1)
	pass

func _process(delta):
	calculate_curve()
	update()
	
	if Input.is_action_just_pressed("ui_right"):
		bend([FollowP1, FollowP2, FollowP3], 
				BEND_DURATION, Tween.TRANS_CUBIC, Tween.EASE_IN_OUT)
	elif Input.is_action_just_released("ui_right"):
		recover([FollowP1, FollowP2, FollowP3],
				RECOVER_DURATION, Tween.TRANS_QUINT, Tween.EASE_OUT)
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

func bend(paths, duration, trans_type, ease_type):
	Tween.remove_all()
	for i in range(paths.size()):
		var current_offset = paths[i].unit_offset
		Tween.interpolate_property(paths[i], "unit_offset", current_offset, 1,
						(1-current_offset) * duration, trans_type, ease_type)
	
	Tween.start()
	pass

func recover(paths, duration, trans_type, ease_type):
	Tween.remove_all()
	for i in range(paths.size()):
		var current_offset = paths[i].unit_offset
		Tween.interpolate_property(paths[i], "unit_offset", current_offset, 0,
						current_offset * duration, trans_type, ease_type)
	
	Tween.start()
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
