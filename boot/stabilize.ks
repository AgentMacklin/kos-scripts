
print "
".
print "Initializing stabilization procedure".
print "------------------------------------".

// set xPid to pidLoop(0.1, 0.01, 0.005, -1, 1).
// set yPid to pidLoop(0.1, 0.01, 0.005, -1, 1).
// set zPid to pidLoop(0.1, 0.01, 0.005, -1, 1).

set prevOrientation to ship:facing.
set prevTime to time:seconds.

// Custom function to get the roll, yaw, and pitch rate. 
// This is necessary because the builtin angular velocity 
// calculation gets thrown off when there is a rotor 
// running on the vessel.
// function orientationRate {
//     set currentOrientation to ship:facing. 
//     set dt to time:seconds - prevTime.
//     set dr to -constant:degtorad * (currentOrientation - prevOrientation).

//     set prevTime to time:seconds.
//     set prevOrientation to currentOrientation.

//     set dr to V(dr:pitch, dr:yaw, dr:roll).

//     if dt <> 0 {
//         return dr * (1 / dt).
//     } else {
//         return V(0, 0, 0).
//     }
// }

// set rollPid to pidLoop(0.5, 0.1, 0.05, -1, 1).
// set pitchPid to pidLoop(0.5, 0.1, 0.05, -1, 1).
// set yawPid to pidLoop(0.5, 0.1, 0.05, -1, 1).
// set rollPid:setpoint to 0.
// set pitchPid:setpoint to 0.
// set yawPid:setpoint to 0.

function dampenVehicle {
    set drdt to ship:angularvel.
    // set ship:control:roll to ship:control:pilotpitch + rollPid:update(time:seconds, drdt:x).
    // set ship:control:pitch to ship:control:pilotyaw + pitchPid:update(time:seconds, drdt:y).
    // set ship:control:yaw to ship:control:pilotroll + yawPid:update(time:seconds, drdt:z).
    print "Rate  : " + drdt at(0, 8).
    // print "Pitch : " + ship:control:pitch at(0, 9).
    // print "Yaw   : " + ship:control:yaw at(0, 10).
    // print "Roll  : " + ship:control:roll at(0, 11).

}


until false {
    dampenVehicle().
    wait 0.01.
}