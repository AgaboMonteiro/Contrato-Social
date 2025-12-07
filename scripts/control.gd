extends Control


@onready var contador_moeda = $container/moedas_container/contador_moeda as Label


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	contador_moeda.text = str("%04d" % Global.moedas)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	contador_moeda.text = str("%04d" % Global.moedas)
