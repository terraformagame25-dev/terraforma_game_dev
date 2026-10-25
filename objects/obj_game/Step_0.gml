// ============================================================
// WASD movement
// ============================================================
var _move_x = 0;
var _move_y = 0;

if (keyboard_check(ord("W"))) _move_y -= 1;
if (keyboard_check(ord("A"))) _move_x -= 1;
if (keyboard_check(ord("S"))) _move_y += 1;
if (keyboard_check(ord("D"))) _move_x += 1;

camera_x += _move_x * camera_speed;
camera_y += _move_y * camera_speed;

// ============================================================
// Mouse drag (right button)
// ============================================================
if (mouse_check_button_pressed(mb_right))
{
    drag_start_mouse_x  = device_mouse_x_to_gui(0);
    drag_start_mouse_y  = device_mouse_y_to_gui(0);
    drag_start_camera_x = camera_x;
    drag_start_camera_y = camera_y;
}

if (mouse_check_button(mb_right))
{
    var _delta_x = device_mouse_x_to_gui(0) - drag_start_mouse_x;
    var _delta_y = device_mouse_y_to_gui(0) - drag_start_mouse_y;

    camera_x = drag_start_camera_x - _delta_x / camera_zoom;
    camera_y = drag_start_camera_y - _delta_y / camera_zoom;
}

// ============================================================
// Debug: unit count
// ============================================================
if (keyboard_check_pressed(ord("C")))
{
    show_debug_message("Unit count: " + string(instance_number(obj_unit)));
}

// ============================================================
// Mouse → grid tile conversion
// ============================================================
var _cam = view_camera[0];

var _vx = view_xport[0];
var _vy = view_yport[0];
var _vw = view_wport[0];
var _vh = view_hport[0];

var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

var _mx = device_mouse_x_to_gui(0);
var _my = device_mouse_y_to_gui(0);

var _nx = (_mx - _vx) / _vw;
var _ny = (_my - _vy) / _vh;

var _world_x = _cam_x + _nx * _cam_w;
var _world_y = _cam_y + _ny * _cam_h;

var _click_gx = floor(_world_x / obj_world.tile_size);
var _click_gy = floor(_world_y / obj_world.tile_size);

// ============================================================
// SPAWN — left click
// ============================================================
// Plain click:      1 villager
// Shift + click:    10 villagers
// Alt + click:      50 villagers (mass spawn for testing)
// ============================================================
if (mouse_check_button_pressed(mb_left))
{
    var _type  = "villager";
    var _count = 1;

    if (keyboard_check(vk_shift))
    {
        _count = 100;
    }
    else if (keyboard_check(vk_control))
    {
        _type  = "villager";
        _count = 1;
    }
    else if (keyboard_check(vk_alt))
    {
        _count = 50;
    }

    repeat (_count)
    {
        scr_spawn_unit(_click_gx, _click_gy, _type);
    }
}

// ============================================================
// Debug: spawn specific types with number keys
// ============================================================
if (keyboard_check_pressed(ord("1")))
{
    scr_spawn_unit(_click_gx, _click_gy, "villager");
}
if (keyboard_check_pressed(ord("2")))
{
    scr_spawn_unit(_click_gx, _click_gy, "soldier");
}
if (keyboard_check_pressed(ord("3")))
{
    scr_spawn_unit(_click_gx, _click_gy, "farmer");
}
if (keyboard_check_pressed(ord("5")))
{
    scr_spawn_unit(_click_gx, _click_gy, "leader");
}
if (keyboard_check_pressed(ord("6")))
{
    scr_spawn_unit(_click_gx, _click_gy, "miner");
}


// === Debug: print village stockpiles ===
if (keyboard_check_pressed(ord("K")))
{
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];
        show_debug_message("Village " + string(_v.id)
            + " | wood=" + string(_v.resources.wood) + "/" + string(_v.resource_caps.wood)
            + " stone=" + string(_v.resources.stone) + "/" + string(_v.resource_caps.stone)
            + " pop=" + string(array_length(_v.member_ids)));
    }
}

if (keyboard_check_pressed(ord("K")))
{
    for (var _i = 0; _i < array_length(global.villages); _i++)
    {
        var _v = global.villages[_i];

        var _soldiers  = 0;
        var _farmers   = 0;
        var _miners    = 0;
        var _builders  = 0;
        var _leaders   = 0;
        var _villagers = 0;
        var _other     = 0;

        for (var _mi = 0; _mi < array_length(_v.member_ids); _mi++)
        {
            var _u = _v.member_ids[_mi];
            if (!instance_exists(_u)) continue;

            switch (_u.unit_type)
            {
                case "soldier":  _soldiers++;  break;
                case "farmer":   _farmers++;   break;
                case "miner":    _miners++;    break;
                case "builder":  _builders++;  break;
                case "leader":   _leaders++;   break;
                case "villager": _villagers++; break;
                default:         _other++;     break;
            }
        }

        var _total = _soldiers + _farmers + _miners + _builders + _leaders + _villagers + _other;

        show_debug_message("=== Village " + string(_v.id)
            + " (" + string(_v.name) + ") pop=" + string(_total) + " ===");
        show_debug_message("  soldiers="  + string(_soldiers));
        show_debug_message("  farmers="   + string(_farmers));
        show_debug_message("  miners="    + string(_miners));
        show_debug_message("  builders="  + string(_builders));
        show_debug_message("  leaders="   + string(_leaders));
        show_debug_message("  villagers=" + string(_villagers));
        if (_other > 0) show_debug_message("  other=" + string(_other));
    }
}
