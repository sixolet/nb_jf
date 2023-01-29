local mod = require 'core/mods'

local JF_I2C_FREQ = 0.02

if note_players == nil then
    note_players = {}
end

function add_kit_player()
    local player = {
        counts = {0, 0, 0, 0, 0, 0}
    }

    function player:note_on(note, vel)
        local n = (note - 1)%6 + 1
        self.counts[n] = self.counts[n] + 1
        crow.ii.jf.vtrigger(n, 8*vel)
    end

    function player:note_off(note)
        local n = (note - 1)%6 + 1
        self.counts[n] = self.counts[n] - 1
        if self.counts[n] < 0 then self.counts[n] = 0 end
        if self.counts[n] <= 0 then
            crow.ii.jf.trigger((note - 1)%6 + 1, 0)
        end
    end

    function player:modulate(val)
        crow.ii.jf.transpose(-2*val)
    end

    function player:describe()
        return {
            name = "jf kit",

            supports_bend = false,
            supports_slew = false,
            modulate_description = "time",
            style = "kit",
        }
    end

    function player:stop_all()
        crow.ii.jf.trigger(0, 0)
    end

    function player:delayed_active()
        crow.ii.jf.mode(0)
    end

    note_players["jf kit"] = player
end

function add_mono_player(idx)
    local player = {
        count = 0
    }

    function player:add_params()
        params:add_group("nb_jf_n_"..idx, "jf n "..idx, 1)
        params:add_control("nb_jf_slew_"..idx, "slew", controlspec.new(0, 1, 'lin', 0, 0, 's', 0.001))
        params:hide("nb_jf_n_"..idx)
    end

    function player:note_on(note, vel)
        self.count = self.count + 1
        self.old_v8 = player.cur_v8
        self.v8 = (note - 60) / 12
        local v_vel = vel * 5
        local slew = params:get("nb_jf_slew_"..idx)
        if slew == 0 or self.old_v8 == nil or self.old_v8 == self.v8 then
            crow.ii.jf.play_voice(idx, player.v8, v_vel)
            self.cur_v8 = player.v8
        else
            if player.routine ~= nil then
                clock.cancel(player.routine)
            end
            crow.ii.jf.vtrigger(idx, v_vel)
            player.routine = clock.run(function()
                local elapsed = 0
                while elapsed < slew do
                    elapsed = elapsed + JF_I2C_FREQ
                    if elapsed > slew then 
                        elapsed = slew
                    end
                    self.cur_v8 = (elapsed/slew)*player.v8 + (1 - elapsed/slew)*player.old_v8
                    crow.ii.jf.pitch(idx, player.cur_v8)
                    clock.sleep(JF_I2C_FREQ)
                end
            end)
        end
    end

    function player:set_slew(s)
        params:set("nb_jf_slew_"..idx, s)
    end

    function player:note_off(note)
        self.count = self.count - 1
        if self.count < 0 then self.count = 0 end
        if self.count == 0 then
            crow.ii.jf.trigger(idx, 0)
        end
    end

    function player:describe(note)
        return {
            name = "jf n "..idx,
            supports_bend = false,
            supports_slew = true,
            modulate_description = "unsupported",
        }
    end

    function player:stop_all()
        crow.ii.jf.trigger(0, 0)
    end

    function player:delayed_active()
        crow.ii.jf.mode(1)
        params:show("nb_jf_n_"..idx)
        _menu.rebuild_params()
    end

    function player:inactive()
        self.is_active = false
        if self.active_routine ~= nil then
            clock.cancel(self.active_routine)
        end
        params:hide("nb_jf_n_"..idx)
        _menu.rebuild_params()
    end    

    note_players["jf n "..idx] = player
end

function add_unison_player()
    local player = {
        count = 0
    }

    function player:add_params()
        params:add_group("nb_jf_unison", "jf unison", 1)
        params:add_control("nb_jf_unison_detune", "detune", controlspec.new(0, 100, 'lin', 0, 0, 'c', 0.01))
        params:hide("nb_jf_unison")
    end

    function player:note_on(note, vel)
        self.count = self.count + 1        
        self.v8 = (note - 60) / 12
        local v_vel = vel * 5
        local detune = params:get("nb_jf_unison_detune")
        for i=1,6 do
            crow.ii.jf.play_voice(i, self.v8 + (detune/1200)*(math.random() - 0.5) , v_vel/2)
        end
    end

    function player:note_off(note)
        self.count = self.count - 1
        if self.count < 0 then self.count = 0 end
        if self.count == 0 then
            crow.ii.jf.trigger(0, 0)
        end
    end

    function player:describe(note)
        return {
            name = "jf unison",
            supports_bend = false,
            supports_slew = false,
            modulate_description = "unsupported",
        }
    end

    function player:stop_all()
        crow.ii.jf.trigger(0, 0)
    end

    function player:delayed_active()
        crow.ii.jf.mode(1)
        params:show("nb_jf_unison")
        _menu.rebuild_params()
    end

    function player:inactive()
        self.is_active = false
        if self.active_routine ~= nil then
            clock.cancel(self.active_routine)
        end
        params:hide("nb_jf_unison")
        _menu.rebuild_params()
    end    

    note_players["jf unison"] = player
end

function add_poly_player()
    local player = {
    }

    function player:note_on(note, vel)
        local v8 = (note - 60)/12
        local v_vel = vel * 5
        crow.ii.jf.play_note(v8, v_vel)
    end

    function player:note_off(note)
        local v8 = (note - 60)/12
        local v_vel = 0
        crow.ii.jf.play_note(v8, v_vel)
    end

    function player:describe(note)
        return {
            name = "jf poly",
            supports_bend = false,
            supports_slew = false,
            modulate_description = "unsupported",
        }
    end

    function player:stop_all()
        crow.ii.jf.trigger(0, 0)
    end

    function player:delayed_active()
        crow.ii.jf.mode(1)
    end

    note_players["jf poly"] = player
end

mod.hook.register("script_pre_init", "nb jf pre init", function()
    for n=1,6 do
        add_mono_player(n)
    end
    add_unison_player()
    add_poly_player()
    add_kit_player()
end)
