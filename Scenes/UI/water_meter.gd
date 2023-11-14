extends CanvasLayer

@onready var meter_container = %MeterContainer
@onready var slimer = %Slimer
@onready var water_progress_bar = %WaterProgressBar as ProgressBar
@onready var red_glow = %RedGlow
@onready var water_drops: GPUParticles2D = %WaterDrops

@export var slimer_start: Vector2
@export var slimer_end: Vector2

var increasing = true
var desired_value = 1
var the_tween

func _ready() -> void:
	GameEvents.health_changed.connect(update_particles)


func update_progress(value: float):
#	if the_tween:
#		the_tween.kill()
	the_tween = create_tween() as Tween
	the_tween.tween_property(water_progress_bar, "value", value, 0.2)


func _process(delta):
	if Input.is_action_pressed("jump") && water_progress_bar.value > 0:
		meter_container.modulate=Color.html("ff0d29")
		slimer.modulate=Color.html("ff0d29")
		red_glow.visible = true
	else:
		meter_container.modulate=Color.html("ffffff")
		slimer.modulate=Color.html("ffffff")	
		red_glow.visible = false
	slimer.position = lerp(slimer_start, slimer_end, water_progress_bar.value)
	if water_progress_bar.value <= 0:
		slimer.modulate=Color.html("ff0d29")
		water_drops.emitting = false
	else:
		water_drops.emitting = true


func update_particles(health: int):
	var amount = 5
	if health == 2:
		amount = 10
	if health == 1:
		amount = 20
	the_tween = create_tween() as Tween
	the_tween.tween_property(water_drops, "amount", amount, 0.2).from_current()

