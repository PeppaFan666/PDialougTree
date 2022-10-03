extends Control

var dialouge = load("res://Dialouge.tscn")
var choice = load("res://Choice.tscn")
var initpos = Vector2(40,40)
var nodeindex = 0
var blocks = []

func _on_Button_pressed():
	var inst = dialouge.instance()
	inst.offset += initpos + (nodeindex * Vector2(20,20))
	inst.title += "-" + str(nodeindex)
	$GraphEdit.add_child(inst)
	nodeindex += 1


func _on_GraphEdit_connection_request(from, from_slot, to, to_slot):
	$GraphEdit.connect_node(from,from_slot,to,to_slot)


func _on_Button2_pressed():
	var inst = choice.instance()
	inst.offset += initpos + (nodeindex * Vector2(20,20))
	inst.title += "-" + str(nodeindex)
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

func _on_Button3_pressed():
	var file = File.new()
	file.open("res://CoolXML.xml", File.WRITE)
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
	list.append(pair)
	
	list = sort_list(list)
	
	var branches = []
	var end = FileWrapper.new()
	for l in list:
		if l == null:
			continue
		if l[0].type == 0:
			file.store_string("<Dialouge>" + str(l[0].get_data()))
			end.store_string("</Dialouge>")
		elif l[0].type == 1:
			pass
	file.store_string(end.text)
	
	for block in blocks:
		file.store_string(block.text)
	file.close()
	#write($GraphEdit.get_child(safeindex),file)





func _on_GraphEdit_disconnection_request(from, from_slot, to, to_slot):
	$GraphEdit.disconnect_node(from,from_slot,to,to_slot)


func save_data(file_name):
	var file = File.new()
	file.open("res://CoolTree.PTF", File.WRITE)
	file.store_string(str($GraphEdit.get_connection_list()) + "\n" +"[BEGINNODES]" + "\n")
	for child in get_tree().get_nodes_in_group("Saveables"):
		if child.type == 0:
			file.store_string("DialougeNode:[\n")
			file.store_string("\tOffset: " +str(child.offset) + ",\n")
			file.store_string("\tName: " +str(child.title) + ",\n")
			file.store_string("\tData: " +child.get_data())
		elif child.type == 1:
			file.store_string("ChoiceNode:[\n")
			file.store_string("\tOffset: " +str(child.offset) + ",\n")
			file.store_string("\tName: " +str(child.title) + ",\n")
			file.store_string("\tData: " +child.get_data())
		file.store_string("\n]\n[NEXTNODE]\n")
		
	file.close()
	
func load_data(file_name):
	var file = File.new()
	file.open("res://CoolTree.PTF", File.READ)
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
			n = n.substr(n.find("Data:") + 5)
			n = n.substr(0,len(n)-1)
			
			var inst = dialouge.instance()
			inst.offset = Vector2(num1,num2)
			inst.title = title
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
		$GraphEdit.connect_node(values.pop_back(),int(values.pop_back()),values.pop_back(),int(values.pop_back()))


func _on_Button4_pressed():
	save_data("CoolFile")


func _on_Button5_pressed():
	load_data("CoolFile")
