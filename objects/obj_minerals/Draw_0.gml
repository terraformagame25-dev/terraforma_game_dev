// === Camera ===
var _cam = view_camera[0];

var _cam_x = camera_get_view_x(_cam);
var _cam_y = camera_get_view_y(_cam);
var _cam_w = camera_get_view_width(_cam);
var _cam_h = camera_get_view_height(_cam);

// === Visible tile range (culled) ===
var _ts = obj_world.tile_size;

var _start_x = max(0, floor(_cam_x / _ts));
var _start_y = max(0, floor(_cam_y / _ts));
var _end_x   = min(obj_world.world_width,  ceil((_cam_x + _cam_w) / _ts) + 1);
var _end_y   = min(obj_world.world_height, ceil((_cam_y + _cam_h) / _ts) + 1);

// === Animation frame from shared timer ===
var _frame = floor(obj_world.anim_timer * 0.25) mod 4;

// === Draw visible stone tiles ===
var _grid = obj_world.resource_grid;
var _w    = obj_world.world_width;

for (var _ty = _start_y; _ty < _end_y; _ty++)
{
    for (var _tx = _start_x; _tx < _end_x; _tx++)
    {
        var _idx = _tx + _ty * _w;
        if (_grid[_idx] != RESOURCE.STONE) continue;

        draw_sprite(
            spr_resource_stone,
            _frame,
            _tx * _ts,
            _ty * _ts
        );
    }
}