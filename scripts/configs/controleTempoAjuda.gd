extends Control

# Referências para os botões e o label
@onready var label = $TempoAjuda
@onready var btn_aumentar = $AumentarTempoAjuda
@onready var btn_diminuir = $DiminuirTempoAjuda

func tocar_click() -> void:
	var click = get_tree().current_scene.get_node_or_null("Click")
	if click:
		click.play()

var tempo_de_dica: int:
	set(value):
		# Garante que o valor sempre fique entre 1 e 3
		value = clampi(value, 1, 30)
		Configuracoes.config.nivel_de_dica = value
		Configuracoes.salvar_todas_configuracoes()
		label.text = str(value) + 's'
	get:
		return Configuracoes.config.nivel_de_dica
		
func _ready():
	
	tempo_de_dica = Configuracoes.config.nivel_de_dica
	label.text = str(tempo_de_dica) + 's'

	# Configurações do Label (Godot 4)
	var label_settings = LabelSettings.new()
	var fonte = load("res://assets/musicas e fontes/Gilroy-Bold.ttf")
	label_settings.font = fonte
	label_settings.font_size = 40
	label_settings.font_color = Color.BLACK
	label.label_settings = label_settings
	
	# Conectar os sinais dos botões
	btn_aumentar.connect("pressed", _aumentar_tempo_ajuda)
	btn_diminuir.connect("pressed", _diminuir_tempo_ajuda)

# Função para atualizar o label com o tempo de ajuda
func atualizar_tempo_ajuda():
	Configuracoes.salvar_todas_configuracoes()
	label.text = str(tempo_de_dica) + 's'

# Função chamada quando o botão de aumentar é pressionado
func _aumentar_tempo_ajuda():
	tocar_click()
	if Configuracoes.config.nivel_de_dica == 30:
		tempo_de_dica = 10
	else:
		tempo_de_dica += 10

func _diminuir_tempo_ajuda():
	tocar_click()
	if Configuracoes.config.nivel_de_dica == 10:
		tempo_de_dica = 30
	else:
		tempo_de_dica -= 10
