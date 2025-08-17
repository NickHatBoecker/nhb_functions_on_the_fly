## All functions of this script are testable.

class_name NhbFunctionsOnTheFlyUtils
extends Node


enum INDENTATION_TYPES { TABS, SPACES }


func is_in_comment(code_edit: CodeEdit, selected_text: String) -> bool:
    if selected_text.begins_with("#"): return true

    var caret_line = code_edit.get_caret_line()
    var line_text = code_edit.get_line(caret_line)
    var selection_start = code_edit.get_selection_from_column()

    var comment_pos = line_text.find("#")
    if comment_pos != -1 and comment_pos < selection_start:
        return true

    return false


## Returns true if
## - text contains a valid variable syntax
## - and text is not a comment line
##
## @param `text` contains the whole line of code.
func should_show_create_variable(code_edit: CodeEdit, text: String, variable_name_regex: String) -> bool:
    var script_text = code_edit.text

    ## Check if valid variable name
    var regex = RegEx.new()
    regex.compile(variable_name_regex)
    if not regex.search(text):
        return false

    if is_in_comment(code_edit, text):
        return false

    return true


## Return return type or an empty string if no return type is provided.
## @example `var button: Button` will return "Button"
## @example `var button` will return ""
func get_variable_return_type(text: String, variable_return_type_regex: String) -> String:
    var regex = RegEx.new()
    regex.compile(variable_return_type_regex)

    var result = regex.search(text)
    if not result:
        return ""

    return result.get_string(1)


func get_current_line_text(_code_edit: CodeEdit) -> String:
    return _code_edit.get_line(_code_edit.get_caret_line())


func get_shortcut_path(parameter: String) -> String:
    return "res://addons/nhb_functions_on_the_fly/%s" % parameter


## Tab or spaces
func get_indentation_character(settings: EditorSettings = null) -> String:
    if !settings:
        ## GUT unit test context
        ## @TODO Remove this as soon as it's possible to stub EditorSettings.
        return "\t"

    var indentation_type = settings.get_setting("text_editor/behavior/indent/type")
    var indentation_character: String = "\t"

    if indentation_type != INDENTATION_TYPES.TABS:
        var indentation_size = settings.get_setting("text_editor/behavior/indent/size")
        indentation_character = " ".repeat(indentation_size)

    return indentation_character


func create_get_set_variable(variable_name: String, code_edit: CodeEdit, variable_return_type_regex: String, settings: EditorSettings = null) -> void:
    var current_line : int = code_edit.get_caret_line()
    var line_text : String = code_edit.get_line(current_line)
    var end_column : int = line_text.length()
    var indentation_character: String = get_indentation_character(settings)

    var return_type: String = ": Variant"
    if not get_variable_return_type(line_text, variable_return_type_regex).is_empty():
        ## Variable already has a return type.
        return_type = ""
    if line_text.contains("="):
        ## Variable has a value so omit return type.
        return_type = ""

    var code_text: String = "%s:\n%sget:\n%sreturn %s\n%sset(value):\n%s%s = value" % [
        return_type,
        indentation_character,
        indentation_character.repeat(2),
        variable_name,
        indentation_character,
        indentation_character.repeat(2),
        variable_name
    ]

    code_edit.deselect()
    code_edit.insert_text(code_text, current_line, end_column)


func create_function(function_name: String, code_edit: CodeEdit, settings: EditorSettings = null):
    code_edit.deselect()

    var indentation_character: String = get_indentation_character(settings)
    var new_function = "\n\nfunc " + function_name + "() -> Variant:\n%sreturn" % indentation_character

    code_edit.text = code_edit.text + new_function

    var line_count = code_edit.get_line_count()
    var pass_line = line_count - 1

    code_edit.set_caret_line(pass_line)
    code_edit.set_caret_column(1)

    code_edit.select(pass_line, 1, pass_line, 5)
    code_edit.text_changed.emit()


func get_word_under_cursor(code_edit: CodeEdit) -> String:
    var caret_line = code_edit.get_caret_line()
    var caret_column = code_edit.get_caret_column()
    var line_text = code_edit.get_line(caret_line)

    var start = caret_column
    while start > 0 and line_text[start - 1].is_subsequence_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):
        start -= 1

    var end = caret_column
    while end < line_text.length() and line_text[end].is_subsequence_of("abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789_"):
        end += 1

    return line_text.substr(start, end - start)
