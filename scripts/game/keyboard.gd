extends Control

var outline_shader := preload("res://shaders/outline.gdshader")
var alphabet = ["A","B", "C", "D", "E", "F", "G", "H", "I", "J", "K", "L", "M", "N", "O", "P", "Q",
"R", "S", "T", "U", "V", "W", "X", "Y", "Z"]
var key_list = []
var tip_timeout = 3000

func spawn_keys(word_list) -> void:
	var rng = RandomNumberGenerator.new();
	rng.randomize()

	# adiciona as letras necessárias p/ palavras chaves
	for word in word_list:
		for l in word["letters"]:
			var letter_name = l[1]
			var template = get_node(letter_name)
			var letter_node = template.duplicate()
			add_child(letter_node)
			letter_node.letter_name = letter_name
			key_list.append(letter_node)

	# completa com outras letras aleatórias
	while key_list.size() < 30:
		var idx = rng.randi_range(0, alphabet.size() - 1)
		var letter_name = alphabet[idx]
		var template = get_node(letter_name)
		var letter_node = template.duplicate()
		add_child(letter_node)
		letter_node.letter_name = letter_name
		key_list.append(letter_node)
		
	key_list.shuffle()

	# posiciona no grid proporcional ao tamanho de tela
	var viewport_size = get_viewport_rect().size
	var viewport_w = viewport_size.x
	var viewport_h = viewport_size.y
	var columns = 10
	var rows = int(ceil(float(key_list.size()) / float(columns)))
	var side_margin = viewport_w * 0.045
	var bottom_margin = viewport_h * 0.11
	var available_w = viewport_w - (side_margin * 2.0)
	var key_size = clamp(min((available_w / float(columns)) * 0.90, viewport_h * 0.092), 44.0, 78.0)
	var horizontal_gap = clamp((available_w - (key_size * columns)) / float(max(columns - 1, 1)), 2.0, 8.0)
	var vertical_gap = clamp(key_size * 0.10, 4.0, 9.0)
	var row_block_w = (key_size * columns) + (horizontal_gap * (columns - 1))
	var start_x = (viewport_w - row_block_w) / 2.0
	var start_y = viewport_h - bottom_margin - (rows * key_size) - ((rows - 1) * vertical_gap)

	for index in key_list.size():
		var l = key_list[index]
		var row = index / columns
		var col = index % columns
		var x = start_x + (col * (key_size + horizontal_gap))
		var y = start_y + (row * (key_size + vertical_gap))
		l.custom_minimum_size = Vector2(key_size, key_size)
		l.size = Vector2(key_size, key_size)
		l.position = Vector2(x, y)
		l.original_position = l.position
		
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	#pass # Replace with function body.
	var lacunas = get_node("/root/Node2D/Control/Lacunas")
	spawn_keys(lacunas.selected_words)
	
func tip_letter(letter: String, type: int) -> void:
	for key in key_list:
		if is_instance_valid(key) and key.letter_name == letter:
			if type == 1:
				# aplica material shader de bordinhas verdes <3
				var mat := ShaderMaterial.new()
				mat.shader = outline_shader
				key.material = mat
			else:
				# nao
				key.material = null
			break
			
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass
