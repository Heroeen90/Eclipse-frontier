extends Node

# Game Settings
const GAME_TITLE = "Eclipse Frontier"
const GAME_VERSION = "0.1.0"
const TARGET_FPS = 60
const MOBILE_OPTIMIZATION = true

# Player Constants
const PLAYER_MAX_HEALTH = 100
const PLAYER_MAX_ENERGY = 100
const PLAYER_SPEED = 200
const PLAYER_SPRINT_SPEED = 350
const PLAYER_SPRINT_ENERGY_DRAIN = 30
const PLAYER_REGEN_RATE = 5
const PLAYER_ENERGY_REGEN_RATE = 8

# Experience and Levels
const MAX_LEVEL = 50
const BASE_EXP_REQUIRED = 100
const EXP_SCALE_FACTOR = 1.15

# Resource Limits
const MAX_INVENTORY_SLOTS = 30
const MAX_STORAGE_CAPACITY = 500
const MAX_BUILDING_COUNT = 10

# Building Constants
const BUILDING_PLACEMENT_RANGE = 300
const BUILDING_BUILD_TIME = 5.0  # seconds
const BUILDING_BASE_HEALTH = 100

# Resource Spawn
const RESOURCE_SPAWN_RADIUS = 800
const RESOURCE_RESPAWN_TIME = 30.0  # seconds
const MAX_RESOURCES_ON_MAP = 20

# Enemy Constants
const ENEMY_SPAWN_DISTANCE = 500
const ENEMY_DESPAWN_DISTANCE = 1000
const MAX_ENEMIES_SPAWNED = 15

# UI Constants
const UI_ANIMATION_SPEED = 0.3
const BUTTON_PRESS_SCALE = 0.95

# Save System
const SAVE_FILE_PATH = "user://"
const SAVE_FILE_NAME = "game_save.dat"
const BACKUP_SAVE_NAME = "game_save_backup.dat"
const AUTOSAVE_INTERVAL = 300.0  # 5 minutes
const SAVE_ENCRYPTION_ENABLED = true

# Difficulty Multipliers
const DIFFICULTY_EASY = 0.75
const DIFFICULTY_NORMAL = 1.0
const DIFFICULTY_HARD = 1.5
const DIFFICULTY_HARDCORE = 2.0

# Colors
const COLOR_COMMON = Color.WHITE
const COLOR_RARE = Color.CYAN
const COLOR_EPIC = Color.MEDIUM_PURPLE
const COLOR_LEGENDARY = Color.GOLD

# Log Levels
const LOG_LEVEL_DEBUG = 0
const LOG_LEVEL_INFO = 1
const LOG_LEVEL_WARNING = 2
const LOG_LEVEL_ERROR = 3
const LOG_LEVEL_CRITICAL = 4
