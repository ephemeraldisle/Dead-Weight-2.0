extends CanvasLayer

@onready var power_indicator: TextureRect = %PowerIndicator
@onready var battery_holder = %BatteryHolder
@onready var power_indicator_animator: AnimationPlayer = %PowerIndicatorAnimator
@onready var sparks: GPUParticles2D = $MarginContainer/BatteryHolder/Battery0/Sparks
@onready var battery_children = battery_holder.get_children()
var previous_percent = 1.0
var current_percent = 1.0
var animating = false
var power_on_ticks = 0

func _ready():
	power_indicator.hide()

func _physics_process(delta: float) -> void:
	if current_percent < previous_percent:
		power_on_ticks = 0
		power_indicator.show()
		animation_on()
	elif animating:
		power_on_ticks += 1
		if power_on_ticks >= 20:
			animating = false
			animation_off()
			power_on_ticks = 0
	previous_percent = current_percent

func animation_on():
	if not animating:
		animating = true
		sparks.emitting = true
		power_indicator_animator.play("poweron")
		await power_indicator_animator.animation_finished
		if animating:
			power_indicator_animator.play("on")

func animation_off():
	power_indicator_animator.play_backwards("poweron")
	sparks.emitting = false
	await power_indicator_animator.animation_finished
	power_indicator.hide()
		
func update_energy(current_energy: int, max_energy: int, percent: float):
	current_percent = percent
	if max_energy < 4:
		print("ALERT ENERGY SETUP IS WRONG")
	var potential_batteries = 0
	var assigned_progress_bar = false
	@warning_ignore("integer_division")
	for i in floor(max_energy/4):
		battery_children[i].visible = true
		potential_batteries+=1
	if potential_batteries < 4:
		for i in 4 - potential_batteries:
			battery_children[i-1].adjust_progress_bar(-1)
			battery_children[i-1].texture.current_frame = 0
	if current_energy > max_energy:
		current_energy = max_energy
		print("ENERGY ERROR MORE ENERGY THAN BATTERIES")
	for i in floor(current_energy/4):
		battery_children[potential_batteries-1].texture.current_frame = 4
		battery_children[potential_batteries-1].adjust_progress_bar(-1)
		current_energy -= 4
		potential_batteries -= 1
	for i in potential_batteries:
		var energy_amount = clamp(current_energy % 4, 0, 4)
		battery_children[potential_batteries-1].texture.current_frame = energy_amount
		current_energy -= energy_amount
		if !assigned_progress_bar:
			battery_children[potential_batteries-1].adjust_progress_bar(current_percent)
			assigned_progress_bar = true
		else:
			battery_children[potential_batteries-1].adjust_progress_bar(-1)
		potential_batteries -= 1
	
