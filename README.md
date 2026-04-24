# 🛰️ External Mod Manager: Road to Vostok

An advanced, lightweight GUI built with **AutoHotkey v2** for seamless mod management in *Road to Vostok*. Specifically designed to manage `mod_config.cfg` for the **Metro Mod Loader**.

<p align="center">
  <img width="940" src="https://github.com/user-attachments/assets/3ae148fe-2e51-4c13-b757-8545ec6263b1" alt="SMM RTV Screenshot" />
</p>

---

### ✨ Key Features

#### 🛠️ Mod Management
* **Auto-Detection:** Instantly scans the `\mods` directory for new content.
* **Smart Sorting:** Custom engine for sorting by **size (B/KB/MB/GB)** and modification date.
* **Power Context Menu:** Right-click to open files, locate in Explorer, or delete mods permanently.

#### ⚖️ Priority & Control
* **Load Order:** Granular priority control (**-100 to 100**) with **mouse wheel support**.
* **Bulk Actions:** One-click to toggle all mods or reset all priorities to zero.
* **Profiles:** Export and Import `.cfg` profiles to switch between different mod builds instantly.

#### 🧹 Optimization & Launch
* **Cache Cleaner:** Purge game logs, mounting cache, and **Shader Cache (DX/Vulkan)**.
* **Smart Launch:** Detects Steam automatically to launch via URI or falls back to direct `.exe`.
* **Conflict Prevention:** Ensures configuration files remain engine-compliant (UTF-8-RAW).

#### 🎨 Modern UI/UX
* **Native Dark Mode:** Deep integration with Windows 10/11 Dark Theme API.
* **Responsive Design:** Fully resizable window with adaptive layout.
* **Bilingual:** Instant toggle between **English** and **Russian** 🌐.

---

### 🚀 Installation & Usage

1.  **Placement:** Move the executable (or script) into your main **Road to Vostok** game folder.
2.  **Requirement:** Ensure [Metro Mod Loader](https://modworkshop.net/mod/55623) is installed.
3.  **Run:** Open the manager, configure your load order, and hit **Launch Game**.

---

### ⚙️ Technical Details

| Feature | Specification |
| :--- | :--- |
| **Language** | AutoHotkey v2.0 |
| **Framework** | Object-Oriented Win32 GUI |
| **Encoding** | UTF-8-RAW (Engine Compatible) |
| **OS Support** | Windows 10 / 11 |

---
<p align="center">
  <i>Developed for the Road to Vostok community.</i>
</p>
