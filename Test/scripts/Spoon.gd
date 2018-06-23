extends Spatial

onready var skeleton = get_node("Armature/Skeleton")
onready var anim_tree = get_node("AnimationTreePlayer")

var id
var head_pose

func _ready():
	anim_tree.active = true
	pass

func _process(delta):
	pass
