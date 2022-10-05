extends Control

var dialouge = load("res://Dialouge.tscn")
var choice = load("res://Choice.tscn")
var initpos = Vector2(40,40)
var nodeindex = 0
var blocks = []

var last = []

func _ready():
	OS.set_window_title("PDialougTree - Untitled")
	$File.get_popup().connect("id_pressed",self,"HandleFile")
	$New.get_popup().connect("id_pressed",self,"HandleNew")
	add_shortcut(KEY_M,$New,0)
	add_shortcut(KEY_N,$New,1)
	add_shortcut(KEY_Z,$New,2)
	
	
func add_shortcut(key,file,index,control = true):
	var shortcut = ShortCut.new()
	var inputev = InputEventKey.new()
	inputev.set_scancode(key)
	inputev.control = control
	shortcut.set_shortcut(inputev)
	
	file.get_popup().set_item_shortcut(index,shortcut,true)
	
func HandleFile(id):
	match id:
		0:
			newfile()
		1:
			save()
		2:
			loadf()
		3: 
			expor()
func HandleNew(id):
	match id:
		0:
			new_dialoug()
		1:
			new_choice()
		2:
			if last != []:
				last.pop_back().queue_free()

func save():
	$Save.popup()
func loadf():
	$Load.popup()

func expor():
	$Export.popup()
func newfile():
	pass

func new_dialoug():
	var inst = dialouge.instance()
	inst.offset += get_global_mouse_position() +  (nodeindex * Vector2(20,20))
	#inst.offset += initpos + (nodeindex * Vector2(20,20))
	inst.title += "-" + str(nodeindex)
	last.append(inst)
	$GraphEdit.add_child(inst)
	nodeindex += 1


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	$GraphEdit.connect_node(from,from_slot,to,to_slot)


func new_choice():
	var inst = choice.instance()
	inst.offset += get_global_mouse_position() + (nodeindex * Vector2(20,20))
	#inst.offset += initpos + (nodeindex * Vector2(20,20))
	inst.title += "-" + str(nodeindex)
	last.append(inst)
	$GraphEdit.add_child(inst)
	nodeindex += 1

func sort_list(lis):
	var res = []
	var i = 1
	while(len(lis) > 0):

		if i > len(lis) - 1:
			res.append(lis.pop_at(0))
			i = 1
		if len(lis) < 2:
			res.append(lis.pop_front())
			break
		if lis[0][1] == lis[i][0]:
			res.append(lis.pop_at(0))
			lis.insert(0,lis.pop_at(i-1))
			i = 1
		else:
			i+=1
	return res

func exportxml(file_name):
	var file = File.new()
	file.open(file_name, File.WRITE)
	var raw = $GraphEdit.get_connection_list()
	var list = []
	for i in raw:
		var pair = []
		pair.append($GraphEdit.get_node(i["from"]))
		pair.append($GraphEdit.get_node(i["to"]))
		list.append(pair)
	var pair = []
	var final = raw[len(raw)-1]
	pair.append($GraphEdit.get_node(final["to"]))
	pair.append($GraphEdit.get_node(final["to"]))
	#pair.append(final["to"])
	#pair.append(final["to"])
	#list.append(pair)
	
	list = sort_list(list)
	file.store_string("<Main>")
	write(file,list)

	
	for block in blocks:
		file.store_string(block.text)
	file.store_string("</Main>")
	file.close()
	#write($GraphEdit.get_child(safeindex),file)

func get_branch(list,start):
	var res = []
	if start >= len(list):
		return []
	var last = list[start]

	for i in range(start+1,len(list)):
		
		if list[i] == null or list[i][0] != last[1]:
			break
		res.append(list[i])
		last = list[i]
	if len(res) ==0 and list[start][1].type != 1:
		res.append([list[start][1],list[start][1]])
	elif list[start+len(res)][1].type != 1:
		res.append([list[start + len(res)][1],list[start + len(res)][1]])
	
	last = list[start]
	if last[0].type != 1:
		res.insert(0,last)
	return res

func write(file,list):
	var branches = []
	var skipto = -1
	var end = FileWrapper.new()
	for i in range(len(list)):
		if i < skipto:
			continue
		var l = list[i]
		if l == null:
			continue
		if l[0].type == 0:
			file.store_string("<Dialouge>" + str(l[0].get_data()))
			end.store_string("</Dialouge>")
		elif l[0].type == 1:
			for j in l[0].get_choices():
				file.store_string("<Choice>" + j + "</Choice>")
			file.store_string(end.text)
			end = FileWrapper.new()
			var readind = i
			var newblock = FileWrapper.new()
			for j in l[0].get_choices():
				newblock.store_string("<Choice id = \"" + j + "\">")
				var branch = get_branch(list,readind)
				readind += len(branch)+1
				write(newblock,branch)
				newblock.store_string("</Choice>")
			blocks.append(newblock)
			skipto = readind+1
	#if len(list) == 1:
		#file.store_string(list[len(list)-1][1].get_data())
	file.store_string(end.text)

