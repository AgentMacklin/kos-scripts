
local logDir is "logs/".
local lastLogTime to time:day.

function createFileName {
    parameter name.
    return logDir + name + ".log".
}

function timeStamp {
    return "[DAY " + time:day + " " + time:clock() + "]".
}

function logInfo {
    parameter file, msg.
    set file to createFileName(file).
    set msg to timeStamp() + "[INFO] " + msg.
    log msg to file.
}

function logWarning {
    parameter file, msg.
    set file to createFileName(file).
    set msg to timeStamp() + "[WARN] " + msg.
    log msg to file.
}

// Create a trigger that backs up the logs after waitTime has passed.
function backupLogs {
    parameter waitTime.
    when (time:day - lastLogTime) > waitTime then {
        cd(logDir).
        for file in files {
            copyPath(file, "0:/logs/").
        }
        set lastLogTime to time:day.
        return true.
    }
}
