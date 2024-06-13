extends CanvasLayer

@onready var timer_label = $TimerLabel
@onready var meat_label = $Panel/MeatLabel

var time_elapsed : float = 0.0 
var meat_counter : int = 0

func _ready():
	meat_label.text = str(meat_counter)
	GameManager.player.meat_collected.connect(on_meat_collected)

func _process(delta):
	#update timer
	time_elapsed += delta
	var time_elapsed_in_seconds : int = floori(time_elapsed)
	var seconds : int = time_elapsed_in_seconds % 60
	var minutes : int = time_elapsed_in_seconds / 60
	timer_label.text = "%02d:%02d" % [minutes, seconds]

func on_meat_collected():
	meat_counter += 1
	meat_label.text = str(meat_counter)
