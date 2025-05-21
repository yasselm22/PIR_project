import("stdfaust.lib");

frequency_shifter(x) = x * gain <: (shifter_up, shifter_down) : mix_control
with {
    shift = hslider("[2]shift[unit:Hz][style:knob]", 100, 0, 4000, 10);
    gain = hslider("[1]level[style:knob]", 0.5, 0, 1, 0.01); 
    mix = hslider("[3]mix[style:knob]", 0.5, 0, 1, 0.01);
    
    carrier_up = os.osc(shift);
    carrier_down = os.osc(shift) : *(2*ma.PI) : sin;
    
    shifter_up(x) = x * carrier_up;
    shifter_down(x) = x * carrier_down;
    
    mix_control(up, down) = up * mix + down * (1 - mix);
    
};

process = hgroup("Frequency shifter", frequency_shifter, frequency_shifter);
