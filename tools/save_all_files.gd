@tool
extends EditorScript

## saves every file in the project.
## should be run after updating a godot version as there will be some diffs that should be saved in one commit.
## should also generate missing .uid files

var files: Array[String]

func _run() -> void:
	files = []
	
	add_files("res://")
	
	for file in files:
		print(file)
		var res: Resource = load(file)
		ResourceSaver.save(res)

func add_files(dir: String) -> void:
	for file in DirAccess.get_files_at(dir):
		if file.get_extension() == "tscn" or file.get_extension() == "tres":
			files.append(dir.path_join(file))
	
	for dr in DirAccess.get_directories_at(dir):
		add_files(dir.path_join(dr))
