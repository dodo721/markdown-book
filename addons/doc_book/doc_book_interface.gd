@tool
extends HSplitContainer

const DocTree = preload("res://addons/doc_book/doc_book_tree.gd")
const PageViewer = preload("res://addons/doc_book/doc_book_page_viewer.gd")

@export
var tree : DocTree;
@export
var page_viewer : PageViewer;

var path_docs_folder: String

func _ready() -> void:
	reload();

func reload ():
	tree.build_doc_tree(path_docs_folder);

func _on_reload_btn_pressed() -> void:
	reload();

func _on_item_selected() -> void:
	if tree._reloading:
		return;
	var selected := tree.get_selected();
	if not selected:
		return;
	var page_entry := tree.get_page_entry(selected);
	if not FileAccess.file_exists(page_entry.filepath):
		# print("[Markdown Viewer] %s file \"%s\" does not exists" % [line.name, line.path])
		page_viewer.set_page_text("[i]Page not found[/i][br][/br][i]Path %s does not exist[/i]" % page_entry.filepath);
		return;
	page_viewer.load_page_file(page_entry.filepath);
