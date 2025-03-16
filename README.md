# Bookmarkr

A Roblox Studio plugin for easily creating and managing script/instance bookmarks in your workspace.
Detailed description in the [DevForum Post](https://devforum.roblox.com/t/bookmarkr-easy-to-use-bookmarking-plugin-for-scripts-and-instances/3554055)

## Features
- Simplistic interface
- Folders
- Easy navigation thanks to a list-based directory system and breadcrumb navigator
- Search function with result cycling
- Persistent bookmarks across sessions
- Customizable bookmark names (and optionally line numbers for scripts)
- Import and export your directories as strings, allowing sharing your bookmarks with other developers in your workspace
- Creating a bookmark while in the script editor automatically uses the currently selected line, no need to enter it manually

## Installation
### Via Roblox Marketplace
Simply install the plugin from the [Roblox Marketplace](https://create.roblox.com/store/asset/104556895236019/Bookmarkr)

### Via file
Grab the latest .rbxm from the releases, insert it into studio, then right click and save as local plugin or upload it as one

### Build from source
1. Clone the repository

2. Make sure you have [rokit](https://github.com/rojo-rbx/rokit) installed

---
#### If you **do** have [Lune](https://lune-org.github.io/docs/getting-started/1-installation) installed, you can skip this step (`rokit install` is also ran by `scripts/Install`)
- Run `rokit install` to install lune
---

3. Run `lune run scripts/Install` to install tools and packages

4. Run `lune run scripts/Build` to build the rbxm
