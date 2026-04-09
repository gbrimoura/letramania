extends Node2D

const FILE_PATH = "user://dados_partidas.csv"
var session_id: String
var acertos_consecutivos_max : int = 0
var erros_consecutivos_max : int = 0
var vidas_iniciais : int
var vidas_finais : int
var tempo_ocioso_menu: float = 0

var is_dragging = false
var is_tipping = false
var word_size = 3
var tempo_decorrido: float = 0.0

var acertos = 0
var erros = 0
var erro_posicao = 0
var erro_escolha = 0
var letras_selecionadas = 0

var time_start: String
var time_end: String
var media_letra: float
var media_letra_certa: float
var aux_time := 0.0  

var total_idle_time := 0.0
var total_idle_time1 := 0.0
var total_idle_time2 := 0.0
var total_idle_time3 := 0.0

var pontos1: int = 0
var pontos2: int = 0
var pontos3: int = 0

var tempo1: float = 0.0
var tempo2: float = 0.0
var tempo3: float = 0.0

var acertos1: int = 0
var acertos2: int = 0
var acertos3: int = 0

var erros1: int = 0
var erros2: int = 0
var erros3: int = 0

var erro_posicao1: int = 0
var erro_posicao2: int = 0
var erro_posicao3: int = 0

var erro_escolha1: int = 0
var erro_escolha2: int = 0
var erro_escolha3: int = 0

var completo: String
var vidas: int
var pontuacao: int

# NÃO usar @onready aqui, porque o node não existe ainda
var erro: Node = null
var paciente_id: String = "" # <-- armazenará o texto digitado

# Chamadas de incremento
func add_letras_selecionadas():
	letras_selecionadas += 1
	
func add_acertos():
	acertos += 1

func add_erros():
	erros += 1

func add_erro_posicao():
	erro_posicao += 1

func add_erro_escolha():
	erro_escolha += 1

func add_idle_time(time: float) -> void:
	total_idle_time += time

func calcular_media():
	media_letra = tempo_decorrido / letras_selecionadas if letras_selecionadas > 0 else 0.0
	media_letra_certa = tempo_decorrido / acertos if acertos > 0 else 0.0

func set_inatividade_fase1():
	total_idle_time1 = total_idle_time
	pontos1 = pontuacao
	tempo1 = tempo_decorrido
	acertos1 = acertos
	erros1 = erros
	erro_escolha1 = erro_escolha
	erro_posicao1 = erro_posicao

func set_inatividade_fase2():
	total_idle_time2 = (total_idle_time - total_idle_time1)
	pontos2 = pontuacao - pontos1
	tempo2 = tempo_decorrido - tempo1
	acertos2 = acertos - acertos1
	erros2 = erros - erros1
	erro_escolha2 = erro_escolha - erro_escolha1
	erro_posicao2 = erro_posicao - erro_posicao1
	
func set_inatividade_fase3():
	total_idle_time3 = (total_idle_time - total_idle_time1 - total_idle_time2)
	pontos3 = pontuacao - pontos1 - pontos2
	tempo3 = tempo_decorrido - tempo1 - tempo2
	acertos3 = acertos - acertos1 - acertos2
	erros3 = erros - erros1 - erros2
	erro_escolha3 = erro_escolha - erro_escolha1 - erro_escolha2
	erro_posicao3 = erro_posicao - erro_posicao1 - erro_posicao2
	
func get_time():
	var current_date_time = Time.get_datetime_dict_from_system()
	var formatted_date_time = "%02d-%02d-%04d %02d:%02d:%02d" % [
		current_date_time["day"], 
		current_date_time["month"], 
		current_date_time["year"], 
		current_date_time["hour"], 
		current_date_time["minute"], 
		current_date_time["second"]
	]
	return formatted_date_time

# Função para registrar o node 'Errado' depois que a cena carregar
func set_erro_node(control_node: Node) -> void:
	erro = control_node.get_node("Errado")

