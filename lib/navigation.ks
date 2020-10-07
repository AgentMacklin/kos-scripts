
@lazyGlobal off.


local northPole is latlng(90, 0).
local steeringPid is pidLoop(0.01, 0.005, 0.00125, -0.1, 0.1).
local throttlePid is pidLoop(0.5, 0.1, 0.1, -1, 1).

function compass {
    return mod(360 - northPole:bearing, 360).
}

function roverSteer {
    parameter head.
    set steeringPid:setpoint to head.
    set ship:control:wheelsteer to -steeringPid:update(time:seconds, compass()).
    print(round(ship:control:wheelsteer, 3)) at (0, 4).
}

function roverThrottle {
    parameter speed.
    set throttlePid:setpoint to speed.
    set ship:control:wheelthrottle to throttlePid:update(time:seconds, ship:groundspeed).
    print(round(speed, 3)) at (0, 3).
} 
