depth = DEPTH.UI;

global.game_speed = 1;

// === Query monitor ===
var _mon_w = display_get_width();
var _mon_h = display_get_height();

// === Window fills monitor ===
window_set_size(_mon_w, _mon_h);
window_center();

// === Viewport fills window ===
view_wport[0] = _mon_w;
view_hport[0] = _mon_h;

// === Camera base — fixed height, width derived from monitor aspect ===
// Height is our "how many world pixels tall is the view" choice.
// Width adapts so aspect always matches the monitor.
camera_base_h = 800;                                       // tune this for feel
camera_base_w = round(camera_base_h * (_mon_w / _mon_h));

// === Remaining camera setup ===
camera_x = 0;
camera_y = 0;
camera_speed = 15;

drag_start_mouse_x  = 0;
drag_start_mouse_y  = 0;
drag_start_camera_x = 0;
drag_start_camera_y = 0;

camera_zoom     = 1.0;
camera_zoom_min = 1.0;
camera_zoom_max = 8.0;

// === Center on world ===
var _world_px_w = obj_world.world_width  * obj_world.tile_size;
var _world_px_h = obj_world.world_height * obj_world.tile_size;

camera_x = _world_px_w * 0.5 - (camera_base_w / camera_zoom) * 0.5;
camera_y = _world_px_h * 0.5 - (camera_base_h / camera_zoom) * 0.5;

// === Crisp pixels ===
gpu_set_texfilter(false);