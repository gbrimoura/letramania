extends Control

@onready var botao_pontuacao = $"Pontuação"
@onready var botao_temporizador = $"Temporizador"
@onready var botao_click = get_node("Click")

@onready var bloco_configuracao = $BlocoConfiguracao

const DESIGN_CENTER = Vector2(592.0, 339.0)

var ui_nodes = [
	"FundoTexto",
	"LabelPontuação",
	"Pontuação",
	"LabelTemporizador",
	"Temporizador",
	"LabelVidas",
	"LabelTempoAjuda",
	"LabelTema",
	"ControleVidas",
	"ControleTempoAjuda",
	"ControleTema",
]

func montar_bloco_configuracao() -> void:
	for node_name in ui_nodes:
		var node = get_node_or_null(node_name)
		if node and node.get_parent() != bloco_configuracao:
			remove_child(node)
			bloco_configuracao.add_child(node)
			if node is Control or node is Sprite2D:
				node.position -= DESIGN_CENTER

func ajustar_bloco_configuracao() -> void:
	if bloco_configuracao == null:
		return

	var viewport_size = get_viewport_rect().size
	var scale_factor = clamp(min(viewport_size.x / 1920.0, viewport_size.y / 1080.0) * 1.08, 0.88, 1.24)
	bloco_configuracao.position = viewport_size * 0.5
	bloco_configuracao.scale = Vector2(scale_factor, scale_factor)

func _ready() -> void:
	# Carrega convertendo para booleanos
	botao_pontuacao.button_pressed = Configuracoes.config.get("pontuacao_ativada", true) as bool
	botao_temporizador.button_pressed = Configuracoes.config.get("temporizador_ativado", true) as bool

	if botao_pontuacao is BaseButton:
		botao_pontuacao.toggled.connect(_on_pontuacao_toggled)
	if botao_temporizador is BaseButton:
		botao_temporizador.toggled.connect(_on_temporizador_toggled)

	montar_bloco_configuracao()
	ajustar_bloco_configuracao()
	get_viewport().size_changed.connect(ajustar_bloco_configuracao)

func _on_pontuacao_toggled(ativado: bool) -> void:
	botao_click.play()
	Configuracoes.config.pontuacao_ativada = ativado
	Configuracoes.salvar_todas_configuracoes()

func _on_temporizador_toggled(ativado: bool) -> void:
	botao_click.play()
	Configuracoes.config.temporizador_ativado = ativado
	Configuracoes.salvar_todas_configuracoes()

func _on_voltar_pressed() -> void:
	botao_click.play()
	get_tree().change_scene_to_file("res://scenes/menu.tscn")
