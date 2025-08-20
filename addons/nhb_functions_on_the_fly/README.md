# NHB Functions On The Fly for Godot 4.4+

<img src="https://img.shields.io/badge/Godot-478CBF?style=for-the-badge&logo=GodotEngine&logoColor=white" alt="Powered by Godot"> <a href="https://github.com/NickHatBoecker/nhb_functions_on_the_fly/issues/new"><img src="https://img.shields.io/badge/Report_Issue-000000?style=for-the-badge&logo=github&logoColor=white" alt="Report Issue"></a> <a href="https://ko-fi.com/nickhatboecker" target="_blank">
<img src="https://img.shields.io/badge/Support_Development_on_Ko--fi-f15f61?style=for-the-badge&logo=kofi&logoColor=white" alt="Support me on Ko-fi">
</a>

Easily create missing functions or getter/setters for variables in Godot on the fly.\
You can install it via the Asset Library or [downloading a copy](https://github.com/nickhatboecker/nhb_functions_on_the_fly/archive/refs/heads/main.zip) from GitHub.

✨ Even function arguments and return types are considered, for both native and custom methods. ✨

Shortcuts are configurable in the Editor settings. Under "_Plugin > NHB Functions On The Fly_"

<table>
    <thead>
        <tr>
            <th>Create function <kbd>Ctrl</kbd> + <kbd>[</kbd></td>
            <th>Create getter/setter variable <kbd>Ctrl</kbd> + <kbd>'</kbd></td>
        </tr>
    </thead>
    <tbody>
        <tr>
            <td>
                <img src="https://raw.githubusercontent.com/NickHatBoecker/nhb_functions_on_the_fly/refs/heads/main/assets/screenshot_function.png" alt="Screenshot: Create function" title="Create function" />
            </td>
            <td>
                <img src="https://raw.githubusercontent.com/NickHatBoecker/nhb_functions_on_the_fly/refs/heads/main/assets/screenshot_getter_setter.png" alt="Screenshot: Create getter/setter variable" title="Create getter/setter variable" />
            </td>
        </tr>
    </tbody>
</table>

## ❓ How to use

### Create function

1. Write `my_button.pressed.connect(on_button_pressed)`
2. Select `on_button_pressed` or put cursor on it
3. Now you can either
    - Right click > "Create function"
    - <kbd>Ctrl</kbd> + <kbd>[</kbd>
    - <kbd>⌘ Command</kbd> + <kbd>[</kbd> (Mac)
4. Function arguments and return type (if any, based on variable/signal signature) will be considered.

### Create getter/setter for variable

1. Write `var my_var` or `var my_var: String` or `var my_var: String = "Hello world"`
2. Select `my_var` or put cursor on it
3. Now you can either
    - Right click > "Create get/set variable"
    - <kbd>Ctrl</kbd> + <kbd>'</kbd>
    - <kbd>⌘ Command</kbd> + <kbd>'</kbd> (Mac)
4. Return type (if any) will be considered

## ⭐ Contributors

- [Initial idea](https://www.reddit.com/r/godot/comments/1morndn/im_a_lazy_programmer_and_added_a_generate_code/) and get/set variable creation: [u/siwoku](https://www.reddit.com/user/siwoku/)
- Get text under cursor, so you don't have to select the text: [u/newold25](https://www.reddit.com/user/newold25/)
- Maintainer, considering indentation type, adding shorcuts: [u/NickHatBoecker](https://nickhatboecker.de/linktree/)

Pleae feel free to create a pull request!
