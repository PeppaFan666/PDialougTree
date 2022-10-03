extends GraphNode


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var data = ""
var type = 0
# Called when the node enters the scene tree for the first time.
func _ready():
	set_slot(0,true,0,Color(1,1,1,1),true,0,Color(1,1,1,1))
	add_to_group("Saveables")

func set_data(indat:String):
	data = indat
	$TextEdit.text = indat

func _on_Dialouge_close_request():
	queue_free()

func get_data():
	return data

func _on_Dialouge_resize_request(new_minsize):
	$TextEdit.rect_min_size = new_minsize *0.75
	rect_size = new_minsize


func _on_TextEdit_text_changed():
	data = $TextEdit.text
