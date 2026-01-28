extends Node

var Quests: Dictionary = {
	"MQ001": {
		"QuestName": "My quest name",
		"CurrentStage": 0,
		"QuestDescription": {
			"10": "Stage 10 Description"
		},
	},
	"MQ002": {
		"QuestName": "My newer quest name",
		"CurrentStage": 0,
		"QuestDescription": {
			"10": "Stage 10 Description",
			"20": "Stage 20 Description",
			"30": "Stage 30 Description"
		},
	},
}

var quests_active: Dictionary = {}
var quests_completed: Array = []

var tutorial_quest: String = ""

# NOTIFICATION FLAGS
var flag_notify_comp_1: bool = false
var flag_notify_comp_2: bool = false
var flag_notify_comp_3: bool = false

@onready var tmr: Timer = Timer.new()

func _ready():
	add_child(tmr)
	tmr.wait_time = 1.0
	tmr.autostart = true
	tmr.start()
	tmr.connect("timeout", Callable(self._on_timer_timeout))

func _on_timer_timeout():
	match quests_completed:
		1:
			if !flag_notify_comp_1:
				print("You have completed Quest 1")
				flag_notify_comp_1 = true
		2:
			if !flag_notify_comp_2:
				print("You have completed Quest 2")
				flag_notify_comp_2 = true
		3:
			if !flag_notify_comp_3:
				print("You have completed Quest 3")
				flag_notify_comp_3 = true


func addQuest(questID: String):
	if questID in Quests.keys():
		quests_active[questID] = Quests[questID]
		printt("Quest Added", questID)

func advanceQuest(questID: String):
	quests_active[questID]["CurrentStage"] += 10
	var currentStage: String = str(quests_active[questID]["CurrentStage"])
	if currentStage in quests_active[questID]["QuestDescription"].keys():
		print(quests_active[questID]["QuestDescription"][currentStage])
	else:
		completeQuest(questID)

func completeQuest(questID: String):
	quests_completed.append(Quests[questID]["QuestName"])
	quests_active.erase(questID)
	printt("Quest completed", quests_completed)
