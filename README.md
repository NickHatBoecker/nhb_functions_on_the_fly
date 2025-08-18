# NHB Functions On The Fly for Godot 4.4+

<a href="https://ko-fi.com/nickhatboecker">
<img src="https://camo.githubusercontent.com/5f3ad29b3051aac409943c7b590b86490c6ec7ad399379ca73521d9ff98a28f7/68747470733a2f2f696d672e736869656c64732e696f2f62616467652f737570706f72745f6d655f6f6e5f6b6f2d2d66692d4631363036313f7374796c653d666f722d7468652d6261646765266c6f676f3d6b6f6669266c6f676f436f6c6f723d663566356635" alt="Support me on Ko-fi">
</a><br><br>

Easily create missing functions or getter/setters for variables in Godot on the fly.\
You can install it via the Asset Library or [downloading a copy](https://github.com/nickhatboecker/nhb_functions_on_the_fly/archive/refs/heads/main.zip) from GitHub.

Shortcuts are configurable in the Editor settings. Under "_Plugin > NHB Functions On The Fly_"

<table>
    <thead>
        <tr>
            <th>Create function</td>
            <th>Create getter/setter variable</td>
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

## How to use

### Create function

1. Write `my_button.pressed.connect(on_button_pressed)`
2. Select `on_button_pressed` or put cursor on it
3. Now you can either
    - Right click > "Create function"
    - <kbd>Ctrl</kbd> + <kbd>[</kbd>
    - <kbd>⌘ Command</kbd> + <kbd>[</kbd> (Mac)

### Create getter/setter for variable

1. Write `var my_var` or `var my_var: String` or `var my_var: String = "Hello world"`
2. Select `my_var` or put cursor on it
3. Now you can either
    - Right click > "Create get/set variable"
    - <kbd>Ctrl</kbd> + <kbd>'</kbd>
    - <kbd>⌘ Command</kbd> + <kbd>'</kbd> (Mac)

## Development

1. Clone git repository
2. Copy `.env.dist` to `.env` and update path to Godot executable
3. You need `node v20` in order to pass unit tests on commit
4. Execute `yarn`

Please make sure to write/update unit tests in `test` directory for any new features.

### Unit tests

You can run tests in Godot or via command line.

```bash
$ yarn test:unit
```

## Contributors

- [Initial idea](https://www.reddit.com/r/godot/comments/1morndn/im_a_lazy_programmer_and_added_a_generate_code/) and get/set variable creation: [u/siwoku](https://www.reddit.com/user/siwoku/)
- Get text under cursor, so you don't have to select the text: [u/newold25](https://www.reddit.com/user/newold25/)
- Maintainer, considering indentation type, adding shorcuts: [u/NickHatBoecker](https://nickhatboecker.de/linktree/)

Pleae feel free to create a pull request!
