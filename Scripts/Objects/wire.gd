extends Path2D

@export var flip := false
@export var on_material: ShaderMaterial
@export var off_material: ShaderMaterial

@onready var wire_art: Line2D = $WireArt

func _ready() -> void:
	var curve_points = curve.get_baked_points()
	if flip:
		curve_points.reverse()
	wire_art.points = curve_points

func change_power(powered: bool) -> void:
	if powered:
		wire_art.material = on_material
	else:
		wire_art.material = off_material
