-- This file will not be overwritten across dots-hyprland updates.
-- The file name is for the sake of organization and does not matter
-- See the corresponding files in ~/.config/hypr/hyprland for examples
require("hyprland.lib")
require("hyprland.variables")
local qsScripts = "$HOME/.config/quickshell/$qsConfig/scripts"
local hyprScripts = "$HOME/.config/hypr/hyprland/scripts"
local qsIpcCall = "qs -c $qsConfig ipc call"
local qsIsAlive = qsIpcCall .. " TEST_ALIVE"

hl.bind("SUPER + F1", hl.dsp.exec_cmd(qsIpcCall .. " brightness increment || brightnessctl s 5%+"),
    { locked = true, repeating = true })

hl.bind("SUPER + F2", hl.dsp.exec_cmd(qsIpcCall .. " brightness decrement || brightnessctl s 5%-"),
    { locked = true, repeating = true })
