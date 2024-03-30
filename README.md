# Foxhole AutoClicker
Foxhole AutoClicker is a program with 5 hotkeys that work <ins>**while tabbed out.**</ins> These hotkeys are custom-made for Foxhole, and are single-action autoclickers that are allowed by the TOS.

The following features are available:
* **Spam left click at location -** (for pulling items/building). This hotkey even allows you to move your mouse anywhere and be tabbed out, since it simulates clicks at the coordinates where you pressed the hotkey on your Foxhole game window.
* **Hold W -** (to move forwards)
* **Hold S -** (to move backwards)
* **Hold Right Click -** (for rotating cranes/binos/aiming)
* **Hold Left Click -** (for Harvesters/building)

![image](https://github.com/Tommythebold/foxholeautoclicker/assets/11021249/e9c9d6a7-8293-4178-b498-9b0673d3322b)   ![image](https://github.com/Tommythebold/foxholeautoclicker/assets/11021249/f62e5631-d40f-4219-b4e5-3b22b992ff24)

# How to Install
To install, head to the [Releases page](https://github.com/Tommythebold/foxholeautoclicker/releases) on the right-hand side of this page. Download the most recent release, which will be a zip file. Make a new folder anywhere on your PC, and drag the contents of the zip into that folder. To launch the GUI, double click the Foxhole AutoClicker file. 

# How to Use
The program comes with default keybinds, but these can easily be changed by clicking the 'Change Keybinds' button in the program. To change a key, click it's corrosponding button, then press the key/key combination of your choice. Any modifiers or extra keys (shift, alt, mouse buttons, etc.) will work. 

The default keybinds are:
* **F2** - Spam left click at location
* **F3** - Hold W
* **F4** - Hold S
* **F5** - Hold Right Click
* **F6** - Hold Left Click
* **F7** - Suspend Hotkeys
* **F9** - Exit Hotkeys

Any changes to your keybinds are saved in the KeyBindings.ini file, and are saved between sessions. The keys will update upon restarting the hotkeys from the GUI. 


# More Info/Troubleshooting
* This entire program is essentially two AutoHotKey scripts - one for the GUI, and one for the Foxhole hotkeys. The GUI exists to set keybinds and start/stop the hotkeys easily. You can stop/suspend either script by clicking the system tray in the bottom right of your taskbar. 

* If you don't want to use the GUI after you've set your keybinds, the script for Foxhole is located in the \bin folder, and is called FoxholeHotkeys. You can simply double click this script to launch it, and can save to taskbar by `right click > create shortcut` for it. 

* If you are familiar with AutoHotKey, or don't want to bother with the GUI at all, there is a 'manual' version of the script in the \bin folder. You can `right click > edit with ...` the FoxholeHotkeysManual script to set keybinds manually. There are instructions in the comments of the script on how to do so.

# Contact
If you have any questions, issues, or feature requests, you can open an issue on this GitHub page, or message me on Discord at tommythebold#0001.
