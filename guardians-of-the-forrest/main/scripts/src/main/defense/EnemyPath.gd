extends PathFollow2D

@export var xReverse = false
@export var speed = 0.002
@onready var remote: RemoteTransform2D = $RemoteTransform2D
@onready var follower = remote.get_node_or_null(remote.remote_path)
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	
	if (self.progress_ratio >= 0.9): 
		xReverse = true
		if(follower && follower.has_method("xFlip")):
			follower.xFlip(xReverse)
	elif(self.progress_ratio <= 0.1):
		xReverse = false
		if(follower && follower.has_method("xFlip")):
			follower.xFlip(xReverse)
		
	

			
	if (xReverse):
		self.progress_ratio -= speed
	elif (!xReverse):
		self.progress_ratio += speed
	
	pass
