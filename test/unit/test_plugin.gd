extends GutTest


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
        assert_true(utils.should_show_create_variable(code_edit, line, variable_name_regex))

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
        assert_false(utils.should_show_create_variable(code_edit, line, variable_name_regex))


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


func test_get_current_line_text():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit:= CodeEdit.new()

    code_edit.set_line(0, "First line")
    assert_eq(utils.get_current_line_text(code_edit), "First line")

    code_edit.set_line(0, "Second line")
    assert_eq(utils.get_current_line_text(code_edit), "Second line")


func test_get_shortcut_path():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    assert_eq(utils.get_shortcut_path("id"), "res://addons/nhb_functions_on_the_fly/id")


func test_create_get_set_variable_only_variable_name():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var button")
    utils.create_get_set_variable("button", code_edit, variable_return_type_regex)

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var button: Variant:")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn button")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\tbutton = value")


func test_create_get_set_variable_with_return_type():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var button: Button")
    utils.create_get_set_variable("button", code_edit, variable_return_type_regex)

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var button: Button:")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn button")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\tbutton = value")


func test_create_get_set_variable_with_return_type_and_value():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var text: String = \"Hello world\"")
    utils.create_get_set_variable("text", code_edit, variable_return_type_regex)

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var text: String = \"Hello world\":")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn text")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\ttext = value")


func test_create_get_set_variable_with_value():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var text = \"Hello world\"")
    utils.create_get_set_variable("text", code_edit, variable_return_type_regex)

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var text = \"Hello world\":")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn text")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\ttext = value")


func test_create_get_set_variable_with_value_without_spaces():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var variable_return_type_regex = "var [a-zA-Z_][a-zA-Z0-9_]* *(?:: *([a-zA-Z_][a-zA-Z0-9_]*))?"
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var text=\"Hello world\"")
    utils.create_get_set_variable("text", code_edit, variable_return_type_regex)

    assert_eq(code_edit.get_line_count(), 5)
    assert_eq(code_edit.get_line(0), "var text=\"Hello world\":")
    assert_eq(code_edit.get_line(1), "\tget:")
    assert_eq(code_edit.get_line(2), "\t\treturn text")
    assert_eq(code_edit.get_line(3), "\tset(value):")
    assert_eq(code_edit.get_line(4), "\t\ttext = value")


func test_create_function():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()
    code_edit.set_line(0, "button.pressed.connect(_on_button_pressed)")
    code_edit.set_caret_column(30)

    utils.create_function("_on_button_pressed", code_edit)

    assert_eq(code_edit.get_line_count(), 4)
    assert_eq(code_edit.get_line(0), "button.pressed.connect(_on_button_pressed)")
    assert_eq(code_edit.get_line(1), "")
    assert_eq(code_edit.get_line(2), "func _on_button_pressed() -> Variant:")
    assert_eq(code_edit.get_line(3), "\treturn")


func test_get_word_under_cursor():
    var utils = NhbFunctionsOnTheFlyUtils.new()
    var code_edit = CodeEdit.new()

    code_edit.set_line(0, "var button")
    code_edit.set_caret_column(8)
    assert_eq(utils.get_word_under_cursor(code_edit), "button")

    code_edit.set_line(0, "button.pressed.connect(_on_button_pressed)")
    code_edit.set_caret_column(30)
    assert_eq(utils.get_word_under_cursor(code_edit), "_on_button_pressed")


## Unfortunately it's not possible to get an EditorSettings instance for now.
## Uncomment this test as soon as it's possible.
# func test_get_indentation_character():
#    var utils = NhbFunctionsOnTheFlyUtils.new()
#
#    #var settings = EditorSettings.new()
#    var settings = double(EditorSettings).new()
#    stub(settings.get_setting.bind("text_editor/behavior/indent/type")).to_return("\t")
#    stub(settings.get_setting.bind("text_editor/behavior/indent/size")).to_return("1")
#
#    settings.set_setting("text_editor/behavior/indent/type", utils.INDENTATION_TYPES.TABS)
#    settings.set_setting("text_editor/behavior/indent/size", 1)
#    assert_eq(utils.get_indentation_character(settings), "\t")
#
#    settings.set_setting("text_editor/behavior/indent/type", utils.INDENTATION_TYPES.SPACES)
#    settings.set_setting("text_editor/behavior/indent/size", 4)
#    assert_eq(utils.get_indentation_character(settings), "    ")
