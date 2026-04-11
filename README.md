# Letra Mania

Jogo educacional desenvolvido em Godot para formação de palavras a partir de imagens e letras arrastáveis. O projeto foi pensado para uso em tela ampla e mobile, com interface adaptativa, feedback sonoro e telas de progresso, derrota e conclusão.

## Visão geral

O jogador começa no menu principal, informa um ID de paciente/jogador, escolhe iniciar a partida e monta palavras com base nas imagens exibidas. As rodadas são organizadas por tamanho de palavra:

- 4 letras
- 5 letras
- 6 letras

A cada fase, o jogo gera palavras diferentes, disponibiliza um conjunto de letras para arrastar e avalia acertos, erros, tempo e vidas.

## Funcionalidades

- Menu inicial com início, saída, áudio e acesso às configurações.
- Tela de configuração com ajuste de tema, vidas, temporizador e tempo de dica.
- Sistema de arrastar e soltar letras para completar palavras.
- Pontuação por acerto, com controle de erros de posição e de escolha.
- Vidas configuráveis, incluindo modo infinito.
- Dicas automáticas após período de inatividade.
- Áudio de clique, acerto, erro e música de fundo com mute persistente.
- Salvamento das configurações em arquivo local.
- Registro de dados da sessão em CSV.

## Telas principais

- `menu.tscn`: menu inicial e entrada do ID do jogador/paciente.
- `game.tscn`: fase principal de formação de palavras.
- `config.tscn`: ajustes de jogo e aparência.
- `prox_fase.tscn`: transição entre fases.
- `lose_screen.tscn`: tela de derrota.
- `fim.tscn`: tela final de conclusão.

## Controles

- Arraste as letras até a lacuna correspondente.
- Use os botões de áudio para ligar ou desligar a música.
- Use o botão de voltar para sair da fase e retornar ao menu, com confirmação.

## Configurações disponíveis

- Tema visual: Padrão, Azul, Verde e Roxo.
- Vidas: de 1 a 11 ou infinito.
- Pontuação: ativar ou desativar exibição.
- Temporizador: ativar ou desativar exibição.
- Tempo de dica: ajuste em segundos.

As preferências são salvas em `user://configuracao.cfg`.

## Dados gerados

Durante as partidas, o jogo registra métricas da sessão e exporta um CSV com os resultados. No código atual, esse arquivo é salvo em `dados_partidas.csv` dentro da pasta de Download do dispositivo Android.

## Instalação

### Arquivos binários
- [Releases](https://github.com/gbrimoura/letramania/releases)

### Construção a partir do código-fonte

#### Pré-requisitos

- Godot 4.6 ou superior.
- Projeto configurado para renderer mobile.

#### Como executar

1. Abra o projeto no Godot.
2. Aguarde a importação dos recursos.
3. Execute a cena principal definida em `project.godot`, que aponta para `scenes/menu.tscn`.

## Estrutura resumida

- `scenes/`: cenas do menu, jogo, configuração e telas finais.
- `scripts/`: lógica de menu, gameplay, configurações e estados globais.
- `assets/` e `recursos/`: imagens, áudios e materiais visuais.
- `shaders/`: shaders usados para destaque visual.

## Observações

- O projeto usa autoloads para música, configurações e estado do jogo.
- O fluxo de fases e o salvamento de dados dependem dos valores globais mantidos durante a execução.
