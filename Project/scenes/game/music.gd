extends AudioStreamPlayer

@export var timer: Timer

@export var delayBetweenSongs: int = 30

const MUSIC_PATH = "res://assets/music/"
var musicList: Dictionary[String, Dictionary] = {
	"death": {"file": "Death.wav", "volume": -0.0},
	"battle3": {"file": "Battle3.wav", "volume": -6.0},
}

func _ready() -> void:
	timer.wait_time = delayBetweenSongs

func _on_finished() -> void:
	pass

func playSong(name: String) -> void:
	var newSong = musicList[name]
	var songFile = load("%s%s" % [MUSIC_PATH, newSong.file])
	fadeVol(newSong.volume, 0.1)
	stream = songFile
	play()

var volTween: Tween

func fadeVol(vol: float, time: float) -> void:
	if volTween and volTween.is_running():
		volTween.stop()
	volTween = create_tween()
	volTween.tween_property(self, "volume_db", vol, time)

var pitchTween: Tween

func fadePitch(pitch: float, time: float) -> void:
	if pitchTween and pitchTween.is_running():
		pitchTween.stop()
	pitchTween = create_tween()
	pitchTween.tween_property(self, "pitch_scale", pitch, time)

func died() -> void:
	fadePitch(0.25, 3.0)
	await pitchTween.finished
	fadeVol(-60.0, 1.5)
	await volTween.finished
	
	playSong("death")
	pitch_scale = 1.0

func again() -> void:
	fadeVol(-60.0, 1.0)
	await volTween.finished
	pitch_scale = 1.0
	await get_tree().process_frame
	playSong("battle3")

func quit() -> void:
	fadeVol(-60.0, 1.0)
