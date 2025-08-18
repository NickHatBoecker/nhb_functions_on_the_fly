extends GutTest

## Unfortunately native class EditorSettings can't be stubbed or mocked.
## So we use this custom class.
## This means that we have to use "Variant" as signature in addon code.
##
## @see https://github.com/bitwes/Gut/issues/740
class MockEditorSettings:
    var settings = {}


    func set_setting(n, v):
        settings[n] = v


    func get_setting(n):
        return settings[n]


    static func get_default() -> MockEditorSettings:
        var settings = MockEditorSettings.new()
        settings.set_setting("text_editor/behavior/indent/type", NhbFunctionsOnTheFlyUtils.INDENTATION_TYPES.TABS)
        settings.set_setting("text_editor/behavior/indent/size", 1)

        return settings


    static func get_default_with_spaces() -> MockEditorSettings:
        var settings = MockEditorSettings.new()
        settings.set_setting("text_editor/behavior/indent/type", NhbFunctionsOnTheFlyUtils.INDENTATION_TYPES.SPACES)
        settings.set_setting("text_editor/behavior/indent/size", 4)

        return settings

###################################################
## START TESTS
###################################################

func test_is_in_comment():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit:= CodeEdit.new()
    var trueLines: Array = [
        "# var button",
        "## var button2",
    ]
    for line in trueLines:
        code_edit.set_line(0, line)
        assert_true(utils.is_in_comment(code_edit, line))

    code_edit.set_line(0, "var button3")
    assert_false(utils.is_in_comment(code_edit, "var button3"))

    utils.free()
    code_edit.free()


func test_should_show_create_variable():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_name_regex = "var [a-zA-Z_][a-zA-Z0-9_]*"
    var code_edit:= CodeEdit.new()
    var trueLines: Array = [
        "var button: Button",
        "var button2",
        "var my_text: String = \"Hello world\"",
        "var my_text2 = \"Hello world\"",
        "var my_text3=\"Hello world\""
    ]

    for line in trueLines:
        code_edit.set_line(0, line)
        assert_true(utils.should_show_create_variable(
            code_edit,
            line,
            variable_name_regex,
            MockEditorSettings.get_default()
            ))

    var falseLines: Array = [
        "# var button: Button",
        "## var button2",
        "func my_test():",
        "func my_test() -> void:",
        "const button",
        "enum TYPES { TEST, TEST2 }"
    ]

    for line in falseLines:
        code_edit.set_line(0, line)
        assert_false(utils.should_show_create_variable(
            code_edit,
            line,
            variable_name_regex,
            MockEditorSettings.get_default()
        ))

    utils.free()
    code_edit.free()


func test_get_current_line_text():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit:= CodeEdit.new()

    code_edit.set_line(0, "First line")
    assert_eq(utils.get_current_line_text(code_edit), "First line")

    code_edit.set_line(0, "Second line")
    assert_eq(utils.get_current_line_text(code_edit), "Second line")

    utils.free()
    code_edit.free()


func test_get_shortcut_path():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    assert_eq(utils.get_shortcut_path("id"), "res://addons/nhb_functions_on_the_fly/id")

    utils.free()


func test_get_word_under_cursor():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var button")
    code_edit.set_caret_column(8)
    assert_eq(utils.get_word_under_cursor(code_edit), "button")

    code_edit.set_line(0, "button.pressed.connect(_on_button_pressed)")
    code_edit.set_caret_column(30)
    assert_eq(utils.get_word_under_cursor(code_edit), "_on_button_pressed")

    utils.free()
    code_edit.free()


#region Create getter/setter variable
func test_create_get_set_variable_only_variable_name():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var button")
    utils.create_get_set_variable(
        "button",
        code_edit,
        variable_return_type_regex,
        MockEditorSettings.get_default()
    )

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var button: Variant:")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn button")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\tbutton = value")

    utils.free()
    code_edit.free()


func test_create_get_set_variable_only_variable_name_with_spaces():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var button")
    utils.create_get_set_variable(
        "button",
        code_edit,
        variable_return_type_regex,
        MockEditorSettings.get_default_with_spaces()
    )

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var button: Variant:")
    assert_eq(code_edit.get_line(1), "    get:")
    assert_eq(code_edit.get_line(2), "        return button")
    assert_eq(code_edit.get_line(3), "    set(value):")
    assert_eq(code_edit.get_line(4), "        button = value")

    utils.free()
    code_edit.free()


func test_create_get_set_variable_with_return_type():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var button: Button")
    utils.create_get_set_variable(
        "button",
        code_edit,
        variable_return_type_regex,
        MockEditorSettings.get_default()
    )

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var button: Button:")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn button")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\tbutton = value")

    utils.free()
    code_edit.free()


