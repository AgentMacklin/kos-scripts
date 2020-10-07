


function getResource {
	parameter name.
	for resource in ship:resources {
		if resource:name = name {
			return resource.
		}
	}
	return false.
}