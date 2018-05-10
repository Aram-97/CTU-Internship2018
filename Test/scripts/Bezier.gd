extends Node2D

onready var P1 = get_node("P1")
onready var P2 = get_node("P2")
onready var P3 = get_node("P3")
onready var P4 = get_node("P4")

onready var FollowP1 = get_node("Path P1/PathFollow2D")
onready var FollowP2 = get_node("Path P2/PathFollow2D")
onready var FollowP3 = get_node("Path P3/PathFollow2D")

var SEGMENT_COUNT = 50

var bezierCurve = PoolVector2Array()

func _ready():
	bezierCurve.resize(SEGMENT_COUNT+1)
	set_process(true)
	
	addPathFollowTweens(FollowP1, 4, Tween.EASE_IN_OUT, Tween.TRANS_QUINT)
	addPathFollowTweens(FollowP2, 4, Tween.EASE_IN_OUT, Tween.TRANS_QUINT)
	addPathFollowTweens(FollowP3, 4, Tween.EASE_IN_OUT, Tween.TRANS_QUINT)
	pass

func _process(delta):
	calculateCurve()
	update()
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
	
	for i in range(bezierCurve.size() - 1):
		draw_line(bezierCurve[i], bezierCurve[i+1], Color(1.0, 1.0, 1.0), 1.5, false)
	pass

func addPathFollowTweens(node, duration, trans_type, ease_type):
	var tween = Tween.new()
	tween.interpolate_property(node, "unit_offset", 0, 1, duration,
								trans_type, ease_type)
	tween.set_repeat(true)
	add_child(tween)
	tween.start()
	pass

func calculateCurve():
	for i in range(SEGMENT_COUNT + 1):
		var t = float(i) / float(SEGMENT_COUNT)
		bezierCurve[i] = calculatePoint(t, P1.position, P2.position, P3.position, P4.position)
	pass

func calculatePoint(t, p1, p2, p3, p4):
	var u = 1 - t
	var tt = t * t
	var uu = u * u
	var uuu = uu * u
	var ttt = tt * t
	
	return uuu*p1 + 3*uu*t*p2 + 3*u*tt*p3 + ttt*p4
