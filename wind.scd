//Pure data patch can be downloaded here
//https://mitpress.mit.edu/books/designing-sound


// RUN FIRST
(
// Initialize buffers, buses. Define utility functions.
if (~windspeed_buffer.isNil, {~windspeed_buffer=Buffer.alloc(s, s.sampleRate*3,1);});
if (~noisebus.isNil, {~noisebus = Bus.audio(s,1);});
if (~left.isNil, {~left=Bus.audio(s,1);});
if (~right.isNil, {~right=Bus.audio(s,1);});


// Convert q to bandwidth
~q_to_bw={
	arg qin;
	var q1st, q2nd, q3rd, q4th;
	q1st = ((2*qin*qin)+1)/(2*qin*qin);
	q2nd =  (q1st*2).pow(2)/4;
	q3rd = sqrt(q2nd-1);
	q4th = q1st+q3rd;
	(1000000*log(q4th)/log(2)).round(0.01)/1000000
};

~fcpan={
	arg sig, pos;
	var align;
	align=pos*0.25-0.25;
	Out.ar(~left, sig*cos((align-0.25)*2pi));
	Out.ar(~right, sig*cos(align*2pi));
};


// SynthDefs
SynthDef.new(\masterSynth, {
	Out.ar(0,In.ar(~left,1)*0.45);
	Out.ar(1,In.ar(~right,1)*0.45);
}).add;

SynthDef.new(\noisegen, {
	var sig;
	sig=WhiteNoise.ar();
	Out.ar(~noisebus,sig)
}).add;

SynthDef.new(\windspeed,{
	var slow, gustout,g1,wsout,mainout,delayed,sig, tapPhase,squall, capture;

	slow=SinOsc.ar(0.1, 0);
	slow=slow+1.0*0.25;

	sig=WhiteNoise.ar();
	sig=OnePole.ar(sig, exp(-2pi * (0.5 * SampleDur.ir)));
	sig=OnePole.ar(sig, exp(-2pi * (0.5 * SampleDur.ir)));
	sig=(sig - OnePole.ar(sig, exp(-2pi * (0 * SampleDur.ir))));
	sig=sig*50.0;

	g1=(slow + 0.5).squared;
	g1=g1-0.125;
	gustout=g1*sig;

	squall=WhiteNoise.ar();
	squall=OnePole.ar(squall, exp(-2pi * (3 * SampleDur.ir)));
	squall=OnePole.ar(squall, exp(-2pi * (3 * SampleDur.ir)));
	squall=(squall- OnePole.ar(sig, exp(-2pi * (0 * SampleDur.ir))))*20.0;

	squall=(max(slow,0.4)-0.4*8).squared*squall;

	wsout=slow+gustout+squall;
	wsout=Clip.ar(wsout,0,1);

	capture= BufWr.ar(wsout, ~windspeed_buffer, Phasor.ar(0,1, 0, BufFrames.ir(~windspeed_buffer),1));

}).add;


SynthDef.new(\buildings, {
	var tapped,noise,mul,clipped,oz;
	tapped=Tap.ar(~windspeed_buffer,1,0);
	tapped=tapped+0.2;
	noise=In.ar(~noisebus);
	mul=tapped*BBandPass.ar(noise,800,~q_to_bw.value(1));
	clipped=Clip.ar(tapped*0.6,0,0.99);
	oz= OneZero.ar(mul,clipped,1);
	~fcpan.value(oz*0.2,0.51);
}).add;


SynthDef(\doorways, {
	arg delay,clip_lo,clip_hi,subtr_1,mult_1,subtr_2,lop_freq,mult_2,add_1,bp_freq,bp_q,fcpan_pos;
	var sig,noise,lop,bp;
	sig=Tap.ar(~windspeed_buffer, 1,delay);
	sig=cos(     (Clip.ar(sig,clip_lo,clip_hi)-subtr_1*mult_1-subtr_2)*2pi);
	lop=OnePole.ar(sig, exp(-2pi * (lop_freq* SampleDur.ir)));
	sig=SinOsc.ar(lop*mult_2+add_1);
	noise=In.ar(~noisebus);
	bp=BBandPass.ar(noise,bp_freq,~q_to_bw.value(bp_q));
	~fcpan.value(bp*lop*2*sig, fcpan_pos);
}).add;



SynthDef(\branches, {
	var noise,sig,sig1,bp;
	noise=In.ar(~noisebus);
	sig=Tap.ar(~windspeed_buffer, 1,0.5);
	sig1=sig*400+600;
	bp=BBandPass.ar(noise,sig1,~q_to_bw.value(60));
	~fcpan.value(bp*((sig+0.12).squared)*1.2,0.28)
}).add;

SynthDef(\wires, {
	var noise,sig,sig1,bp;
	noise=In.ar(~noisebus);
	sig=Tap.ar(~windspeed_buffer, 1,0.9);
	sig1=sig.squared;
	sig=sig*1000+1000;
	bp=BBandPass.ar(noise,sig,~q_to_bw.value(60));
	~fcpan.value(sig1*bp*2,0.64);
}).add;

SynthDef(\tree_leaves, {
	var lop,sig,noise,oneminus,maxof,lop2;
	sig=Tap.ar(~windspeed_buffer, 1,3)+0.3;
	lop=OnePole.ar(sig, exp(-2pi * (0.07* SampleDur.ir)));
	noise=In.ar(~noisebus);
	oneminus=1-(lop*0.4);
	maxof=max(oneminus,noise);
	maxof=maxof-oneminus;
	maxof=maxof*oneminus;
	maxof=(maxof - OnePole.ar(maxof, exp(-2pi * (200 * SampleDur.ir))));
	lop2=OnePole.ar(maxof, exp(-2pi * (4000* SampleDur.ir)));
	~fcpan.value(lop2*(lop-0.2)*0.8,0.71);
}).add;
)

//THEN RUN THIS TO PLAY
(
~sources = Group.new;
~sinks = Group.new(~sources,\addAfter);
~master = Group.new(~sinks,\addAfter);

~noisegen=Synth(defName:\noisegen,target:~sources,addAction:'addToHead');
~windspeed=Synth(defName:\windspeed,target:~sources,addAction:'addToTail');
~masterSynth=Synth(defName:\masterSynth,target:~master);

~buildings=Synth(defName:\buildings,target:~sinks);
~doorways_1=Synth(defName:\doorways,args:  [\delay, 0.1, \clip_lo,0.35, \clip_hi,0.6, \subtr_1,0.35, \mult_1,2, \subtr_2,0.25, \lop_freq,0.5, \mult_2,200, \add_1,30, \bp_freq,400, \bp_q,40, \fcpan_pos,0.91 ]  ,target:~sinks);
~doorways_2=Synth(defName:\doorways,args:  [\delay, 0.3, \clip_lo,0.25, \clip_hi,0.5, \subtr_1,0.25, \mult_1,2, \subtr_2,0.25, \lop_freq,0.1, \mult_2,100, \add_1,20, \bp_freq,200, \bp_q,40, \fcpan_pos,0.03 ]  ,target:~sinks);
~branches=Synth(defName:\branches,target:~sinks);
~wires=Synth(defName:\wires,target:~sinks);
~tree_leaves=Synth(defName:\tree_leaves,target:~sinks);
)


//TO STOP PLAYING
(
~sources.free;
~sinks.free;
~master.free;
)

//CLEANUP
(
~windspeed_buffer.free;~windspeed_buffer=nil;
~noisebus.free;~noisebus=nil;
~left.free;~left=nil;
~right.free;~right=nil;
)