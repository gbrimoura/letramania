extends TextureButton

func _ready():
	# Atualiza o sprite com o estado atual ao carregar a cena
	_atualizar_sprite(Configuracoes.is_music_on)
	# Conecta ao sinal usando Callable (Godot 4)
	Configuracoes.music_state_changed.connect(_atualizar_sprite)

func _atualizar_sprite(is_on: bool):
	if is_on:
		texture_normal = load("res://recursos/menu/Botões/VolumeLigado.png")
	else:
		texture_normal = load("res://recursos/menu/Botões/VolumeDesligado.png")

func _on_pressed():
	Configuracoes.is_music_on = !Configuracoes.is_music_on
	_atualizar_sprite(Configuracoes.is_music_on)
