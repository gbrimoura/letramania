extends Button

const TIP_TIMEOUT = 3000
var tip_time_trigger = Configuracoes.config.nivel_de_dica * 1000 # Debug (pode usar Configuracoes.config.nivel_de_dica depois)

var offset := Vector2()
var original_position := Vector2()
var current_snap_area: Node = null
var current_snap_area_letter

var is_snapped := false
var completed = false

var last_release_time := 0  
var idle_time := 0  
var letter_name
var acertos_consecutivos: int = 0
var erros_consecutivos : int = 0

@onready var slots = get_node("/root/Node2D/Control/Lacunas")
@onready var keyboard = get_node("/root/Node2D/Control/Letras")
@onready var erro = get_node("/root/Node2D/Control/Errado")
@onready var certo = get_node("/root/Node2D/Control/Correto")

func _ready():
	Jogo.aux_time = Time.get_ticks_msec()

func _process(_delta: float) -> void:
	is_idle()

func is_idle():
	if completed:
		return

	var current_time = Time.get_ticks_msec()
	if current_time - Jogo.aux_time > tip_time_trigger:
		game_tips()
		Jogo.aux_time = current_time

func game_tips() -> void:
	if Jogo.is_tipping:
		return
	
	Jogo.is_tipping = true
	
	for word in slots.selected_words:
		var letters = word["letters"]
		var word_complete := true
		
		for current_letter in letters:
			if not current_letter[0].is_occupied:
				word_complete = false
				break
		
		if not word_complete:
			for current_letter in letters:
				if not current_letter[0].is_occupied:
					await piscar_letra(current_letter)
					Jogo.is_tipping = false
					return
	
	Jogo.is_tipping = false

func piscar_letra(current_letter: Array) -> void:
	var slot_node = current_letter[0]
	var letra = current_letter[1]
	
	if not is_instance_valid(slot_node) or not is_instance_valid(keyboard):
		Jogo.is_tipping = false
		return
	
	var original_color = slot_node.color
	keyboard.tip_letter(letra, 1)

	var tween = create_tween()
	tween.set_parallel(false)
	
	# Pisca 3 vezes
	for i in range(3):
		tween.tween_property(slot_node, "color", Color(0, 1, 0), 0.25) # Verde vivo
		tween.tween_property(slot_node, "color", original_color, 0.25)
	
	await tween.finished
	
	slot_node.color = original_color
	keyboard.tip_letter(letra, 0)
	Jogo.is_tipping = false

func _gui_input(event: InputEvent) -> void:
	var root_node = get_parent().get_parent()
	
	if is_snapped:
		return

	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.pressed:
			Jogo.add_letras_selecionadas()
			idle_time = Time.get_ticks_msec() - Jogo.aux_time  
			Jogo.add_idle_time(idle_time)  
			Jogo.is_dragging = true
			offset = get_local_mouse_position()
		else:
			Jogo.aux_time = Time.get_ticks_msec() 
			Jogo.is_dragging = false

			if current_snap_area and not current_snap_area.is_occupied and current_snap_area_letter == letter_name:
				certo.play()
				var new_button = duplicate()
				new_button.material = null
				
				current_snap_area.is_occupied = true
				current_snap_area.modulate.a = 0.0
				new_button.position = current_snap_area.global_position - get_parent().global_position
				get_parent().add_child(new_button)
				new_button.is_snapped = true
				Jogo.is_tipping = false
				Jogo.add_acertos()
				atualizar_acertos_consecutivos()
				erros_consecutivos = 0
				
				for word in slots.selected_words:
					for letters in word["letters"]:
						if letters[0].get_global_rect().has_point(get_global_mouse_position()):
							Jogo.pontuacao += word["letter_value"]
							root_node.atualizar_ui_pontos()
							break
				
				queue_free()
				completed = slots.verify_gaps()

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
				acertos_consecutivos = 0
				atualizar_erros_consecutivos()
				
				if not already_missed() and Jogo.vidas != -1:
					Jogo.vidas -= 1
				
				var palavra_errada = null
				for palavra_atual in slots.selected_words:
					for letra_posicao in palavra_atual["letters"]:
						if letra_posicao[0] == current_snap_area:
							palavra_errada = palavra_atual["letters"]
							break
					if palavra_errada:
						erro.play()
						break
				if palavra_errada:
					verify_type_error(letter_name, palavra_errada)
				
				if Jogo.vidas != -1 and Jogo.vidas <= 0:
					Jogo.completo = "S/ VIDAS"
					if Jogo.word_size == 4:
						Jogo.set_inatividade_fase1()
					elif Jogo.word_size == 5:
						Jogo.set_inatividade_fase2()
					elif Jogo.word_size == 6:
						Jogo.set_inatividade_fase3()
						Jogo.word_size = 3
						Jogo.salvar_dados_no_csv()
					get_tree().change_scene_to_file("res://scenes/lose_screen.tscn")

				root_node.atualizar_ui_vidas()
			
			position = original_position
			accept_event()
			
	elif event is InputEventMouseMotion and Jogo.is_dragging:
		position = get_global_mouse_position() - offset - get_parent().global_position
		check_snap_area()
		accept_event()

func check_snap_area(): 
	current_snap_area = null
	for word in slots.selected_words:
		var letters = word["letters"]
		for current_letter in letters: 
			if not current_letter[0].is_occupied:
				current_letter[0].modulate.a = 0.8
		for current_letter in letters:
			if current_letter[0].is_occupied:
				continue
			if current_letter[0].get_global_rect().has_point(get_global_mouse_position()):
				current_snap_area = current_letter[0]
				current_snap_area_letter = current_letter[1]
				current_letter[0].modulate.a = 1.2
				break

func verify_type_error(letter_name: String, word: Array):
	var correct_letters = []
	for pair in word:
		correct_letters.append(pair[1])

	if letter_name in correct_letters:
		Jogo.add_erro_posicao()
	else:
		Jogo.add_erro_escolha()

func already_missed():
	var missed = true
	for word in slots.selected_words:
		for letters in word["letters"]:
			if letters[0].get_global_rect().has_point(get_global_mouse_position()):
				if word["miss"] == false:
					missed = false
					word["miss"] = true
					word["letter_value"] = 50
					break
	return missed
	
func atualizar_acertos_consecutivos():
	acertos_consecutivos += 1
	if acertos_consecutivos > Jogo.acertos_consecutivos_max:
		Jogo.acertos_consecutivos_max = acertos_consecutivos

func atualizar_erros_consecutivos():
	erros_consecutivos += 1
	if erros_consecutivos > Jogo.erros_consecutivos_max:
		Jogo.erros_consecutivos_max = erros_consecutivos
