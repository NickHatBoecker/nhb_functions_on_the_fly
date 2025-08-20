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
func should_show_create_variable(code_edit: CodeEdit, text: String, variable_name_regex: String, settings) -> bool:
    ## Check if valid variable name
    var regex = RegEx.new()
    regex.compile(variable_name_regex)
    if not regex.search(text):
        return false

    if is_in_comment(code_edit, text):
        return false

    if !is_global_variable(text, settings):
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


## Get accumulated indentation string.
## Will return "\t" if tabs are used for indentation.
## Will return " " * indent/size if spaces are used for indentation.
func get_indentation_character(settings) -> String:
    var indentation_type = settings.get_setting("text_editor/behavior/indent/type")
    var indentation_character: String = "\t"

    if indentation_type != INDENTATION_TYPES.TABS:
        var indentation_size = settings.get_setting("text_editor/behavior/indent/size")
        indentation_character = " ".repeat(indentation_size)

    return indentation_character


func create_get_set_variable(variable_name: String, code_edit: CodeEdit, variable_return_type_regex: String, settings) -> void:
    var current_line : int = code_edit.get_caret_line()
    var line_text : String = code_edit.get_line(current_line)

    if !is_global_variable(line_text, settings): return

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


func create_function(function_name: String, code_edit: CodeEdit, settings):
    var current_line : int = code_edit.get_caret_line()
    var line_text : String = code_edit.get_line(current_line)

    code_edit.deselect()

    var return_type: String = get_function_return_type(function_name, code_edit)
    var return_type_string: String = " -> %s" % return_type
    if !return_type:
        return_type_string = ""

    var return_value: String = get_return_value_by_return_type(return_type)
    var return_value_string: String = " %s" % str(return_value)
    if !return_value:
        return_value_string = ""

    var function_parameters = find_signal_declaration_parameters(code_edit.get_caret_line(), line_text, code_edit)
    if !function_parameters:
        function_parameters = find_function_parameters(function_name, code_edit.get_caret_line(), line_text, code_edit)

    var indentation_character: String = get_indentation_character(settings)
    var new_function = "\n\nfunc %s(%s)%s:\n%sreturn%s" % [
        function_name,
        function_parameters,
        return_type_string,
        indentation_character,
        return_value_string
    ]

    code_edit.text = code_edit.text + new_function

    var line_with_new_function = code_edit.get_line_count() - 1
    code_edit.set_caret_line(line_with_new_function)
    code_edit.set_caret_column(code_edit.get_line(line_with_new_function).length())

    code_edit.text_changed.emit()


## @TODO Is there any easier way to create default value based on return type?
func get_return_value_by_return_type(return_type: String) -> String:
    match (return_type):
        "String":
            return "\"\""
        "int":
            return "0"
        "float":
            return "0.0"
        "bool":
            return "false"
        "Color":
            return "Color.WHITE"
        "Array":
            return "[]"
        "Dictionary":
            return "{}"
        "Vector2":
            return "Vector2.ZERO"
        "Vector2i":
            return "Vector2i.ZERO"
        "Vector3":
            return "Vector3.ZERO"
        "Vector3i":
            return "Vector3i.ZERO"
        "Vector4":
            return "Vector4.ZERO"
        "Vector4i":
            return "Vector4i.ZERO"
    return ""


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


func trim_char(text: String, char: String) -> String:
    if text.is_empty() or char.is_empty():
        return text

    var start := 0
    var end   := text.length()

    while start < end and text.substr(start, char.length()) == char:
        start += char.length()

    while end > start and text.substr(end - char.length(), char.length()) == char:
        end -= char.length()

    return text.substr(start, end - start)


func get_variable_from_line(line_index: int, line_text : String, code_edit: CodeEdit) -> String:
    var parts = line_text.split("=")
    if parts.size() < 2:
        parts = line_text.split(".")
        if parts.size() < 2:
            return ""

    var left_part = parts[0].strip_edges()

    var name_token = left_part.split(":")[0].strip_edges()
    name_token = name_token.split(".")[0].strip_edges()
    if name_token == "":
        return ""

    return name_token


