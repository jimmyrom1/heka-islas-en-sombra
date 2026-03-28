extends Control

@onready var background = $Background
@onready var character = $Character
@onready var speaker_label = $DialogPanel/VBoxContainer/SpeakerLabel
@onready var dialog_text = $DialogPanel/VBoxContainer/DialogText
@onready var choices_box = $DialogPanel/VBoxContainer/ChoicesBox

var scenes_data = {}
var current_scene_id = ""

var speaker_portrait = {
	"Alanda": "prota.png",
	"Arlong": "novio.png",
	"Inspector": "malo_maloso.png",
	"Anciana": "vieja.png",
	"Soldado": "soldado_joven.png",
	"Narrador": ""
}

# Typewriter
var _full_text = ""
var _typing = false
var _typewriter_tween: Tween = null

func _ready():
	var vp = get_viewport_rect().size

	# Fondo - toda la pantalla
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED

	# Personaje - lado derecho, 75% de la altura del viewport
	character.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	character.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
	var char_h = vp.y * 0.75
	# Contenedor cuadrado; KEEP_ASPECT_CENTERED ajustará la imagen real
	character.size = Vector2(char_h, char_h)
	character.position = Vector2(vp.x - char_h - 20.0, 0.0)

	load_scenes()
	start_game("P1")

func _input(event: InputEvent):
	if event is InputEventMouseButton and event.pressed and event.button_index == MOUSE_BUTTON_LEFT:
		_complete_typewriter()

# --- Typewriter ---

func _start_typewriter(text: String):
	_full_text = text
	_typing = true
	dialog_text.text = text
	dialog_text.visible_characters = 0
	if _typewriter_tween:
		_typewriter_tween.kill()
	_typewriter_tween = create_tween()
	# 0.03 s por carácter
	_typewriter_tween.tween_property(dialog_text, "visible_characters", text.length(), text.length() * 0.03)
	_typewriter_tween.tween_callback(func(): _typing = false)

func _complete_typewriter():
	if not _typing:
		return
	if _typewriter_tween:
		_typewriter_tween.kill()
		_typewriter_tween = null
	dialog_text.visible_characters = -1  # muestra todo
	_typing = false

# --- Carga de datos ---

func load_scenes():
	var file = FileAccess.open("res://data/scenes.json", FileAccess.READ)
	if file == null:
		push_error("No se pudo abrir scenes.json")
		return
	var json_string = file.get_as_text()
	file.close()

	var json = JSON.new()
	var error = json.parse(json_string)
	if error != OK:
		push_error("Error al parsear scenes.json: " + json.get_error_message())
		return

	scenes_data = json.get_data()

func start_game(scene_id: String):
	load_scene(scene_id)

func load_scene(scene_id: String):
	if scene_id == "MENU":
		get_tree().change_scene_to_file("res://scenes/menu_scene.tscn")
		return

	if not scenes_data.has(scene_id):
		push_error("Escena no encontrada: " + scene_id)
		return

	current_scene_id = scene_id
	var scene = scenes_data[scene_id]

	speaker_label.text = scene["speaker"]

	# Fondo
	var bg_path = "res://assets/backgrounds/" + scene["background"]
	var bg_texture = load(bg_path)
	if bg_texture:
		background.texture = bg_texture

	# Personaje - escala según aspecto real de la textura
	var portrait_file = speaker_portrait.get(scene["speaker"], "")
	if portrait_file == "":
		character.visible = false
	else:
		var char_path = "res://assets/characters/" + portrait_file
		var char_texture = load(char_path)
		if char_texture:
			character.texture = char_texture
			var vp = get_viewport_rect().size
			var char_h = vp.y * 0.75
			var char_w = char_h * char_texture.get_width() / float(char_texture.get_height())
			character.size = Vector2(char_w, char_h)
			character.position = Vector2(vp.x - char_w - 20.0, 0.0)
			character.visible = true
		else:
			character.visible = false

	# Botones de elección
	for child in choices_box.get_children():
		child.queue_free()

	for choice in scene["choices"]:
		var btn = Button.new()
		btn.text = choice["text"]
		var next_id = choice["next"]
		btn.pressed.connect(func(): load_scene(next_id))
		choices_box.add_child(btn)

	# Texto con efecto typewriter
	_start_typewriter(scene["text"])
