extends Node2D

const GRAVITY : int = 1000
const MAX_VEL : int = 600
const FLAP_SPEED:int = -500
const SCROLL_SPEED : int = 4
const PIPE_DELAY: int = 100
const PIPE_RANGE: int = 200

var gameRunning : bool
var gameOver : bool
var scroll
var score
var screenSize
var groundHeight:int = 100
var pipes : Array

var flying :  bool = false
var falling : bool = true
const START_POS = Vector2(200, 540)

@onready var player: CharacterBody2D = $Player

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	reset()

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	if Input.is_action_just_pressed("flap"):
		if not gameRunning:
			start_game()
		else:
			if flying:
				flap()
				
func start_game():
	gameRunning = true
	flying = true

func new_game():
	gameRunning = false
	gameOver = true
	score = 0
	scroll = 0
	reset()

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
		if flying:
			player.set_rotation(deg_to_rad(player.velocity.y * 0.05))
		elif  falling:
			player.set_rotation(PI/2)
	player.move_and_collide(player.velocity * delta)

func flap():
	player.velocity.y = FLAP_SPEED


func _on_ground_body_entered(body: Node2D) -> void:
	pass # Replace with function body.
