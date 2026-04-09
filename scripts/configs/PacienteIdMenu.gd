extends Control

@onready var input: LineEdit = get_node("PacienteIdInput")
@onready var botao: TextureButton = get_node("Salvar")

# Referência ao script principal
var main_script: Node = null

func _ready():
	# Verifica se já existe um paciente_id
	if Jogo.paciente_id != "":
		hide()  # Esconde a aba se já tiver sido preenchido
	else:
		show()  # Mostra a aba se estiver vazio

	# Conecta o botão ao método
	botao.pressed.connect(_on_botao_confirmar_pressed)

func _on_botao_confirmar_pressed():
	var texto_id = input.text.strip_edges()

	if texto_id == "":
		print("⚠️ Digite um ID de paciente antes de confirmar.")
		return

	# Envia o ID para o script principal
	if Jogo != null:
		Jogo.paciente_id = texto_id
		print("✅ Paciente ID salvo:", texto_id)
	else:
		print("⚠️ Script principal não encontrado!")

	# Fecha / esconde esta janela
	hide()
