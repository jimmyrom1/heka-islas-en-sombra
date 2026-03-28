extends Control

@onready var background = $Background
@onready var title_image = $TitleImage
@onready var vbox = $VBoxContainer

func _ready():
	var vp = get_viewport_rect().size

	# Fondo - toda la pantalla
	var bg_texture = load("res://assets/backgrounds/fondo_menu.jpg")
	if bg_texture:
		background.texture = bg_texture
	background.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
	background.stretch_mode = TextureRect.STRETCH_SCALE

	# Título - 40% del ancho, relación de aspecto real de la textura, centrado, tercio superior
	var title_texture = load("res://assets/backgrounds/titulo_.png")
	if title_texture:
		title_image.texture = title_texture
		var tex_size = title_texture.get_size()
		var title_w = vp.x * 0.40
		var title_h = title_w * tex_size.y / tex_size.x
		title_image.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
		title_image.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		title_image.size = Vector2(title_w, title_h)
		title_image.position = Vector2((vp.x - title_w) / 2.0, vp.y * 0.08)

		# Animación flotante
		var start_y = title_image.position.y
		var tween = create_tween()
		tween.set_loops()
		tween.tween_property(title_image, "position:y", start_y - 10.0, 1.2)
		tween.tween_property(title_image, "position:y", start_y, 1.2)

	# Botones - centrados en el tercio inferior
	vbox.set_anchors_and_offsets_preset(Control.PRESET_TOP_LEFT)
	vbox.size = Vector2(250.0, 170.0)
	vbox.position = Vector2((vp.x - 250.0) / 2.0, vp.y * 0.68)

func _on_btn_nueva_partida_pressed():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_btn_cargar_partida_pressed():
	get_tree().change_scene_to_file("res://scenes/game_scene.tscn")

func _on_btn_salir_pressed():
	get_tree().quit()
