extends TextureRect

const PROGRESS_BAR_X_BASE = 12
const BATTERY_BAR_SEPARATION = 28

@onready var texture_progress_bar = $TextureProgressBar
@onready var sparks: GPUParticles2D = $Sparks


func change_progress_bar_visibility(visibility: bool) -> void:
	texture_progress_bar.visible = visibility


func adjust_progress_bar_position(number_of_bars: int) -> void:
	texture_progress_bar.position.x = PROGRESS_BAR_X_BASE + BATTERY_BAR_SEPARATION * number_of_bars


func adjust_progress_bar_fill(percent: float):
	texture_progress_bar.value = percent

