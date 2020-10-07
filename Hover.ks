// This script is meant to allow a ship to hover at a set altitude.

set thrott to 0.
lock throttle to thrott.
set shipSteering to ship:srfretrograde.

set targalt to alt:radar.

set kp to 0.01.
set ki to 0.005.
set kd to 0.015.
set altPid to pidloop(kp, ki, kd,  -0.025, 0.025).
set speedPid to pidloop(kp, ki, kd, -0.05, 0.05).

set altPid:setpoint to targalt.
set speedPid:setpoint to 0.

set runMode to "hover".

sas on.
stage.



until runMode = "killLoop" {

    if runMode = "landing" {
        set altout to 0.
        set speedout to speedPid:update(time:seconds, ship:verticalspeed).
        set thrott to thrott + speedout.

        if ship:status = "landed" or "splashed" {
            set thrott to 0.
            set ship:control:pilotmainthrottle to thrott.
            set runMode to "standby".
        }
    }

    if runMode = "hover" {

        if hoverMode = "radar" {
            set altout to altPid:update(time:seconds, alt:radar).
        }

        else if hoverMode = "absolute" {
            set altout to altPid:update(time:seconds, ship:altitude).
        }

        set speedout to speedPid:update(time:seconds, ship:verticalspeed).

        // The vertical speed pid controller is meant to take effect when the altitude
        // is close to the target altitude, so it smooths out the throttle. The altitude
        // pid has a hard time holding a steady altitude on its own.

        if altPid:error < 1 and altPid:error > -1 {
            set thrott to thrott + altout.
            set thrott to thrott + speedout.
        }

        else if altPid:error > 1 or altPid:error < -1 {
            set thrott to thrott + altout.
            set speedout to 0.
        }

        if thrott > 1 { set thrott to 1. }
        else if thrott < 0 { set thrott to 0. }        

    }


    // Block of code that handles user input.

    on ag1 {
         set altPid:setpoint to altPid:setpoint - 5.
         if altPid:setpoint < 0 { set altPid:setpoint to 0. }
     }

    on ag2 {
         set altPid:setpoint to altPid:setpoint + 5.
         if altPid:setpoint < 0 { set altPid:setpoint to 0. }
     }

    on ag3 {
        // Changes the target altitude between radar and sea level.
        if hoverMode = "radar" {
            set hoverMode to "absolute".
            set altPid:setpoint to ceiling(ship:altitude).
            if altPid:setpoint < 0 { set altPid:setpoint to 0. }
        }

        else if hoverMode = "absolute" {
            set hoverMode to "radar".
            set altPid:setpoint to ceiling(alt:radar).
            if altPid:setpoint < 0 { set altPid:setpoint to 0. }
        }
    }


    on ag4 {
        // Allows user to land or hover vehicle.
        if runMode = "hover" {
            set runMode to "landing".
            lock steering to shipSteering.
        }

        else if runMode = "landing" {
            set runMode to "hover"
            set speedPid:setpoint to 0.
            unlock steering.
        }
    }


    on ag5 {
        if runMode = "landing" or "hover" {
            set ship:control:pilotmainthrottle to thrott.
            set runMode to "standby".
            if sas off { sas on. }
        }

        else if runMode = "standby" {
            set runMode = "hover".
            if hoverMode = "absolute" {
                set hoverMode to "radar".
            }
        }
    }

    on ag6 {
        set loopKey to true.
        until loopKey = false {
            print "Kill program?" at (0, 1).
            print "Press 1 to confirm or 2 to cancel." at (0, 2).
            on ag1 {
                set ship:control:pilotmainthrottle to thrott.
                if sas off { sas on. }
                set runMode to "killLoop".
            }
            on ag2 {
                set loopKey to false.
            }
            wait 0.001.
            clearscreen.
        }
    }

    // Printing to terminal.
    print "Target Alt: " + altPid:setpoint at (0,1).
    print "Mode:       " + runMode at (0, 2).
    print "Hover:      " + hoverMode at (0,3).
    wait 0.001.
    clearscreen.
}
