depth = DEPTH.TERRAIN;

// === World Dimensions ===
world_width  = 512;
world_height = 512;
tile_size    = 8;

// === Terrain IDs ===
// 0 = Water
// 1 = Sand
// 2 = Grass
// 3 = Land placeholder (transient)
enum TERRAIN {
	LAND  = 0,
    WATER = 1,
    SAND  = 2,
    GRASS = 3,
}

// === Resource IDs ===
enum RESOURCE {
    NONE  = 0,
    TREE  = 1,
    STONE = 2,
}

// === World seed ===
random_set_seed(irandom_range(1000,9999));

// === Terrain grid ===
terrain_grid = array_create(world_width * world_height, TERRAIN.WATER);

// === Size scaling ===
var _size_scale = world_width / 128;

// === Island parameters ===
var _island_count = max(2, round(irandom_range(2, 4) * _size_scale));

var _island_cx   = array_create(_island_count);
var _island_cy   = array_create(_island_count);
var _island_r    = array_create(_island_count);
var _island_seed = array_create(_island_count);

var _grid_cols = ceil(sqrt(_island_count));
var _grid_rows = ceil(_island_count / _grid_cols);

for (var _i = 0; _i < _island_count; _i++)
{
    var _col = _i mod _grid_cols;
    var _row = _i div _grid_cols;

    var _cell_w = world_width  / _grid_cols;
    var _cell_h = world_height / _grid_rows;

    var _margin = 0.20;

    var _x_min = (_col + _margin)     * _cell_w;
    var _x_max = (_col + 1 - _margin) * _cell_w;
    var _y_min = (_row + _margin)     * _cell_h;
    var _y_max = (_row + 1 - _margin) * _cell_h;

    _island_cx[_i]   = irandom_range(_x_min, _x_max);
    _island_cy[_i]   = irandom_range(_y_min, _y_max);
    _island_r[_i]    = round(irandom_range(22, 32) * sqrt(_size_scale));
    _island_seed[_i] = irandom(10000);
}

// === Pass 1: Carve islands ===
var _noise_scale = 0.06 / sqrt(_size_scale);

for (var tile_y = 0; tile_y < world_height; tile_y++)
{
    for (var tile_x = 0; tile_x < world_width; tile_x++)
    {
        var index = tile_x + tile_y * world_width;

        for (var _ii = 0; _ii < _island_count; _ii++)
        {
            var _dx = tile_x - _island_cx[_ii];
            var _dy = tile_y - _island_cy[_ii];
            var _dist = sqrt(_dx * _dx + _dy * _dy);

            if (_dist > _island_r[_ii] * 2) continue;

            var _falloff = 1 - (_dist / _island_r[_ii]);
            var _noise = scr_noise_2d_octaves(
                tile_x * _noise_scale,
                tile_y * _noise_scale,
                _island_seed[_ii],
                3,
                0.5
            );

            var _land_value = _falloff * 0.6 + (_noise - 0.5) * 0.8;

            if (_land_value > 0.15)
            {
                terrain_grid[index] = TERRAIN.LAND;
                break;
            }
        }
    }
}

// === Pass 2: Classify LAND as Sand (coast) or Grass (inland) ===
var terrain_copy = array_create(world_width * world_height, TERRAIN.WATER);

for (var i = 0; i < array_length(terrain_grid); i++)
{
    terrain_copy[i] = terrain_grid[i];
}

for (var tile_y = 0; tile_y < world_height; tile_y++)
{
    for (var tile_x = 0; tile_x < world_width; tile_x++)
    {
        var index = tile_x + tile_y * world_width;

        if (terrain_grid[index] != TERRAIN.LAND) continue;

        var _left   = (tile_x > 0)                 ? terrain_grid[index - 1]           : TERRAIN.WATER;
        var _right  = (tile_x < world_width - 1)   ? terrain_grid[index + 1]           : TERRAIN.WATER;
        var _up     = (tile_y > 0)                 ? terrain_grid[index - world_width] : TERRAIN.WATER;
        var _down   = (tile_y < world_height - 1)  ? terrain_grid[index + world_width] : TERRAIN.WATER;

        var touching_water =
               _left  == TERRAIN.WATER
            || _right == TERRAIN.WATER
            || _up    == TERRAIN.WATER
            || _down  == TERRAIN.WATER;

        terrain_copy[index] = touching_water ? TERRAIN.SAND : TERRAIN.GRASS;
    }
}

terrain_grid = terrain_copy;

// === Resource grid ===
resource_grid = array_create(world_width * world_height, RESOURCE.NONE);

// === Territory grid ===
// -1 = unclaimed, otherwise = village id that owns the tile
territory_grid = array_create(world_width * world_height, -1);

/*
_tree_scale	Forest character
0.05–0.10	Vast, continent-spanning forests
0.15–0.25	Large forest regions
0.40–0.60	Small woods, clumps, copses
0.80+	Single-tile trees, almost no clustering
_tree_threshold	Density
0.45	Very dense — most grass has trees
0.55	Moderate
0.65	Sparse
0.75	Very sparse — occasional lone trees
*/

// === Resource grid ===
resource_grid = array_create(world_width * world_height, RESOURCE.NONE);
block_grid    = array_create(world_width * world_height, 0);

// Tree noise parameters
var _tree_scale     = 0.55 / sqrt(_size_scale);
var _tree_seed      = irandom(10000) + 1001;
var _tree_threshold = 0.6;

// Stone noise parameters
var _stone_scale     = 0.22 / sqrt(_size_scale);
var _stone_seed      = irandom(10000) + 2002;
var _stone_threshold = 0.58;

for (var tile_y = 0; tile_y < world_height; tile_y++)
{
    for (var tile_x = 0; tile_x < world_width; tile_x++)
    {
        var index = tile_x + tile_y * world_width;
        var _terrain = terrain_grid[index];

        if (_terrain == TERRAIN.WATER) continue;

        // Trees only on grass
        if (_terrain == TERRAIN.GRASS)
        {
            var _tn = scr_noise_2d_octaves(
                tile_x * _tree_scale,
                tile_y * _tree_scale,
                _tree_seed,
                3,
                0.5
            );
            if (_tn > _tree_threshold)
            {
                resource_grid[index] = RESOURCE.TREE;
                block_grid[index]    = 1;
                continue;
            }
        }

        // Stone on grass or sand
        var _sn = scr_noise_2d_octaves(
            tile_x * _stone_scale,
            tile_y * _stone_scale,
            _stone_seed,
            2,
            0.5
        );
        if (_sn > _stone_threshold)
        {
            resource_grid[index] = RESOURCE.STONE;
            block_grid[index]    = 1;
        }
    }
}

// === Terrain sprite lookup ===
terrain_sprite = [
    spr_land_tiles,
    spr_water_tiles,
    spr_sand_tiles,
    spr_grass_tiles,
];

// === Terrain animation clock ===
anim_timer = 0;
anim_speed = 0.15;

global.is_paused = false;