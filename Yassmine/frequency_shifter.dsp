import("stdfaust.lib");

//-------------------------------frequency shifter sans widget modulation----------------------------------
frequency_shifter = _<: shifter, shifter
with {
    shift = hslider("[2]shift[unit:Hz][style:knob]", 500, 50, 4000, 0.1);
    gain = hslider("[1]gain[style:knob]", 5, 0, 10, 0.1); 
    mix = hslider("[3]mix[style:knob]", 5, 0, 10, 0.1);
    
    modulated_up(x) = x*os.osc(shift);
    modulated_down(x) = x*os.osc(-shift);

    shifter(x) = (modulated_up(x)*mix/10 + modulated_down(x)*(10-mix)/10)*gain/10 : ef.cubicnl(0.8, 0.0);
};

process = hgroup("Frequency Shifter", frequency_shifter);

//-------------------------------frequency shifter avec widget modulation----------------------------------
frequency_shifter = _<: shifter, shifter
with {
    shift = hslider("shift[unit:Hz][style:knob]", 500, 50, 4000, 0.1);
    gain = hslider("gain[style:knob]", 5, 0, 10, 0.1); 
    mix = hslider("mix[style:knob]", 5, 0, 10, 0.1);
    
    modulated_up(x) = x*os.osc(shift);
    modulated_down(x) = x*os.osc(-shift);

    shifter(x) = (modulated_up(x)*mix/10 + modulated_down(x)*(10-mix)/10)*gain/10 : ef.cubicnl(0.8, 0.0);
};

shift_lfo = (os.osc(0.2)+1)*1975+50;
gain_lfo = os.osc(0.2)*5+5;
mix_lfo = os.osc(0.2)*5+5;

process = ["shift":shift_lfo, "gain":gain_lfo, "mix":mix_lfo -> frequency_shifter];