func test_create_get_set_variable_with_return_type_and_value():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var text: String = \"Hello world\"")
    utils.create_get_set_variable(
        "text",
        code_edit,
        variable_return_type_regex,
        MockEditorSettings.get_default()
    )

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var text: String = \"Hello world\":")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn text")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\ttext = value")

    utils.free()
    code_edit.free()


func test_create_get_set_variable_with_value():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var text = \"Hello world\"")
    utils.create_get_set_variable(
        "text",
        code_edit,
        variable_return_type_regex,
        MockEditorSettings.get_default()
    )

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var text = \"Hello world\":")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn text")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\ttext = value")

    utils.free()
    code_edit.free()


func test_create_get_set_variable_with_value_without_spaces():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var text=\"Hello world\"")
    utils.create_get_set_variable(
        "text",
        code_edit,
        variable_return_type_regex,
        MockEditorSettings.get_default()
    )

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var text=\"Hello world\":")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn text")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\ttext = value")

    utils.free()
    code_edit.free()
#endregion


#region Create function
func test_create_function_without_return_type():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()
    code_edit.set_line(0, "button.pressed.connect(_on_button_pressed)")
    code_edit.set_caret_column(30)

    utils.create_function("_on_button_pressed", code_edit, MockEditorSettings.get_default())

    assert_eq(code_edit.get_line_count(), 4)
    assert_eq(code_edit.get_line(0), "button.pressed.connect(_on_button_pressed)")
    assert_eq(code_edit.get_line(1), "")
    assert_eq(code_edit.get_line(2), "func _on_button_pressed() -> void:")
    assert_eq(code_edit.get_line(3), "\treturn")

    utils.free()
    code_edit.free()


func test_create_function_without_return_type_with_spaces():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()
    code_edit.set_line(0, "button.pressed.connect(_on_button_pressed)")
    code_edit.set_caret_column(30)

    utils.create_function("_on_button_pressed", code_edit, MockEditorSettings.get_default_with_spaces())

    assert_eq(code_edit.get_line_count(), 4)
    assert_eq(code_edit.get_line(0), "button.pressed.connect(_on_button_pressed)")
    assert_eq(code_edit.get_line(1), "")
    assert_eq(code_edit.get_line(2), "func _on_button_pressed() -> void:")
    assert_eq(code_edit.get_line(3), "    return")

    utils.free()
    code_edit.free()


func test_create_function_with_return_type_by_variable_at_same_line():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()
    code_edit.set_line(0, "var my_text: String = _get_my_text()")
    code_edit.set_caret_column(25)

    utils.create_function("_get_my_text", code_edit, MockEditorSettings.get_default())

    assert_eq(code_edit.get_line_count(), 4)
    assert_eq(code_edit.get_line(0), "var my_text: String = _get_my_text()")
    assert_eq(code_edit.get_line(1), "")
    assert_eq(code_edit.get_line(2), "func _get_my_text() -> String:")
    assert_eq(code_edit.get_line(3), "\treturn \"\"")

    utils.free()
    code_edit.free()


func test_create_function_with_return_type_by_variable_at_previous_line():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var my_text: String\n")
    code_edit.set_line(1, "my_text = _get_my_text()")
    code_edit.set_caret_line(1)
    code_edit.set_caret_column(15)

    utils.create_function("_get_my_text", code_edit, MockEditorSettings.get_default())

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var my_text: String")
    assert_eq(code_edit.get_line(1), "my_text = _get_my_text()")
    assert_eq(code_edit.get_line(2), "")
    assert_eq(code_edit.get_line(3), "func _get_my_text() -> String:")
    assert_eq(code_edit.get_line(4), "\treturn \"\"")

    utils.free()
    code_edit.free()
#endregion


#region Test return types
func test_get_variable_return_type():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"

    var checks: Array = [
        { "line": "var button: Button", "expectedReturnType": "Button" },
        { "line": "var button2", "expectedReturnType": "" },
        { "line": "var my_text: String = \"Hello world\"", "expectedReturnType": "String" },
        { "line": "var my_text2 = \"Hello world\"", "expectedReturnType": "" },
        { "line": "var my_text3=\"Hello world\"", "expectedReturnType": "" },
    ]

    for check in checks:
        assert_eq(utils.get_variable_return_type(check.line, variable_return_type_regex), check.expectedReturnType)

    utils.free()


