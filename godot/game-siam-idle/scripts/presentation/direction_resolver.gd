class_name DirectionResolver
extends RefCounted

static func direction_for_vector(vector: Vector2, fallback := "south") -> String:
	if vector.length_squared() < 0.0001:
		return fallback

	var angle := rad_to_deg(atan2(vector.y, vector.x))
	if angle >= -22.5 and angle < 22.5:
		return "east"
	if angle >= 22.5 and angle < 67.5:
		return "south-east"
	if angle >= 67.5 and angle < 112.5:
		return "south"
	if angle >= 112.5 and angle < 157.5:
		return "south-west"
	if angle >= 157.5 or angle < -157.5:
		return "west"
	if angle >= -157.5 and angle < -112.5:
		return "north-west"
	if angle >= -112.5 and angle < -67.5:
		return "north"
	return "north-east"
