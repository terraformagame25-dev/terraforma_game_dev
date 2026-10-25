global.villages = [];
global.kingdoms = [];

// How often to scan for new villages (in frames)
scan_interval = 60;   // once per second at 60fps
scan_timer    = scan_interval;
reproduction_timer = 0;

depth = DEPTH.BORDERS;