extends Label

@export var active = false;

var last_timestamp = 0

# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta):
	if self.active:
		if Time.get_ticks_msec() >= last_timestamp:
			self.visible = !self.visible
			last_timestamp = Time.get_ticks_msec() + 500
