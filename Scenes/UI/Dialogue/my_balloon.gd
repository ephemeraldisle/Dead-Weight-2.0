extends CanvasLayer

@onready var placer = $Placer

@onready var balloon: NinePatchRect = $%Balloon
@onready var margin: MarginContainer = $%Margin
@onready var character_label: RichTextLabel = $%CharacterLabel
@onready var dialogue_label: DialogueLabel = $%DialogueLabel
@onready var responses_menu: VBoxContainer = $%Responses
@onready var response_template: RichTextLabel = %ResponseTemplate
@onready var animation_player: AnimationPlayer = $AnimationPlayer 
@onready var character_name_background = $Placer/CharacterNameBackground
@onready var main_bubble_margin_container = $Placer/MainBubbleMarginContainer
@onready var test_label = %TestLabel
@onready var prompt_holder = $Placer/PromptHolder
@onready var portrait: TextureRect = %Portrait

var main_bubble_original_position
var main_bubble_original_size
var character_background_original_position
var character_background_original_size
var prompt_holder_original_position
var prompt_holder_offset
var speaker
var is_visible = false

## The dialogue resource
var resource: DialogueResource

## Temporary game states
var temporary_game_states: Array = []

## See if we are waiting for the player
var is_waiting_for_input: bool = false

## See if we are running a long mutation and should hide the balloon
var will_hide_balloon: bool = false

## The current line
var dialogue_line: DialogueLine:
	set(next_dialogue_line):
		is_waiting_for_input = false

		if not next_dialogue_line:
			if speaker != null:
				speaker.ping_animation.animation_player.play("RESET")
				animation_player.play_backwards("Appear With Portrait")
				is_visible = false
			else:
				animation_player.play_backwards("Appear")
				is_visible = false
			GameState.dialogue_happening = false
			return

		# Remove any previous responses
		for child in responses_menu.get_children():
			responses_menu.remove_child(child)
			child.queue_free()
		
		
		
		dialogue_line = next_dialogue_line

		character_label.visible = not dialogue_line.character.is_empty()
		character_label.text = tr("[right]%s [/right]" %dialogue_line.character, "dialogue")
		character_name_background.visible = not dialogue_line.character.is_empty()
		
		var new_width = character_label.get_content_width()+10
		var difference = new_width - character_background_original_size.x
		character_name_background.size = Vector2(new_width, character_label.get_content_height())
		character_name_background.position.x = character_background_original_position.x - difference
		
		dialogue_label.modulate.a = 0
		dialogue_label.custom_minimum_size.x = dialogue_label.get_parent().size.x - 1
		dialogue_label.dialogue_line = dialogue_line
		if not dialogue_line.character.is_empty():
			var new_speaker = get_tree().get_first_node_in_group("%s" %dialogue_line.character)
			if new_speaker != speaker:
				if speaker != null:
					speaker.ping_animation.animation_player.play("RESET")
				speaker = new_speaker
			if speaker != null:
				speaker.ping_animation.animation_player.play("ping")
				if speaker.ping_animation.portrait_texture.size()-1 >= GameState.alternate_face:
					portrait.texture = speaker.ping_animation.portrait_texture[GameState.alternate_face]
				else:
					portrait.texture = speaker.ping_animation.portrait_texture[0]
		elif speaker != null:
			speaker.ping_animation.animation_player.play("RESET")
		# Show any responses we have
		responses_menu.modulate.a = 0
		if dialogue_line.responses.size() > 0:
			for response in dialogue_line.responses:
				# Duplicate the template so we can grab the fonts, sizing, etc
				var item: RichTextLabel = response_template.duplicate(0)
				item.name = "Response%d" % responses_menu.get_child_count()
				if not response.is_allowed:
					item.name = String(item.name) + "Disallowed"
					item.modulate.a = 0.4
				item.text = response.text
				item.show()
				responses_menu.add_child(item)

		# Show our balloon
		balloon.show()
		if not is_visible and speaker != null:
			print("need portrait")
			animation_player.play("Appear With Portrait")
			is_visible = true
		elif !is_visible:
			animation_player.play("Appear")
			is_visible = true
		will_hide_balloon = false

		test_label.text = dialogue_line.text
		main_bubble_margin_container.size.y = test_label.get_content_height() + 50
		prompt_holder.position.y = main_bubble_margin_container.size.y + prompt_holder_offset
