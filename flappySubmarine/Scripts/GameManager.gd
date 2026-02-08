extends Node2D

const GRAVITY : int = 1000
const MAX_VEL : int = 600
const FLAP_SPEED:int = -500
const SCROLL_SPEED : int = 4
const PIPE_DELAY: int = 100
const PIPE_RANGE: int = 200
const START_POS = Vector2(200, 540)
const GAP_RANGE = Vector2(200,400)

var gameRunning : bool
var gameOver : bool
var scroll = 0.0
var score = 0
var screenSize
var groundHeight:int = 100
var pipes : Array
var paused = false

var flying :  bool = false
var falling : bool = true
var lastVelocity

@onready var player: CharacterBody2D = $Player
@onready var ground: Area2D = $Ground
@onready var pipe_holder: Node2D = $"Pipe Holder"
@onready var timer: Timer = $Timer
@onready var score_label: Label = $BackGround/ScoreLabel
@onready var audio_stream_player: AudioStreamPlayer = $AudioStreamPlayer
@onready var highscore_label: Label = $"Panel/Label/Highscore Label"


const PIPE_DOWN = preload("res://Prefabs/pipe_down.tscn")
const PIPE_UP = preload("res://Prefabs/pipe_up.tscn")
const GAP = preload("res://Prefabs/gap.tscn")
const LOSE_SOUND_1_0 = preload("res://Sounds/lose sound 1_0.wav")
const SCORE = preload("res://Sounds/Score.wav")

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	score_label.text = str(score)
	screenSize = get_viewport_rect().size
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if gameRunning:
		scroll += SCROLL_SPEED
		if scroll >= screenSize.x * 2:
			scroll = 0
		ground.position.x = -scroll
		pipe_holder.position.x -= SCROLL_SPEED
	
	if Input.is_action_just_pressed("flap"):
		if not gameRunning:
			start_game()
		else:
			if flying:
				flap()
				check_top()

func pause():
	paused = true
	gameRunning = false
	timer.paused = true
	lastVelocity = player.velocity
	player.velocity = Vector2.ZERO
	player.move_and_collide(Vector2.ZERO)
	
func unpause():
	paused = false
	gameRunning = true
	timer.paused = false
	
func start_game():
	gameRunning = true
	flying = true
	score = 0
	score_label.text = str(score)
	flap()
	timer.start()

func new_game():
	gameRunning = false
	gameOver = true
	flying = false
	falling = false
	score = 0
	scroll = 0
	ground.position.x = -scroll
	for x in pipe_holder.get_children():
		x.queue_free()
	reset()
	await get_tree().create_timer(0.1).timeout
	generate_pipes()

func reset():
	falling = false
	flying = false
	player.position = START_POS
	player.set_rotation(0)

func _physics_process(delta: float) -> void:
	if flying or falling:
		player.velocity.y += GRAVITY * delta
		if player.velocity.y > MAX_VEL:
			player.velocity.y = MAX_VEL
		if flying and not paused:
			player.set_rotation(deg_to_rad(player.velocity.y * 0.05))
		elif falling:
			player.set_rotation(PI/2)
		if not paused:
			player.move_and_collide(player.velocity * delta)

func flap():
	player.velocity.y = FLAP_SPEED


func _on_ground_body_entered(_body: Node2D) -> void:
	falling = false
	stop_game()

func birdHit(_body: Node2D) -> void:
	falling = true
	stop_game()

func check_top():
	if player.position.y < 0:
		falling = true
		stop_game()

func stop_game():
	timer.stop()
	flying = false
	falling = false
	gameRunning = false
	gameOver = true
	new_game()
	audio_stream_player.stream = LOSE_SOUND_1_0
	audio_stream_player.play()

func add_score(_body):
	audio_stream_player.stream = SCORE
	audio_stream_player.play()
	score += 1
	score_label.text = str(score)
	

func generate_pipes():
	var pipe_up = PIPE_UP.instantiate()
	var pipe_down = PIPE_DOWN.instantiate()
	pipe_holder.add_child(pipe_up)
	pipe_holder.add_child(pipe_down)
	var gapSize = randf_range(GAP_RANGE.x,GAP_RANGE.y)
	var gapPos = randf_range(gapSize + 100, 850-gapSize)
	pipe_up.global_position.x = screenSize.x + PIPE_DELAY
	pipe_up.global_position.y = gapPos -(gapSize/2)
	pipe_down.global_position.x = screenSize.x + PIPE_DELAY
	pipe_down.global_position.y = gapPos + (gapSize/2)
	pipe_up.body_entered.connect(birdHit)
	pipe_down.body_entered.connect(birdHit)
	var gap = GAP.instantiate()
	pipe_holder.add_child(gap)
	gap.global_position.x = screenSize.x + PIPE_DELAY
	gap.global_position.y = gapPos
	gap.get_child(0).shape.size.y = gapSize
	gap.body_entered.connect(add_score)
	
func _on_timer_timeout() -> void:
	generate_pipes()
	
