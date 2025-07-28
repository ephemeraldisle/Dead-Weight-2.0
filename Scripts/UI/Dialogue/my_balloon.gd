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
var is_visible := false

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
			# Disconnect the mutation signal to prevent infinite loops
			if Engine.get_singleton("DialogueManager").mutated.is_connected(_on_mutated):
				Engine.get_singleton("DialogueManager").mutated.disconnect(_on_mutated)
			
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
		character_label.text = tr("[right]%s [/right]" % dialogue_line.character, "dialogue")
		character_name_background.visible = not dialogue_line.character.is_empty()
		
		var new_width: int = character_label.get_content_width() + 10
		var difference: float = new_width - character_background_original_size.x
		character_name_background.size = Vector2(new_width, character_label.get_content_height())
		character_name_background.position.x = character_background_original_position.x - difference
		
		dialogue_label.modulate.a = 0
		dialogue_label.custom_minimum_size.x = dialogue_label.get_parent().size.x - 1
		dialogue_label.dialogue_line = dialogue_line
		if not dialogue_line.character.is_empty():
			var new_speaker = get_tree().get_first_node_in_group("%s" % dialogue_line.character)
			if new_speaker != speaker:
				if speaker != null:
					speaker.ping_animation.animation_player.play("RESET")
				speaker = new_speaker
			if speaker != null:
				speaker.ping_animation.animation_player.play("ping")
				if speaker.ping_animation.portrait_texture.size() - 1 >= GameState.alternate_face:
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
			animation_player.play("Appear With Portrait")
			is_visible = true
		elif !is_visible:
			animation_player.play("Appear")
			is_visible = true
		will_hide_balloon = false

		test_label.text = dialogue_line.text
		main_bubble_margin_container.size.y = test_label.get_content_height() + 50
		prompt_holder.position.y = main_bubble_margin_container.size.y + prompt_holder_offset

		dialogue_label.modulate.a = 1
		if not dialogue_line.text.is_empty():
			dialogue_label.type_out()
			await dialogue_label.finished_typing
		
		# Wait for input
		if dialogue_line.responses.size() > 0:
			responses_menu.modulate.a = 1
			configure_menu()
		elif dialogue_line.time != null and dialogue_line.time != "":
			var time: float = dialogue_line.text.length() * 0.02 if dialogue_line.time == "auto" else dialogue_line.time.to_float()
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
	
	Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)


func _unhandled_input(event: InputEvent) -> void:
	# Handle E key for dialogue advancement
	if is_waiting_for_input and dialogue_line != null and dialogue_line.responses.size() == 0:
		if event.is_action_pressed("interact"):
			get_viewport().set_input_as_handled()
			next(dialogue_line.next_id)
			return
	
	# Only the balloon is allowed to handle input while it's showing
	get_viewport().set_input_as_handled()


## Start some dialogue
func start(dialogue_resource: DialogueResource, title: String, extra_game_states: Array = []) -> void:
	# Ensure we're connected to the mutation signal
	if not Engine.get_singleton("DialogueManager").mutated.is_connected(_on_mutated):
		Engine.get_singleton("DialogueManager").mutated.connect(_on_mutated)
	
	temporary_game_states = extra_game_states
	is_waiting_for_input = false
	resource = dialogue_resource
	self.dialogue_line = await resource.get_next_dialogue_line(title, temporary_game_states)


## Go to the next line
func next(next_id: String) -> void:
	self.dialogue_line = await resource.get_next_dialogue_line(next_id, temporary_game_states)


### Helpers


func place_balloon(global_pos: Vector2) -> void:
	placer.global_position = global_pos


## Get a line of dialogue
func get_line(key: String) -> DialogueLine:
	return await resource.get_next_dialogue_line(key, temporary_game_states)


## Get the menu that is displayed when there are multiple player responses to choose from
func configure_menu() -> void:
	balloon.focus_mode = Control.FOCUS_NONE

	var items := []
	for i in responses_menu.get_child_count():
		var item: Control = responses_menu.get_child(i)
		if item.name.begins_with("Response"):
			item.focus_mode = Control.FOCUS_ALL
			item.focus_neighbor_left = item.get_path()
			item.focus_neighbor_right = item.get_path()
			
			if i == 0:
				item.focus_neighbor_top = item.get_path()
				item.focus_previous = item.get_path()
			else:
				item.focus_neighbor_top = responses_menu.get_child(i - 1).get_path()
			
			if i == responses_menu.get_child_count() - 1:
				item.focus_neighbor_bottom = item.get_path()
				item.focus_next = item.get_path()
			else:
				item.focus_neighbor_bottom = responses_menu.get_child(i + 1).get_path()
				
			item.mouse_entered.connect(_on_response_mouse_entered.bind(item))
			item.gui_input.connect(_on_response_gui_input.bind(item))
			
			items.append(item)

	if items.size() > 0:
		items[0].grab_focus()


### Signals


func _on_mutated(_mutation: Dictionary) -> void:
	# Guard against mutations when dialogue has ended
	if dialogue_line == null:
		return
		
	is_waiting_for_input = false
	will_hide_balloon = true
	get_tree().process_frame.connect(func():
		if will_hide_balloon and dialogue_line != null:
			will_hide_balloon = false
			self.dialogue_line = await resource.get_next_dialogue_line(dialogue_line.next_id, temporary_game_states)
	, CONNECT_ONE_SHOT)


func _on_balloon_gui_input(event: InputEvent) -> void:
	# If the user clicks on the balloon while it's typing then skip typing
	if dialogue_label.is_typing:
		get_viewport().set_input_as_handled()
		dialogue_label.skip_typing()
		return
	
	if not is_waiting_for_input: return
	if dialogue_line.responses.size() > 0: return
	
	# When there are no response options the balloon itself is the clickable thing
	get_viewport().set_input_as_handled()
	
	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.next_id)
	elif event.is_action_pressed("ui_accept") and get_viewport().gui_get_focus_owner() == balloon:
		next(dialogue_line.next_id)
	elif event.is_action_pressed("interact"):  # Add E key support
		next(dialogue_line.next_id)


func _on_response_mouse_entered(item: Control) -> void:
	if "Disallowed" in item.name: return
	item.grab_focus()


func _on_response_gui_input(event: InputEvent, item: Control) -> void:
	if "Disallowed" in item.name: return
	
	get_viewport().set_input_as_handled()

	if event is InputEventMouseButton and event.is_pressed() and event.button_index == MOUSE_BUTTON_LEFT:
		next(dialogue_line.responses[item.get_index()].next_id)
	elif event.is_action_pressed("ui_accept") and item in responses_menu.get_children():
		next(dialogue_line.responses[item.get_index()].next_id)


func _on_margin_resized() -> void:
	if not is_instance_valid(dialogue_label): return
	
	dialogue_label.custom_minimum_size.x = dialogue_label.get_parent().size.x
