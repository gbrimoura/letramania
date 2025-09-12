extends Node

const config_path = "user://configuracao.cfg"
var lista_temas = ["Padrão", "Azul", "Verde", "Roxo"]

var is_music_on: bool = true : set = set_music_on
var config = {
	"vidas": -1,
	"pontuacao": 0,
	"pontuacao_ativada": true,
	"temporizador_ativado": true,
	"nivel_de_dica": 20,
	"tema": 0
}

var nome_tema: String

signal music_state_changed(is_on)

func _ready():
	carregar_todas_configuracoes()  # Carrega tudo ao iniciar
	nome_tema = lista_temas[config.tema]

# --------------------------- Áudio ---------------------------
func set_music_on(value: bool) -> void:
	is_music_on = value
	emit_signal("music_state_changed", is_music_on)
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Musica"), not value)
	salvar_todas_configuracoes()

# --------------------------- Sistema Unificado de Salvamento ---------------------------
func salvar_todas_configuracoes():
	var config_file = ConfigFile.new()
	
	# Seção de áudio
	config_file.set_value("audio", "is_music_on", is_music_on)
	
	# Seção de jogo
	config_file.set_value("jogo", "vidas", config.vidas)
	config_file.set_value("jogo", "pontuacao_ativada", config.pontuacao_ativada)
	config_file.set_value("jogo", "temporizador_ativado", config.temporizador_ativado)
	config_file.set_value("jogo", "nivel_de_dica", config.nivel_de_dica)
	config_file.set_value("jogo", "tema", config.tema)
	
	var erro = config_file.save(config_path)
	if erro != OK:
		print("Erro ao salvar:", error_string(erro))

func carregar_todas_configuracoes():
	var config_file = ConfigFile.new()
	var erro = config_file.load(config_path)
	
	if erro == OK:
		# Carrega áudio
		is_music_on = config_file.get_value("audio", "is_music_on", true)
		
		# Carrega configurações do jogo
		config.vidas = config_file.get_value("jogo", "vidas", 3)
		config.pontuacao_ativada = config_file.get_value("jogo", "pontuacao_ativada", true)
		config.temporizador_ativado = config_file.get_value("jogo", "temporizador_ativado", true)
		config.nivel_de_dica = config_file.get_value("jogo", "nivel_de_dica", 20)
		config.tema = config_file.get_value("jogo", "tema", 0)
		
		# Força tipos booleanos
		config.pontuacao_ativada = bool(config.pontuacao_ativada)
		config.temporizador_ativado = bool(config.temporizador_ativado)
		
	# Se não existir, cria com valores padrão
	salvar_todas_configuracoes()
	
	# Aplica configurações de áudio
	AudioServer.set_bus_mute(AudioServer.get_bus_index("Musica"), not is_music_on)

# --------------------------- Interface Pública --------"res://scripts/global/configsGlobal.gd"-------------------
func atualizar_config_jogo(chave: String, valor):
	config[chave] = valor
	salvar_todas_configuracoes()
