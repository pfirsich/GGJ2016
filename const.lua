-- psssh
TILESIZE = 32
SIM_DT = 1/60.0

const = {

	PLAYER_SPEED = 250; --maximal speed of player character
	GP_DEADZONE = 0.2; --gamepad deadzone

	SIM_DT = SIM_DT,

	TILESIZE = TILESIZE,

	camera = {
		MOVE_SPEED = 10.0,
		SCALE_SPEED = 10.0,
		MAX_SCALE = 1.5,
		PLAYER_MARGIN = 0 * TILESIZE,
		VIEW_OFFSET = 2*TILESIZE
	},

	maps = {
		MAX_SPRITES = 10000
	},
}