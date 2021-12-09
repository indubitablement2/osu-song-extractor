extends Control

var mode_in := true
var main_dir = ""
var out_dir = ""

func _on_FileDialog_confirmed():
	if mode_in:
		main_dir = $FileDialog.current_dir
		$HBoxContainer/Label.set_text(main_dir)
	else:
		out_dir = $FileDialog.current_dir
		$HBoxContainer2/Label.set_text(out_dir)
	if !main_dir.empty() && !out_dir.empty():
		$StartButton.show()

func _on_Button_pressed():
	mode_in = true
	$FileDialog.popup()

func _on_OutButton_pressed():
	mode_in = false
	$FileDialog.popup()

func _on_StartButton_pressed():
	$HBoxContainer/Button.hide()
	$HBoxContainer2/OutButton.hide()
	$StartButton.hide()
	
	var file := File.new()
	var dir := Directory.new()
	var dir2 := Directory.new()
	
	if dir.open(main_dir) != OK:
		$Console.add_text("\nError opening directory.")
		return
	
	var found_dir = []
	if dir.list_dir_begin(true, true) != OK:
		$Console.add_text("\nError could not list dir")
		return
	var file_name = dir.get_next()
	while file_name != "":
		if dir.current_is_dir():
			found_dir.push_back(file_name)
		file_name = dir.get_next()
	dir.list_dir_end()
	
	for i in found_dir.size():
		$ProgressBar.set_value( float(i) / (found_dir.size()))
		
		var cur_dir :String = main_dir + "/" + found_dir[i]
		
		# Get a clean song name.
		var song_name :String = found_dir[i]
		var to_remove := 0
		for c in song_name:
			to_remove += 1
			if c == " ":
				break
		song_name = song_name.right(to_remove)
		
		if dir.open(cur_dir) != OK:
			$Console.add_text("\nError opening " + cur_dir)
			continue
		
		# Get the biggest mp3 file in that directory.
		var biggest_mp3 := 0
		var mp3_file_name := ""
		if dir.list_dir_begin(true, true) != OK:
			$Console.add_text("\nError could not list dir")
			return
		file_name = dir.get_next()
		while file_name != "":
			if !dir.current_is_dir() && file_name.ends_with(".mp3"):
				if file.open(cur_dir + "/" + file_name, File.READ) == OK:
					var file_size := file.get_len()
					if file_size > biggest_mp3:
						biggest_mp3 = file_size
						mp3_file_name = file_name
					file.close()
				else:
					$Console.add_text("\ncould not open" + file_name)
			file_name = dir.get_next()
		dir.list_dir_end()
		
		if mp3_file_name.empty() || biggest_mp3 < 100000:
			$Console.add_text("\nNo valid song for " + song_name)
			continue
		var copy_err = dir2.copy(cur_dir + "/" + mp3_file_name, out_dir+ "/" + song_name+ ".mp3")
		if copy_err != OK:
			$Console.add_text("\nCould not copy " + song_name + " " + str(copy_err))
		else:
			$Console.add_text("\n" + song_name)
