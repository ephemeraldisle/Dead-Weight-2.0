extends Path2D
@onready var wire_art: Line2D = $WireArt

func _ready() -> void:
	wire_art.points = curve.get_baked_points()
