extends CharacterBody3D

# Signals
signal Entered


# References
@onready var head: Node3D = $Head
@onready var camera: Camera3D = $Head/Camera3D
@onready var Ray: RayCast3D = $Head/Camera3D/RayCast3D
@onready var texture: TextureRect = $Head/Camera3D/CanvasLayer/TextureRect
@onready var ani: AnimationPlayer = $AnimationPlayer
@onready var spot: SpotLight3D = $Head/Camera3D/Camera/Spot
@onready var flash_sound: AudioStreamPlayer3D = $Head/Camera3D/Camera/Flash
@onready var Line: LineEdit = $Head/Camera3D/CanvasLayer/LineEdit


# Export variables
@export var sens = 0.005
@export var max_lean := 10 #This is self explaintory make it 10 for extra nuttyness
@export var lean_smoothness := 10 #also this

# Variables
var bob_freq = 2.0
var bob_time = 0.0
var bob_amp = 0.08
var flashing = false
var is_on = false
var SPEED = 5.0
var can_flash = true
var cam_cooldown = 1.0
var JUMP_VELOCITY = 4.5

# Constants


func _input(event: InputEvent) -> void:
	if event is InputEventMouseMotion:
		head.rotate_y(-event.relative.x * sens)
		camera.rotate_x(-event.relative.y * sens)
		camera.rotation.x = clamp(camera.rotation.x, -90, 90)

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	texture.visible = false
	spot.visible = false
	Line.visible = false

func _physics_process(delta: float) -> void:
	
	if Ray.is_colliding():
		var target = Ray.get_collider()
		if target != null and target.has_method("Interact"):
			if Input.is_action_just_pressed("interact"):
				target.Interact()
	
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta
		
	# Handle jump.
	if Input.is_action_just_pressed("jump") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	if Input.is_action_just_pressed("ui_accept"):
		texture.visible = false

	#if Input.is_action_just_pressed("aim"):
		#ani.play("Camera")

	if Input.is_action_just_pressed("Click") and can_flash == true:
		flash_sound.play()
		do_flash()

	if Input.is_action_just_pressed("tab"):
		is_on = true
		if is_on == true:
			Line.visible = true
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
			is_on = false
	
	Cheats()
		
	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	var input_dir = Input.get_vector("left", "right", "foward", "backward")
	var direction = (head.transform.basis * Vector3(input_dir.x, 0, input_dir.y)).normalized()
	if direction:
		velocity.x = direction.x * SPEED
		velocity.z = direction.z * SPEED
	else:
		velocity.x = move_toward(velocity.x, 0, SPEED)
		velocity.z = move_toward(velocity.z, 0, SPEED)

	# QUITTING
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()
		
	if Input.is_action_just_pressed("on"):
		Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)


	# LEAN
	var target_lean = -input_dir.x * max_lean
	
	head.rotation_degrees.z = lerp(
		head.rotation_degrees.z,
		target_lean,
		delta * lean_smoothness,
		)
	# BOB
	if input_dir.length() > 0 and is_on_floor():
			bob_time += delta * velocity.length()
			head.position.y = (
				sin(bob_time * bob_freq) * bob_amp
				)

	else:
		# RESET SMOOTHLY
		head.position.y = lerp(head.position.y, 0.0, delta * 10)

	move_and_slide()


func _on_paper_picked_up() -> void:
	texture.visible = true

func do_flash():
	
		can_flash = false
		spot.visible = true
		spot.light_energy = 16.0
		
		await get_tree().create_timer(0.08).timeout
		
		var tween = create_tween()
		tween.tween_property(spot, "light_energy", 0.0, 0.2)
		await tween.finished
		
		spot.visible = false
		spot.light_energy = 0.0
		
		await get_tree().create_timer(cam_cooldown).timeout
		can_flash = true

func Cheats():
	if Line.text == "LIGHT 100":
		spot.light_energy = 16.0
		spot.visible = true
		
	if Line.text == "RESET":
		spot.light_energy = 0
		spot.visible = false
		Line.visible = false
		SPEED = 5.0
		JUMP_VELOCITY = 4.5
		
	if Line.text == "RESTART":
		get_tree().reload_current_scene()
		
	if Line.text == "QUIT":
		get_tree().quit()
	
	if Line.text == "SPEED 100":
		SPEED = 100.0
	
	if Line.text == "JUMP 100":
		JUMP_VELOCITY = 100.0
		


func _on_trigger_zone_body_entered(body: Node3D) -> void:
	emit_signal("Entered")
