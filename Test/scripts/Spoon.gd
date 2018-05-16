extends Spatial

onready var SpoonMesh = get_node("SpoonMesh")
onready var P1 = get_node("Points/P1")
onready var P2 = get_node("Points/P2")
onready var P3 = get_node("Points/P3")

var sp_material

var inputS;
var inputE;
var outputS = -1;
var outputE = 1;

func _ready():
	sp_material = SpoonMesh.get_surface_material(0)
	inputS = -SpoonMesh.mesh.size.x/2
	inputE = SpoonMesh.mesh.size.x/2
	pass

func _process(delta):
	P1.translation.z = 0.0;
	P2.translation.z = 0.0;
	P3.translation.z = 0.0;
	
	sp_material.set("shader_param/P1", map_range(P1.translation))
	sp_material.set("shader_param/P2", map_range(P2.translation))
	sp_material.set("shader_param/P3", map_range(P3.translation))
	
	print(map_range(P1.translation))
	pass

func map_range(X):
  return outputS + ((outputE-outputS)/(inputE-inputS)) * (X - inputS)