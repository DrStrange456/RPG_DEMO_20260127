class_name Move_Ability extends Node2D

func execute(s, dir):
	s.velocity = Vector2()
	
	if dir == "UP":
		s.velocity.y -= 1
	elif dir == "DOWN":
		s.velocity.y += 1
	elif dir == "LEFT":
		s.velocity.x -= 1
	elif dir == "RIGHT":
		s.velocity.x += 1
	else:
		s.velocity.x = 0
		s.velocity.y = 0

	s.velocity = s.velocity.normalized()
	s.velocity = (s.velocity * s._get_sprint_bonus()) * s._get_friction()
	s.move_and_slide()

func running(s, dir):
	if dir == "SPRINT_START":
		s._set_sprint_bonus(350)
	if dir == "SPRINT_END":
		s._set_sprint_bonus(100)
		
