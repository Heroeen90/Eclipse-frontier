extends Node

class_name ChecksumUtil

static func calculate_checksum(data: String) -> String:
	var hash = HashingContext.new()
	hash.start(HashingContext.HASH_SHA256)
	hash.update(data.to_utf8_buffer())
	var result = hash.finish()
	return result.hex_encode()

static func verify_checksum(data: String, checksum: String) -> bool:
	var calculated = calculate_checksum(data)
	return calculated == checksum

static func calculate_dict_checksum(data: Dictionary) -> String:
	var json_string = JSON.stringify(data)
	return calculate_checksum(json_string)

static func calculate_file_checksum(file_path: String) -> String:
	if not FileAccess.file_exists(file_path):
		return ""
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return ""
	
	var content = file.get_as_text()
	return calculate_checksum(content)