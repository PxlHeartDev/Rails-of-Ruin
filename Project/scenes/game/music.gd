extends AudioStreamPlayer

@export var timer: Timer

@export var delayBetweenSongs: int = 30

var musicList: Array[Dictionary] = [
	{"file": "res://assets/music/14470LS.wav", "volume": -6.0}
]

func _ready() -> void:
	timer.wait_time = delayBetweenSongs

func _on_finished() -> void:
	timer.start()

func _on_timer_timeout() -> void:
	var newSong = musicList.pick_random()
	var songFile = load(newSong.file)
	volume_db = newSong.volume
	stream = songFile
	play()
