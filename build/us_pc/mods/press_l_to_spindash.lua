-- name: Press L to Spindash.
-- incompatible: moveset
-- description: Pretty self-explanatory :/

ACT_SPINDASH =                  (0x037 | ACT_FLAG_STATIONARY | ACT_FLAG_ATTACKING)
ACT_ROLL =                      (0x05B | ACT_FLAG_MOVING | ACT_FLAG_BUTT_OR_STOMACH_SLIDE)

gMarioStateExtras = {}
for i=0,(MAX_PLAYERS-1) do
    gMarioStateExtras[i] = {}
    local m = gMarioStates[i]
    local e = gMarioStateExtras[i]
	e.rotAngle = 0
	e.dashspeed = 0
    e.animFrame = 0
end

function update_roll_sliding_angle(m, accel, lossFactor)
    local floor = m.floor
    local slopeAngle = atan2s(floor.normal.z, floor.normal.x)
    local steepness = math.sqrt(floor.normal.x * floor.normal.x + floor.normal.z * floor.normal.z)

    m.slideVelX = m.slideVelX + accel * steepness * sins(slopeAngle)
    m.slideVelZ = m.slideVelZ + accel * steepness * coss(slopeAngle)

    m.slideVelX = m.slideVelX * lossFactor
    m.slideVelZ = m.slideVelZ * lossFactor

    m.slideYaw = atan2s(m.slideVelZ, m.slideVelX)

    local facingDYaw = m.faceAngle.y - m.slideYaw
    local newFacingDYaw = facingDYaw

    if newFacingDYaw > 0 and newFacingDYaw <= 0x4000 then
        newFacingDYaw = newFacingDYaw - 0x200
        if newFacingDYaw < 0 then newFacingDYaw = 0 end

    elseif newFacingDYaw >= -0x4000 and newFacingDYaw < 0 then
        newFacingDYaw = newFacingDYaw + 0x200
        if newFacingDYaw > 0 then newFacingDYaw = 0 end

    elseif newFacingDYaw > 0x4000 and newFacingDYaw < 0x8000 then
        newFacingDYaw = newFacingDYaw + 0x200
        if newFacingDYaw > 0x8000 then newFacingDYaw = 0x8000 end

    elseif newFacingDYaw > -0x8000 and newFacingDYaw < -0x4000 then
        newFacingDYaw = newFacingDYaw - 0x200
        if newFacingDYaw < -0x8000 then newFacingDYaw = -0x8000 end
    end

    m.faceAngle.y = m.slideYaw + newFacingDYaw

    m.vel.x = m.slideVelX
    m.vel.y = 0.0
    m.vel.z = m.slideVelZ

    mario_update_moving_sand(m)
    mario_update_windy_ground(m)

    --! Speed is capped a frame late (butt slide HSG)
    m.forwardVel = math.sqrt(m.slideVelX * m.slideVelX + m.slideVelZ * m.slideVelZ)
    if m.forwardVel > 100.0 then
        m.slideVelX = m.slideVelX * 100.0 / m.forwardVel
        m.slideVelZ = m.slideVelZ * 100.0 / m.forwardVel
    end

    if newFacingDYaw < -0x4000 or newFacingDYaw > 0x4000 then
        m.forwardVel = m.forwardVel * -1.0
        m.faceAngle.y = m.faceAngle.y + 0x4000
    end

    -- HACK: instead of approaching slideYaw, just set faceAngle to it
    -- this is different than the original Extended Movement... just couldn't figure out the bug
    m.faceAngle.y = m.slideYaw
end

function update_roll_sliding(m, stopSpeed)
    local stopped = 0

    local intendedDYaw = m.intendedYaw - m.slideYaw
    local forward = coss(intendedDYaw)
    local sideward = sins(intendedDYaw)

    --! 10k glitch
    if forward < 0.0 and m.forwardVel >= 0.0 then
        forward = forward * (0.5 + 0.5 * m.forwardVel / 100.0)
    end

    local accel = 4.0
    local lossFactor = 0.994

    local oldSpeed = math.sqrt(m.slideVelX * m.slideVelX + m.slideVelZ * m.slideVelZ)

    --! This is uses trig derivatives to rotate Mario's speed.
    -- In vanilla, it was slightly off/asymmetric since it uses the new X speed, but the old
    -- Z speed. I've gone and fixed it here.
    local angleChange  = (m.intendedMag / 32.0) * 0.6
    local modSlideVelX = m.slideVelZ * angleChange * sideward * 0.05
    local modSlideVelZ = m.slideVelX * angleChange * sideward * 0.05

    m.slideVelX = m.slideVelX + modSlideVelX
    m.slideVelZ = m.slideVelZ - modSlideVelZ

    local newSpeed = math.sqrt(m.slideVelX * m.slideVelX + m.slideVelZ * m.slideVelZ)

    if oldSpeed > 0.0 and newSpeed > 0.0 then
        m.slideVelX = m.slideVelX * oldSpeed / newSpeed
        m.slideVelZ = m.slideVelZ * oldSpeed / newSpeed
    end

    update_roll_sliding_angle(m, accel, lossFactor)

    if m.playerIndex == 0 and mario_floor_is_slope(m) == 0 and m.forwardVel * m.forwardVel < stopSpeed * stopSpeed then
        mario_set_forward_vel(m, 0.0)
        stopped = 1
    end

    return stopped
