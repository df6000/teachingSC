
// to send some code to the server, select it and then hit command+return

//this is a white noise generator with a control rate sin oscillator on its volume level
{WhiteNoise.ar(1.0*SinOsc.kr(1))}.play



//you can also select code by clicking on a paren, it should select all the code to the next paren.


//you need to store the synthdef on the server before you can call it in the Routine below
(

 SynthDef(\whiteNoiseInst,{arg vol=1,fadeIn=0.1,playLength=1.0,fadeOut=0.1,chan=0;

 	var env = EnvGen.ar(Env.new([0,1,1,0],[fadeIn,playLength,fadeOut]),doneAction:2);

 	Out.ar(
 	chan, WhiteNoise.ar(vol)*env)
 }).store;


)


//now run the routine.  try changing the values of the various parameters.
(

Routine.run({


	100.do{

Synth(\whiteNoiseInst, [\vol,rrand(0.5,1.0),\chan,rrand(0,1),\fadeIn,rrand(0.01,0.001),\fadeOut,rrand(0.01,0.001),\playLength,0.01]);
rrand(0.1,0.5).wait;
	};


})	;


)