func test_find_variable_declaration_return_type():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var my_text: String")
    code_edit.set_line(1, "my_text = _get_my_text()")
    assert_eq(utils.find_variable_declaration_return_type(1, "my_text = _get_my_text()", code_edit), "String")

    code_edit.set_line(0, "var my_text: String = \"Hello world\"")
    code_edit.set_line(1, "my_text = _get_my_text()")
    assert_eq(utils.find_variable_declaration_return_type(1, "my_text = _get_my_text()", code_edit), "String")

    code_edit.set_line(0, "var my_text = \"Hello world\"")
    code_edit.set_line(1, "my_text = _get_my_text()")
    assert_eq(utils.find_variable_declaration_return_type(1, "my_text = _get_my_text()", code_edit), "")

    code_edit.set_line(0, "@export var my_text: String")
    code_edit.set_line(1, "my_text = _get_my_text()")
    assert_eq(utils.find_variable_declaration_return_type(1, "my_text = _get_my_text()", code_edit), "String")

    utils.free()
    code_edit.free()


func test_get_return_value_by_return_type():
    var utils = NhbFunctionsOnTheFlyUtils.new()

    assert_eq(utils.get_return_value_by_return_type("String"), "\"\"")
    assert_eq(utils.get_return_value_by_return_type("int"), "0")
    assert_eq(utils.get_return_value_by_return_type("float"), "0.0")
    assert_eq(utils.get_return_value_by_return_type("Vector2"), "Vector2.ZERO")
    assert_eq(utils.get_return_value_by_return_type("dummy"), "")

    utils.free()


func test_get_function_return_type():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var my_button: Button = _get_my_button()\n")
    assert_eq(utils.get_function_return_type("_get_my_button", code_edit), "Button")

    code_edit.set_line(0, "var my_text: String = _get_my_string()\n")
    assert_eq(utils.get_function_return_type("_get_my_string", code_edit), "String")

    code_edit.set_line(0, "var my_text = _get_my_string()\n")
    assert_eq(utils.get_function_return_type("_get_my_string", code_edit), "")

    utils.free()
    code_edit.free()
#endregion


#region Test signals
func test_get_signal_name_by_line():
    var utils = NhbFunctionsOnTheFlyUtils.new()

    assert_eq(utils.get_signal_name_by_line("my_button.pressed.connect(_on_pressed)"), "pressed")
    assert_eq(utils.get_signal_name_by_line("my_object.my_button.pressed.connect(_on_pressed)"), "pressed")
    assert_eq(utils.get_signal_name_by_line("(my_button as Button).pressed.connect(_on_pressed)"), "pressed")

    utils.free()


func test_find_signal_declaration_parameters_with_native_signals():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var my_area: Area2D\n")
    code_edit.set_line(1, "my_area.body_entered.connect(_on_body_entered)")
    assert_eq(utils.find_signal_declaration_parameters(1, code_edit.get_line(1), code_edit), "body: Node2D")

    code_edit.set_line(0, "var my_button: Button\n")
    code_edit.set_line(1, "my_button.pressed.connect(_on_button_pressed)")
    assert_eq(utils.find_signal_declaration_parameters(1, code_edit.get_line(1), code_edit), "")

    utils.free()
    code_edit.free()


func test_find_signal_declaration_parameters_with_custom_signals():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var my_custom_class: CustomClassWithSignal\n")
    code_edit.set_line(1, "my_custom_class.custom_signal.connect(_on_custom_signal)")
    assert_eq(utils.find_signal_declaration_parameters(1, code_edit.get_line(1), code_edit), "text: String, number: int")

    utils.free()
    code_edit.free()
#endregion


func test_is_global_variable():
    var utils = NhbFunctionsOnTheFlyUtils.new()

    assert_true(utils.is_global_variable("var my_button: Button", MockEditorSettings.get_default()))
    assert_false(utils.is_global_variable("\tvar my_button: Button", MockEditorSettings.get_default()))

    utils.free()


func test_get_indentation_character():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var settings = MockEditorSettings.new()

    settings.set_setting("text_editor/behavior/indent/type", utils.INDENTATION_TYPES.TABS)
    settings.set_setting("text_editor/behavior/indent/size", 1)
    assert_eq(utils.get_indentation_character(settings), "\t")

    settings.set_setting("text_editor/behavior/indent/type", utils.INDENTATION_TYPES.SPACES)
    settings.set_setting("text_editor/behavior/indent/size", 4)
    assert_eq(utils.get_indentation_character(settings), "    ")

    settings.set_setting("text_editor/behavior/indent/type", utils.INDENTATION_TYPES.SPACES)
    settings.set_setting("text_editor/behavior/indent/size", 2)
    assert_eq(utils.get_indentation_character(settings), "  ")

    utils.free()