end

-- This version of rolling was modified from EM's version.
function act_roll(m)
    local e = gMarioStateExtras[m.playerIndex]

    local MAX_NORMAL_ROLL_SPEED = 50.0

    -- e.rotAngle is used for Mario's rotation angle during the roll (persists when going into ACT_ROLL_AIR and back)

    if (m.input & INPUT_A_PRESSED) ~= 0 then
        return set_jumping_action(m, ACT_JUMP, 0)
    end

    if (m.controller.buttonPressed & R_TRIG) ~= 0 and m.actionTimer > 0 then
        m.vel.y = 19.0
        play_mario_sound(m, SOUND_ACTION_TERRAIN_JUMP, 0)


            if m.forwardVel < MAX_NORMAL_ROLL_SPEED then
                mario_set_forward_vel(m, math.min(m.forwardVel + ROLL_BOOST_GAIN, MAX_NORMAL_ROLL_SPEED))
            end

            m.particleFlags = m.particleFlags | PARTICLE_HORIZONTAL_STAR

            -- ! playing this after the call to play_mario_sound seems to matter in making this sound play
            play_sound(SOUND_ACTION_SPIN, m.marioObj.header.gfx.cameraToObject)

        return set_mario_action(m, ACT_BUTT_SLIDE, m.actionArg)
    end

    set_mario_animation(m, MARIO_ANIM_FORWARD_SPINNING)

    if update_roll_sliding(m, 10.0) ~= 0 then
        return set_mario_action(m, ACT_CROUCH_SLIDE, 0)
    end

    common_slide_action(m, ACT_CROUCH_SLIDE, ACT_BUTT_SLIDE, MARIO_ANIM_FORWARD_SPINNING)

    e.rotAngle = e.rotAngle + (0x80 * m.forwardVel)
    if e.rotAngle > 0x10000 then
        e.rotAngle = e.rotAngle - 0x10000
    end
    set_anim_to_frame(m, 10 * e.rotAngle / 0x10000)

    e.dashspeed = 0
    m.actionTimer = m.actionTimer + 1

    return 0
end

function act_spindash(m)
    local e = gMarioStateExtras[m.playerIndex]
	local MAXDASH = 550.0
    local MINDASH = 150.0
	-- Spindash revving
	e.dashspeed = e.dashspeed + 1
	if e.dashspeed < MINDASH then
	   e.dashspeed = MINDASH
	elseif e.dashspeed > MAXDASH then
	   e.dashspeed = MAXDASH
	end
	set_mario_animation(m, MARIO_ANIM_FORWARD_SPINNING)
	set_anim_to_frame(m, e.animFrame)
	if e.animFrame >= m.marioObj.header.gfx.animInfo.curAnim.loopEnd then
       e.animFrame = e.animFrame - m.marioObj.header.gfx.animInfo.curAnim.loopEnd
    end
    if (m.controller.buttonDown & L_TRIG) == 0 then
	   mario_set_forward_vel(m, e.dashspeed)
       return set_mario_action(m, ACT_ROLL, 0)
    end
	m.particleFlags = m.particleFlags | PARTICLE_DUST
	e.animFrame = e.animFrame + (e.dashspeed / 100)
	return 0
end


function mario_update(m)
   local e = gMarioStateExtras[m.playerIndex]
   if m.action == ACT_IDLE or m.action == ACT_WALKING then
      if (m.controller.buttonDown & L_TRIG) ~= 0 then
         return set_mario_action(m, ACT_SPINDASH, 0)
      end
   end
end
-----------
-- hooks --
-----------

hook_event(HOOK_BEFORE_MARIO_UPDATE, before_mario_update)
hook_event(HOOK_MARIO_UPDATE, mario_update)
hook_event(HOOK_ON_SET_MARIO_ACTION, mario_on_set_action)

hook_mario_action(ACT_SPINDASH, act_spindash)
hook_mario_action(ACT_ROLL, act_roll)