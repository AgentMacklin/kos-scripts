
set thrott to 0.
lock throttle to thrott.
set steer to up.
lock steering to steer.
set launchpad to ship:geoposition.
set control to ship:control.
set shipdir to ship:up.

set kp to 1000.
set ki to 100.
set kd to 1000.

set speedpid to pidloop(0.01, 0.005, 0.015,  -0.05, 0.05).
set speedpid:setpoint to -1.
set latpid to pidloop(kp, ki, kd,  -1, 1).
set latpid:setpoint to launchpad:lat.
set lngpid to pidloop(kp, ki, kd,  -1, 1).
set lngpid:setpoint to launchpad:lng.
set rollpid to pidloop(0.1, 0.01, 0.05,  -0.1, 0.1).
set rollpid:setpoint to 90.


set runmode to "launch".
rcs on.

function calc_twr {
    parameter returnval.
    set totthrust to 0.
    set grav to 9.81.
    list engines in eng.
    for engine in eng {
        set totthrust to totthrust + engine:maxthrust.
    }
    set twr to totthrust / (ship:mass * grav).
    set accel to totthrust / (ship:mass).
    if returnval = "twr" { return twr. }
    else if returnval = "accel" { return accel. }

}
function quadratic {
    parameter a, b, c.
    set t to (b + sqrt(b^2 + 2*a*c)) / a.
    return t.
}
function impact_eta {
    set shipaccel to calc_twr("accel").
    set accel to ship:sensors:acc:mag.
    set impacteta to quadratic(accel, ship:verticalspeed, alt:radar).
    set burntime to -1 * ship:verticalspeed / (shipaccel + accel).
    print impacteta at (0, 2).
    print burntime at (0, 3).
    print ship:sensors:acc:mag at (0,4).
    if burntime > (impacteta - 0.25) {
        return true.
    } else { return false. }
}
function pid_master {
    if addons:tr:hasimpact = true {
        set impactpos to addons:tr:impactpos.
        set shipdir to ship:facing.
        set retro to ship:srfretrograde.
        set latout to latpid:update(time:seconds, impactpos:lat).
        set lngout to lngpid:update(time:seconds, impactpos:lng).
        set rollout to rollpid:update(time:seconds, shipdir:roll).
        set control:roll to -rollout.
        if throttle = 0 {
            set control:yaw to -latout.
            if shipdir > retro + 5 {
                set control:yaw to -latout.
            }
            set control:pitch to -lngout.
        }
        else {
            set control:yaw to latout.
            set control:pitch to lngout.
        }
    }
}


until runmode = "complete" {

    if addons:tr:hasimpact = true {
        set impactpos to addons:tr:impactpos.
    }

    if runmode = "launch" {
        set thrott to 1.
        set steer to up + r(0,0,90).
        stage.
        gear off.
        wait until ship:altitude > 1000.
        set thrott to 0.
        wait until ship:altitude < 1500 and ship:verticalspeed < 0.
        set runmode to "landing".
        unlock steering.
    }

    if runmode = "landing" {
        set burn to impact_eta().
        if burn = false { set thrott to 0. }
        else if burn = true { set runmode to "burn". }
        pid_master().
    }

    if runmode = "burn" {
        gear on.
        if ship:verticalspeed < -5 { set thrott to 1. }
        else if ship:verticalspeed > 0 { set thrott to 0. }
        else {
            set out to speedpid:update(time:seconds, ship:verticalspeed).
            set thrott to thrott + out.
            if thrott > 1 { set thrott to 1. }
            else if thrott < 0 { set thrott to 0. }
        }
        pid_master().
    }


    if ship:status = "landed" {
        set ship:control:pilotmainthrottle to 0.
        set runmode to "complete".
    }

    print runmode at (0,0).
    print "roll: " + shipdir:roll at (0, 5).
    clearscreen.
    wait 0.001.

}
