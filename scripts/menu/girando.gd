extends Node2D

# Dicionário para guardar o estado de cada filho
var estados_filhos = {}

var centro_horizontal_titulo: float = 0.0
	
func _ready():
	calcular_centro_horizontal()
	recentrar_filhos()
	ajustar_posicao()
	if get_viewport() and not get_viewport().size_changed.is_connected(ajustar_posicao):
		get_viewport().size_changed.connect(ajustar_posicao)
	# Inicializa o estado para cada filho
	for filho in get_children():
		if filho is Node2D:
			estados_filhos[filho] = true  # Valor inicial de 'indo'


func calcular_centro_horizontal() -> void:
	var menor_x: float = INF
	var maior_x: float = -INF

	for filho in get_children():
		if filho is Sprite2D and filho.texture:
			var largura_sprite: float = filho.texture.get_size().x * absf(filho.scale.x) * 0.5
			menor_x = minf(menor_x, filho.position.x - largura_sprite)
			maior_x = maxf(maior_x, filho.position.x + largura_sprite)
		elif filho is Node2D:
			menor_x = minf(menor_x, filho.position.x)
			maior_x = maxf(maior_x, filho.position.x)

	if menor_x == INF:
		centro_horizontal_titulo = 0.0
	else:
		centro_horizontal_titulo = (menor_x + maior_x) * 0.5


func recentrar_filhos() -> void:
	for filho in get_children():
		if filho is Node2D:
			filho.position.x -= centro_horizontal_titulo
	centro_horizontal_titulo = 0.0

func ajustar_posicao():
	var parent_control := get_parent() as Control
	if parent_control:
		position = Vector2(parent_control.size.x * 0.5, parent_control.size.y / 5.0)
		return

	var viewport_size = get_viewport().get_visible_rect().size
	position = Vector2(viewport_size.x * 0.5, viewport_size.y / 5.0)

func _process(delta: float) -> void:
	for filho in estados_filhos:
		var indo = estados_filhos[filho]
		
		if indo:
			filho.rotation_degrees -= 1 * delta
			if filho.rotation_degrees <= -5:
				estados_filhos[filho] = false
		else:
			filho.rotation_degrees += 1 * delta
			if filho.rotation_degrees >= 5:
				estados_filhos[filho] = true
