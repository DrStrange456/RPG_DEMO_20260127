extends Area2D

@export var QuestID: String

func _ready():
	self.connect("body_entered", Callable(self, "areaReached"))


func areaReached(body):
	if body.is_in_group("player"):
		#Missions.advanceQuest(QuestID)
		self.queue_free()
