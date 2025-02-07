@tool
extends EditorPlugin


const ADDON_PATH := "addons/doc_book/"
const ADDON_NAME := "DocBook"
const PANEL_DOCS = preload("res://addons/doc_book/doc_book.tscn")
const PANEL_ICON = preload("res://addons/doc_book/icon.svg")

var plugin_path_docs := ADDON_PATH.path_join("docs_folder")
var main_panel_instance


func _enter_tree() -> void:
	if not ProjectSettings.has_setting(plugin_path_docs):
		ProjectSettings.set_setting(plugin_path_docs, "res://docs")
		
		var property_info := {
			"name": plugin_path_docs,
			"type": TYPE_STRING,
			"hint": PROPERTY_HINT_DIR,
		}
		
		ProjectSettings.add_property_info(property_info)
		print("[Doc Book] Plugin activated! Go to \"Docs\" to begin.");
		return
	
	# TODO: reload on setting change
	var path_docs_folder = ProjectSettings.get_setting(plugin_path_docs)
	
	if DirAccess.dir_exists_absolute(path_docs_folder):
		var dir = DirAccess.open(path_docs_folder);
		if dir.get_open_error():
			printerr("[Doc Book] Could not open docs path ", path_docs_folder, ": ", dir.get_open_error());
			printerr("[Doc Book] Please set a valid directory path in Advanced Project Settings > Addons > Doc Book > Docs Folder");
	else:
		print("[Doc Book] No docs found. Go to \"DocBook\" to create one.");
	
	main_panel_instance = PANEL_DOCS.instantiate()
	main_panel_instance.get_node("%MainInterface").path_docs_folder = path_docs_folder
	
	EditorInterface.get_editor_main_screen().add_child.call_deferred(main_panel_instance)
	_make_visible(false)


func _exit_tree() -> void:
	if main_panel_instance:
		main_panel_instance.queue_free()


func _has_main_screen():
	return true


func _make_visible(visible):
	if main_panel_instance:
		main_panel_instance.visible = visible


func _get_plugin_name():
	return ADDON_NAME


func _get_plugin_icon():
	return PANEL_ICON
