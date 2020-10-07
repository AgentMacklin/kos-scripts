clearScreen.

set thrott to 0.

lock throttle to thrott.
lock steering to up.

function controlSpeed {
    set thrott to pid:update(time:seconds, verticalSpeed).
    print thrott at(0, 0).
    print verticalSpeed at(0, 1).
    wait 0.01.
}

set pid to pidLoop(0.5, 0.05, 0.025, 0, 1).
set pid:setpoint to 5.

when alt:radar < 50 and verticalSpeed < 0 then {
    gear on.
}

stage.


until alt:radar > 100 {
    controlSpeed().
}


set pid:setpoint to -2.5.

until ship:status = "landed" {
    controlSpeed().
}

print "Landed!".

set thrott to 0.