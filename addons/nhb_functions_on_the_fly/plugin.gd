## Idea by u/siwoku
##
## Contributors:
##   - You don't have to select text to create a function u/newold25
##   - Consider editor settings's indentation type u/NickHatBoecker
##   - Added shortcuts (configurable in editor settings) u/NickHatBoecker

@tool
class_name NhbFunctionsOnTheFly
extends EditorPlugin

## Editor setting for the function shortcut
const FUNCTION_SHORTCUT: StringName = "function_shortcut"
## Editor setting for the get/set variable shortcut
const GET_SET_SHORTCUT: StringName = "get_set_shortcut"

const DEFAULT_SHORTCUT_FUNCTION = KEY_BRACKETLEFT
const DEFAULT_SHORTCUT_GET_SET = KEY_APOSTROPHE

## If the current text matches this expression, the function popup menu item will be displayed.
const FUNCTION_NAME_REGEX = "^[a-zA-Z_][a-zA-Z0-9_]*$"

## If the current text matches this expression, the variable popup menu item will be displayed.
## Must contain the keyword "var".
const VARIABLE_NAME_REGEX = "var [a-zA-Z_][a-zA-Z0-9_]*"

## This is used to determine if a variable string already has a return type.
const VARIABLE_RETURN_TYPE_REGEX = VARIABLE_NAME_REGEX + " *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"

const CALLBACK_MENU_PRIORITY = 1500
enum CALLBACK_TYPES { FUNCTION, VARIABLE }

var utils: NhbFunctionsOnTheFlyUtils
var script_editor: ScriptEditor
var current_popup: PopupMenu

var function_shortcut: Shortcut
var get_set_shortcut: Shortcut


func _enter_tree():
    utils = NhbFunctionsOnTheFlyUtils.new()
    script_editor = EditorInterface.get_script_editor()
    script_editor.connect("editor_script_changed", _on_script_changed)
    _setup_current_script()
    _init_shortcuts()


func _exit_tree():
    if script_editor and script_editor.is_connected("editor_script_changed", _on_script_changed):
        script_editor.disconnect("editor_script_changed", _on_script_changed)
    _cleanup_current_script()


func _on_script_changed(_script):
    _setup_current_script()


func _setup_current_script():
    _cleanup_current_script()
    var current_editor = script_editor.get_current_editor()
    if current_editor:
        var code_edit = _find_code_edit(current_editor)
        if code_edit:
            current_popup = _find_popup_menu(current_editor)
            if current_popup:
                current_popup.connect("about_to_popup", _on_popup_about_to_show)


func _cleanup_current_script():
    if current_popup and current_popup.is_connected("about_to_popup", _on_popup_about_to_show):
        current_popup.disconnect("about_to_popup", _on_popup_about_to_show)
    current_popup = null


func _find_code_edit(node: Node) -> CodeEdit:
    if node is CodeEdit:
        return node
    for child in node.get_children():
        var result = _find_code_edit(child)
        if result:
            return result
    return null


func _find_popup_menu(node: Node) -> PopupMenu:
    if node is PopupMenu:
        return node
    for child in node.get_children():
        var result = _find_popup_menu(child)
        if result:
            return result
    return null


func _on_popup_about_to_show():
    var current_editor = script_editor.get_current_editor()
    if not current_editor:
        return

    var code_edit = _find_code_edit(current_editor)
    if not code_edit:
        return

    var selected_text = _get_selected_text(code_edit)
    if selected_text.is_empty():
        return

    var current_line = utils.get_current_line_text(code_edit)

    ## Because variable regex is more precise, it has to be checked first
    if utils.should_show_create_variable(code_edit, current_line, VARIABLE_NAME_REGEX, _get_editor_settings()):
        _create_menu_item(
            "Create getter/setter for variable: " + selected_text,
            selected_text,
            code_edit,
            CALLBACK_TYPES.VARIABLE
        )
    elif _should_show_create_function(code_edit, selected_text):
        _create_menu_item(
            "Create function: " + selected_text,
            selected_text,
            code_edit,
            CALLBACK_TYPES.FUNCTION
        )


func _create_menu_item(item_text: String, selected_text: String, code_edit: CodeEdit, callback_type: CALLBACK_TYPES) -> void:
    current_popup.add_separator()
    current_popup.add_item(item_text, CALLBACK_MENU_PRIORITY)

    if current_popup.is_connected("id_pressed", _on_menu_item_pressed):
        current_popup.disconnect("id_pressed", _on_menu_item_pressed)

    current_popup.connect("id_pressed", _on_menu_item_pressed.bind(selected_text, code_edit, CALLBACK_MENU_PRIORITY, callback_type))


func _should_show_create_function(code_edit: CodeEdit, text: String) -> bool:
    var script_text = code_edit.text

    ## Check if valid function name
    var regex = RegEx.new()
    regex.compile(FUNCTION_NAME_REGEX)
    if not regex.search(text):
        return false

    if _function_exists_anywhere(script_text, text):
        return false

    if _global_variable_exists(script_text, text):
        return false

    if _local_variable_exists_in_current_function(code_edit, text):
        return false

    if utils.is_in_comment(code_edit, text):
        return false

    return true


func _function_exists_anywhere(script_text: String, func_name: String) -> bool:
    var regex = RegEx.new()
    regex.compile("func\\s+" + func_name + "\\s*\\(")
    return regex.search(script_text) != null


