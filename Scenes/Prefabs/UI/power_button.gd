extends Button
class_name PowerButton

@export var b_icon:TextureRect

func set_icon(texture:CompressedTexture2D)->void:
	b_icon.texture=texture
