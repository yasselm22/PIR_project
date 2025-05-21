import("stdfaust.lib");

frequency_shifter(x) = x * gain <: (shifter_up, shifter_down) : mix_control
with {
    shift_knob = hgroup("Main parameters", hslider("[2]shift[unit:Hz][style:knob]", 100, 0, 4000, 10));
    gain_knob = hgroup("Main parameters", hslider("[1]level[style:knob]", 0.5, 0, 1, 0.01)); 
    mix_knob = hgroup("Main parameters", hslider("[3]mix[style:knob]", 0.5, 0, 1, 0.01));

    shift_mod = hgroup("Modulation parameters", hslider("[2]shift mod[style:knob]", 0, 0, 1, 0.01));
    gain_mod = hgroup("Modulation parameters", hslider("[1]gain mod[style:knob]", 0, 0, 1, 0.01));
    mix_mod = hgroup("Modulation parameters", hslider("[3]mix mod[style:knob]", 0, 0, 1, 0.01));

    shift_lfo = (os.osc(0.2)+1)*2000;
    gain_lfo = (os.osc(0.2)+1)/2;
    mix_lfo = (os.osc(0.2)+1)/2;
    
    shift = shift_knob + shift_mod*shift_lfo : min(4000);
    gain = gain_knob + gain_mod*gain_lfo : min(1);
    mix = mix_knob + mix_mod*mix_lfo : min(1);

    carrier_up = os.osc(shift);
    carrier_down = os.osc(shift) : *(2*ma.PI) : sin;
    
    shifter_up(x) = x * carrier_up;
    shifter_down(x) = x * carrier_down;
    
    mix_control(up, down) = up * mix + down * (1 - mix);
    
};

process = hgroup("Frequency shifter", frequency_shifter, frequency_shifter);