func _global_variable_exists(script_text: String, var_name: String) -> bool:
    var lines = script_text.split("\n")
    var inside_function = false

    for i in range(lines.size()):
        var line = lines[i]
        var trimmed = line.strip_edges()

        if trimmed.begins_with("func "):
            inside_function = true
            continue

        if not inside_function:
            var regex = RegEx.new()
            regex.compile("^var\\s+" + var_name + "\\b")
            if regex.search(trimmed):
                return true
        else:
            if trimmed.is_empty():
                continue
            elif not line.begins_with("\t") and not line.begins_with(" ") and trimmed != "":
                inside_function = false
                var regex = RegEx.new()
                regex.compile("^var\\s+" + var_name + "\\b")
                if regex.search(trimmed):
                    return true

    return false


func _local_variable_exists_in_current_function(code_edit: CodeEdit, var_name: String) -> bool:
    var script_text = code_edit.text
    var current_line = code_edit.get_caret_line()

    var function_start = -1
    var function_end = -1
    var lines = script_text.split("\n")

    for i in range(current_line, -1, -1):
        if i < lines.size():
            var line = lines[i].strip_edges()
            if line.begins_with("func "):
                function_start = i
                break

    if function_start == -1:
        return false

    for i in range(function_start + 1, lines.size()):
        var line = lines[i].strip_edges()
        if line.begins_with("func ") or (line != "" and not lines[i].begins_with("\t") and not lines[i].begins_with(" ")):
            function_end = i - 1
            break

    if function_end == -1:
        function_end = lines.size() - 1

    for i in range(function_start, function_end + 1):
        if i < lines.size():
            var line = lines[i].strip_edges()

            var regex = RegEx.new()
            regex.compile("^var\\s+" + var_name + "\\b")
            if regex.search(line):
                return true

            if i == function_start:
                var param_regex = RegEx.new()
                param_regex.compile("func\\s+\\w+\\s*\\([^)]*\\b" + var_name + "\\b")
                if param_regex.search(line):
                    return true

    return false


func _on_menu_item_pressed(id: int, original_text: String, code_edit: CodeEdit, target_index: int, callback_type: CALLBACK_TYPES) -> void:
    if id != target_index: return

    if callback_type == CALLBACK_TYPES.FUNCTION:
        utils.create_function(original_text, code_edit, _get_editor_settings())
    elif callback_type == CALLBACK_TYPES.VARIABLE:
        utils.create_get_set_variable(original_text, code_edit, VARIABLE_RETURN_TYPE_REGEX, _get_editor_settings())


## Process the user defined shortcuts
func _shortcut_input(event: InputEvent) -> void:
    if !event.is_pressed() || event.is_echo():
        return

    if function_shortcut.matches_event(event):
        ## Function
        get_viewport().set_input_as_handled()
        var code_edit: CodeEdit = _get_code_edit()
        var function_name = utils.get_word_under_cursor(code_edit)
        if _should_show_create_function(code_edit, function_name):
            utils.create_function(function_name, code_edit, _get_editor_settings())
    elif get_set_shortcut.matches_event(event):
        ## Get/set variable
        get_viewport().set_input_as_handled()
        var code_edit: CodeEdit = _get_code_edit()
        var variable_name = utils.get_word_under_cursor(code_edit)
        utils.create_get_set_variable(variable_name, code_edit, VARIABLE_RETURN_TYPE_REGEX, _get_editor_settings())


func _get_editor_settings() -> EditorSettings:
    return EditorInterface.get_editor_settings()


## Initializes all shortcuts.
## Every shortcut can be changed while this plugin is active, which will override them.
func _init_shortcuts():
    var editor_settings: EditorSettings = _get_editor_settings()

    if !editor_settings.has_setting(utils.get_shortcut_path(FUNCTION_SHORTCUT)):
        var shortcut: Shortcut = Shortcut.new()
        var event: InputEventKey = InputEventKey.new()
        event.device = -1
        event.command_or_control_autoremap = true
        event.keycode = DEFAULT_SHORTCUT_FUNCTION

        shortcut.events = [ event ]
        editor_settings.set_setting(utils.get_shortcut_path(FUNCTION_SHORTCUT), shortcut)

    if !editor_settings.has_setting(utils.get_shortcut_path(GET_SET_SHORTCUT)):
        var shortcut: Shortcut = Shortcut.new()
        var event: InputEventKey = InputEventKey.new()
        event.device = -1
        event.command_or_control_autoremap = true
        event.keycode = DEFAULT_SHORTCUT_GET_SET

        shortcut.events = [ event ]
        editor_settings.set_setting(utils.get_shortcut_path(GET_SET_SHORTCUT), shortcut)

    function_shortcut = editor_settings.get_setting(utils.get_shortcut_path(FUNCTION_SHORTCUT))
    get_set_shortcut = editor_settings.get_setting(utils.get_shortcut_path(GET_SET_SHORTCUT))


## This is the editor window, where code lines can be selected.
func _get_code_edit() -> CodeEdit:
    return get_editor_interface().get_script_editor().get_current_editor().get_base_editor()


func _get_selected_text(_code_edit: CodeEdit) -> String:
    var selected_text = _code_edit.get_selected_text().strip_edges()

    if selected_text.is_empty():
        selected_text = utils.get_word_under_cursor(_code_edit)

    return selected_text
