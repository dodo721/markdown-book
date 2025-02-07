@tool
extends Tree

const ICON = preload("res://addons/doc_book/icon.svg")
const PageViewer = preload("res://addons/doc_book/doc_book_page_viewer.gd");

const ACCEPT_FILE_TYPES = [ "md", "txt" ];

# Page data that cant be stored in TreeItem
class PageEntry:
	var filepath : String;
	var is_dir : bool;
	var tree_item : TreeItem;
	
	func _init(filep: String, dir: bool, ti: TreeItem, is_root: bool = false) -> void:
		# Remove filepath extension if present, so pages with a file and directory match names
		filepath = filep;
		is_dir = dir;
		tree_item = ti;
	static func get_pagepath (filepath: String) -> String:
		return filepath.replace("." + filepath.get_extension(), "");
# Other functions don't care about tree structure - makes fetch time O(1)
var _page_entries_by_path : Dictionary[String, PageEntry] = {};
# So item_selected signal callback can find the matching page entry
var _page_entries_by_item : Dictionary[TreeItem, PageEntry] = {};

@export
var page_viewer : PageViewer;

var doc_tree : PageEntry = null;
var _reloading : bool = false;

func build_doc_tree(doc_dir_path: String) -> void:
	_reloading = true;
	print("[Doc Book] (Re)building doc tree from ", doc_dir_path);
	clear();
	_page_entries_by_path.clear();
	doc_tree = PageEntry.new(doc_dir_path, true, null, true);
	_page_entries_by_path[doc_dir_path] = doc_tree;
	_recurse_load_dir(doc_dir_path, null);
	_reloading = false;
	print(_page_entries_by_item.values().map(func (page_entry): return page_entry.filepath));

func _recurse_load_dir(path: String, parent: TreeItem, self_entry: PageEntry = null):
	var dir = DirAccess.open(path);
	# Don't add empty dirs
	var valid_page_files = dir.get_files() as Array[String];
	valid_page_files = valid_page_files.filter(func (file: String): return ACCEPT_FILE_TYPES.has(file.get_extension()));
	if valid_page_files.size() == 0:
		return null;
	# Create entry for self
	var self_item: TreeItem = null;
	if not self_entry:
		self_item = create_item(parent);
		self_item.set_text(0, path.get_file().capitalize());
		self_item.set_tooltip_text(0, path);
		self_entry = PageEntry.new(path, true, self_item);
	else:
		self_item = self_entry.tree_item;
	_page_entries_by_path[path] = self_entry;
	_page_entries_by_item[self_item] = self_entry;
	# Create page entries from files
	for file: String in valid_page_files:
		var file_path = path.path_join(file);
		var page_item = create_item(self_item);
		page_item.set_text(0, file.get_basename().capitalize());
		page_item.set_tooltip_text(0, file);
		var page_entry = PageEntry.new(file_path, false, page_item);
		if file_path.contains("links"):
			print("FOUND LINKS: ", file_path);
		_page_entries_by_path[PageEntry.get_pagepath(file_path)] = page_entry;
		_page_entries_by_item[page_item] = page_entry;
	# Recursively scan subdirs
	for subdir: String in dir.get_directories():
		var subdir_path = path.path_join(subdir);
		var subdir_entry: PageEntry = _page_entries_by_path.get(subdir_path);
		if subdir_entry:
			# Add pages to existing item
			subdir_entry = _recurse_load_dir(subdir_path, self_item, subdir_entry);
		else:
			# Let recursive method create new item
			subdir_entry = _recurse_load_dir(subdir_path, self_item);

func get_page_entry(item: TreeItem) -> PageEntry:
	return _page_entries_by_item[item];
