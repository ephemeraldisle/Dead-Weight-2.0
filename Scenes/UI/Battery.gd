extends TextureRect

@onready var texture_progress_bar = $TextureProgressBar

func adjust_progress_bar(percent: float):
	var truth = percent > -1
	texture_progress_bar.visible = truth
	if truth:
		texture_progress_bar.position.x = 12 + 28 * texture.current_frame
		texture_progress_bar.value = percent
