extends TextureRect

const EMPTY_AMOUNT := -1
const X_OFFSET := 12
const X_OFFSET_MULTIPLIER := 28

@onready var texture_progress_bar = $TextureProgressBar

func adjust_progress_bar(percent: float) -> void:
	var display = percent > EMPTY_AMOUNT
	texture_progress_bar.visible = display
	if display:
		texture_progress_bar.position.x = X_OFFSET + X_OFFSET_MULTIPLIER * texture.current_frame
		texture_progress_bar.value = percent
