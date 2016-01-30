-- psssh
TILESIZE = 32
SIM_DT = 1/60.0

const = {
	SIM_DT = SIM_DT,

	TILESIZE = TILESIZE,

	camera = {
		MOVE_SPEED = 0.9,
		SCALE_SPEED = 4.9,
		MAX_SCALE = 1/2.0,
		PLAYER_MARGIN = 0 * TILESIZE,
		VIEW_OFFSET = 10*TILESIZE
	},

	maps = {
		MAX_SPRITES = 10000
	},

	PLAYER_SPEED = 100, --maximal speed of player character
	GP_DEADZONE = 0.2, --gamepad deadzone
}