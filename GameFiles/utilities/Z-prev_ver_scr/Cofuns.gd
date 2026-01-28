class_name Cofun
extends Node

###
# COMMON FUNCTION LIBRARY


func is_hit_location_valid(tm: TileMap, hitLoc: Vector2)->bool:
	# INPUT
	# 1) Tilemap to check hit location against
	# 2) Hit Location
	# 
	# If Hit location matches with a valid tilemap tile, return true.
	# Else return false
	
	var tmp_pos_id
	if tm:
		tmp_pos_id = tm.get_cell_atlas_coords(0,tm.local_to_map(hitLoc)) 
		return (tmp_pos_id[1] > -1)
	return false

func is_hit_location_valid_tml(tm: TileMapLayer, hitLoc: Vector2)->bool:
	# INPUT
	# 1) Tilemap to check hit location against
	# 2) Hit Location
	# 
	# If Hit location matches with a valid tilemap tile, return true.
	# Else return false
	
	var tmp_pos_id
	if tm:
		tmp_pos_id = tm.get_cell_atlas_coords(tm.local_to_map(hitLoc))
		return (tmp_pos_id[1] > -1)
	return false
