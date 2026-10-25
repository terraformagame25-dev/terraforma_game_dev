function Script1(){
	// Base resolution (your pixel art's native size)
	global.base_w = 320;
	global.base_h = 180;

	// Get display size
	var _display_w = display_get_width();
	var _display_h = display_get_height();

	// Find the LARGEST integer scale that fits
	var _scale_x = floor(_display_w / global.base_w);
	var _scale_y = floor(_display_h / global.base_h);
	var _scale = max(1, min(_scale_x, _scale_y));

	// Set window to exact integer multiple
	window_set_size(global.base_w * _scale, global.base_h * _scale);
	window_center();

	// Set application surface to match window
	surface_resize(application_surface, window_get_width(), window_get_height());

	// Turn off filtering (the #1 rule)
	gpu_set_texfilter(false);
}