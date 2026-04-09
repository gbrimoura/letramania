extends Control

# Referências para os botões e o label
@onready var label = $Tema
@onready var btn_direita = $DireitaTema
@onready var btn_esquerda = $EsquerdaTema

func tocar_click() -> void:
	var click = get_tree().current_scene.get_node_or_null("Click")
	if click:
		click.play()

func get_background() -> TextureRect:
	return get_tree().current_scene.get_node_or_null("Background")

var id_tema: int:
	set(value):
		# Garante que o valor sempre fique entre 1 e 3
		value = clampi(value, 0, 3)
		Configuracoes.config.tema = value
		Configuracoes.salvar_todas_configuracoes()
		label.text = Configuracoes.lista_temas[value]
	get:
		return Configuracoes.config.tema
		
func _ready():
	
	id_tema = Configuracoes.config.tema
	var background = get_background()
	if background:
		background.texture = load("res://assets/menu/background_" + Configuracoes.nome_tema + ".png")
	label.text = Configuracoes.lista_temas[id_tema]

	# Configurações do Label (Godot 4)
	var label_settings = LabelSettings.new()
	var fonte = load("res://assets/musicas e fontes/Gilroy-Bold.ttf")
	label_settings.font = fonte
	label_settings.font_size = 40
	label_settings.font_color = Color.BLACK
	label.label_settings = label_settings
	
	# Conectar os sinais dos botões
	btn_direita.connect("pressed", _prox_tema)
	btn_esquerda.connect("pressed", _ante_tema)

# Função para atualizar o label com a quantidade de vidas
func atualizar_tema():
	Configuracoes.salvar_todas_configuracoes()
	Configuracoes.nome_tema = Configuracoes.lista_temas[id_tema]
	label.text = Configuracoes.nome_tema  # Atualiza o texto do Label

# Função chamada quando o botão de aumentar é pressionado
func _prox_tema():
	tocar_click()
	if Configuracoes.config.tema == 3:
		id_tema = 0
	else:
		id_tema += 1
	Configuracoes.nome_tema = Configuracoes.lista_temas[id_tema]
	var background = get_background()
	if background:
		background.texture = load("res://assets/menu/background_" + Configuracoes.nome_tema + ".png")

func _ante_tema():
	tocar_click()
	if Configuracoes.config.tema == 0:
		id_tema = 3
	else:
		id_tema -= 1
	Configuracoes.nome_tema = Configuracoes.lista_temas[id_tema]
	var background = get_background()
	if background:
		background.texture = load("res://assets/menu/background_" + Configuracoes.nome_tema + ".png")
	
