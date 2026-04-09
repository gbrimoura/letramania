extends Control

@onready var label = $Vidas
@onready var btn_aumentar = $AumentarVidas
@onready var btn_diminuir = $DiminuirVidas

func tocar_click() -> void:
	var click = get_tree().current_scene.get_node_or_null("Click")
	if click:
		click.play()

var vidas_iniciais: int:
	set(value):
		if value == -1:
			Configuracoes.config.vidas = -1
			label.text = "∞"
		else:
			value = clampi(value, 1, 11)
			Configuracoes.config.vidas = value
			label.text = str(value)
		Configuracoes.salvar_todas_configuracoes()
	get:
		return Configuracoes.config.vidas

func _ready():
	vidas_iniciais = Configuracoes.config.vidas
	Jogo.vidas_iniciais = vidas_iniciais if vidas_iniciais != -1 else 999
	
	label.text = "∞" if vidas_iniciais == -1 else str(vidas_iniciais)

	# Fonte personalizada
	var label_settings = LabelSettings.new()
	var fonte = load("res://assets/musicas e fontes/Gilroy-Bold.ttf")
	label_settings.font = fonte
	label_settings.font_size = 40
	label_settings.font_color = Color.BLACK
	label.label_settings = label_settings

	# Conectar botões
	btn_aumentar.connect("pressed", _aumentar_vidas)
	btn_diminuir.connect("pressed", _diminuir_vidas)

func atualizar_vidas():
	label.text = "∞" if vidas_iniciais == -1 else str(vidas_iniciais)
	Configuracoes.salvar_todas_configuracoes()
	
	Jogo.vidas_finais = vidas_iniciais if vidas_iniciais != -1 else 999

func _aumentar_vidas():
	tocar_click()
	if vidas_iniciais == -1:
		vidas_iniciais = 1
	elif vidas_iniciais == 11:
		vidas_iniciais = -1
	else:
		vidas_iniciais += 1

func _diminuir_vidas():
	tocar_click()
	if vidas_iniciais == -1:
		vidas_iniciais = 11
	elif vidas_iniciais == 1:
		vidas_iniciais = -1
	else:
		vidas_iniciais -= 1
