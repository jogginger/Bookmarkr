local process = require("@lune/process")

print("Installing rokit tools")

-- Install rokit tools
local rokit_install = process.spawn("rokit", {
    "install"
})

print(rokit_install.stdout)
if not rokit_install.ok then
    print("Error installing rokit tools: " .. rokit_install.stderr)
    return
end

print("Installing wally packages")

-- Install wally packages
local wally_install = process.spawn("wally", {
    "install"
})

print(wally_install.stdout)
if not wally_install.ok then
    print("Error installing wally packages: " .. wally_install.stderr)
    return
end

print("Installation complete")