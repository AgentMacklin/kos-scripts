function include {
    parameter packages.
    parameter path is "0:/lib/".
    for package in packages {
        if not exists (package) {
            copyPath(path + package, "").
        }
        runOncePath(package).
    }
}