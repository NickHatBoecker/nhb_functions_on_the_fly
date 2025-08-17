## This script will find a custom class based on its class_name.
## If a script was found, its script path will be returned.
## If no script is found within {CANCEL_AFTER_MS} ms, an empty string is returned.
class_name NhbFunctionsOnTheFlyClassFinder
extends Node


const CANCEL_AFTER_MS = 3000


var _found_path: String


func get_found_path() -> String:
    return _found_path


func find_class_path(name_of_class : String) -> String:
    var dir = DirAccess.open("res://")
    if not dir:
        return ""

    var start_ms = Time.get_ticks_msec()
    _search_dir(dir, name_of_class, start_ms)

    return _found_path


func _search_dir(dir : DirAccess, target : String, start_ms : int):
    if Time.get_ticks_msec() - start_ms > 3000:
        _found_path = ""
        return

    for item in dir.get_files():
        if !item.ends_with(".gd"): continue

        var path = dir.get_current_dir() + "/" + item
        var file = FileAccess.open(path, FileAccess.READ)
        if !file:
            continue

        while not file.eof_reached():
            if Time.get_ticks_msec() - start_ms > CANCEL_AFTER_MS:
                _found_path = ""
                return
            var line = file.get_line()
            if line.begins_with("class_name "):
                var parts = line.split(" ")
                if parts.size() > 1 and parts[1] == target:
                    _found_path = path
                    return
        file.close()

    for sub in dir.get_directories():
        dir.change_dir(sub)
        _search_dir(dir, target, start_ms)

        if _found_path != "": return

        dir.change_dir("..")
