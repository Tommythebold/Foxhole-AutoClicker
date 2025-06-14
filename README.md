# Foxhole AutoClicker
**New update v1.2 -> [Click Here to Download](https://github.com/Tommythebold/Foxhole-AutoClicker/releases/download/1.2/Foxhole.AutoClicker.-.v1.2.zip)**

**AutoHotKey (required) -> [Click Here to Download](https://www.autohotkey.com/download/ahk-v2.exe)**

Foxhole AutoClicker is a program with 6 hotkeys that work <ins>**while tabbed out**</ins>, meaning you can use your mouse and keyboard freely while they are active. These hotkeys are custom-made for Foxhole, and are single-action autoclickers that are allowed by the TOS.

The following features are available:
* **Spam left click at location -** (for pulling items/building). This hotkey simulates clicks at the coordinates where you pressed the hotkey on your Foxhole game window.
* **Hold W -** (to move forwards)
* **Hold S -** (to move backwards)
* **Hold Right Click -** (for rotating cranes/binos/aiming)
* **Hold Left Click -** (for Harvesters/building)
* **v1.1 - Spam Left Building -** (for building without character rotating)

  
![image](https://github.com/Tommythebold/Foxhole-AutoClicker/assets/11021249/62f07a9e-00e4-427e-877e-092ff3e59e25)   ![image](https://github.com/Tommythebold/Foxhole-AutoClicker/assets/11021249/3377e997-95a1-4591-b1fa-9c386a36b187)

# How to Install
This program requires you to install [AutoHotKey](https://www.autohotkey.com/) - either version will work.

To install the program itself, head to the [Releases page](https://github.com/Tommythebold/foxholeautoclicker/releases) on the right-hand side of this page. Download the most recent release, which will be a zip file named FoxholeAutoClicker. Drag the folder inside anywhere on your PC. To launch the GUI, double click the Foxhole AutoClicker file. 

# How to Use
The program comes with default keybinds, but these can easily be changed by clicking the 'Change Keybinds' button in the program. To change a key, click it's corrosponding button, then press the key/key combination of your choice. Any modifiers or extra keys (shift, alt, mouse buttons, etc.) will work. 

The default keybinds are:
* **F2** - Spam left click at location
* **F3** - Hold W
* **F4** - Hold S
* **F5** - Left Click Building
* **F6** - Hold Right Click
* **F7** - Hold Left Click
* **F9** - Suspend Hotkeys
* **F10** - Exit Hotkeys

Any changes to your keybinds are saved in the KeyBindings.ini file, and are saved between sessions. The keys will update upon restarting the hotkeys from the GUI. 

# Changelog
v1.2 - Now allows you to use the Shift key while W/S hotkeys are active, which was previously impossible. This means you can now type capital letters and more. Some shift key presses may miss, and the character will stop holding W/S for about half a second on tab out, but it is still a significant improvement. If you don't agree, please let me know. Feature requested by Saturnda and others.

v1.1 - Adds the "Spam Left Building" key. This key allows you to build with a hammer/shovel/etc without your character changing direction when your mouse moves. Requested by Saturnda.

v1.0 - Initial release.


# More Info/Troubleshooting
* This entire program is essentially two AutoHotKey scripts - one for the GUI, and one for the Foxhole hotkeys. The GUI exists to set keybinds and start/stop the hotkeys easily. You can stop/suspend either script by finding them in system tray in the bottom right of your taskbar. 

* If you don't want to use the GUI after you've set your keybinds, the script for Foxhole is located in the \bin folder, and is called FoxholeHotkeys. You can simply double click this script to launch it, and can save to taskbar by `right click > create shortcut` for it. 

* If you are familiar with AutoHotKey, or don't want to bother with the GUI at all, there is a 'manual' version of the script in the \bin folder. You can `right click > edit with ...` the FoxholeHotkeysManual script to set keybinds manually. There are instructions in the comments of the script on how to do so.

# Contact
If you have any questions, issues, or feature requests, you can open an issue on this GitHub page, or message me on Discord (tommythebold).
