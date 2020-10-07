clearScreen.

copyPath("0:/lib/logger.ks", "").
copyPath("0:/lib/resource.ks", "").
copyPath("0:/lib/name.ks", "").
runOncePath("logger.ks").
runOncePath("resource.ks").
runOncePath("name.ks").

nameVessel("ComSat", 4).

set charge to getResource("ElectricCharge").
set lowPowerMode to false.

initLog("comm").
initLog("power").


when charge:amount < (charge:capacity * 0.1) then {
    logWarning("power", "Vessel low on power: " + round(charge:amount, 2) + " of " + round(charge:capacity, 2)).
    set lowPowerMode to true.
    return true.
}

when lowPowerMode = true and (charge:amount > (charge:capacity * 0.5)) then {
    logInfo("power", "Exiting low power mode").
    set lowPowerMode to false.
    return true.
}

if not hasTarget {
    set target to Body("Kerbin").
}

lock steering to target:position.

until false {
    if lowPowerMode = true {

    } else {

    }
    wait 0.01.
}