func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	$GraphEdit.disconnect_node(from,from_slot,to,to_slot)


func save_data(file_name):
	var file = File.new()
	OS.set_window_title("PDialougTree - " + file_name)
	file.open(file_name, File.WRITE)
	var raw = $GraphEdit.get_connection_list()
	var list = []
	for i in raw:
		var pair = []
		pair.append("from:" + str($GraphEdit.get_node(i["from"]).id))
		pair.append("from_port:"+str(i["from_port"]))
		pair.append("to:"+str($GraphEdit.get_node(i["to"]).id))
		pair.append("to_port:"+str(i["to_port"]))
		list.append(pair)
	file.store_string(str(list) + "\n" +"[BEGINNODES]" + "\n")
	for child in get_tree().get_nodes_in_group("Saveables"):
		if child.type == 0:
			file.store_string("DialougeNode:[\n")
			file.store_string("\tOffset: " +str(child.offset) + ",\n")
			file.store_string("\tName: " +str(child.title) + ",\n")
			file.store_string("\tID: " +str(child.id) + ",\n")
			file.store_string("\tData: " +child.get_data())
		elif child.type == 1:
			file.store_string("ChoiceNode:[\n")
			file.store_string("\tOffset: " +str(child.offset) + ",\n")
			file.store_string("\tName: " +str(child.title) + ",\n")
			file.store_string("\tID: " +str(child.id) + ",\n")
			file.store_string("\tData: " +child.get_data())
		file.store_string("\n]\n[NEXTNODE]\n")
		
	file.close()
	
func load_data(file_name):
	var file = File.new()
	OS.set_window_title("PDialougTree - " + file_name)
	file.open(file_name, File.READ)
	var data = file.get_as_text().split("[BEGINNODES]")
	var arr = data[1].split("[NEXTNODE]")
	for n in arr:
		n = n.replace("\t", "").replace("\n","")
		if n.substr(0,13) == "DialougeNode:":
			n = n.substr(13)
			n = n.substr(8)
			var num1 = float(n.substr(2,n.find(",")-2))
			n = n.substr(n.find(","))
			var num2 = float(n.substr(2,n.find(")")-2))
			n = n.substr(n.find(")")+2)
			n = n.substr(n.find("Name:") + 5)
			var title = n.substr(0,n.find(","))
			n = n.substr(n.find("ID:") + 3)
			var id = int(n.substr(0,n.find(",")))
			n = n.substr(n.find("Data:") + 5)
			n = n.substr(0,len(n)-1)
			
			var inst = dialouge.instance()
			inst.offset = Vector2(num1,num2)
			inst.title = title
			inst.id = id
			inst.set_data(n)
			$GraphEdit.add_child(inst)
		elif n.substr(0,11).strip_edges() == "ChoiceNode:":
			n = n.substr(11)
			n = n.substr(8)
			var num1 = float(n.substr(2,n.find(",")-2))
			n = n.substr(n.find(","))
			var num2 = float(n.substr(2,n.find(")")-2))
			n = n.substr(n.find(")")+2)
			n = n.substr(n.find("Name:") + 5)
			var title = n.substr(0,n.find(","))
			n = n.substr(n.find("Data:") + 5)
			n = n.substr(2,len(n)-4)
			
			var inst = choice.instance()
			inst.offset = Vector2(num1,num2)
			inst.title = title
			inst.set_data(n.split("[NEXTDATA]"))
			$GraphEdit.add_child(inst)
		nodeindex+=1
	arr = data[0].split(":")
	var values = []
	for j in range(len(arr)):
		var i = arr[j]
		if i.find(",") != -1 or j == len(arr)-1:
			values.append(i.substr(0,i.find(",")).replace("}","").replace("]","").strip_edges())
	values.invert()
	while len(values) > 0:
		$GraphEdit.connect_node(matchnode(values.pop_back()),int(values.pop_back()),matchnode(values.pop_back()),int(values.pop_back()))

func matchnode(id):
	for node in get_tree().get_nodes_in_group("Saveables"):
		if node.id == int(id):
			return node.get_path()
	push_error("ERROR: ID in save file does not exist")
	return -1





func _on_Save_file_selected(path):
	save_data(path)


func _on_Load_file_selected(path):
	load_data(path)


func _on_Export_file_selected(path):
	exportxml(path)
