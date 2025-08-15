static func getUnitsAround(own : Area2D) -> Array[Unit]:
	var object_list : Array[Unit] = []
	for obj in own.get_overlapping_areas():
		var unit = obj.get_parent()
		if not unit is Unit:
			continue 
		if object_list.find(unit) == -1:
			object_list.append(unit)
	return object_list
