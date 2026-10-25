/// @func scr_apply_unit_type(_unit, _type)
/// @desc Sets sprites, speed, behavior, and stats based on unit type.
function scr_apply_unit_type(_unit, _type)
{
    _unit.unit_type = _type;

    // ==========================================
    // 1. BASE DEFAULTS (Every unit starts as a land villager)
    // ==========================================
    _unit.unit_class            = "land";      // "land", "water", "air"
    _unit.can_leave_territory   = false;       // Can they cross the purple border?
    _unit.can_walk_on_resources = false;       // Can they step on trees/rocks?
    _unit.can_walk_on_water     = false;       // Can they swim?
    _unit.can_harvest           = false;
    _unit.can_build             = false;
    _unit.is_leader             = false;
    
    _unit.hp                    = 10;
    _unit.max_hp                = 10;
    _unit.damage                = 0;
    _unit.attack_range          = 0;
    _unit.can_attack_air        = false;

    // ==========================================
    // 2. SPECIFIC OVERRIDES
    // ==========================================
    switch (_type)
    {
        case "villager":
            _unit.spr_idle = spr_human_villager_idle;
            _unit.spr_walk = spr_human_villager_walk;
            _unit.move_speed       = 1.5;
            _unit.wander_radius    = 10;
            _unit.wander_pause_min = 15;
            _unit.wander_pause_max = 30;
            break;

        case "soldier":
            _unit.spr_idle = spr_human_soldier_idle;
            _unit.spr_walk = spr_human_soldier_walk;
            _unit.move_speed       = 2.0;
            _unit.wander_radius    = 25;
            _unit.wander_pause_min = 5;
            _unit.wander_pause_max = 15;
            
            _unit.can_leave_territory = true; // Soldiers can patrol outside
            _unit.hp      = 50;
            _unit.max_hp  = 50;
            _unit.damage  = 10;
            _unit.attack_range = 1; // Melee
            break;

        case "farmer":
            _unit.spr_idle = spr_human_farmer_idle;
            _unit.spr_walk = spr_human_farmer_walk;
            _unit.move_speed       = 1.3;
            _unit.wander_radius    = 8;
            _unit.wander_pause_min = 20;
            _unit.wander_pause_max = 45;
            break;

        case "miner":
            _unit.spr_idle = spr_human_miner_idle;
            _unit.spr_walk = spr_human_miner_walk;
            _unit.move_speed       = 1.4;
            _unit.wander_radius    = 12;
            _unit.wander_pause_min = 15;
            _unit.wander_pause_max = 35;
            
            _unit.can_leave_territory   = true; // Miners leave to gather
            _unit.can_walk_on_resources = true; // Miners can walk on trees/rocks
            _unit.can_harvest           = true;
            break;

        case "builder":
            _unit.spr_idle = spr_human_builder_idle;
            _unit.spr_walk = spr_human_builder_walk;
            _unit.move_speed       = 1.4;
            _unit.wander_radius    = 12;
            _unit.wander_pause_min = 15;
            _unit.wander_pause_max = 35;
            
            _unit.can_build = true;
            break;

        case "leader":
            _unit.spr_body_idle  = spr_human_leader_body_idle;
            _unit.spr_body_walk  = spr_human_leader_body_walk;
            _unit.spr_tunic_idle = spr_human_leader_tunic_idle;
            _unit.spr_tunic_walk = spr_human_leader_tunic_walk;
            _unit.spr_idle = spr_human_leader_body_idle;
            _unit.spr_walk = spr_human_leader_body_walk;
            
            _unit.move_speed       = 1.3;
            _unit.wander_radius    = 5;
            _unit.wander_pause_min = 20;
            _unit.wander_pause_max = 45;
            
            _unit.is_leader = true;
            _unit.hp        = 100;
            _unit.max_hp    = 100;
            break;
            
        // ==========================================
        // FUTURE UNITS GO HERE
        // ==========================================
        case "ship":
            _unit.spr_idle = spr_ship_idle;
            _unit.spr_walk = spr_ship_walk;
            _unit.move_speed = 2.5;
            _unit.unit_class = "water"; // Can only move on water
            _unit.can_leave_territory = true;
            _unit.hp = 200;
            _unit.max_hp = 200;
            _unit.damage = 25;
            _unit.attack_range = 4;
            break;

        case "plane":
            _unit.spr_idle = spr_plane_idle;
            _unit.spr_walk = spr_plane_walk;
            _unit.move_speed = 5.0;
            _unit.unit_class = "air"; // Ignores terrain entirely
            _unit.can_leave_territory = true;
            _unit.hp = 150;
            _unit.max_hp = 150;
            _unit.damage = 50;
            _unit.attack_range = 3;
            _unit.can_attack_air = true;
            break;

        default:
            _unit.spr_idle = spr_human_villager_idle;
            _unit.spr_walk = spr_human_villager_walk;
            _unit.move_speed       = 1.5;
            _unit.wander_radius    = 10;
            _unit.wander_pause_min = 15;
            _unit.wander_pause_max = 30;
            break;
    }

    // ==========================================
    // 3. FINAL SETUP
    // ==========================================
    _unit.sprite_index = _unit.spr_idle;
    _unit.image_index  = 0;

    _unit.harvest_target_x = -1;
    _unit.harvest_target_y = -1;
    _unit.harvest_timer    = 0;

    _unit.build_target_id  = noone;
    
    // Reset pathing so they don't get stuck on an old path
    _unit.walk_path = [];
    _unit.walk_index = 0;
    _unit.path_allow_res = false;
}