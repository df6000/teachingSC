(
// Basic drum kit

SynthDef("hihat", {arg out = 0, amp = 0.5, att = 0.01, rel = 0.2, ffreq = 6000, pan = 0;
	var env, snd;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd = WhiteNoise.ar;
	snd = HPF.ar(in: snd, freq: ffreq, mul: env);
	Out.ar(out, Pan2.ar(snd, pan));
}).add;

SynthDef("snare", {arg out = 0, amp = 0.1, sinfreq = 180, att = 0.01, rel = 0.2, ffreq = 2000, pan = 0;
	var env, snd1, snd2, sum;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	snd1 = HPF.ar(
		in: WhiteNoise.ar,
		freq: ffreq,
		mul: env
	);
	snd2 = SinOsc.ar(freq: sinfreq, mul: env);
	sum = snd1 + snd2;
	Out.ar(out, Pan2.ar(snd2, pan));
}).add;

SynthDef("kick", {arg out = 0, amp = 0.3, sinfreq = 60, glissf = 0.9, att = 0.01, rel = 0.45, pan = 0;
	var env, snd, ramp;
	env = Env.perc(att, rel, amp).kr(doneAction: 2);
	ramp = XLine.kr(
		start: sinfreq,
		end: sinfreq * glissf,
		dur: rel
	);
	snd = SinOsc.ar(freq: ramp, mul: env);
	snd = Pan2.ar(snd, pan);
	Out.ar(out, snd);
}).add;

// Basic saw synth for chords and bass
SynthDef("sawSynth", { arg freq = 440, amp = 0.1, att = 0.1, rel = 2, lofreq = 1000, hifreq = 3000, lin=0.2;
    var env, snd;
    env = Env.perc(
		attackTime: att,
		releaseTime: rel,
		level: amp,
	).kr(doneAction: 2);
    snd = SinOsc.ar(freq: freq * [0.99, 1, 1.001, 1.008], mul: env);
	snd = LPF.ar(
		in: snd,
		freq: LFNoise2.kr(1).range(lofreq, hifreq)
	);
    snd = Splay.ar(snd);
    Out.ar(0, snd);
}).add;

SynthDef("plucking", {arg amp = 0.1, freq = 440, decay = 5, dampen = 0.1;

var env, snd;
env = Env.linen(0, decay, 0).kr(doneAction: 2);
snd = Pluck.ar(
        in: PinkNoise.ar(amp),
        trig: Impulse.kr(0),
        maxdelaytime: 0.1,
        delaytime: freq.reciprocal,
        decaytime: decay,
        coef: dampen);
    Out.ar(0, [snd, snd]);
}).add;
)




// Example


(
Pbind(
	\instrument, "hihat",
	\dur, Pseq([1/2, 1/2, Rest(1/4), 1/16, Rest(1/16), 1/16, Rest(1/16), 1/16, Rest(1/16), 1/16, 1/16, Rest(1/4)], inf),
	\att, 0.05,
	\rel, 0.1,
	\ffreq, Pseq([1000, 600, 9000, 9000, 9000, 9000, 9000], 8),
	\pan, 0,
		\amp, 0.2,
).play;

Pbind(
	\instrument, "snare",
	\dur, 1,
	\att, 0.01,
	\rel, 0.1,
	\sinfreq, 280,
	\ffreq, 2000,
	\amp, 0.1

).play;

Pbind(
	\instrument, "kick",
	\dur, Pseq([1, 1, 1, 1, 1/4, 1/4, 1/4, 1/4, 1/4], inf),
	\att, 0.01,
	\rel, 0.22,
	\sinfreq, Pseq([50, 50, 50 , 50, 70, 70, 70, 70, 50],64),
	\glissf, 0.9,
	\amp, 1,
).play;

Pbind(
    \instrument, "sawSynth",
	\midinote, Pseq([
		[31, 33, 35], [32, 34, 36], [34, 37, 38]], 32),
    \dur, Prand([ 3, 4, 5, 4.5], inf),
	\att, 0.1,
	\rel, Pkey(\dur) + -1,
	\hifreq, 3000,
    \amp, 0.2,
).play;

Pbind(
	\instrument, "sawSynth",
	\midinote, Pseq([52, 42, 42, Rest(3)], inf),
	\dur, Pseq([1/4, 1/4, 1/2, Rest(3)], 80),
	\ctranspose, [0, -12],
	\att, Pseq([0.05, 0.2, 0.2, Rest(3)], inf),
	\rel, 0.5,
	\amp, 0.4,
	\lofreq, 100,
	\hifreq, 1000
).play;

Pbind(
    \instrument, "plucking",
	\degree, Pseq([1, 5, 7, 5], inf),
    \mtranspose, -12,
    \amp, 0.05,
    \decay, Pseq([7, 6, 6, 5, 4, 3, 7, 5, 5], inf),
	\dampen, 0.6,
	\dur, Prand([Rest(8),1/2, 1/2, 1/2, Pn(1/8, 2), Pn(1/8, 4)], 32),
).play;


)


s.record;
s.stopRecording;