External Mod Manager: Road to Vostok
An advanced, lightweight graphical interface (GUI) built with AutoHotkey v2 for managing mods in Road to Vostok. This tool acts as a dedicated manager for the mod_config.cfg file, providing a seamless experience for users of the Metro Mod Loader.

Key Features
🛠️ Mod Management
Automatic Scanning: Instantly detects all mod files in the \mods directory.

Comprehensive Data: Displays mod status (On/Off), filename, priority, modification date, and file size.

Smart Sorting: Features a custom sorting engine for file sizes (correctly handles B, KB, MB, and GB) and other columns.

Quick Context Menu: Right-click any mod to open the file, show it in Windows Explorer, or delete it permanently.

⚖️ Priority & State Control
Load Order Control: Easily adjust mod priorities ranging from -100 to 100 to resolve loading conflicts.

Mouse Wheel Integration: Quickly change priority values by hovering over the input field and using the scroll wheel.

Bulk Actions: Includes "Toggle All" to enable/disable your entire library and "Reset Priority" to clear custom load orders.

🧹 Maintenance & Optimization
Cache Cleaner: One-click removal of temporary game files, including:

Game logs and mounting cache.

Shader Cache (DirectX and Vulkan).

Modloader conflict logs.

Conflict Prevention: Ensures the configuration is correctly formatted for the game engine.

📁 Profiles & Portability
Export/Import: Save your current mod list and priorities to external .cfg profiles. Switch between different mod builds in seconds.

Steam Integration: Automatically detects if Steam is running to launch the game via the Steam URI, with a fallback to the direct executable.

🎨 Modern User Interface
Native Dark Mode: Implements the Windows 11/10 Dark Mode API for a sleek, integrated look.

Adaptive Design: Fully resizable window with responsive element placement.

Bilingual Support: Real-time switching between English and Russian.

Interactive UX: Hover effects on buttons and detailed tooltips for every function.

Installation & Requirements
Place the executable (or script) into your Road to Vostok game folder.

Ensure you have Metro Mod Loader installed (the app will provide a link if it’s missing).

Run the manager and start modding!

Technical Details
Language: AutoHotkey v2.0

Encoding: UTF-8-RAW (for engine compatibility)

Framework: Win32 GUI via AHK Object-Oriented syntax