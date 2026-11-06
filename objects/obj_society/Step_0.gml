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

// NOTE: the founding beacon (global.village_founder_*) is owned entirely by
// scr_try_form_villages(). The old block that reset it every frame and wrote
// to global.lead_explorer_* has been removed.

// Change game speed (60 is normal, 180 is 3x)
if (keyboard_check_pressed(vk_f1)) game_set_speed(60,  gamespeed_fps); // Normal
if (keyboard_check_pressed(vk_f2)) game_set_speed(120, gamespeed_fps); // 2x
if (keyboard_check_pressed(vk_f3)) game_set_speed(180, gamespeed_fps); // 3x
if (keyboard_check_pressed(vk_f4)) game_set_speed(300, gamespeed_fps); // 5x
