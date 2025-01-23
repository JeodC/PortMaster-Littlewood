#!/bin/bash

if [ -d "/opt/system/Tools/PortMaster/" ]; then
  controlfolder="/opt/system/Tools/PortMaster"
elif [ -d "/opt/tools/PortMaster/" ]; then
  controlfolder="/opt/tools/PortMaster"
else
  controlfolder="/roms/ports/PortMaster"
fi

source $controlfolder/control.txt
[ -f "${controlfolder}/mod_${CFW_NAME}.txt" ] && source "${controlfolder}/mod_${CFW_NAME}.txt"
get_controls

# Variables
GAMEDIR=/$directory/ports/littlewood

# CD and set permissions
cd $GAMEDIR
> "$GAMEDIR/log.txt" && exec > >(tee "$GAMEDIR/log.txt") 2>&1
$ESUDO chmod +x -R $GAMEDIR/*

# Display loading splash
[ "$CFW_NAME" == "muOS" ] && $ESUDO $GAMEDIR/splash "splash.png" 1
$ESUDO $GAMEDIR/splash "splash.png" 30000 & 

# Exports
export SDL_GAMECONTROLLERCONFIG="$sdl_controllerconfig"
export WINEPREFIX=/storage/.wine64
export WINEDEBUG=-all

# Install dependencies
if ! winetricks list-installed | grep -q "^dxvk$"; then
    pm_message "Installing dependencies."
    winetricks dxvk
fi


# Config Setup
mkdir -p $GAMEDIR/config
bind_directories "$WINEPREFIX/drive_c/users/root/AppData/LocalLow/SmashGames/Littlewood" "$GAMEDIR/config"

# Run the game
$GPTOKEYB "Littlewood.exe" -c "./littlewood.gptk" &
box64 wine64 "./data/Littlewood.exe"

# Kill processes
pm_finish