extends GraphNode


# Declare member variables here. Examples:
# var a = 2
# var b = "text"
var type = 1
var ind = 1
# Called when the node enters the scene tree for the first time.
func _ready():
	set_slot(0,true,0,Color(0.262745, 0.141176, 0.764706),false,0,Color(0.262745, 0.141176, 0.764706))
	add_to_group("Saveables")

func set_data(input):
	for i in range(len(input)-1):
		newtext(input[i])

func get_data():
	var res = "["
	for i in get_children():
		if i is TextEdit:
			res += i.text + "[NEXTDATA]"
	res+= "]"
	return res

func get_choices():
	var res = []
	for i in get_children():
		if i is TextEdit:
			res.append(i.text)
	return res


func _on_Dialouge_close_request():
	queue_free()


func _on_Dialouge_resize_request(new_minsize):
	#$TextEdit.rect_min_size = new_minsize *0.75
	rect_size = new_minsize

func newtext(s = ""):
	var edit = TextEdit.new()
	edit.set_name("node")
	edit.rect_min_size = Vector2(30,30)
	edit.text = s
	add_child(edit)
	set_slot(ind,false,0,Color(0.262745, 0.141176, 0.764706),true,0,Color(0.262745, 0.141176, 0.764706))
	ind += 1

func _on_Button_pressed():
	newtext()
