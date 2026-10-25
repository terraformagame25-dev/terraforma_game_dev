depth = DEPTH.UNITS;

// === Position (set by scr_spawn_unit) ===
grid_x = 0;
grid_y = 0;
x = 0;
y = 0;

// safety net — initialize grid coords from current position
if (grid_x == 0 && grid_y == 0 && (x != 0 || y != 0))
{
    grid_x = floor(x / obj_world.tile_size);
    grid_y = floor(y / obj_world.tile_size);
}

// === Type (set by scr_apply_unit_type) ===
unit_type = "villager";
spr_idle  = spr_human_villager_idle;
spr_walk  = spr_human_villager_walk;

// === Leader layered sprites ===
spr_body_idle  = -1;
spr_body_walk  = -1;
spr_tunic_idle = -1;
spr_tunic_walk = -1;

// === Animation ===
state        = "idle";
facing       = 1;
sprite_index = spr_human_villager_idle;
image_speed  = 0.5;
image_index  = 0;

// === Movement ===
move_speed = 0.5;

// === Path ===
walk_path  = [];
walk_index = 0;
path_allow_res = false;

// === Wander AI ===
wander_radius      = 10;
wander_pause_timer = 0;
wander_pause_min   = 15;
wander_pause_max   = 45;

// === Pathfinding stagger ===
path_cooldown = irandom_range(15, 60);

// === Village membership ===
village_id = -1;
kingdom_id = -1;

// === Leadership ===
is_leader       = false;
leader_anchor_x = -1;
leader_anchor_y = -1;

// === Faction stance ===
is_hostile = false;

// === Explorer seek ===
seek_target_x = -1;
seek_target_y = -1;
seek_cooldown = 0;

// === Miner harvest state ===
harvest_target_x = -1;
harvest_target_y = -1;
harvest_timer    = 0;
harvest_required = 120;

// === Builder state ===
build_target_id = noone;


