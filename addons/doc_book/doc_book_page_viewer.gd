@tool
extends HBoxContainer

var _rich_text : RichTextLabel;
var _md_text : MarkdownLabel;

func _ready() -> void:
	_rich_text = $RichTextLabel;
	_md_text = $MarkdownLabel;

func load_page_file(filepath: String) -> bool:
	if not FileAccess.file_exists(filepath):
		printerr("[Doc Book] Tried to load non-existent page file at path ", filepath);
		return false;
	var text = FileAccess.get_file_as_string(filepath);
	if FileAccess.get_open_error() != Error.OK:
		printerr("[Doc Book] Error opening page file at path ", filepath, ": ", FileAccess.get_open_error());
		return false;
	var is_md := filepath.get_extension() == "md";
	if is_md:
		_rich_text.visible = false;
		_md_text.visible = true;
		_md_text.markdown_text = text;
	else:
		_md_text.visible = false;
		_rich_text.visible = true;
		_rich_text.text = text;
	return true;

func set_page_text(text: String, md: bool = false) -> void:
	if md:
		_rich_text.visible = false;
		_md_text.visible = true;
		_md_text.markdown_text = text;
	else:
		_md_text.visible = false;
		_rich_text.visible = true;
		_rich_text.text = text;
