f32 get_additive_y_vel_for_jumps(void);
void mario_bonk_reflection(struct MarioState *, u32);
u32 mario_update_quicksand(struct MarioState *, f32);
u32 mario_push_off_steep_floor(struct MarioState *, u32, u32);
u32 mario_update_moving_sand(struct MarioState *);
u32 mario_update_windy_ground(struct MarioState *);
void stop_and_set_height_to_floor(struct MarioState *);
s32 stationary_ground_step(struct MarioState *);
s32 perform_ground_step(struct MarioState *);
s32 perform_air_step(struct MarioState *, u32);
void set_vel_from_pitch_and_yaw(struct MarioState* m);
