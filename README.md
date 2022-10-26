# Multiplayer Net Demo

This is a demo of the high-level networking APIs in the godot game engine. 

This project can run as either a client or server. See ["Use" section](#use) for details

## Building

### Requirements

- [godot engine 3.5.1](https://godotengine.org/download) - [github page](https://github.com/godotengine/godot)
- git

### Steps

- Checkout the repo using `git clone --recurse-submodules https://github.com/SkylarGill/networked-multiplayer-demo.git`
    - this will initialise the submodule for the included custom font

- Open the project in godot

- Under the project menu in the toolbar, click the "Export..." option

- Next to presets, click add and select your desired platform

- Click the "Export project" button and confirm location

## Use

To use as a client, simply run the executable.

To use as a server, you'll need to run from the command line with the argument "--server".

For exporting to run on a dedicated server without graphics, see [this documentation article](https://docs.godotengine.org/en/stable/tutorials/export/exporting_for_dedicated_servers.html)

## Controls

### Keyboard
[Arrow keys] or [WASD] to move
[Spacebar] to kick

### Controller
[Left Stick] to move
[A button] to kick

## License

This project is available under the permissive MIT license. See [LICENSE.txt](LICENSE.txt) for more details.