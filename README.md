# External Mod Manager: Road to Vostok

![Version](https://img.shields.io/badge/version-1.1-blue)
![License](https://img.shields.io/badge/license-MIT-green)
![Platform](https://img.shields.io/badge/platform-Windows-lightgrey)

A lightweight, high-performance external mod manager for **Road to Vostok**, built with AutoHotkey v2. This tool provides a clean UI to manage your mod library, load orders, and game settings without touching configuration files manually.

---

## ✨ Key Features

* **🗂️ Profile Management** – Create, rename, and switch between multiple mod profiles for different playstyles or testing.
* **⚖️ Load Order Control** – Easily adjust mod priority (double-click to edit) and toggle specific mods on/off.
* **🚀 One-Click Launch** – Integrated launcher supporting both Steam and standalone versions with custom modloader arguments.
* **🧹 Cache Cleanup** – Built-in utility to clear logs, shader caches, and temporary files to improve stability.
* **🎨 Modern UI** – Dark-themed interface with responsive layout, tooltips, and real-time mod statistics.
* **⚡ Bulk Actions** – Quickly toggle all mods or reset priorities to default values.

---

## 🛠️ Installation & Usage

1.  **Placement:** Place the executable (or script) directly into your **Road to Vostok** game folder (the one containing `RTV.exe`).
2.  **Requirement:** Ensure you have the [Mod Loader (modloader.gd)](https://modworkshop.net/mod/55623) installed.
3.  **Run:** Launch the manager. It will automatically detect your mods and create a config file in your AppData folder.
4.  **Configure:** Enable your desired mods, set their priority, and click **Save Config**.
5.  **Play:** Use the **LAUNCH GAME** button to start your session.

---

## ⚙️ Technical Details

* **Language:** AutoHotkey v2.0
* **Config Path:** `%AppData%\Road to Vostok\mod_config.cfg`
* **OS Support:** Windows 10/11 (supports DWM Dark Mode)
* **Game Version:** Compatible with current Road to Vostok public builds.

---

## 🗒️ Notes

- The manager checks for `RTV.exe` and `modloader.gd` on startup to ensure proper functionality.
- You can toggle the **Ingame Mod UI** via a checkbox directly in the manager.
