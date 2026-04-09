extends Control

@onready var background = $Background
@export var bus_name: String = "Musica"
var musica: int
@onready var label_tempo = $Tempo
@onready var label_pontuacao = $Pontuação
@onready var label_vidas = $Vidas
#var tempo_decorrido: float = 0.0
var temporizador_ligado: bool = false
@onready var botao_click = get_node("Click")
@onready var confirmation_dialog = $ConfirmationDialog

func _ready():
	# ESTILIZAÇÃO DO CONFIRMATIONDIALOGE
	var theme = Theme.new()
	var font = load("res://recursos/musicas e fontes/Gilroy-Black.ttf")
	var font_size = 24
	var label_settings = LabelSettings.new()
	label_settings.font = font
	label_settings.font_size = 24
	
	var button_style = StyleBoxFlat.new()
	button_style.bg_color = Color(0.35, 0.35, 0.35)  # Cor cinza escuro
	button_style.corner_radius_top_left = 5
	button_style.corner_radius_bottom_right = 5
	
	var ok_button = confirmation_dialog.get_ok_button()
	var cancel_button = confirmation_dialog.get_cancel_button()
	
	ok_button.focus_mode = Control.FOCUS_NONE
	cancel_button.focus_mode = Control.FOCUS_NONE
	
	theme.set_font("font", "Button", font)
	theme.set_font_size("font_size", "Button", font_size)
	theme.set_color("font_color", "Button", Color.WHITE)
	
	# Centraliza o texto dos botões
	var dialog_label = confirmation_dialog.get_label()
	dialog_label.label_settings = label_settings
	dialog_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	
	# --- APLICA O TEMA ---
	confirmation_dialog.theme = theme
	
	# ------------------------------------------------------------------------
	
	confirmation_dialog.hide()
	confirmation_dialog.set_flag(Window.FLAG_BORDERLESS, true)
	confirmation_dialog.set_flag(Window.FLAG_RESIZE_DISABLED, true)
	confirmation_dialog.dialog_text = "Deseja realmente sair do jogo?"
	confirmation_dialog.get_ok_button().text = "Sim"
	confirmation_dialog.get_cancel_button().text = "Não"
	confirmation_dialog.exclusive = false
	
	# Conexão dos sinais
	confirmation_dialog.confirmed.connect(_on_confirmation_dialog_confirmed)
	confirmation_dialog.canceled.connect(_on_confirmation_dialog_canceled)
	
	ajustar_background()
	Jogo.time_start = Jogo.get_time()
	label_pontuacao.visible = Configuracoes.config.pontuacao_ativada
	label_tempo.visible = Configuracoes.config.temporizador_ativado
	if Jogo.word_size == 4: # Verifica se está no início do jogo
		Jogo.vidas = Configuracoes.config.vidas  # Valor inicial
		Jogo.pontuacao = 0  # Começa do zero
	atualizar_ui_vidas()
	atualizar_ui_pontos()
	
	check_snap_area()
	
	musica = AudioServer.get_bus_index(bus_name)
	iniciar_temporizador()  # Inicia o contador
	
	# AJUSTES PRAS LABELS
	var label_configs = LabelSettings.new()
	var fonte = load("res://recursos/musicas e fontes/Gilroy-Bold.ttf")
	label_configs.font = fonte
	label_configs.font_size = 24
	label_configs.font_color = Color.BLACK
	label_tempo.label_settings = label_configs
	label_pontuacao.label_settings = label_configs
	label_vidas.label_settings = label_configs
	label_vidas.label_settings.font_size = 36

func _process(delta):
	if temporizador_ligado:
		Jogo.tempo_decorrido += delta
		atualizar_ui_tempo()

func ajustar_background():
	if background and background.texture:
		background.size = get_viewport_rect().size
		background.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_COVERED
		background.z_index = -1
# ----------------------------- Labels

func iniciar_temporizador():
	temporizador_ligado = true

func parar_temporizador():
	temporizador_ligado = false

func resetar_temporizador():
	Jogo.tempo_decorrido = 0.0

func atualizar_ui_tempo():
	var minutos = int(Jogo.tempo_decorrido / 60)
	var segundos = int(Jogo.tempo_decorrido) % 60
	label_tempo.text = "%02d:%02d" % [minutos, segundos]
	
func atualizar_ui_vidas():
	label_vidas.text = "Vidas: %02d" % Jogo.vidas
	
func atualizar_ui_pontos():
	label_pontuacao.text = "%02d" % Jogo.pontuacao
	
func _on_pause_changed(paused: bool):
	temporizador_ligado = !paused

# ----------------------------- Música

func _on_musga_on_off_pressed() -> void:
	botao_click.play()
	var is_muted = AudioServer.is_bus_mute(musica)
	AudioServer.set_bus_mute(musica, not is_muted)

# ----------------------------- Arrastável	

func check_snap_area():
	for area in get_tree().get_nodes_in_group("arrastaveis"):
			if not area.is_occupied:
				area.modulate.a = 0.8  # Feedback visual para áreas disponíveis
				
func _on_exit_button_pressed():
	get_tree().paused = true
	confirmation_dialog.popup_centered_ratio(0.3)  # Tamanho relativo à tela

func _on_voltar_pressed() -> void:
	botao_click.play()
	if Jogo.word_size == 4:
		Jogo.set_inatividade_fase1()
	elif Jogo.word_size == 5:
		Jogo.set_inatividade_fase2()
	elif Jogo.word_size == 6:
		Jogo.set_inatividade_fase2()
	Jogo.completo = "INTERROMPIDO"
	Jogo.salvar_dados_no_csv()
	Jogo.word_size = 3
	# Pausa apen"res://scripts/game/gaps.gd"as a física e lógica do jogo, mantendo a UI ativa
	get_tree().paused = true
	# Mantém o diálogo processando input mesmo com o jogo pausado
	confirmation_dialog.process_mode = Node.PROCESS_MODE_ALWAYS
	confirmation_dialog.popup_centered_ratio(0.3)

func _on_confirmation_dialog_confirmed():
	get_tree().paused = false
	resetar_temporizador() # reseta o timer antes de voltar pro menu principal
	get_tree().change_scene_to_file("res://scenes/menu.tscn")

func _on_confirmation_dialog_canceled():
	get_tree().paused = false
	confirmation_dialog.hide()
