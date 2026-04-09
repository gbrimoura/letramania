extends Control

var selected_words = [{"letters": [], "miss": false, "letter_value": 100}, 
{"letters": [], "miss": false, "letter_value": 100},
{"letters": [], "miss": false, "letter_value": 100},
{"letters": [], "miss": false, "letter_value": 100}]
var word_images = []  # Armazenará as imagens das palavras

var fourl_words = [
	{"image": "res://assets/vetores/casa.png", "word": "CASA"},
	{"image": "res://assets/vetores/sino.png", "word": "SINO"},
	{"image": "res://assets/vetores/cama.png", "word": "CAMA"},
	{"image": "res://assets/vetores/bola.png", "word": "BOLA"},
	{"image": "res://assets/vetores/foca.png", "word": "FOCA"},
	{"image": "res://assets/vetores/lixo.png", "word": "LIXO"},
	{"image": "res://assets/vetores/urso.png", "word": "URSO"},
	{"image": "res://assets/vetores/pato.png", "word": "PATO"},
	{"image": "res://assets/vetores/rato.png", "word": "RATO"},
	{"image": "res://assets/vetores/pipa.png", "word": "PIPA"},
] # 10 palavras com imagens

var fivel_words = [
	{"image": "res://assets/vetores/apito.png", "word": "APITO"},
	{"image": "res://assets/vetores/pente.png", "word": "PENTE"},
	{"image": "res://assets/vetores/livro.png", "word": "LIVRO"},
	{"image": "res://assets/vetores/lapis.png", "word": "LAPIS"},
	{"image": "res://assets/vetores/jarra.png", "word": "JARRA"},
	{"image": "res://assets/vetores/piano.png", "word": "PIANO"},
	{"image": "res://assets/vetores/porta.png", "word": "PORTA"},
	{"image": "res://assets/vetores/chave.png", "word": "CHAVE"},
	{"image": "res://assets/vetores/pedra.png", "word": "PEDRA"},
	{"image": "res://assets/vetores/cobra.png", "word": "COBRA"},
	{"image": "res://assets/vetores/zebra.png", "word": "ZEBRA"},
]

var sixl_words = [
	{"image": "res://assets/vetores/colher.png", "word": "COLHER"},
	{"image": "res://assets/vetores/sapato.png", "word": "SAPATO"},
	{"image": "res://assets/vetores/boneca.png", "word": "BONECA"},
	{"image": "res://assets/vetores/tijolo.png", "word": "TIJOLO"},
	{"image": "res://assets/vetores/panela.png", "word": "PANELA"},
	{"image": "res://assets/vetores/abajur.png", "word": "ABAJUR"},
	{"image": "res://assets/vetores/girafa.png", "word": "GIRAFA"},
	{"image": "res://assets/vetores/cavalo.png", "word": "CAVALO"},
	{"image": "res://assets/vetores/macaco.png", "word": "MACACO"},
	{"image": "res://assets/vetores/banana.png", "word": "BANANA"},
	{"image": "res://assets/vetores/tomate.png", "word": "TOMATE"},
]

func set_gaps(array_size: int) -> void:
	var viewport_size = get_viewport_rect().size
	var viewport_w = viewport_size.x
	var viewport_h = viewport_size.y
	var side_margin = viewport_w * 0.06
	var column_gap = viewport_w * 0.06
	var available_w = viewport_w - (side_margin * 2.0) - column_gap
	var column_w = available_w / 2.0
	var top_y = viewport_h * 0.12
	var row_gap = viewport_h * 0.16
	var y_positions = [top_y, top_y + row_gap, top_y, top_y + row_gap]
	var words

	if array_size == 4:
		words = fourl_words
	elif array_size == 5:
		words = fivel_words
	else:
		words = sixl_words

	# Limpa imagens anteriores
	for img in word_images:
		img.queue_free()
	word_images.clear()

	var selected_indices = []
	while selected_indices.size() < 4:
		var idx = randi() % words.size()
		if not selected_indices.has(idx):
			selected_indices.append(idx)

	# Criação dos elementos
	for i in 4:
		var word_data = words[selected_indices[i]]
		var word_str = word_data["word"]
		var row = i % 2
		var col = i / 2
		var col_x = side_margin + (col * (column_w + column_gap))
		var base_y = y_positions[i]

		var image_size = clamp(viewport_h * 0.10, 44.0, 82.0)
		var letter_size = clamp(min((column_w * 0.72) / float(array_size), viewport_h * 0.085), 46.0, 78.0)
		var letter_gap = clamp(letter_size * 0.14, 6.0, 14.0)
		var image_gap = clamp(letter_size * 0.20, 8.0, 18.0)
		var word_w = (letter_size * array_size) + (letter_gap * (array_size - 1))
		var block_w = image_size + image_gap + word_w
		var block_x = col_x + (column_w - block_w) / 2.0
		var img_x = block_x
		var base_x = img_x + image_size + image_gap

		# Aplica um pequeno deslocamento vertical alternado para separar visualmente as linhas.
		if row == 1:
			base_y += letter_size * 0.15

		# Criação das letras primeiro
		for n in array_size:
			var draggable = get_node("Arrastável").duplicate()
			selected_words[i]["letters"].append([draggable, word_str[n]])
			add_child(draggable)
			draggable.size = Vector2(letter_size, letter_size)
			draggable.position = Vector2(base_x + (n * (letter_size + letter_gap)), base_y)

		# Agora adiciona a imagem da palavra
		if word_data["image"] != "":
			var img = TextureRect.new()
			img.texture = load(word_data["image"])
			img.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
			img.expand = true
			img.custom_minimum_size = Vector2(image_size, image_size)
			img.position = Vector2(img_x, base_y + (letter_size - image_size) / 2.0)
			add_child(img)
			word_images.append(img)

func verify_gaps() ->bool:
	var completed = true
	for w in selected_words:
		var letters = w["letters"]
		for l in letters:
			if not(l[0].is_occupied):
				completed = false
				break
	return completed

func _ready() -> void:
	set_gaps(Jogo.word_size)
