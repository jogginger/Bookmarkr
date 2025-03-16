local process = require("@lune/process")
local fs = require("@lune/fs")

-- Create build folder if it doesn't exist
if not fs.isDir("build") then
    fs.writeDir("build")
end

print("Building...")

-- Convert requires with darklua
local darklua_convert = process.spawn("darklua", {
    "process",
    "src",
    "build",
    "--config=darklua.json"
})

print(darklua_convert.stdout)
if not darklua_convert.ok then
    print("Error: " .. darklua_convert.stderr)
end

-- Build rojo project
local rojo_build = process.spawn("rojo", {
    "build",
    "build.project.json",
    "-o",
    "plugin.rbxm",
})

print(rojo_build.stdout)
if not rojo_build.ok then
    print("Error: " .. rojo_build.stderr)
end