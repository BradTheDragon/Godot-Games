extends Node

@onready var label: Label = $Label
@onready var timer: Timer = $Timer

func _process(delta: float) -> void:
	if TimerVariables.started == true:
		TimerVariables.time += delta
	var result = "%.0f" % TimerVariables.time
	label.text = result + "s"

func _on_start_body_entered(body) -> void:
	TimerVariables.started = true

func _on_finish_body_entered(body: Node2D) -> void:
	if TimerVariables.time > 0.0:
		TimerVariables.started = false
		Engine.time_scale = 0.25
		timer.start()

func _on_timer_timeout() -> void:
	Engine.time_scale = 1.0
	TimerVariables.time = 0.0
