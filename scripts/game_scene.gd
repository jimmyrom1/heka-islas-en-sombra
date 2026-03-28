extends Control

# Referencias a los nodos
@onready var background = $Background
@onready var character = $Character
@onready var speaker_label = $DialogPanel/SpeakerLabel
@onready var dialog_text = $DialogPanel/DialogText
@onready var choices_box = $DialogPanel/ChoicesBox

# Datos
var scenes_data = {}
var current_scene_id = ""

# Mapa speaker -> imagen de personaje
var speaker_portrait = {
	"Alanda": "prota.png",
	"Arlong": "novio.png",
	"Inspector": "malo_maloso.png",
	"Anciana": "vieja.png",
	"Soldado": "soldado_joven.png",
	"Narrador": ""
}

func _ready():
	load_scenes()
	start_game("P1")

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
	
	# Speaker
	speaker_label.text = scene["speaker"]
	
	# Texto
	dialog_text.text = scene["text"]
	
	# Fondo
	var bg_path = "res://assets/backgrounds/" + scene["background"]
	var bg_texture = load(bg_path)
	if bg_texture:
		background.texture = bg_texture
	
	# Personaje
	var portrait_file = speaker_portrait.get(scene["speaker"], "")
	if portrait_file == "":
		character.visible = false
	else:
		var char_path = "res://assets/characters/" + portrait_file
		var char_texture = load(char_path)
		if char_texture:
			character.texture = char_texture
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
