import("stdfaust.lib");

ma = library("maths.lib");
ba = library("basics.lib");
si = library("signals.lib");
os = library("oscillators.lib");
de = library("delays.lib");

process = ["Auto LFO Rate":*((os.osc(0.5)+1)/2), "Auto LFO Depth":*((os.osc(0.5)+1)/2),  "Auto Feedback":*((os.osc(0.5)+1)/2), "Auto Mix":*((os.osc(0.5)+1)/2), "Auto ModRange":*((os.osc(0.5)+1)/2) -> flanger329(1)];

//process = flanger329(1);

flanger329(n) = vgroup("%n.329_FLANGER", ba.bypass2(bypass, par(i, 2, flanger_core)))
with {
  
    pots_group(x) = hgroup("[1] Contrôles Manuels", x);
    // Manual controls
    lfoRate_m   = pots_group(hslider("[1] LFO Rate [unit:Hz] [style:knob]", 0.2, 0.01, 10.0, 0.01));
    lfoDepth_m  = pots_group(hslider("[2] LFO Depth [style:knob]", 0.7, 0, 1, 0.01));
    feedback_m  = pots_group(hslider("[3] Feedback [style:knob]", 0.3, 0, 0.99, 0.01));
    mix_m       = pots_group(hslider("[4] Mix Dry/Wet [style:knob]", 0.5, 0, 1, 0.01));
    modRange_m  = pots_group(hslider("[5] Modulation Range [unit:Hz] [style:knob]", 300, 0, 1000, 1));
    outLevel = pots_group(hslider("[6] Output Level [unit:dB] [style:knob]", 0, -60, 10, 0.1) : ba.db2linear : si.smoo);
    bypass   = pots_group(checkbox("[7] Bypass [tooltip: Désactive le module]"));


    checks_group(x) = hgroup("[2] Modes Auto", x);
    // Auto-mode switches
    autoRate    = checks_group(checkbox("[A1] Auto LFO Rate"));
    autoDepth   = checks_group(checkbox("[A2] Auto LFO Depth"));
    autoFB      = checks_group(checkbox("[A3] Auto Feedback"));
    autoMix     = checks_group(checkbox("[A4] Auto Mix"));
    autoModR    = checks_group(checkbox("[A5] Auto ModRange"));

    // Auto LFOs
    lfoRate_a   = (os.osc(0.03)+1)/2 * (10.0 - 0.01) + 0.01;
    lfoDepth_a  = (os.osc(0.02)+1)/2 * 1.0;
    feedback_a  = (os.osc(0.015)+1)/2 * 0.99;
    mix_a       = (os.osc(0.01)+1)/2 * 1.0;
    modRange_a  = (os.osc(0.025)+1)/2 * 1000;

    // Selection (manual ou auto)
    lfoRate     = si.smoo((1 - autoRate) * lfoRate_m + autoRate * lfoRate_a);
    lfoDepth    = si.smoo((1 - autoDepth) * lfoDepth_m + autoDepth * lfoDepth_a);
    feedback    = si.smoo((1 - autoFB) * feedback_m + autoFB * feedback_a);
    mix         = si.smoo((1 - autoMix) * mix_m + autoMix * mix_a);
    modRange    = si.smoo((1 - autoModR) * modRange_m + autoModR * modRange_a);

    // LFO Modulation (triangle ou changer)
    lfo = os.triangle(lfoRate) * lfoDepth;
    baseFreq = 400;
    modFreq = baseFreq + (lfo * modRange);

    // Convert to delay in samples
    modDelay = ma.SR / modFreq;

    // Flanger: 2 delay stages
    stage(d) = de.delay(2048, d);
    flanger_chain = stage(modDelay) : stage(modDelay);

    flanger_core = x : (+ ~ *(feedback)) : flanger_chain <: x, _ : mix_drywet : *(outLevel)
    with {
        x = _;
    };

    // Dry/wet mix
    mix_drywet(wet) = dry_with(wet)
    with {
        dry_with(w) = dry * x + wet * y
        with {
            dry = 1 - mix;
            x = _;
            y = w;
        };
    };
};
