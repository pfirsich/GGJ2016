-- psssh
TILESIZE = 32
SIM_DT = 1/60.0

const = {

	PLAYER_SPEED = 450; --maximal speed of player character
	GP_DEADZONE = 0.2; --gamepad deadzone

	SIM_DT = SIM_DT,

	TILESIZE = TILESIZE,

	camera = {
		MOVE_SPEED = 5.0,
		SCALE_SPEED = 10.0,
		MAX_SCALE = 1.5,
		PLAYER_MARGIN = 3.5 * TILESIZE,
		VIEW_OFFSET = 2*TILESIZE
	},

	maps = {
		MAX_SPRITES = 10000
	},

	player = {
		WALL_BOUNCE = 0.0,
	},

	DOOR_DEADTIME = 0.2,

	FALL_TURN_SPEED = 4.5,
	FALL_DURATION = 1.5,
	FALL_SPEED = 2.0 * TILESIZE,
	PLAYER_SHOVE_DIST = 2.5 * TILESIZE,
	PLAYER_SHOVE_ANGLE = 60.0 / 180.0 * math.pi,
	SHOVE_ANIM_DURATION = 0.2,
	SHOVE_AMOUNT = TILESIZE * 1.1
}