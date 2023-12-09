extends Node

const HEAL_WATER_DRAIN = 0.00025

var health = 3
signal health_changed
signal damaged

@export var regen_time = 10
@export var controller: Node
@export var water_manager: Node
@onready var timer = $Timer

func _ready():
	GameEvents.full_heal.connect(full_heal)
	timer.timeout.connect(on_timer_timeout)
	controller.player_damaged.connect(on_damage)
#	await get_tree().create_timer(2).timeout
#	on_damage()

func _process(_delta):
#	print(timer.time_left)
	if timer.time_left > 0:
		GameEvents.emit_water_collected(-HEAL_WATER_DRAIN)
	if health == 3:
		timer.stop()

func full_heal():
	health = 3
	health_changed.emit()
	GameEvents.emit_health_changed(health)

func on_damage():
	health -=1
	damaged.emit()
	if health > 0:
#		SharedPlayerManager.player.play_hurt_sounds()
		health_changed.emit()
		GameEvents.emit_health_changed(health)
		if timer.time_left > 0:
			timer.stop()
		timer.start(regen_time)
	elif health == 0:
		SharedPlayerManager.die()

func on_timer_timeout():
	if health < 3 && health > 0:
		health += 1
		GameEvents.emit_health_changed(health)
		health_changed.emit()
	if health <3:
		timer.start(regen_time)
