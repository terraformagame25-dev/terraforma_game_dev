if (global.is_paused) exit;

scan_timer--;
if (scan_timer <= 0)
{
    scan_timer = scan_interval;
    scr_try_form_villages();
}

reproduction_timer++;
if (reproduction_timer >= 300)   // 5 sec at 60 fps
{
    reproduction_timer = 0;
    scr_try_reproduction();
}
// Find the unaffiliated villager with the lowest ID (the lead)
global.village_founder_id = noone;
global.village_founder_x  = -1;
global.village_founder_y  = -1;

var _lowest_id = 9999999;

with (obj_unit)
{
    // Changed from "explorer" to "villager"
    if (unit_type != "villager") continue;
    if (village_id != -1)        continue;
    
    if (id < _lowest_id)
    {
        _lowest_id = id;
        global.lead_explorer_id = id;
        global.lead_explorer_x = grid_x;
        global.lead_explorer_y = grid_y;
    }
}

// Change game speed (60 is normal, 180 is 3x)
if (keyboard_check_pressed(vk_f1)) game_set_speed(60, gamespeed_fps); // Normal
if (keyboard_check_pressed(vk_f2)) game_set_speed(120, gamespeed_fps); // 2x
if (keyboard_check_pressed(vk_f3)) game_set_speed(180, gamespeed_fps); // 3x
if (keyboard_check_pressed(vk_f4)) game_set_speed(300, gamespeed_fps); // 5x