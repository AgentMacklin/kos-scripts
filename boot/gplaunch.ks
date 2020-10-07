clearScreen.
print "==================== " + ship:name + " ====================".


// ================== Utility functions =================== //

function thrustToWeight {
    set thrust to 0.
    list engines in engs.
    for engine in engs {
        set thrust to thrust + engine:thrust.
    }
    return thrust / (ship:mass * constant:g0).
}

// velocity required to create a circular orbit
function circularOrbitVelocity {
    parameter alt_.
    local bod is ship:body.
    return sqrt(bod:mu / (bod:radius + alt_)).
}

// The current velocity at apoapsis
function apoapsisVelocity {
    local bod is ship:body.
    local orb is ship:orbit.
    return sqrt(bod:mu * ((2 / (bod:radius + apoapsis)) - (1 / orb:semimajoraxis))).
}

// Check if two values are close, given a tolerance.
function isClose {
    parameter a.
    parameter b.
    parameter tol.
    local diff is abs(a - b).
    return diff < tol.
}

function calculatePitch {
    parameter targetAlt.
    set param to (ship:altitude / targetAlt) ^ (1 / 2).
    return ((constant:pi / 2) * (1 - param)) * constant:radtodeg.
}

function maxMassFlow {
    local totIsp is averageIsp().
    return ship:maxThrust / (totIsp * constant:g0).
}

function averageIsp {
    local totIsp is 0.
    list engines in engs.
    for eng in engs {
        set totIsp to totIsp + eng:isp.
    }
    return totIsp / engs:length.
}

function burnTime {
    parameter dv_.
    local dm is maxMassFlow().
    local isp is averageIsp().
    if ship:maxthrust <> 0 {
        return abs(constant:g0 * ship:mass * isp * (1 - constant:e^(dv_ / (constant:g0 * isp))) / ship:maxthrust).
    } else {
        return 0.
    }
}

// ================ Important program variables ================ //

// altitude at which rocket should be completely horizontal
set targetAltitude to 55000.
set targetApoapsis to 85000.
set circularize to false.
set maintainApoapsis to false.

// pid controllers
set throttlePid to pidLoop(0.1, 1, 0, 0, 1).
set throttlePid:setpoint to 1.5.

// steering
set steer to heading(90, 90, 180).
lock steering to steer.

// throttle control
set thrott to 1.
lock throttle to thrott.

// Nest triggers to reduce the number of trigger checks. This increments the TWR
// as altitude increases
when ship:altitude > 10000 then { 
    set throttlePid:setpoint to 1.75. 
    when ship:altitude > 25000 then { 
        set throttlePid:setpoint to 2. 
        when ship:altitude > 35000 then { set throttlePid:setpoint to 2.25. }
    }
}

// When the apoapis is close to the target, begin setting up the circulization maneuvers
when isClose(apoapsis, targetApoapsis, 100) then {
    set throttlePid:setpoint to targetApoapsis.
    set throttlePid:kp to 0.001.
    set throttlePid:ki to 0.01.
    set maintainApoapsis to true.
}

when ship:altitude > ship:body:atm:height then {
    set circularize to true.
}


// ================ Mission loop ================ //
wait 1.
stage.

until circularize = true {

    if ship:verticalspeed < 100 {
        set steer to heading(90, 90, 180).
    } else if ship:altitude <= targetAltitude {
        set desiredPitch to calculatePitch(targetAltitude).
        set steer to heading(90, desiredPitch, 180).
    } else {
        set steer to heading(90, 0, 180).
    }

    if maintainApoapsis = true {
        set thrott to throttlePid:update(time:seconds, apoapsis).
    } else {
        set thrott to throttlePid:update(time:seconds, thrustToWeight()).
    }

    print "TWR    : " + round(thrustToWeight(), 3) at (0, 2).
    print "APOGEE : " + round(apoapsis, 3) at (0, 3).
    print "PITCH  : " + round(calculatePitch(targetAltitude), 3) at (0, 4).
    print "DM     : " + round(maxMassFlow(), 3) at (0, 4).

    wait 0.001.
}

set dv to circularOrbitVelocity(targetApoapsis) - apoapsisVelocity().
set circNode to node(time:seconds + eta:apoapsis, 0, 0, dv).
add circNode.

set thrott to 0.
set steer to circNode:burnvector.

wait until (burnTime(dv) / 2) >= eta:apoapsis. 

until isClose(ship:periapsis, targetApoapsis, 1000) {
    print "ETA     : " + round(eta:apoapsis, 3) at (0, 2).
    print "APOGEE  : " + round(apoapsis, 3) at (0, 3).
    print "PERIGEE : " + round(periapsis, 3) at (0, 4).
    print "CIRC V  : " + round(circularOrbitVelocity(targetApoapsis), 3) at (0, 5).
    print "CURAP V : " + round(apoapsisVelocity(), 3) at (0, 6).
    print "BURN T  : " + round(burnTime(dv), 3) at (0, 7).
    set thrott to 1.
    wait 0.001.
}
unlock throttle.
unlock steering.

set ship:control:pilotmainthrottle to 0.
print "Welcome to space!" at (0, 6).
print "Program has terminated." at (0, 7).