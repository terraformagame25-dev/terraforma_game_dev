depth = DEPTH.BUILDINGS;
// === Set by scr_place_construction and scr_try_complete_buildings ===
village_id    = -1;
building_type = "";          // "town_hall", "house_a", "house_b"
building_size = 24;          // 24 or 16
level         = 1;           // advancement era at time of construction
state         = "construction";
footprint_left   = 0;
footprint_top    = 0;
footprint_right  = 0;
footprint_bottom = 0;

// === Default sprite ===
sprite_index = spr_building_construction_24;
image_speed  = 1;
image_index  = 0;

show_debug_message("BUILDING CREATED: type=" + string(building_type) + " x=" + string(x) + " y=" + string(y) + " village_id=" + string(village_id));
