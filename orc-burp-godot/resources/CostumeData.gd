extends Resource
class_name CostumeData

enum CostumeType { Hat, Clothe }

@export var id: String
@export var name: String
@export_multiline var description: String
@export var type: CostumeType
@export var texture : Texture
