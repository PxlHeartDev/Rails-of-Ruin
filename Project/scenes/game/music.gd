extends AudioStreamPlayer

@export var timer: Timer

@export var delayBetweenSongs: int = 30

const MUSIC_PATH = "res://assets/music/"
var musicList: Dictionary[String, Dictionary] = {
	"death": {"file": "Death.wav", "volume": 0.0},
	"plains": {"file": "Plains.wav", "volume": -10.0},
	"plains_boss": {"file": "Plains_Boss.wav", "volume": -8.0},
	"pipe": {"file": "BattlePipe.wav", "volume": -12.0}
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
func fadeVol(vol: float, time: float = 0.0) -> void:
	if volTween and volTween.is_running():
		volTween.stop()
	if time:
		volTween = create_tween()
		volTween.tween_property(self, "volume_db", vol, time)
	else:
		volume_db = vol

var pitchTween: Tween
func fadePitch(pitch: float, time: float = 0.0) -> void:
	if pitchTween and pitchTween.is_running():
		pitchTween.stop()
	if time:
		pitchTween = create_tween()
		pitchTween.tween_property(self, "pitch_scale", pitch, time)
	else:
		pitch_scale = pitch

var filterTween: Tween
func lowPassFilter(freq: float, time: float = 0.0) -> void:
	var eff := AudioServer.get_bus_effect(AudioServer.get_bus_index("Music"), 0) as AudioEffectLowPassFilter
	if filterTween and filterTween.is_running():
		filterTween.stop()
	if time:
		filterTween = create_tween()
		filterTween.tween_property(eff, "cutoff_hz", freq, time)
	else:
		eff.cutoff_hz = freq

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
	playSong("plains")

func quit() -> void:
	fadeVol(-60.0, 1.0)
