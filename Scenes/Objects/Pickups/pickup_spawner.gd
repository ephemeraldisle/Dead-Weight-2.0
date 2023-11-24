extends Node2D

@export var thing_to_spawn: PackedScene
@export var initial_delay = 0.5
@export var respawn_time = 30
@export var debug = false
@export var automatic_respawn = true
@onready var area_2d: Area2D = $Area2D
@onready var timer: Timer = $Timer

var waiting_to_spawn = false

func _ready() -> void:
	if !automatic_respawn:
		spawn_pickup()
		GameEvents.player_died.connect(spawn_pickup)
	timer.timeout.connect(timer_done)
	await get_tree().create_timer(initial_delay, false, true).timeout
	while automatic_respawn == true:
		check_kids()
		await get_tree().create_timer(1, false, true).timeout

func start_spawn_timer() -> void:
	if debug:
		print_debug("starting respawn timer")
	waiting_to_spawn = true
	timer.start(respawn_time)
	
func timer_done() -> void:
	waiting_to_spawn = false

func spawn_pickup() -> void:
	if debug:
		print_debug("spawning pickup")
	if get_child_count() <3:
		var pickup = thing_to_spawn.instantiate()
		add_child(pickup)
		pickup.global_position = global_position
		pickup.collected.connect(child_grabbed)
	
	
func child_grabbed() -> void:
	if debug:
		print_debug("child grabbed")
	start_spawn_timer()
	check_kids()

func check_kids() -> void:
	if debug:
		print_debug("checking kids")
		print_debug(timer.time_left)
	if area_2d.get_overlapping_bodies().size() != 0:
		if debug:
			print_debug("we got overlap")
		start_spawn_timer()
		return
	if get_child_count() <3 && !waiting_to_spawn:
		spawn_pickup()
