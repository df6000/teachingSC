{(SinOsc.ar(600*SinOsc.kr(20)))}.scope;




//
// ~sinFunc={
// 	var env = Env([0, 1, 0.5, 1, 0], [0.01, 0.5, 0.02, 0.5]);
//
// 	{
//
// 		(SinOsc.ar(600*SinOsc.kr(10)))* EnvGen.kr(env, doneAction: 2)
//
//
// 	}.play;
// };
//
//
//
// Routine.run({
//
// 	20.do{
// 		~sinFunc.value;
// 		1.5.wait;
// 	}
//
// });
