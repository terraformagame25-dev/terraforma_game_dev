// === World pixel dimensions ===
var _world_px_w = obj_world.world_width  * obj_world.tile_size;
var _world_px_h = obj_world.world_height * obj_world.tile_size;

// === View size = base / zoom ===
var _view_w = camera_base_w / camera_zoom;
var _view_h = camera_base_h / camera_zoom;

// === Clamp camera so it stays inside the world ===
camera_x = clamp(camera_x, 0, max(0, _world_px_w - _view_w));
camera_y = clamp(camera_y, 0, max(0, _world_px_h - _view_h));

// === Apply to viewport ===
camera_set_view_pos (view_camera[0], camera_x, camera_y);
camera_set_view_size(view_camera[0], _view_w,  _view_h);