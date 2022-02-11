-- name: TauntsV2
-- incompatible:
-- description: So uh... Taunts!  \n\D-Down = Shivering \n\D-Up = Cough\n\D-Left = Backflip land\n\D-Right = Sleep\n\L + D-Down = Hard KB\n\L + D-Up = Unlocking Star Door\n\L + D-Left = Shocked\n\And L + D-Right = Fade In

function mario_update(m)
	if (m.controller.buttonDown & D_JPAD) ~= 0 then
		set_mario_action(m, ACT_SHIVERING, 0)
    end
	
	if (m.controller.buttonDown & U_JPAD) ~= 0 then
		set_mario_action(m, ACT_COUGHING, 0)
    end
	
	if (m.controller.buttonDown & L_JPAD) ~= 0 then
		set_mario_action(m, ACT_BACKFLIP_LAND, 0)
	end
	
	if (m.controller.buttonDown & R_JPAD) ~= 0 then
		set_mario_action(m, ACT_START_SLEEPING, 0)
	end
	
	if (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonDown & D_JPAD) ~= 0 then
		set_mario_action(m, ACT_HARD_BACKWARD_GROUND_KB, 0)
    end
	
	if (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonDown & U_JPAD) ~= 0 then
		set_mario_action(m, ACT_UNLOCKING_STAR_DOOR, 0)
    end
	
	if (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonDown & L_JPAD) ~= 0 then
		set_mario_action(m, ACT_SHOCKED, 0)
    end
	
	if (m.controller.buttonDown & L_TRIG) ~= 0 and (m.controller.buttonDown & R_JPAD) ~= 0 then
		set_mario_action(m, ACT_TELEPORT_FADE_IN, 0)
    end
end

hook_event(HOOK_MARIO_UPDATE, mario_update)