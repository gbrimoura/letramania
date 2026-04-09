extends Area2D  # Ou "Control" para UI

var is_occupied := false

# Quando um item entra na área
func _on_body_entered() -> void:
	if not is_occupied:
		modulate.a = 0.2  # Define opacidade para 50%

# Quando um item sai da área
func _on_body_exited() -> void:
	modulate.a = 0.5  # Volta à opacidade total (100%)
