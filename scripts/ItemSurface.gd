extends StaticBody2D

## Shared "one item resting on this surface" behavior for Station/Counter.
## Items (WineBottle instances) are reparented here so they visually sit on
## top of the furniture until something takes them again.

const ITEM_OFFSET := Vector2.ZERO

var held_item: Node2D = null


func has_item() -> bool:
	return held_item != null


func place_item(item: Node2D) -> bool:
	if has_item():
		return false
	held_item = item
	if item.get_parent():
		item.get_parent().remove_child(item)
	add_child(item)
	item.position = ITEM_OFFSET
	return true


func take_item() -> Node2D:
	var item: Node2D = held_item
	if item:
		remove_child(item)
	held_item = null
	return item