# função para gerar um session_id randomico utilizando parâmetros de tempo
func gerar_session_id() -> String:
	var datetime = Time.get_datetime_dict_from_system()
	var timestamp = "%04d%02d%02d-%02d%02d%02d" % [
		datetime.year,
		datetime.month,
		datetime.day,
		datetime.hour,
		datetime.minute,
		datetime.second
	]
	var random_part = randi() % 10000
	return "LM-" + timestamp + "-" + str(random_part)

# Função para salvar os dados no CSV (igual ao seu original)
func salvar_dados_no_csv():
	if paciente_id == "":
		print("⚠️ Nenhum ID de paciente inserido! Adicione antes de salvar.")
		return
	
	# Configura as variaveis que serao salvas no CSV
	var linhas = []
	var erros_area_invalida: int = erros - erro_escolha - erro_posicao
	var date : String = get_date_yyyy_mm_dd()
	var tempo_reacao: float = total_idle_time / 1000.0
	var total_respostas: int = acertos + erros
	var taxa_acerto: float = (float(acertos) * 100.0) / float(total_respostas) if total_respostas > 0 else 0.0
	time_start = extrair_hora(time_start)
	time_end = get_time_hh_mm_ss()
	
	randomize()
	session_id = gerar_session_id()
	
	calcular_media()

	var total_idle_time_segundos = total_idle_time / 1000.0
	var total_idle_time1_segundos = total_idle_time1 / 1000.0
	var total_idle_time2_segundos = total_idle_time2 / 1000.0
	var total_idle_time3_segundos = total_idle_time3 / 1000.0

	var pasta_destino = "/storage/emulated/0/Download"
	var caminho_arquivo = pasta_destino + "/dados_partidas.csv"

	if FileAccess.file_exists(caminho_arquivo):
		var file = FileAccess.open(caminho_arquivo, FileAccess.READ)
		if file:
			while not file.eof_reached():
				var line = file.get_line()
				if line != "":
					linhas.append(line)
			if linhas.size() > 1:
				var last_line = linhas[-1].split(",")
			file.close()

	if linhas.is_empty():
		linhas.append("ID, nome_jogador, jogo, data, hora_inicio, hora_fim, duracao, acertos, erros,
						tempo_reacao_media, acertos_consecutivos_max, erros_consecutivos_max, taxa_acerto,
						tempo_para_ajuda, vidas_inicial, vidas_final, quantidade_ajuda, erros_escolha,
						erro_ferramenta, erro_area_invalida, tempo_medio_por_letra, tempo_medio_por_acerto
						tempo_f1, tempo_ociosidade_f1, acertos_f1, erros_f1, erros_escolha_f1, erros_posicao_f1
						tempo_f2, tempo_ociosidade_f2, acertos_f2, erros_f2, erros_escolha_f2, erros_posicao_f2
						tempo_f3, tempo_ociosidade_f3, acertos_f3, erros_f3, erros_escolha_f3, erros_posicao_f3
						perseveracao_erro, tempo_inicio_sessao, status_sessao ")

	linhas.append(
		str(session_id) + "," + 						# ID
		str(paciente_id) + "," + 						# nome_jogador
		str("Letra Mania") + "," + 						# jogo
		str(date) + "," + 								# data
		str(time_start) + "," +							# hora_inicio
		str(time_end) + "," +							# hora_fim
		"%.0f" % tempo_decorrido + "," +				# duracao
		str(acertos) + "," +							# acertos
		str(erros) + "," +								# erros
		str(tempo_reacao) + "," +						# tempo_reacao_media
		str(acertos_consecutivos_max) + "," +			# acertos_consecutivos_max
		str(erros_consecutivos_max) + "," +				# erros_consecutivos_max
		"%.2f" % taxa_acerto + "," +					# taxa_acerto
		str(Configuracoes.config.nivel_de_dica) + "," + # tempo_para_ajuda
		str(vidas_iniciais) + "," +						# vidas_inicial
		str(vidas_finais) + "," +						# vidas_final
		str("-") + "," +								# quantidade_ajuda *
		str(erro_escolha) + "," +						# erros_escolha
		str("-") + "," +								# erro_ferramenta *
		str(erros_area_invalida) + "," +				# erro_area_invalida
		"%.0f" % media_letra + "," +					# tempo_medio_por_letra
		"%.0f" % media_letra_certa + "," +				# tempo_medio_por_acerto
		
		"%.0f" % tempo1 + "," + 						# coisas da Fase 1
		"%.0f" % total_idle_time1_segundos + ","  +			#
		str(acertos1) + ","  +							#
	 	str(erros1) + ","  + 							#
		str(erro_escolha1) + "," +						#
		str(erro_posicao1) + "," + 						#
		str(pontos1) + "," +							#
		
		"%.0f" % tempo2 + "," + 						# coisas da Fase 2
		"%.0f" % total_idle_time2_segundos + ","  +			#
		str(acertos2) + ","  + 							#
		str(erros2) + ","  + 							#
		str(erro_escolha2) + "," +						#
		str(erro_posicao2) + "," + 						#
		str(pontos2) + "," +							#
		
		"%.0f" % tempo3 + "," + 						# coisas da Fase 3
		"%.0f" % total_idle_time3_segundos + ","  +			#
		str(acertos3) + ","  + 							#
		str(erros3) + ","  + 							#
		str(erro_escolha3) + "," +						#
		str(erro_posicao3) + "," + 						#
		str(pontos3) + "," +							#
		
		str("-") + "," +								# perseveracao_erro *
		str(tempo_ocioso_menu) + "," +					# tempo_inicio_sessao
		str(completo) + ","

		
		#str(completo) + "," +
		#str(time_start) + "," +
		#str(time_end) + "," +
		#"%.2f" % tempo_decorrido + "," +
		#str(Configuracoes.config.nivel_de_dica) + "," +
		#str(letras_selecionadas) + "," +
		#str(acertos) + "," +
		#str(erros) + "," +
		#str(erro_escolha) + "," +
		#str(erro_posicao) + "," +
		#str(erros_area_invalida) + "," +
		#"%.2f" % total_idle_time + "," +
		#str(pontuacao) + ","  +
		#"%.2f" % tempo1 + "," + "%.2f" % total_idle_time1 + ","  +
		#str(acertos1) + ","  + str(erros1) + ","  + str(erro_escolha1) + "," +
		#str(erro_posicao1) + "," + str(pontos1) + "," +
		#"%.2f" % tempo2 + "," + "%.2f" % total_idle_time2 + ","  +
		#str(acertos2) + ","  + str(erros2) + ","  + str(erro_escolha2) + "," +
		#str(erro_posicao2) + "," + str(pontos2) + "," +
		#"%.2f" % tempo3 + "," + "%.2f" % total_idle_time3 + ","  +
		#str(acertos3) + ","  + str(erros3) + ","  + str(erro_escolha3) + "," +
		#str(erro_posicao3) + "," + str(pontos3) + "," +
		#"%.2f" % media_letra + "," + "%.2f" % media_letra_certa
	)

	var file = FileAccess.open(caminho_arquivo, FileAccess.WRITE)
	if file:
		for line in linhas:
			file.store_line(line)
		file.close()
		print("✅ Dados salvos em: " + caminho_arquivo)
	else:
		push_error("❌ Erro ao salvar o arquivo!")
		
# Função para gerar o tempo no formato YYYY-MM-DD
func get_date_yyyy_mm_dd() -> String:
	var date = Time.get_date_dict_from_system()
	return "%04d-%02d-%02d" % [
		date.year,
		date.month,
		date.day
	]

# Função para gerar o tempo no formato HH-MM-SS
func get_time_hh_mm_ss() -> String:
	var time = Time.get_time_dict_from_system()
	return "%02d:%02d:%02d" % [
		time.hour,
		time.minute,
		time.second
	]

# Função pra extrair só a hora de um get_time
func extrair_hora(datetime_str: String) -> String:
	if datetime_str == "":
		return ""
	
	var parts = datetime_str.split(" ")
	
	if parts.size() > 1:
		return parts[1] # veio "data hora"
	else:
		return parts[0] # já é só hora
