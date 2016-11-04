

 SynthDef(\whiteNoiseInst,{arg vol=1,fadeIn=0.1,playLength=1.0,fadeOut=0.1,chan=0;

 	var env = EnvGen.ar(Env.new([0,1,1,0],[fadeIn,playLength,fadeOut]),doneAction:2);

 	Out.ar(
 	chan, WhiteNoise.ar(vol)*env)
 }).store;


