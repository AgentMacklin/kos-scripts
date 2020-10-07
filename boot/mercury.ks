clearScreen.

function thrustToWeight {
    set thrust to 0.
    list engines in engs.
    for engine in engs {
        set thrust to thrust + engine:thrust.
    }
    return thrust / (ship:mass * constant:g0).
}


set dir to 90.
set roll to 180.
set steer to heading(dir, 90, roll).
set twrPid to pidLoop(0.1, 1, 0, 0, 1).
set twrPid:setpoint to 1.75.
set thrott to 0.75.
set returning to false.

lock throttle to thrott.
lock steering to steer.

wait 1.
stage.

when ship:altitude > 5000 then {
    set steer to heading(dir, 60, roll).
}

when ship:altitude > 10000 then {
    set steer to heading(dir, 45, roll).
}

when ship:altitude > 25000 then {
    set steer to heading(dir, 30 ,roll).
    set twrPid:setpoint to 2.
}

when ship:altitude > 35000 then {
    set steer to heading(dir, 10 ,roll).
}

when ship:solidfuel < 1 then {
    twrPid:reset.
    stage.
}

when ship:liquidfuel < 1 then {
    wait 1.
    stage.
    wait 5.
    set steer to lookdirup(facing:topvector,-velocity:surface).
    set returning to true.
    unlock throttle.
}

when ship:verticalspeed < 0 and alt:radar < 3500 and returning = true then {
    chutes on.
    unlock steering.
}

until ship:status = "landed" and returning = true {
    set twr to thrustToWeight().
    set thrott to twrPid:update(time:seconds, twr).
    print "TWR    : " + round(twr, 3) at (0, 0).
    print "APOGEE : " + round(apoapsis, 3) at (0, 0).
    wait 0.001.
}


clearScreen.
print "========== Landed successfully! ==========".