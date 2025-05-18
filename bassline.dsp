import("stdfaust.lib");

cutoff_lfo = os.osc(0.6)*400 + 800;
reso_lfo = os.osc(0.7)*2 + 3;

process = ["Cutoff" : cutoff_lfo, "Resonance" : reso_lfo -> bassline];

bassline = vgroup("Bassline", amplified) with {
    //──────────────────OSCILLATOR──────────────────
    tune = hslider("h:[0]Bassline/[style:knob][0]Tune", 200, 20, 2000, 1) : si.smoo;
    sub_level = hslider("h:[0]Bassline/[style:knob][1]Sub Level", 0.5, 0, 1, 0.01);
    drive = hslider("h:[0]Bassline/[style:knob][2]Drive", 1, 0.01, 10, 0.01); // TODO : FIX OVERDRIVE
    wform = hslider("h:[3]Bassline/Signal[style:menu{'Triangle':0;'Saw':1;'Square':2}]", 0, 0, 2, 1);

    softclip(x) = x - (1.0/3.0) * pow(x,3);
    overdrive(g) = *(g) : softclip : * (1.0/(g*1.0));    


    tri_osc    = os.triangle(tune);
    saw_osc    = os.sawtooth(tune);
    square_osc = os.square(tune);
    sub_osc = os.square(tune/2) * sub_level;
    bassline_osc = (select3(wform, tri_osc, saw_osc, square_osc) + sub_osc) : overdrive(drive);

    //──────────────────FILTER──────────────────
    cutoff = hslider("h:[1]Bassline/[style:knob][0]Cutoff", 800, 50, 5000, 1) : si.smoo;
    resonance = hslider("h:[1]Bassline/[style:knob][1]Resonance", 4.3, 0.1, 10, 0.1) : si.smoo;
    vcf_mode = hslider("h:[1]Bassline/[1][style:radio{'Bandpass':0;'Lowpass':1}][hidden:0]Filter Mode", 0, 0, 1, 1);
    cutoff_cv = hslider("h:[1]Bassline/[style:knob][1]C-OFF CV", 1000, 0, 3000, 1);
    vcf_env = hslider("h:[2]Bassline/[style:knob][1]vcf env", 0.3, 0.01, 2.0, 0.01);
    gate = button("Gate");

    env_vcf = en.ar(0.001, vcf_env, gate);

    gain = 1 + (resonance * 0.1); // Adjust constant to taste
    modulated_cutoff = cutoff+ (env_vcf*cutoff_cv);
    lowpass = fi.resonlp(modulated_cutoff, resonance, gain);
    bandpass = fi.resonbp(modulated_cutoff, resonance, gain);
    vcf = select2(vcf_mode, bandpass, lowpass);

    filtered = bassline_osc <: vcf;

    // VCA
    vca_env = hslider("h:[2]Bassline/[style:knob][2]Decay", 1.3, 0.01, 5.0, 0.01);
    env_vca = en.ar(0.001, vca_env, gate); // Short attack, variable decay

    amplified = filtered * env_vca;
};
