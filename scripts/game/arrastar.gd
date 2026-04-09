extends Button

var offset := Vector2()
var original_position := Vector2()
var current_snap_area: Node = null
var current_snap_area_letter
var is_snapped := false  # Indica se a letra está encaixada
var letter_name
var completed = false

# new theomob vars
var _originalColor: Color
var _hintTimer = 15000 # 1000 = 1 sec


@onready var lacunas = get_node("/root/Node2D/Control/Lacunas")
var last_release_time := 0  
var idle_time := 0  
var tip_timeout = 3000
@onready var keyboard = get_node("/root/Node2D/Control/Letras")

@onready var erro = get_node("/root/Node2D/Control/Errado")
@onready var certo = get_node("/root/Node2D/Control/Correto")

func is_idle():
	if not completed:
		var current_time = Time.get_ticks_msec()
		var elapsed_time = current_time - Jogo.aux_time
		if elapsed_time > _hintTimer: # 20 segundos de inatividade para mostrar dica
			game_tips()
			Jogo.aux_time = current_time

func game_tips():
	if Jogo.is_dragging:
		return
		
	var word_complete
	for word in lacunas.selected_words:
		var letters = word["letters"]
		word_complete = true 
		
		for current_letter in letters:
			if not current_letter[0].is_occupied:
				word_complete = false  
				break 
				
		if not word_complete:  
			for current_letter in letters:
				if not current_letter[0].is_occupied:  
					var end_time = Time.get_ticks_msec() + tip_timeout
					
					while Time.get_ticks_msec() < end_time:
						current_letter[0].modulate = Color(0,1,0) # verde
						keyboard.tip_letter(current_letter[1], 1)
						await get_tree().create_timer(0.5).timeout 
						
						# Se a letra começou a ser arrastada durante o flash, restaura e sai
						if Jogo.is_dragging:
							current_letter[0].modulate = _originalColor
							keyboard.tip_letter(current_letter[1], 0)
							return
							
						current_letter[0].modulate = _originalColor
						keyboard.tip_letter(current_letter[1], 0)
						await get_tree().create_timer(0.5).timeout 
					
					current_letter[0].modulate = _originalColor
					return  

func _ready():
	Jogo.aux_time = Time.get_ticks_msec()
	_originalColor = modulate
	
func _process(delta: float) -> void:
	is_idle()

func _gui_input(event: InputEvent) -> void:
	var root_node = get_parent().get_parent()
	if not(is_snapped):
		if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
			if event.pressed:  # Botão pressionado
				Jogo.is_dragging = true
				Jogo.add_letras_selecionadas()
				idle_time = Time.get_ticks_msec() - Jogo.aux_time  
				Jogo.add_idle_time(idle_time)  
				offset = get_local_mouse_position()
			else:  # Botão solto
				Jogo.is_dragging = false
				Jogo.aux_time = Time.get_ticks_msec() 
				if current_snap_area and not current_snap_area.is_occupied and current_snap_area_letter == letter_name:
					# Cria um novo botão para preencher a área
					certo.play()
					var new_button = duplicate()
					
					# Encaixa a cópia da letra na área
					current_snap_area.is_occupied = true
					current_snap_area.modulate.a = 0.0  # Opacidade total ao encaixar
					new_button.position = current_snap_area.global_position - get_parent().global_position
					get_parent().add_child(new_button)
					new_button.is_snapped = true
					Jogo.add_acertos()
					
					# Adiciona a pontuação conforme a ocorrência de erro ou não na palavra
					for word in lacunas.selected_words:
						for letters in word["letters"]:
							if letters[0].get_global_rect().has_point(get_global_mouse_position()):
								Jogo.pontuacao += word["letter_value"]
								root_node.atualizar_ui_pontos()
								break
					queue_free() # remove a letra do "teclado".
					completed = lacunas.verify_gaps()
					if completed:
						root_node.parar_temporizador() 
						if Jogo.word_size < 6:
							idle_time = Time.get_ticks_msec() - Jogo.aux_time  
							Jogo.add_idle_time(idle_time)
						if Jogo.word_size == 4:
							Jogo.set_inatividade_fase1()
						elif Jogo.word_size == 5:
							Jogo.set_inatividade_fase2()
						else:
							Jogo.set_inatividade_fase3()
							Jogo.completo = "SIM"
							Jogo.salvar_dados_no_csv()
						get_tree().change_scene_to_file("res://scenes/prox_fase.tscn")
				else:
					Jogo.add_erros()
					
					if Jogo.life_per_letter: # perde vida sempre que erra
						Jogo.vidas -= 1
					elif not(already_missed()): # só perde vida uma vez por palavra
						Jogo.vidas -= 1
					
					var palavra_errada = null
					# Encontrar a palavra correspondente à lacuna onde a letra foi solta
					for palavra_atual in lacunas.selected_words:
						for letra_posicao in palavra_atual["letters"]:
							if letra_posicao[0] == current_snap_area:
								palavra_errada = palavra_atual["letters"]
								break
						if palavra_errada:
							erro.play()
							break
					if palavra_errada:
						verify_type_error(letter_name, palavra_errada)
					
					if Jogo.vidas < 0:
						Jogo.completo = "S/ VIDAS"
						if Jogo.word_size == 4:
							Jogo.set_inatividade_fase1()
						elif Jogo.word_size == 5:
							Jogo.set_inatividade_fase2()
						elif Jogo.word_size == 6:
							Jogo.set_inatividade_fase2()
							Jogo.word_size = 3
							Jogo.salvar_dados_no_csv()
						get_tree().change_scene_to_file("res://scenes/lose_screen.tscn")
					root_node.atualizar_ui_vidas()
					
				position = original_position # move o botão para a posição de origem
				accept_event()
				
		elif event is InputEventMouseMotion and Jogo.is_dragging:
			position = get_global_mouse_position() - offset - get_parent().global_position
			check_snap_area()
			accept_event()

func check_snap_area(): 
	current_snap_area = null
	for word in lacunas.selected_words: # Cada palavra
		var letters = word["letters"]
		for current_letter in letters:
			if not current_letter[0].is_occupied:
				current_letter[0].modulate.a = 0.8  # Feedback visual para áreas disponíveis
		for current_letter in letters:
			if current_letter[0].is_occupied:
				continue
			if current_letter[0].get_global_rect().has_point(get_global_mouse_position()):
				current_snap_area = current_letter[0]
				current_snap_area_letter = current_letter[1]
				current_letter[0].modulate.a = 1.2  # Feedback visual para área sob o mouse
				break

#função para verificar que tipo de erro
func verify_type_error(letter_name: String, word: Array):
	var correct_letters = []  # Lista de letras da palavra correta
	for pair in word:  # Percorre cada posição da palavra
		correct_letters.append(pair[1])

	if letter_name in correct_letters:
		Jogo.add_erro_posicao()
		return  # A letra existe, mas foi colocada no lugar errado
	else:
		Jogo.add_erro_escolha()
		return  # A letra não existe na palavra
		
func already_missed():
	var missed = true
	for word in lacunas.selected_words:
		for letters in word["letters"]:
			if letters[0].get_global_rect().has_point(get_global_mouse_position()):
				if word["miss"] == false:
					missed = false
					word["miss"] = true
					word["letter_value"] = 50
					break
	return missed
