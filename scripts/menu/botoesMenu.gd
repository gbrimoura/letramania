extends Control

@export var bus_name: String = "Musica"  # Permite definir o nome do bus no editor
var musica: int
@onready var background = $Background
@onready var pacienteMenu: TextureRect = get_node_or_null("PacienteMenu")
@onready var botao_click = get_node("Click")
@onready var botao_iniciar = get_node_or_null("Botoes/Iniciar")
@onready var botao_sair = get_node_or_null("Botoes/Sair")
@onready var botao_musica = get_node_or_null("Botoes/MusgaOnOff")
@onready var botao_configuracoes = get_node_or_null("Botoes/Configuraçoes")
var texture_normal
var texture_highlight
var texture_pressed
var next_scene

func ajustar_tamanho_botoes() -> void:
	var viewport_size = get_viewport_rect().size
	var viewport_w = viewport_size.x
	var viewport_h = viewport_size.y
	var is_large_screen = viewport_w >= 1600.0
	var is_medium_screen = viewport_w >= 1200.0 and viewport_w < 1600.0

	var principal_w = 400.0
	var principal_h = 120.0
	if is_large_screen:
		principal_w = viewport_w * 0.285
		principal_h = viewport_h * 0.13
	elif is_medium_screen:
		principal_w = viewport_w * 0.255
		principal_h = viewport_h * 0.124
	else:
		principal_w = viewport_w * 0.325
		principal_h = viewport_h * 0.12

	principal_w = clamp(principal_w, 340.0, 550.0)
	principal_h = clamp(principal_h, 100.0, 160.0)

	var icon_size = clamp(viewport_w * 0.048, 60.0, 96.0)
	var principal_size = Vector2(principal_w, principal_h)
	var icon_button_size = Vector2(icon_size, icon_size)

	if botao_iniciar:
		botao_iniciar.custom_minimum_size = principal_size
		botao_iniciar.size = principal_size
		botao_iniciar.scale = Vector2.ONE
	if botao_sair:
		botao_sair.custom_minimum_size = principal_size
		botao_sair.size = principal_size
		botao_sair.scale = Vector2.ONE
	if botao_musica:
		botao_musica.custom_minimum_size = icon_button_size
		botao_musica.size = icon_button_size
		botao_musica.scale = Vector2.ONE
	if botao_configuracoes:
		botao_configuracoes.custom_minimum_size = icon_button_size
		botao_configuracoes.size = icon_button_size
		botao_configuracoes.scale = Vector2.ONE
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	$Background.texture = load("res://assets/menu/background_" + Configuracoes.nome_tema + ".png")	
	if pacienteMenu:
		$PacienteMenu.texture = load("res://assets/menu/background_" + Configuracoes.nome_tema + ".png")
	
	ajustar_background()
	ajustar_tamanho_botoes()
	get_viewport().size_changed.connect(ajustar_tamanho_botoes)
	musica = AudioServer.get_bus_index(bus_name)
	if Jogo.word_size == 6 and Jogo.vidas >= 0:
		$Iniciar.texture_normal = preload("res://assets/parabenizacao/Botões/InicioBase.png")
		$Iniciar.texture_hover = preload("res://assets/parabenizacao/Botões/InicioHighlight.png")
		$Iniciar.texture_pressed = preload("res://assets/parabenizacao/Botões/InicioPressed.png")
	elif Jogo.vidas != -1 and Jogo.vidas <= 0:
		Jogo.word_size = 3
		Jogo.tempo_decorrido = 0.0
		Jogo.vidas = Configuracoes.config["vidas"]
func ajustar_background():
	if background and background.texture:
		background.size = get_viewport_rect().size
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		
		
func _on_sair_pressed() -> void:
	botao_click.play()
	get_tree().quit()

func _on_musga_on_off_pressed() -> void:
	botao_click.play()
	var is_muted = AudioServer.is_bus_mute(musica)
	AudioServer.set_bus_mute(musica, not is_muted)

func _on_iniciar_pressed() -> void:
	botao_click.play()
	if Jogo.word_size == 4:
		Jogo.tempo_ocioso_menu = Jogo.tempo_decorrido
	
	if Jogo.word_size < 6:
		Jogo.word_size += 1
		next_scene = "res://scenes/game.tscn"
		print("inicio")
	else:
		next_scene = "res://scenes/menu.tscn"
		Jogo.word_size = 4 # Voltando para a primeira fase
		Jogo.tempo_decorrido = 0.0 # Resetando temporizador
		Jogo.vidas = Configuracoes.config["vidas"]
		Jogo.salvar_dados_no_csv()
	get_tree().change_scene_to_file(next_scene)

func _on_reiniciar_pressed() -> void:
	botao_click.play()
	Jogo.word_size = 4 # Voltando para a primeira fase
	Jogo.tempo_decorrido = 0.0 # Resetando temporizador
	Jogo.vidas = Configuracoes.config["vidas"]
	Jogo.salvar_dados_no_csv()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
	 
func _on_configuraçoes_pressed() -> void:
	botao_click.play()
	get_tree().change_scene_to_file("res://scenes/config.tscn")