## Check for variable declaration in current line and all lines above.
func find_variable_declaration_return_type(variable_name: String, line_index: int, line_text : String, code_edit: CodeEdit) -> String:
    for i in range(line_index, -1, -1):
        var prev_line = code_edit.get_line(i).strip_edges()

        if !prev_line.begins_with("var") and !prev_line.begins_with("@onready") and !prev_line.begins_with("@export"):
            continue

        if variable_name not in prev_line:
            continue

        var rest = prev_line.split(variable_name)[1].strip_edges()
        if rest.begins_with(":"):
            var type_part = rest.split("=")
            type_part = type_part[0].split(":")[1]
            return type_part.strip_edges()

    return ""


func find_signal_declaration_parameters(line_index: int, line_text : String, code_edit: CodeEdit) -> String:
    var variable_name: String = get_variable_from_line(line_index, line_text, code_edit)
    var object_name: String = find_variable_declaration_return_type(variable_name, line_index, line_text, code_edit)
    if !object_name: return ""

    var instance: Variant
    if type_exists(object_name):
        instance = ClassDB.instantiate(object_name)

    if !instance or !instance.has_method("get_signal_list"):
        var class_finder = NhbFunctionsOnTheFlyClassFinder.new()
        var script_path: String = class_finder.find_class_path(object_name)
        class_finder.free()
        if !script_path: return ""

        instance = load(script_path).new()

    var signal_name = get_signal_name_by_line(line_text)
    if !instance.has_signal(signal_name): return ""

    var signal_parameters = []
    for signature in instance.get_signal_list():
        if signature.name != signal_name: continue

        signal_parameters = signature.args

    if signal_parameters.size() == 0:
        instance.free()
        return ""

    var signal_parameter_string_parts: Array = []
    for i: Dictionary in signal_parameters:
        if !i.has("class_name"):
            signal_parameter_string_parts.push_back(i.name)
        elif !i.class_name.is_empty():
            signal_parameter_string_parts.push_back("%s: %s" % [i.name, i.class_name])
        elif i.class_name.is_empty() and i.has("type"):
            signal_parameter_string_parts.push_back("%s: %s" % [i.name, type_string(i.type)])

    instance.free()

    return ", ".join(signal_parameter_string_parts)


func find_function_parameters(function_name: String, line_index: int, line_text : String, code_edit: CodeEdit) -> String:
    var regex = RegEx.new()
    regex.compile(function_name + "(\\(.*\\))")

    var result = regex.search(line_text)
    if not result:
        return ""

    var arguments = result.get_string(1).lstrip("(").rstrip(")").split(",", false)
    var argumentString: String

    for i in arguments.size():
        arguments[i] = arguments[i].strip_edges()
        var argumentType = find_variable_declaration_return_type(arguments[i], line_index, line_text, code_edit)
        if argumentType:
            arguments[i] = "%s: %s" % [arguments[i], argumentType]

    return ", ".join(arguments)


func get_signal_name_by_line(line_text: String) -> String:
    var parts = line_text.split(".connect")
    if parts.size() == 1: return ""

    parts = parts[0].split(".")
    if parts.size() == 1: return ""

    return parts[parts.size() - 1]


func get_function_return_type(function_name: String, code_edit: CodeEdit):
    var current_line = get_current_line_text(code_edit).strip_edges()

    if current_line.begins_with(function_name):
        ## We cannot determine return type if function name is the only information in this line.
        return ""

    if current_line.contains("="):
        ## Function is tied to a variable. If this variable was initialized with a return type, we can use it.
        var variable_name: String = get_variable_from_line(code_edit.get_caret_line(), current_line, code_edit)
        return find_variable_declaration_return_type(variable_name, code_edit.get_caret_line(), current_line, code_edit)

    if current_line.contains(".connect"):
        return "void"

    return ""


## Lines with global variables do not start with whitespace.
func is_global_variable(text: String, settings) -> bool:
    var indentation_character: String = get_indentation_character(settings)

    var regex = RegEx.new()
    regex.compile("^\\s")

    if not regex.search(text):
        return true

    return false
