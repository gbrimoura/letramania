extends Control

@onready var label = $Vidas
@onready var btn_aumentar = $AumentarVidas
@onready var btn_diminuir = $DiminuirVidas
@onready var botao_click = get_parent().get_node("Click")

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

func _aumentar_vidas():
	botao_click.play()
	if vidas_iniciais == -1:
		vidas_iniciais = 1
	elif vidas_iniciais == 11:
		vidas_iniciais = -1
	else:
		vidas_iniciais += 1

func _diminuir_vidas():
	botao_click.play()
	if vidas_iniciais == -1:
		vidas_iniciais = 11
	elif vidas_iniciais == 1:
		vidas_iniciais = -1
	else:
		vidas_iniciais -= 1
