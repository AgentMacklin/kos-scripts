
@lazyGlobal off.

local alphanumerical is "ABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789".


function rand {
    parameter start.
    parameter end.
    return (start + floor(end * random())).
}

function uuid {
    parameter len.
    local numVal to alphanumerical:length.
    local out is "".
    for i in range(0, len) {
        set out to out + alphanumerical[rand(0, numVal - 1)].
    }
    return out.
}

function nameVessel {
    parameter name.
    parameter uuidLen is 4.

    local fileName is "name.json".
    if not exists(fileName) {
        local json is lexicon().
        set ship:name to name + "-" + uuid(uuidLen).
        json:add("name", ship:name).
        writeJson(json, fileName).
    } else {
        local json is readJson(fileName).
        set ship:name to json["name"].
    }
}

