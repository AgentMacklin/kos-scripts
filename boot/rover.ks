@lazyGlobal off.

// These include directives are for the VSCode KOS server, not KOS itself

// #include "lib/packager.ks"
// #include "lib/name.ks"
// #include "lib/resource.ks"
// #include "lib/navigation.ks"
// #include "lib/logger.ks"

clearScreen.

copyPath("0:/lib/packager.ks", ""). 
runOncePath("packager.ks").

// Library "packages" located in the archive at KSC
local packages is list(
    "name.ks", 
    "resource.ks", 
    "navigation.ks", 
    "logger.ks"
).
include(packages).

// Give the rover a unique name, with a unique 2 digit number.
nameVessel("Rover", 4).

// Backup the logs every 14 days.
backupLogs(14).

local dir is 0.
local speed is 5.

local charging is false.
local electricCharge is getResource("ElectricCharge").

when ship:electriccharge < (electricCharge:capacity * 0.1) then {
    set charging to true.
    set speed to 0.
    brakes on.
    logWarning("power", "Log on charge, stopping to recharge.").
    return true.
}

when charging = true and electricCharge:amount > (electricCharge:capacity * 0.95) then {
    set charging to false.
    brakes off.
    set speed to 5.
    logInfo("power", "Rover is charged, continuing mission.").
    return true.
 }

 on ag1 {
     set dir to dir - 10.
     if dir < 0 set dir to 360.
     return true.
 }

 on ag2 {
     set dir to dir + 10.
     if dir > 360 set dir to 0.
     return true.
 }

until false {
    if charging = true {
        wait 60.
    } else {
        print(round(ship:groundspeed, 3)) at (0, 2).
        roverSteer(dir).
        roverThrottle(speed).
        wait 0.01.
    }
}
