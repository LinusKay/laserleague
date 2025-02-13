extends Node

@onready var scores: Array = [ 0, 0 ]


func add_score(player_index: int, score: int = 1) -> void:
	scores[player_index] += score
	Global.emit_player_won_round(player_index)
	#print(scores)
