extends Control

@onready var MainGame: PackedScene
@onready var MainHolder = $Panel/VBoxContainer
@onready var QuitDialogue = $Panel/QuitDialogue
@onready var Credits = $Panel/Credits
@onready var QuitPanel = $QuitPanel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer

const CLICK = preload("res://Sounds/click.wav")

var activeGame
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	MainGame = load("res://Scenes/Main.tscn")
	Credits.visible = false
	QuitDialogue.visible = false
	MainHolder.visible = true
	
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("exit") and activeGame != null:
		audio_stream_player.stream = CLICK
		audio_stream_player.play()
		if activeGame.paused:
			QuitPanel.visible = false
			activeGame.unpause()
		else:
			QuitPanel.visible = true
			activeGame.pause()

func _on_cpu_button_pressed() -> void:
	activeGame = MainGame.instantiate()
	add_child(activeGame)
	move_child(activeGame,1)
	get_child(0).visible = false
	audio_stream_player.stream = CLICK
	audio_stream_player.play()

func _on_two_players_pressed() -> void:
	activeGame = MainGame.instantiate()
	add_child(activeGame)
	move_child(activeGame,1)
	get_child(0).visible = false
	audio_stream_player.stream = CLICK
	audio_stream_player.play()
	
func _on_credits_pressed() -> void:
	MainHolder.visible = false
	Credits.visible = true
	audio_stream_player.stream = CLICK
	audio_stream_player.play()

func _on_quit_pressed() -> void:
	QuitDialogue.visible = true
	audio_stream_player.stream = CLICK
	audio_stream_player.play()

func _on_yes_button_pressed() -> void:
	audio_stream_player.stream = CLICK
	audio_stream_player.play()
	get_tree().quit()

func _on_no_button_pressed() -> void:
	QuitDialogue.visible = false
	audio_stream_player.stream = CLICK
	audio_stream_player.play()

func _on_back_button_pressed() -> void:
	Credits.visible = false
	MainHolder.visible = true
	audio_stream_player.stream = CLICK
	audio_stream_player.play()


func _on_no_pressed() -> void:
	QuitPanel.visible = false
	QuitPanel.visible = false
	activeGame.unpause()
	audio_stream_player.stream = CLICK
	audio_stream_player.play()


func _on_yes_pressed() -> void:
	QuitPanel.visible = false
	activeGame.queue_free()
	get_child(0).visible = true
	audio_stream_player.stream = CLICK
	audio_stream_player.play()
	