#		main_bubble_margin_container.size.x = test_label.get_content_width()+60
#		balloon.custom_minimum_size.x = test_label.get_content_width()+40

		dialogue_label.modulate.a = 1
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing
		
		
		
		# Wait for input
		if dialogue_line.responses.size() > 0:
			responses_menu.modulate.a = 1
			configure_menu()
		elif dialogue_line.time != null:
			var time = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
			await get_tree().create_timer(time).timeout
			next(dialogue_line.next_id)
		else:
			is_waiting_for_input = true
			balloon.focus_mode = Control.FOCUS_ALL
			balloon.grab_focus()
	get:
		return dialogue_line


func _ready() -> void:
	response_template.hide()
	balloon.hide()
	character_background_original_position = character_name_background.position
	character_background_original_size = character_name_background.size
	main_bubble_original_position = main_bubble_margin_container.position
	main_bubble_original_size = main_bubble_margin_container.size
	prompt_holder_original_position = prompt_holder.position
	prompt_holder_offset = prompt_holder_original_position.y - main_bubble_original_size.y
#	balloon.custom_minimum_size.x = balloon.get_viewport_rect().size.x
	
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)


func _unhandled_input(_event: InputEvent) -> void:
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()
	_on_balloon_gui_input(_event)

## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	
	GameState.dialogue_happening = true
	temporary_game_states = extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource

	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


### Helpers

# Set up keyboard movement and signals for the response menu
func configure_menu() -> void:
	balloon.focus_mode = Control.FOCUS_NONE

	var items = get_responses()
	for i in items.size():
		var item: Control = items[i]

		item.focus_mode = Control.FOCUS_ALL

		item.focus_neighbor_left = item.get_path()
		item.focus_neighbor_right = item.get_path()

		if i == 0:
			item.focus_neighbor_top = item.get_path()
			item.focus_previous = item.get_path()
		else:
			item.focus_neighbor_top = items[i - 1].get_path()
			item.focus_previous = items[i - 1].get_path()

		if i == items.size() - 1:
			item.focus_neighbor_bottom = item.get_path()
			item.focus_next = item.get_path()
		else:
			item.focus_neighbor_bottom = items[i + 1].get_path()
			item.focus_next = items[i + 1].get_path()

		item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
		item.gui_input.connect(_on_response_gui_input.bind(item))

	items[0].grab_focus()


# Get a list of enabled items
func get_responses() -> Array:
	var items: Array = []
	for child in responses_menu.get_children():
		if "Disallowed" in child.name: continue
		items.append(child)

	return items


func handle_resize() -> void:
	if not is_instance_valid(margin):
		call_deferred("handle_resize")
		return

	#balloon.custom_minimum_size.y = margin.size.y
	# Force a resize on only the height
	#balloon.size.y = 0
#	var viewport_size = balloon.get_viewport_rect().size
	#balloon.global_position = Vector2((viewport_size.x - balloon.size.x) * 0.5, viewport_size.y - balloon.size.y)


### Signals


func _on_mutated(_mutation: Dictionary) -> void:
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().create_timer(0.1).timeout.connect(func():
		if will_hide_balloon:
			will_hide_balloon = false
			balloon.hide()
	)


func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return

	item.grab_focus()


func _on_response_gui_input(event: InputEvent, item: Control) -> void:
	if "Disallowed" in item.name: return

	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == 1:
		next(dialogue_line.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in get_responses():
		next(dialogue_line.responses[item.get_index()].next_id)


func _on_balloon_gui_input(event: InputEvent) -> void:
	
	# If the user clicks on the balloon while it's typing then skip typing
	if dialogue_label.is_typing and (event.is_pressed()) and ((event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT)  || event.is_action_pressed("interact")):
		get_viewport().set_input_as_handled()
		dialogue_label.skip_typing()
		return

	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return
	
	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()
	if (event is InputEventMouseButton and event.is_pressed()) or event.is_action_pressed("interact"):
		next(dialogue_line.next_id)


func _on_margin_resized() -> void:
	handle_resize()

func place_balloon(pos: Vector2):
	placer.position = pos
	
