// World position under the mouse, before zoom changes
var _mouse_world_x = camera_x + (device_mouse_x_to_gui(0) - view_xport[0]) / camera_zoom;
var _mouse_world_y = camera_y + (device_mouse_y_to_gui(0) - view_yport[0]) / camera_zoom;

// Apply zoom
camera_zoom = clamp(camera_zoom / 1.1, camera_zoom_min, camera_zoom_max);

// Re-anchor camera so the same world point stays under the mouse
camera_x = _mouse_world_x - (device_mouse_x_to_gui(0) - view_xport[0]) / camera_zoom;
camera_y = _mouse_world_y - (device_mouse_y_to_gui(0) - view_yport[0]) / camera_zoom;