extends Node3D
signal newlevel_text(chapter, level, text)
@export var chapter: String = ""
@export var level: String = ""
@export var text: String = ""
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	newlevel_text.emit(chapter, level, text)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
