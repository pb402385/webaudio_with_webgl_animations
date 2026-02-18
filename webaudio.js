
/**
	Functions CSS
**/
var buttonsAnimDisabled = false;

function setCursorHoverDisable(element,nb){
	if(buttonsAnimDisabled == false){
		if(nb == 0){
			if(buttonOutside == false){
				element.style.cursor = "pointer";
			}else{
				element.style.cursor = "not-allowed";
			}
		}else if(nb == 1){
			if(buttonInside == false){
				element.style.cursor = "pointer";
			}else{
				element.style.cursor = "not-allowed";
			}
		}
	}

}

function setBackgroundColor(element,color){
	element.style.backgroundColor = color;
}

function setPianoHover(i,typeTouche,on){
	if(typeTouche == 1){
		var id = 'testNoteTD'+i;
		var id2 = 'topPiano'+i;
		if(on == true){
			document.getElementById(id).style.backgroundColor = "yellow";
			document.getElementById(id2).style.backgroundColor = "yellow";
			document.getElementById(id).style.outline = "yellow solid 1px";
			document.getElementById(id2).style.outline = "yellow solid 1px";
		}else{
			document.getElementById(id).style.backgroundColor = "white";
			document.getElementById(id2).style.backgroundColor = "white";
			document.getElementById(id).style.outline = "white solid 1px";
			document.getElementById(id2).style.outline = "white solid 1px";
		}
	}else if(typeTouche == 0){
		var id = 'testNoteDieseTD'+i;
		if(on == true){
			document.getElementById(id).style.backgroundColor = "yellow";
		}else{
			document.getElementById(id).style.backgroundColor = "black";
		}
	}
}

function setHoverElement(element){
	if(element.id == buttonEffectSelected){
		//Do not touch a selected button
	}else if(element.id == "runMelodie1" && stopMelodie == false){
		//same
	}else if(element.id == "runMelodieStarWars" && stopMelodie2 == false){
		//same
	}else if(element.id == "runMelodie1"){
		//same
	}else if(element.id == "runMelodieStarWars"){
		//same
	}else{
		element.style.backgroundColor = "yellow";
	}
}

function unsetHoverElement(element){
	if(element.id == buttonEffectSelected){
		//Do not touch a selected button
	}else if(element.id == "runMelodie1" && stopMelodie == false){
		//same
	}else if(element.id == "runMelodieStarWars" && stopMelodie2 == false){
		//same
	}else{
		element.style.backgroundColor = "white";
	}
}

function setEvenementBoutons(){
	var id = [];

	//part sound
	id[0] = "stopAllSounds";
	id[1] = "buttonTypeSound";
	id[2] = "filterTest";
	id[3] = "buttonGenerateSound0";
	id[4] = "buttonGenerateSound1";
	id[5] = "buttonGenerateSound2";
	id[6] = "runMelodie1";
	id[7] = "buttonGenerateSound3";
	id[8] = "buttonGenerateSound4";
	id[9] = "runMelodieStarWars";
	
	//part anim 
	id[10] = "buttonTypeTextureAnim";
	id[11] = "buttonFreqAnim";
	id[12] = "buttonTypeAnim";
	id[13] = "buttonInfinityAnim";
	id[14] = "buttonEffectAnim";

	var elem;
	for(var i = 0; i<id.length; i++){
		elem = document.getElementById(id[i]);
		// Attention � la closure pour que �a marche pour tous les elements et pas juste le dernier
		(function(i,elem) {
			elem.onmouseover = function(){setHoverElement(elem)};
			elem.onmouseout = function(){unsetHoverElement(elem)};
		})(i,elem);
	}

}





/** PART SOUND **/
//context audio
let audioCtx;
let isUnlocked = false;
let isPlayingTheremin = false;
let interval = null;

// Fonction à appeler sur le premier clic/touch de l’utilisateur
async function unlockAudio() {
    if (isUnlocked) return;

    // Crée ou reprend l’AudioContext
    audioCtx = new AudioContext();

	//initAudio();


	// Start when user clicks or after resume (required on most browsers)
	document.documentElement.addEventListener('click', () => {
		if (audioCtx.state === 'suspended') audioCtx.resume();
		initAudio().then(() => {
			console.log("AudioContext débloqué et prêt !");
			isUnlocked = true;

			// Mets ici tout ce qui a besoin du son
			initAudioContext2();
			initAudioGraphTheremin();
			initAudioGraphDrumMachine();
		});

	}, { once: true });

    // Nettoyage : on ne veut appeler ça qu’une seule fois
    document.removeEventListener('click', unlockAudio);
    document.removeEventListener('touchstart', unlockAudio);
    document.removeEventListener('keydown', unlockAudio);
}

async function initAudio() {
    try {
      // This MUST be awaited and inside try/catch
      console.log("Loading processor...");
      await audioCtx.audioWorklet.addModule('./audio-worklet-processor.js');
      console.log("Processor (my-audio-processor) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/simple-lowpass.js');
	  console.log("Processor (simple-lowpass-effect) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/bit-crusher.js');
	  console.log("Processor (bit-crusher-effect) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/pink.js');
	  console.log("Processor (pink-effect) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/noise.js');
	  console.log("Processor (noise-effect) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/pitch.js');
	  console.log("Processor (pitch) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/compressor.js');
	  console.log("Processor (compressor) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/reverb.js');
	  console.log("Processor (reverb) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/tremolo.js');
	  console.log("Processor (tremolo) loaded successfully");

	  await audioCtx.audioWorklet.addModule('./effect/fft-fx.js');
	  console.log("Processor (fft-fx) loaded successfully");

      // Only now is it safe to create the node
      analyserNode = new AudioWorkletNode(audioCtx, 'my-audio-processor');
      console.log("AudioWorkletNode created and connected (my-audio-processor)");


	  // effects
	  simplePassEffectNode = new AudioWorkletNode(audioCtx, 'simple-lowpass', {
		parameterData: { cutoff: 800 }
	  });
	  console.log("AudioWorkletNode created and connected (simple-lowpass-effect-processor)");

	  bitCrusherEffectNode = new AudioWorkletNode(audioCtx, 'bitcrusher', {
		outputChannelCount: [2]
	  });

	  bitCrusherEffectNode.parameters.get('bitDepth').setValueAtTime(16, audioCtx.currentTime);
	  bitCrusherEffectNode.parameters.get('bitDepth').linearRampToValueAtTime(4, audioCtx.currentTime + 2);
	  console.log("AudioWorkletNode created and connected (bit-crusher-effect-processor)");

	  pinkEffectNode = new AudioWorkletNode(audioCtx, 'pink-noise-filtered');
	  pinkEffectNode.parameters.get('cutoff').linearRampToValueAtTime(200, audioCtx.currentTime + 5);
	  console.log("AudioWorkletNode created and connected (pink-effect-processor)");

	  pitchEffectNode = new AudioWorkletNode(audioCtx, 'pitch');
	  pitchEffectNode.parameters.get('pitch').setValueAtTime(2, audioCtx.currentTime);

	  console.log("AudioWorkletNode created and connected (pitch-effect-processor)");

	  noiseEffectNode = new AudioWorkletNode(audioCtx, 'noise');
	  noiseEffectNode.parameters.get('type').setValueAtTime(1, 0);        // pink
	  console.log("AudioWorkletNode created and connected (noise-effect-processor)");

	  compressorEffectNode = new AudioWorkletNode(audioCtx, 'compressor', {
		processorOptions: { channelCount: 2 }
	  });

	  compressorEffectNode.parameters.get('threshold').value = -24;
	  compressorEffectNode.parameters.get('ratio').value = 4;
	  compressorEffectNode.parameters.get('attack').value = 8;
	  compressorEffectNode.parameters.get('release').value = 120;
	  compressorEffectNode.parameters.get('makeup').value = 6;
	  compressorEffectNode.parameters.get('mix').value = 100;
	  console.log("AudioWorkletNode created and connected (compressor-effect-processor)");

	  reverbEffectNode = new AudioWorkletNode(audioCtx, 'reverb', {
		outputChannelCount: [2]
	  });

	  // Exemple de contrôle
  	  reverbEffectNode.parameters.get('roomSize').setValueAtTime(0.85, audioCtx.currentTime);
  	  reverbEffectNode.parameters.get('damping').setValueAtTime(0.3, audioCtx.currentTime);
  	  reverbEffectNode.parameters.get('wet').setValueAtTime(0.4, audioCtx.currentTime);
  	  reverbEffectNode.parameters.get('freeze').setValueAtTime(1, audioCtx.currentTime + 5); // freeze après 5s
	  console.log("AudioWorkletNode created and connected (reverb-effect-processor)");

	  tremoloEffectNode = new AudioWorkletNode(audioCtx, 'tremolo', {
		  outputChannelCount: [2],           // indispensable
		  channelCount: 2,                   // force 2 canaux en sortie
		  channelCountMode: 'explicit',
		  channelInterpretation: 'speakers'
	  });

	  // 3. Carré 8 Hz ultra-nerveux (style dub/techno)
	  tremoloEffectNode.parameters.get('rate').setValueAtTime(8, audioCtx.currentTime);
	  tremoloEffectNode.parameters.get('shape').setValueAtTime(2, audioCtx.currentTime);
	  tremoloEffectNode.parameters.get('smooth').setValueAtTime(0.7, audioCtx.currentTime); // adoucit le carré
	  console.log("AudioWorkletNode created and connected (tremolo-effect-processor)");

	fftFxEffectNode = new AudioWorkletNode(audioCtx, 'fft-fx');
	fftFxEffectNode.parameters.get('mode').setValueAtTime(0, audioCtx.currentTime);
	fftFxEffectNode.parameters.get('freeze').setValueAtTime(1, audioCtx.currentTime + 2); // pad infini !

console.log("AudioWorkletNode created and connected (fft-fx-effect-processor)");
    } catch (err) {
      console.error("Failed to load AudioWorklet module:", err);
      // This is where you’ll see the real error (syntax, 404, CORS, etc.)
    }
}

function setNoiseParams(val) {
	if( val === '0' ) {
		noiseEffectNode.parameters.get('type').setValueAtTime(0, 0);
	}
	if( val === '1' ) {
		noiseEffectNode.parameters.get('type').setValueAtTime(1, 0);
	}
	if( val === '2' ) {
		noiseEffectNode.parameters.get('type').setValueAtTime(2, 0);
	}
	if( val === '3' ) {
		noiseEffectNode.parameters.get('type').setValueAtTime(3, 0);
	}
	if( val === '4' ) {
		noiseEffectNode.parameters.get('type').setValueAtTime(4, 0);
	}
}

function setBitCrusherParams(val) {
	if( val === '0' ) {
		// Super smooth automation without zippering
		bitCrusherEffectNode.parameters.get('frequencyReduction').setValueAtTime(0.0, audioCtx.currentTime);
	}
	if( val === '1' ) {
		// Extreme lo-fi effect
		bitCrusherEffectNode.parameters.get('frequencyReduction').setValueAtTime(0.9, audioCtx.currentTime);
	}
}

function setFftFxParams(val) {
	if( val === '0' ) {
		// Spectral Freeze
		fftFxEffectNode.parameters.get('mode').setValueAtTime(0, audioCtx.currentTime);
		fftFxEffectNode.parameters.get('freeze').setValueAtTime(1, audioCtx.currentTime + 2); // pad infini !
		fftFxEffectNode.parameters.get('amount').setValueAtTime(0.5, audioCtx.currentTime);
		fftFxEffectNode.parameters.get('pitch').exponentialRampToValueAtTime(1, audioCtx.currentTime);
	}
	if( val === '1' ) {
		// Shimmer / Spectral Blur
		fftFxEffectNode.parameters.get('mode').setValueAtTime(1, audioCtx.currentTime);
		fftFxEffectNode.parameters.get('amount').setValueAtTime(0.8, audioCtx.currentTime);
		fftFxEffectNode.parameters.get('pitch').exponentialRampToValueAtTime(1, audioCtx.currentTime);
		fftFxEffectNode.parameters.get('freeze').setValueAtTime(0, audioCtx.currentTime);
	}
	if( val === '2' ) {
		// Pitch shifter ±2 octaves formant-preserving
		fftFxEffectNode.parameters.get('mode').setValueAtTime(3, audioCtx.currentTime);
		fftFxEffectNode.parameters.get('pitch').exponentialRampToValueAtTime(4, audioCtx.currentTime + 5); // +2 octaves
		fftFxEffectNode.parameters.get('amount').setValueAtTime(0.5, audioCtx.currentTime);
		fftFxEffectNode.parameters.get('freeze').setValueAtTime(0, audioCtx.currentTime);
	}
}

function setPitchParams(val) {
	if( val === '0' ) {
		// Octave up
	    pitchEffectNode.parameters.get('pitch').setValueAtTime(2, audioCtx.currentTime);
		pitchEffectNode.parameters.get('wet').setValueAtTime(0.5, audioCtx.currentTime);
	}
	if( val === '1' ) {
		// Octave down
	    pitchEffectNode.parameters.get('pitch').setValueAtTime(0.5, audioCtx.currentTime);
		pitchEffectNode.parameters.get('wet').setValueAtTime(0.5, audioCtx.currentTime);
	}
	if( val === '2' ) {
		// Démon / robot
	    pitchEffectNode.parameters.get('pitch').setValueAtTime(0.7, audioCtx.currentTime);
	    pitchEffectNode.parameters.get('wet').setValueAtTime(0.9, audioCtx.currentTime);
	}
	if( val === '3' ) {
		// Chorus léger
	    pitchEffectNode.parameters.get('pitch').setValueAtTime(1.02, audioCtx.currentTime);
	    pitchEffectNode.parameters.get('wet').setValueAtTime(0.4, audioCtx.currentTime);
	}
}

function setCompressorParams(val) {
	if( val === '0' ) {
		compressorEffectNode.parameters.get('threshold').value = -24;
	    compressorEffectNode.parameters.get('ratio').value = 4;
	    compressorEffectNode.parameters.get('attack').value = 8;
	    compressorEffectNode.parameters.get('release').value = 120;
	    compressorEffectNode.parameters.get('makeup').value = 6;
		compressorEffectNode.parameters.get('knee').value = 6;
	}
	if( val === '1' ) {
		compressorEffectNode.parameters.get('threshold').value = -18;
	    compressorEffectNode.parameters.get('ratio').value = 2;
	    compressorEffectNode.parameters.get('attack').value = 10;
	    compressorEffectNode.parameters.get('release').value = 150;
	    compressorEffectNode.parameters.get('knee').value = 12;
		compressorEffectNode.parameters.get('makeup').value = 6;
	}
	if( val === '2' ) {
		compressorEffectNode.parameters.get('threshold').value = -24;
	    compressorEffectNode.parameters.get('ratio').value = 4;
	    compressorEffectNode.parameters.get('attack').value = 5;
	    compressorEffectNode.parameters.get('release').value = 100;
	    compressorEffectNode.parameters.get('knee').value = 10;
		compressorEffectNode.parameters.get('makeup').value = 4;
	}
	if( val === '3' ) {
		compressorEffectNode.parameters.get('threshold').value = -30;
	    compressorEffectNode.parameters.get('ratio').value = 10;
	    compressorEffectNode.parameters.get('attack').value = 2;
	    compressorEffectNode.parameters.get('release').value = 80;
	    compressorEffectNode.parameters.get('knee').value = 6;
		compressorEffectNode.parameters.get('makeup').value = 10;
	}
	if( val === '4' ) {
		compressorEffectNode.parameters.get('threshold').value = -6;
	    compressorEffectNode.parameters.get('ratio').value = 20;
	    compressorEffectNode.parameters.get('attack').value = 0.5;
	    compressorEffectNode.parameters.get('release').value = 50;
	    compressorEffectNode.parameters.get('knee').value = 2;
		compressorEffectNode.parameters.get('makeup').value = 5;
	}
}

function setTremoloParams(val) {
	if( val === '0' ) {
		// Exemples de contrôles rapides
	    tremoloEffectNode.parameters.get('rate').setValueAtTime(4, audioCtx.currentTime);
	    tremoloEffectNode.parameters.get('depth').setValueAtTime(0.6, audioCtx.currentTime);
	    tremoloEffectNode.parameters.get('shape').setValueAtTime(0, audioCtx.currentTime); // sinus
		tremoloEffectNode.parameters.get('smooth').setValueAtTime(0.9, audioCtx.currentTime);
	}
	if( val === '1' ) {
		// 2. Auto-pan large et lent (0.33 Hz)
		tremoloEffectNode.parameters.get('rate').setValueAtTime(0.33, audioCtx.currentTime);
		tremoloEffectNode.parameters.get('depth').setValueAtTime(1, audioCtx.currentTime);
		tremoloEffectNode.parameters.get('smooth').setValueAtTime(0.9, audioCtx.currentTime);
		tremoloEffectNode.parameters.get('shape').setValueAtTime(0, audioCtx.currentTime);
	}
	if( val === '2' ) {
	  // 3. Carré 8 Hz ultra-nerveux (style dub/techno)
	  tremoloEffectNode.parameters.get('rate').setValueAtTime(8, audioCtx.currentTime);
	  tremoloEffectNode.parameters.get('shape').setValueAtTime(2, audioCtx.currentTime);
	  tremoloEffectNode.parameters.get('smooth').setValueAtTime(0.7, audioCtx.currentTime); // adoucit le carré
	  tremoloEffectNode.parameters.get('depth').setValueAtTime(0.5, audioCtx.currentTime);
	}

}


//Volume node
var gainNode;
//Oscillator node;
var oscillator;
var oscillator1;
var oscillator2;
var oscillator0;
var oscillatorTab = [];
//Filter node
var filter;

//Analysis node to analyze sound data
var analyser;
//JavaScript node to exploit data from sound (deprecated, to change !)
var javascriptNode;
var analyserNode;
var simplePassEffectNode;
var bitCrusherEffectNode;
var pinkEffectNode;
var pitchEffectNode;
var noiseEffectNode;
var compressorEffectNode;
var reverbEffectNode;
var tremoloEffectNode;
var fftFxEffectNode;


var tabKeyNotes = [];
tabKeyNotes[81] = 0;//q
tabKeyNotes[90] = 1;//z
tabKeyNotes[83] = 2;//s
tabKeyNotes[68] = 3;//d
tabKeyNotes[82] = 4;//r
tabKeyNotes[70] = 5;//f
tabKeyNotes[84] = 6;//t
tabKeyNotes[71] = 7;//g
tabKeyNotes[72] = 8;//h
tabKeyNotes[85] = 9;//u
tabKeyNotes[74] = 10;//j
tabKeyNotes[73] = 11;//i
tabKeyNotes[75] = 12;//k
tabKeyNotes[79] = 13;//o
tabKeyNotes[76] = 14;//l
tabKeyNotes[77] = 15;//m


//param egaliseur
var hBand;
var lBand;
var lGain;
var mGain;
var hGain;
var bandSplit = [360,3600];
var gainDb = -40.0;

//un buffer pour les effets
var bufferSize = 4096;

var boolEventMouse = false;

function initAudioContext2(){
	try{
		
		//We connect the sound's node
		gainNode = audioCtx.createGain();
		gainNode.gain.value = (20/100) * (20/100);
		
		//sound equalizer
		hBand = audioCtx.createBiquadFilter();
		lBand = audioCtx.createBiquadFilter();	
		lGain = audioCtx.createGain();
		mGain = audioCtx.createGain();
		hGain = audioCtx.createGain();
		
		//filter
		filter = audioCtx.createBiquadFilter();
		
		//We create a node to analyze as well as a javascript node
		analyser = audioCtx.createAnalyser();
		
		/**
		javascriptNode = audioCtx.createScriptProcessor(1024, 1, 1);
		javascriptNode.onaudioprocess = function () {
					//retrieve sound information here!!!!!!
					//alert('audioProcess');
					draw(analyser);
					drawWave(analyser);
		};
		**/
		
		
		//Creation of oscillators
		oscillator = audioCtx.createOscillator();
		oscillator1 = audioCtx.createOscillator();
		oscillator2 = audioCtx.createOscillator();
		oscillator0 = audioCtx.createOscillator();
		
		oscillator.start(0);
		oscillator1.start(0);
		oscillator2.start(0);
		oscillator0.start(0);
		
		var cpt = 0;
		for (key in tabKeyNotes) {
			oscillatorTab[cpt] = audioCtx.createOscillator();
			oscillatorTab[cpt].start(0);
			cpt++;
		}

		buidGraph();
		setDefaultValues();
		
	}catch(e){
		alert('Web Audio API is not supported in this browser');
	}
}



var notePlayed = false;
var type = 0;
var delay = 100;

var stopMelodieBool = false;


//the grade that is generated and inserted into the grade table
var noteToPlay;
//We create a table of notes sorted in frequency order
var tabFrequences = [220,233.1,247,261.6,277.2,293.7,311.1,329.6,349.2,370,392,415.3,440,466.2,493.9,523.3];
//The type of note
var tabType = ["triangle","sine","square","sawtooth"];
//We generate our table of musical notes
var tabNotes = [];
for(var i=0; i<tabType.length; i++){
	tabNotes[i] = [];
	for(var j=0; j<tabFrequences.length; j++){
		tabNotes[i][j] = [];
		tabNotes[i][j][0] = tabFrequences[j];
		tabNotes[i][j][1] = tabType[i];
	}
}

function playNote(freq,duree){
	if(!duree) duree = delay;
	if(notePlayed == false){
		noteToPlay = new Sound(tabFrequences[freq], tabType[type]);
		play(freq);
		setTimeout(function(){ stop(freq); }, delay);
	}
}

function play(i,boolEventMouse){
	if(boolEventMouse == false) noteToPlay = new Sound(tabFrequences[i], tabType[type]);
    if(notePlayed == false) {
        notePlayed = true;
		if(boolEventMouse == false){
			if(i !== 1 && i !== 4 && i !== 6 && i !== 9 && i !== 11 && i !== 13){
				var id = 'testNoteTD'+i;
				var id2 = 'topPiano'+i;
				document.getElementById(id).style.backgroundColor = "cyan";
				document.getElementById(id2).style.backgroundColor = "cyan";
			}else{
				var id = 'testNoteDieseTD'+i;
				document.getElementById(id).style.backgroundColor = "cyan";
			}
		}else{
			var id = 'testNoteTD'+i;
			var id2 = 'topPiano'+i;
			document.getElementById(id).style.backgroundColor = "red";
			document.getElementById(id2).style.backgroundColor = "red";
		}
    }
}

function stop(i,boolEventMouse){
    notePlayed = false;
	safeDisconnect(oscillator);
	if(boolEventMouse == false){
		if(i !== 1 && i !== 4 && i !== 6 && i !== 9 && i !== 11 && i !== 13){
			var id = 'testNoteTD'+i;
			var id2 = 'topPiano'+i;
			document.getElementById(id).style.backgroundColor = "white";
			document.getElementById(id2).style.backgroundColor = "white";
		}else{
			var id = 'testNoteDieseTD'+i;
			document.getElementById(id).style.backgroundColor = "inherit";
		}
	}else{
		var id = 'testNoteTD'+i;
		var id2 = 'topPiano'+i;
		document.getElementById(id).style.backgroundColor = "white";
		document.getElementById(id2).style.backgroundColor = "white";
	}
}

function buidGraph(){
		/** PARAM EGALISEUR **/
		hBand.type = "lowshelf";
		hBand.frequency.value = bandSplit[0];
		hBand.gain.value = gainDb;

		lBand.type = "highshelf";
		lBand.frequency.value = bandSplit[1];
		lBand.gain.value = gainDb;
		lBand.connect(lGain);
		hBand.connect(hGain);


		// Connect the sound sample to its volume node
		lGain.connect(gainNode);
		mGain.connect(gainNode);
		hGain.connect(gainNode);

		/** END PARAM EGALISEUR **/
		gainNode.connect(filter);
		
		filter.connect(analyserNode);	
		analyserNode.connect(analyser);

		function draw1() {
			draw(analyser);
			requestAnimationFrame(draw1);
		}
		draw1();

		function draw2() {
			drawWave(analyser);
			requestAnimationFrame(draw2);
		}
		draw2();	
		
		analyserNode.connect(audioCtx.destination);	

		let frontCanvasTimeline = document.getElementById("spectreTimelineMP3");
		frontCanvasTimeline.addEventListener("mousedown", function(event) {
			if( mp3Buffer !== undefined ){
				console.log("mouse click on canvas, let's jump to another position in the song")
				var mousePos = getMousePos(frontCanvasTimeline, event);
				// will compute time from mouse pos and start playing from there...
				jumpTo(mousePos);
			}
		});
}

function play2(i){
    if(notePlayed2 == false) {
        notePlayed2 = true;
		var id = 'testNoteTD'+i;
		var id2 = 'topPiano'+i;
		document.getElementById(id).style.backgroundColor = "orange";
		document.getElementById(id2).style.backgroundColor = "orange";			
    }
}

function play1(i){
    if(notePlayed1 == false) {
        notePlayed1 = true;
		var id = 'testNoteTD'+i;
		var id2 = 'topPiano'+i;
		document.getElementById(id).style.backgroundColor = "red";
		document.getElementById(id2).style.backgroundColor = "red";			
    }
}

function stop2(i){
    notePlayed2 = false;
	safeDisconnect(oscillator2);
	var id = 'testNoteTD'+i;
	var id2 = 'topPiano'+i;
	document.getElementById(id).style.backgroundColor = "white";
	document.getElementById(id2).style.backgroundColor = "white";
}

function stop1(i){
    notePlayed1 = false;
	safeDisconnect(oscillator1);
	var id = 'testNoteTD'+i;
	var id2 = 'topPiano'+i;
	document.getElementById(id).style.backgroundColor = "white";
	document.getElementById(id2).style.backgroundColor = "white";
}

function stop0(i){
    notePlayed0 = false;
	safeDisconnect(oscillator0);
	if(i !== -1){
		if(i == 4 || i == 6 || i == 9 || i == 11 || i == 13 ){
			var id = 'testNoteDieseTD'+i;
			document.getElementById(id).style.backgroundColor = "black";
		}else{
			var id = 'testNoteTD'+i;
			document.getElementById(id).style.backgroundColor = "white";
			var id2 = 'topPiano'+i;
			document.getElementById(id2).style.backgroundColor = "white";
		}
	}
}

function play0(i){
    if(notePlayed0 == false) {
        notePlayed0 = true;
		if(i !== -1){
			if(i == 4 || i == 6 || i == 9 || i == 11 || i == 13 ){
				var id = 'testNoteDieseTD'+i;
				document.getElementById(id).style.backgroundColor = "red";
			}else{
				var id = 'testNoteTD'+i;
				document.getElementById(id).style.backgroundColor = "orange";
				var id2 = 'topPiano'+i;
				document.getElementById(id2).style.backgroundColor = "orange";
			}
		}
    }
}

function Sound2(frequency, type) {
    oscillator2.frequency.value = frequency;
    oscillator2.type = type;
	oscillator2.connect(lBand);
	oscillator2.connect(hBand);
	oscillator2.connect(mGain);
	notePlayed2 = false; // flag to indicate if sound is playing
};

function Sound1(frequency, type) {
    oscillator1.frequency.value = frequency;
    oscillator1.type = type;
	oscillator1.connect(lBand);
	oscillator1.connect(hBand);
	oscillator1.connect(mGain);
	notePlayed1 = false; // flag to indicate if sound is playing
};

function Sound0(frequency, type) {
    oscillator0.frequency.value = frequency;
    oscillator0.type = type;
	oscillator0.connect(lBand);
	oscillator0.connect(hBand);
	oscillator0.connect(mGain);
	notePlayed0 = false; // flag to indicate if sound is playing
};


function Sound(frequency, type) {
    oscillator.frequency.value = frequency;
    oscillator.type = type;
	oscillator.connect(lBand);
	oscillator.connect(hBand);
	oscillator.connect(mGain);
	notePlayed = false; // flag to indicate if sound is playing
};




//Manage volume
function changeVolume(element){
  var volume = element.value;
  var fraction = parseInt(element.value) / parseInt(element.max);
  gainNode.gain.value = fraction * fraction;
}

//Type of wave
function setType(value){
	if(value == tabType[0]) type = 0;
	if(value == tabType[1]) type = 1;
	if(value == tabType[2]) type = 2;
	if(value == tabType[3]) type = 3;
}

//Params equalizer
function changeGainEg(string,type)
{
	let value = "";
	if(type.indexOf("lGain") > -1){
		type = "lGain";
		value = parseFloat(string);
		//Upate screen egaliseur H
		//document.getElementById('lGainInputValue').innerHTML = value + " / 100"
	}
	if(type.indexOf("mGain") > -1){
		type = "mGain";
		value = parseFloat(string);
		//Upate screen egaliseur H
		//document.getElementById('mGainInputValue').innerHTML = value + " / 100"
	}
	if(type.indexOf("hGain") > -1){
		type = "hGain";
		value = parseFloat(string);
		//Upate screen egaliseur H
		//document.getElementById('hGainInputValue').innerHTML = value + " / 100"
	}

	switch(type)
	{
		case 'lGain': lGain.gain.value = value; break;
		case 'mGain': mGain.gain.value = value; break;
		case 'hGain': hGain.gain.value = value; break;
	}
			
}

//Params filter (frequency)
function changeFrequency(freq) {
	//alert(parseInt(freq));
	filter.frequency.value = parseInt(freq);
}
//Params filter (quality)
function changeQuality(qual) {
	//alert(parseInt(qual));
	filter.Q.value = parseInt(qual);
}
//Params filter (gain)
function changeGain(gainVal) {
	//alert(parseInt(gainVal));
	filter.gain.value = parseInt(gainVal);
	document.getElementById('valGain').innerHTML = gainVal + " / 100";
}

function domIdIsExist(name) {
	var myEle = document.getElementById(name);
	if(myEle) {
		return true;
	}
	return false;
}

//Params filter (type)
function changeEffect(name) {
	//alert(name);
	if(domIdIsExist('gainRangeTest')) document.getElementById('gainRangeTest').style.display = 'none';
	if(domIdIsExist('txtGain')) document.getElementById('txtGain').style.display = 'none';
	if(domIdIsExist('valGain')) document.getElementById('valGain').style.display = 'none';
	if(domIdIsExist('qualityRangeTest')) document.getElementById('qualityRangeTest').style.display = 'none';
	if(domIdIsExist('txtQuality')) document.getElementById('txtQuality').style.display = 'none';
	if(domIdIsExist('valQuality')) document.getElementById('valQuality').style.display = 'none';

	let frequencyRange = document.getElementById('frequencyRangeTest');

    if (name == "lowpass"){
		filter.type = name;

		//Default Params
		frequencyRange.value = 120;
		manualUpdateFrequency(120);
		filter.frequency.value = 180;
  		filter.gain.value = 0;    // boost graves
		filter.Q.value = 1;
	}else if (name == "highpass"){
		filter.type = name;

		//Default Params
		filter.frequency.value = 120;
		frequencyRange.value = 120;
		manualUpdateFrequency(120);
		filter.Q.value = 1;
		filter.gain.value = 0;    // boost graves
		//NO GAIN
	}else if (name == "bandpass"){
		filter.type = name;

		//Default Params
		filter.frequency.value = 800;   // centre
		frequencyRange.value = 800;
		manualUpdateFrequency(800);
		filter.Q.value = 8;             // assez étroit
		filter.gain.value = 0;
		//NO GAIN
	}else if (name == "lowshelf"){
		filter.type = name;

		//Default Params
		filter.frequency.value = 180;
		frequencyRange.value = 180;
		manualUpdateFrequency(180);
		filter.gain.value = 4;    // boost graves
		filter.Q.value = 0;
		//NO QUALITY
		if(domIdIsExist('qualityRangeTest')) document.getElementById('qualityRangeTest').style.display = 'none';
		if(domIdIsExist('txtQuality')) document.getElementById('txtQuality').style.display = 'none';
		if(domIdIsExist('valQuality')) document.getElementById('valQuality').style.display = 'none';
		if(domIdIsExist('gainRangeTest')) document.getElementById('gainRangeTest').style.display = 'inherit';
		if(domIdIsExist('txtGain')) document.getElementById('txtGain').style.display = 'inherit';
		if(domIdIsExist('valGain')) document.getElementById('valGain').style.display = 'inherit';
	}else if (name == "highshelf"){
		filter.type = name;

		//Default Params
		filter.frequency.value = 6000;
		frequencyRange.value = 6000;
		manualUpdateFrequency(6000);
		filter.gain.value = 5; // un peu d'air
		filter.Q.value = 0;

		//NO QUALITY
		if(domIdIsExist('qualityRangeTest')) document.getElementById('qualityRangeTest').style.display = 'none';
		if(domIdIsExist('txtQuality')) document.getElementById('txtQuality').style.display = 'none';
		if(domIdIsExist('valQuality')) document.getElementById('valQuality').style.display = 'none';
		if(domIdIsExist('gainRangeTest')) document.getElementById('gainRangeTest').style.display = 'inherit';
		if(domIdIsExist('txtGain')) document.getElementById('txtGain').style.display = 'inherit';
		if(domIdIsExist('valGain')) document.getElementById('valGain').style.display = 'inherit';
	}else if (name == "peaking"){
		filter.type = name;

		//Default Params
		filter.frequency.value = 1000;
		frequencyRange.value = 1000;
		manualUpdateFrequency(1000);
		filter.Q.value = 1;
		filter.gain.value = -3;   // creuser un peu les mids

		if(domIdIsExist('gainRangeTest')) document.getElementById('gainRangeTest').style.display = 'inherit';
		if(domIdIsExist('txtGain')) document.getElementById('txtGain').style.display = 'inherit';
		if(domIdIsExist('valGain')) document.getElementById('valGain').style.display = 'inherit';
	}else if (name == "notch"){
		filter.type = name;

		//Default Params
		filter.frequency.value = 110;
		frequencyRange.value = 110;
		manualUpdateFrequency(500);
		filter.gain.value = 0;
		filter.Q.value = 10;
		//NO GAIN
	}else if (name == "allpass"){
		filter.type = name;

		//Default Params
		filter.frequency.value = 500;
		frequencyRange.value = 500;
		manualUpdateFrequency(500);
		filter.gain.value = 0;
		filter.Q.value = 0;
		//NO GAIN
	}

}


//Effects management
var oscillatorEffectTab = [false,false,false,false,false,false,false,false,false];
var effect;
function addEffect(i){
	
	if(oscillatorEffectTab[i] == false){		
		//we update the table
		oscillatorEffectTab = [false,false,false,false,false,false,false,false,false];
		oscillatorEffectTab[i] = true;

		safeDisconnect(filter,pitchEffectNode);
		safeDisconnect(filter,noiseEffectNode);
		safeDisconnect(filter,pinkEffectNode);
		safeDisconnect(filter,bitCrusherEffectNode);
		safeDisconnect(filter,simplePassEffectNode);
		safeDisconnect(filter,compressorEffectNode);
		safeDisconnect(filter,reverbEffectNode);
		safeDisconnect(filter,tremoloEffectNode);
		safeDisconnect(filter,fftFxEffectNode);

		safeDisconnect(pitchEffectNode,analyserNode);
		safeDisconnect(noiseEffectNode,analyserNode);
		safeDisconnect(pinkEffectNode,analyserNode);
		safeDisconnect(bitCrusherEffectNode,analyserNode);
		safeDisconnect(simplePassEffectNode,analyserNode);
		safeDisconnect(reverbEffectNode,analyserNode);
		safeDisconnect(tremoloEffectNode,analyserNode);
		safeDisconnect(tremoloEffectNode,fftFxEffectNode);

		if( i == 0 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(pitchEffectNode);
			pitchEffectNode.connect(analyserNode);
		}else if( i == 1 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(noiseEffectNode);
			noiseEffectNode.connect(analyserNode);
		}else if( i == 2 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(pinkEffectNode);
			pinkEffectNode.connect(analyserNode);
		}else if( i == 3 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(bitCrusherEffectNode);
			bitCrusherEffectNode.connect(analyserNode);
		}else if( i == 4 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(simplePassEffectNode);
			simplePassEffectNode.connect(analyserNode);
		} else if ( i == 5 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(compressorEffectNode);
			compressorEffectNode.connect(analyserNode);
		} else if ( i == 6 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(reverbEffectNode);
			reverbEffectNode.connect(analyserNode);
		} else if ( i == 7 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(tremoloEffectNode);
			tremoloEffectNode.connect(analyserNode);
		} else if ( i == 8 ){
			safeDisconnect(filter,analyserNode);
			filter.connect(fftFxEffectNode);
			fftFxEffectNode.connect(analyserNode);
		}
		selectEffectCSS(i,true);
	}else if(oscillatorEffectTab[i] == true){
		//we update the table
		if( i == 0 ){
			safeDisconnect(filter,pitchEffectNode);
			safeDisconnect(pitchEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 1 ){
			safeDisconnect(filter,noiseEffectNode);
			safeDisconnect(noiseEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 2 ){
			safeDisconnect(filter,pinkEffectNode);
			safeDisconnect(pinkEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 3 ){
			safeDisconnect(filter,bitCrusherEffectNode);
			safeDisconnect(bitCrusherEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 4 ){
			safeDisconnect(filter,simplePassEffectNode);
			safeDisconnect(simplePassEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 5 ){
			safeDisconnect(filter,compressorEffectNode);
			safeDisconnect(compressorEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 6 ){
			safeDisconnect(filter,reverbEffectNode);
			safeDisconnect(reverbEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 7 ){
			safeDisconnect(filter,tremoloEffectNode);
			safeDisconnect(tremoloEffectNode,analyserNode);
			filter.connect(analyserNode);
		}else if( i == 8 ){
			safeDisconnect(filter,fftFxEffectNode);
			safeDisconnect(fftFxEffectNode,analyserNode);
			filter.connect(analyserNode);
		}
		oscillatorEffectTab = [false,false,false,false,false,false,false,false,false];
		selectEffectCSS(i,false);
	}
	buidGraph();
	
}

function safeDisconnect(node, destination = null) {
  try {
    if (node && typeof node.disconnect === 'function') {
      node.disconnect(destination);
    }
  } catch (e) {
    // rien à faire – le nœud n’était pas connecté ou déjà déconnecté
  }
}

var buttonEffectSelected = "";
function selectEffectCSS(id,selectOrDeselect){
	for(var j=0; j<oscillatorEffectTab.length; j++){
		if(j!== id){
			document.getElementById("buttonGenerateSound"+j).style.backgroundColor = "white";
			document.getElementById("buttonGenerateSound"+j).style.outline = "none";
		}
	}
	var elemId = "buttonGenerateSound"+id;
	if(selectOrDeselect == true){
		buttonEffectSelected = elemId;
		document.getElementById(elemId).style.backgroundColor = "cyan";
		document.getElementById(elemId).style.outline = "thick double #32a1ce";
	}else{
		buttonEffectSelected = "";
		document.getElementById(elemId).style.backgroundColor = "white";
		document.getElementById(elemId).style.outline = "none";
	}
}

function avg(array){
	var somme = 0;
	for(var i=0; i<array.length; i++){
		somme = somme+array[i];
	}
	return somme/array.length;
}


// PART SPECTRUM
function draw(analyser) {
    var canvas, context2, width, height, barWidth, barHeight, barSpacing, frequencyData, barCount, loopStep, i, hue;
	
    canvas = document.getElementById('spectre');
	context2 = canvas.getContext('2d');
	
    width = canvas.width;
    height = canvas.height;
    barWidth = 4;
    barSpacing = 1;
 
    context2.clearRect(0, 0, width, height);
	if(analyser.frequencyBinCount){
		frequencyData = new Uint8Array(analyser.frequencyBinCount);
		analyser.getByteFrequencyData(frequencyData);
	} 
    //analyser.getByteFrequencyData(frequencyData);
	
	// Float32Array
	//frequencyData = new Uint8Array(analyser);

	
    barCount = Math.round(width / (barWidth + barSpacing));
    loopStep = Math.floor(frequencyData.length / (4*barCount));
	
	var my_gradient=context2.createLinearGradient(0,0,800,0);
	my_gradient.addColorStop(0,"white");
	my_gradient.addColorStop(0.1,"blue");
	my_gradient.addColorStop(0.2,"white");
	my_gradient.addColorStop(0.3,"blue");
	my_gradient.addColorStop(0.4,"white");
	my_gradient.addColorStop(0.5,"blue");
	my_gradient.addColorStop(0.6,"white");
	my_gradient.addColorStop(0.7,"blue");
	my_gradient.addColorStop(0.8,"white");
	my_gradient.addColorStop(0.9,"blue");
	my_gradient.addColorStop(1.0,"white");
	
	//arrayFreqToOpenGL = readAndReturn(frequencyData);
	arrayFreqToOpenGL = frequencyData;

	// Regler l'amplitude de la courbe
	let echelle = 40/100;
	
	//We get the shape of the wave
    for (i = 0; i < barCount; i++) {
		//console.log(frequencyData[i * loopStep]);
        barHeight = parseInt(frequencyData[i * loopStep]* echelle + 16);

		context2.fillStyle = 'hsl(' + i*10 + ', 50%, 50%)';
		context2.fillRect(((barWidth + barSpacing) * i) + (barSpacing / 2), height-barHeight-20, barWidth - barSpacing, -height);
		
		context2.beginPath();
		context2.arc(((barWidth + barSpacing) * i) + (barSpacing / 2)+2, height-barHeight-10, 3, 0, 2 * Math.PI);

		context2.fillStyle = 'gold';	
		context2.fill();

		context2.fillStyle = my_gradient;
		
        context2.fillRect(((barWidth + barSpacing) * i) + (barSpacing / 2), height, barWidth - barSpacing, -barHeight);
		
    }

}


function drawWave(analyser) {
    var canvas, context3, width, height, barWidth, barHeight, barSpacing, waveData, barCount, loopStep, i, hue, hauteurArc, diff;
	
    canvas = document.getElementById('spectreWave');
	context3 = canvas.getContext('2d');
	
    width = canvas.width;
    height = canvas.height;
    barWidth = 1;
    barSpacing = 1;
 
    context3.clearRect(0, 0, width, height);
	waveData = new Uint8Array(analyser.fftSize);
    analyser.getByteTimeDomainData(waveData);
	//waveData = analyser;
	
	barCount = Math.round(width/2);
    loopStep = 3;
	
	var my_gradient=context3.createLinearGradient(0,0,800,0);
	my_gradient.addColorStop(0,"black");
	my_gradient.addColorStop(0.1,"red");
	my_gradient.addColorStop(0.2,"black");
	my_gradient.addColorStop(0.3,"red");
	my_gradient.addColorStop(0.4,"black");
	my_gradient.addColorStop(0.5,"red");
	my_gradient.addColorStop(0.6,"black");
	my_gradient.addColorStop(0.7,"red");
	my_gradient.addColorStop(0.8,"black");
	my_gradient.addColorStop(0.9,"red");
	my_gradient.addColorStop(1.0,"black");

	// regler l'amplitude de la barre
	let echelle = 40/100;
	
	for (i = 0; i < barCount; i++) {

        barHeight = parseInt(waveData[i * loopStep]*echelle+36);

		context3.fillStyle = my_gradient;
		context3.fillRect(((barWidth + barSpacing) * i) + (barSpacing / 2), height-barHeight-10, barWidth + barSpacing, -height);
		
		context3.beginPath();
		
		hauteurArc = height-barHeight-5;
		diff = (height-102-5);
		if(hauteurArc > (diff +1)) hauteurArc = hauteurArc + hauteurArc/diff +1;
		if(hauteurArc < (diff -1)) hauteurArc = hauteurArc - hauteurArc/diff -1;
		
		context3.arc(((barWidth + barSpacing) * i) + (barSpacing / 2)+2, hauteurArc, 5, 0, 2 * Math.PI);

		context3.fillStyle = 'gold';	
		context3.fill();

		context3.fillStyle = my_gradient;
		
        context3.fillRect(((barWidth + barSpacing) * i) + (barSpacing / 2), height, barWidth + barSpacing, -barHeight);
		
    }

}






function divideBy2(array){
	for(var i = 0; i<array.length; i++) array[i] = array[i] / 2;
	return array;
}



/** PART MELODY inspired by "La Marche de Sacco et Vanzetti - Ennio Morricone"**/
var dureeNote = 300;
var dureeNote2 = 75;

var stopMelodie = true;
var stopMelodie2 = true;

//var notesAjouerImperialMarch = ["G4","G4", "G4", "D#4/Eb4", "A#4/Bb4", "G4", "D#4/Eb4","A#4/Bb4", "G4", "D5", "D5", "D5", "D#5/Eb5", "A#4/Bb4", "F#4/Gb4", "D#4/Eb4","A#4/Bb4", "G4", "G5","G4","G4","G5","F#5/Gb5", "F5","E5","D#5/Eb5","E5", "rest", "G4", "rest","C#5/Db5","C5","B4","A#4/Bb4","A4","A#4/Bb4", "rest", "D#4/Eb4", "rest", "F#4/Gb4", "D#4/Eb4","A#4/Bb4", "G4" ,"D#4/Eb4","A#4/Bb4", "G4"];
//var beatsImperialMarch = [ 8, 8, 8, 6, 2, 8, 6 , 2 ,16 , 8, 8, 8, 6, 2, 8, 6, 2, 16,8,6,2,8,6,2,2, 2, 2,6,2,2,8,6,2,2,2,2,6,2,2,9,6,2,8,6,2,16];
//var noteNamesImperialMarch = ["D#4/Eb4", "E4", "F4", "F#4/Gb4", "G4", "G#4/Ab4", "A4", "A#4/Bb4", "B4", "C5", "C#5/Db5", "D5", "D#5/Eb5", "E5", "F5", "F#5/Gb5", "G5", "G#5/Ab5", "A5", "A#5/Bb5", "B5", "C6", "C#6/Db6", "D6", "D#6/Eb6", "E6", "F6", "F#6/Gb6", "G6"];
//var tonesImperialMarch = [1607, 1516, 1431, 1351, 1275, 1203, 1136, 1072, 1012, 955, 901, 851, 803, 758, 715, 675, 637, 601, 568, 536, 506, 477, 450, 425, 401, 379, 357, 337, 318];

//var notesAjouerImperialMarch = ["E","D","E","D","E","b","D","C","a","c","e","a","b","e","g","b","C","e","E","D","E","D","E","b","D","C","a","c","e","a","b","e","C","b","a","E","D","E","D","E","b","D","C","a","c","e","a","b","e","g","b","C","e","E","D","E","D","E","b","D","C","a","c","e","a","b","e","C","b","a","b","C","D","E","g","F","E","D","f","E","D","C","e","D","C","b","e","E","e","E","D","E","D","E","D","E","D","E","D","E","D","E","b","D","C","a","c","e","a","b","e","g","b","C","e","E","D","E","D","E","b","D","C","a","c","e","a","b","e","C","b","a"];
//var beatsImperialMarch = [ 1,1,1,1,1,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1,1,1,1,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1,1,1,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1,1,1,1,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1,2,1,1,1,2,1,1,1,2,1,1,1,3,1,5,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,1,3,1,1,1,3,1,1,1,3,1,1,1,1,1,1,1,1,1,3,1,1,1,3,1,1,1,6];
//var noteNamesImperialMarch = ['c','d','e','f','g','a','b','C', 'D', 'E', 'F', 'G', 'A', 'B', 'U']
//var tonesImperialMarch = [3822,3424,3033,2864,2551,2272,2024, 1915, 1700, 1519, 1432, 1275, 1136, 1014, 956];

//mibredosib =  "re#+","re+","do+","la#+"
var notesAjouerStarWarsL1 = ["fa","fa","fa","la#","fa++","re#+","re+","do+","la#+","fa+","re#+","re+","do+","la#+","fa+","re#+","re+","re#+"];
var notesAjouerStarWarsL2 = ["do+.","fa","fa","fa","do+","soupir","fa","fa","sol.","sol","re#+","re+","do+","la#+","la#+","do+","re+","do+","sol","la","fa","fa"];
var notesAjouerStarWarsL3 = ["sol.","sol","re#+","re+","do+","la#+","fa+","fa","fa","fa","sol.","sol","re#+","re+","do+","la#+"];
var notesAjouerStarWarsL4 = ["la#+","do+","re+","do+","sol","la","fa.","fa","la#+.","sol#+","fa#+.","fa+","re#+.","do#+","do+.","la#+","do+.","fa","fa","fa"];
var beatsStarWarsL1 = [4,4,4,16,8,4,4,4,16,8,4,4,4,16,8,4,4,4];
var beatsStarWarsL2 = [16,4,4,4,16,8,4,4,8,4,4,4,4,4,4,2,2,4,4,8,4,4];
var beatsStarWarsL3 = [8,4,4,4,4,4,16,8,4,4,8,4,4,4,4,4];
var beatsStarWarsL4 = [4,2,2,4,4,8,4,2,4,2,4,2,4,2,4,2,16,4,4,4];
var noteNamesStarWars = ['do','do#','re','re#','mi','fa','fa#','sol','sol#','la','la#','si']
var tonesStarWars = [261.626,277.183,293.665,311.127,329.628,349.228,369.994,391.995,415.305,440,466.164,493.883];
var noteNamesTxt = ['3','4','5','6','7','8','9','10','11','12','13','14'];

notesAjouerStarWars = notesAjouerStarWarsL1.concat(notesAjouerStarWarsL2).concat(notesAjouerStarWarsL3).concat(notesAjouerStarWarsL4);
beatsStarWars = beatsStarWarsL1.concat(beatsStarWarsL2).concat(beatsStarWarsL3).concat(beatsStarWarsL4);

//notesAjouerStarWars = notesAjouerStarWarsL4;
//beatsStarWars = beatsStarWarsL4;
tonesStarWars = divideBy2(tonesStarWars);

function reverseDiese(){
	for(var i=0; i<noteNamesStarWars.length; i++){
		if(noteNamesStarWars[i].indexOf("#") >= 0){
			var tmpNote = noteNamesStarWars[i];
			noteNamesStarWars[i] = noteNamesStarWars[i-1];
			noteNamesStarWars[i-1] = tmpNote;
			var tmpFreq = tonesStarWars[i];
			tonesStarWars[i] = tonesStarWars[i-1];
			tonesStarWars[i-1] = tmpFreq;
		}
	}
}

reverseDiese();

notePlayed0 = false;
var finish0 = true;
function runMelodieStarWars(i,j){
	
	var beat;
	finish0 = false;
	
	if(notePlayed0 == false && stopMelodie2 == false){

		var tempo;
		var notePlayedForHover = -1;
		
		if(i==j){

			for (var k = 0; k < noteNamesStarWars.length; k++) {
				
				if(notesAjouerStarWars[i].indexOf(noteNamesStarWars[k]) >= 0){
					
					var freqToPlay = tonesStarWars[k];
					if(notesAjouerStarWars[i].indexOf("+") >= 0) freqToPlay = freqToPlay*2;
					if(notesAjouerStarWars[i].indexOf("-") >= 0) freqToPlay = freqToPlay/2;
					noteToPlay = new Sound0(freqToPlay, tabType[type]);
					beat = tabMelodieDureeNoteStarWars[i];
					if(notesAjouerStarWars[i].indexOf(".") >= 0) beat = beat*1.5;
					
					
					notePlayedForHover = noteNamesTxt[k];
					//console.log(notesAjouerStarWars[i]+" freq:"+freqToPlay+" beat="+beat);
					break;
				}
				
			}
			
			if(notesAjouerStarWars[i] == "soupir"){
				beat = 1;
			}

			play0(notePlayedForHover);
			tempo = dureeNote2*beat;
		}else{
			tempo = 10;
		}

		setTimeout(function(){
			
			if(i==notesAjouerStarWars.length-1){
				runMelodieStarWars(0,0);
			}else{
				if(i==j){
					stop0(notePlayedForHover);

					finish0 = true;
					
					//we move on to the next musical note
					if(i<notesAjouerStarWars.length-1) runMelodieStarWars(i+1,j);
				}else{
					//we play time out
					runMelodieStarWars(i,j+1);
				}
			}
			
			//if(i==notesAjouerStarWars.length-1) runMelodieStarWars(0,0);
		
		}, tempo);
	}
}


var delayNote = 50;
var delayNote2 = 100;
//The melody contains the note and the delay
var tabMelodie = [];
tabMelodie[0] = [];
tabMelodie[1] = [];
//notes
tabMelodie[0][0] = [7,-1,3,-1,5,-1,2,-1,3,-1,2,-1,0,-1,2,-1];		
tabMelodie[0][1] = [7,-1,3,-1,5,-1,2,-1,3,-1,2,-1,0,-1,5,-1];		
tabMelodie[0][2] = [10,-1,7,-1,8,-1,5,-1,5,-1,7,-1,8,-1,7,-1];						
tabMelodie[0][3] = [7,-1,3,-1,5,-1,2,-1,3,-1,2,-1,0,-1];
				
//delay
//3+1+3+1+1+1+1+5 = 16
//3+1+3+1+1+1+1+5 = 16
//3+1+3+1+1+1+2+4 = 16
//3+1+3+1+2+2+4   = 16
tabMelodie[1][0] = [dureeNote*3,delayNote,dureeNote,delayNote,dureeNote*3,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote*5,delayNote];		
tabMelodie[1][1] = [dureeNote*3,delayNote,dureeNote,delayNote,dureeNote*3,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote*5,delayNote];			
tabMelodie[1][2] = [dureeNote*3,delayNote,dureeNote,delayNote,dureeNote*3,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote,delayNote,dureeNote*2,delayNote,dureeNote*4,delayNote];					
tabMelodie[1][3] = [dureeNote*3,delayNote,dureeNote,delayNote,dureeNote*3,delayNote,dureeNote,delayNote,dureeNote*2,delayNote,dureeNote*2,delayNote,dureeNote*4,delayNote];
				
//We divide by two to obtain the lower range
var tabFrequencesBasse = [220/2,233.1/2,247/2,261.6/2,277.2/2,293.7/2,311.1/2,329.6/2,349.2/2,370/2,392/2,415.3/2,440/2,466.2/2,493.9/2,523.3/2];
var tabMelodieBasse = [];
tabMelodieBasse[0] = [];
tabMelodieBasse[1] = [];
//notes
tabMelodieBasse[0][0] = [3,-1,2,-1,0,-3,10,-1];
tabMelodieBasse[0][1] = [3,-1,2,-1,0,-3,10,-1];
tabMelodieBasse[0][2] = [7,-1,5,-1,10,-1,3,-1];
tabMelodieBasse[0][3] = [3,-1,5,-1,7,-1,0,-1];
				
//delay
//4+4+4+4 = 16
//4+4+4+4 = 16
//4+4+4+4 = 16
//4+4+4+4 = 16
tabMelodieBasse[1][0] = [dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2];
tabMelodieBasse[1][1] = [dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2];
tabMelodieBasse[1][2] = [dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2];
tabMelodieBasse[1][3] = [dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2,dureeNote*4,delayNote2];
				
//Melody
notePlayed1 = false;
var finish1 = true;
function runMelodie1(i,j){

	finish1 = false;
	if(notePlayed1 == false && stopMelodie == false){

		if(tabMelodie[0][i][j] !== -1){
			noteToPlay = new Sound1(tabFrequences[tabMelodie[0][i][j]], tabType[type]);
			play1(tabMelodie[0][i][j]);
		}
		setTimeout(function(){
			if(tabMelodie[0][i][j] !== -1){
				stop1(tabMelodie[0][i][j]);
			}
			finish1 = true;
			
			//we move on to the next musical note
			if(j<tabMelodie[0][i].length-1) runMelodie1(i,j+1);
			
			//We move to the next partition line on both partitions
			if(j == tabMelodie[0][i].length-1 && i < tabMelodie[0].length-1){
				runMelodieAll(i+1);
			}
			//If it's the end we launch the two melodies
			if(j == tabMelodie[0][i].length-1 && i == tabMelodie[0].length-1){
				runMelodieAll(0);
			}
			
		}, tabMelodie[1][i][j]);
	}
}

/** Cloning tables so as not to affect the original values **/
function clone(array) {
	var arrayReturn = [];
	for(var j=0; j<array.length; j++){
		arrayReturn[j] = [];
		for(var i=0; i<array[j].length; i++){
			arrayReturn[j][i] = array[j][i];
		}
	}
	return arrayReturn;
}

function cloneSimpleTab(array) {
	var arrayReturn = [];
	for(var j=0; j<array.length; j++){
		arrayReturn[j] = array[j];
	}
	return arrayReturn;
}

var tabMelodieDureeNoteCopy = [];
tabMelodieDureeNoteCopy = clone(tabMelodie[1]);
var tabMelodieBasseDureeNoteCopy = [];
tabMelodieBasseDureeNoteCopy = clone(tabMelodieBasse[1]);
function modifierDureeNote(array,val,tabType){
	for(var j=0; j<array.length; j++){
		for(var i=0; i<array[j].length; i++){
			if(i%2 == 0){

				if(tabType == 0) array[j][i] = tabMelodieDureeNoteCopy[j][i] * val;
				if(tabType == 1) array[j][i] = tabMelodieBasseDureeNoteCopy[j][i] * val;
			
			}
		}
	}
}

var tabMelodieDureeNoteStarWars = [];
tabMelodieDureeNoteStarWars = cloneSimpleTab(beatsStarWars);
function modifierDureeNoteStarWars(array,val){
	for(var j=0; j<array.length; j++){
		array[j] = beatsStarWars[j] * val;
	}
}

function setVitesse(element){
	var val = parseFloat(element.value/500);
	modifierDureeNote(tabMelodie[1],val,0);
	modifierDureeNote(tabMelodieBasse[1],val,1);
	// //!\\ I did the opposite and used the copy (table) in the Star Wars melody
	modifierDureeNoteStarWars(tabMelodieDureeNoteStarWars,val);
}

function sommeTabDebug(array){
	var somme = 0;
	for(var j=0; j<array.length; j++){
		for(var i=0; i<array[j].length; i++){
			somme = somme + array[j][i];
		}
	}
	return somme;
}

function sommeTabLigneDebug(array){
	var somme = 0;
	for(var j=0; j<array.length; j++){
			somme = somme + array[j];
	}
	return somme;
}


notePlayed2 = false;
var firstExecMelodie = true;
var finish2 = true;
function runMelodie2(i,j,oct){
	finish2 = false;
	if(notePlayed2 == false && stopMelodie == false){
		var octave = "";
		if(tabMelodieBasse[0][i][j] == -2) octave = 'sup';
		if(tabMelodieBasse[0][i][j] == -3) octave = 'inf'; 
			
		if(tabMelodieBasse[0][i][j] >= 0){
			var freq = tabFrequences[tabMelodieBasse[0][i][j]];
			if(oct == 'sup') freq = freq*2;
			if(oct == 'inf') freq = freq/2;
			noteToPlay = new Sound2(freq, tabType[type]);
			play2(tabMelodieBasse[0][i][j]);
		}
		setTimeout(function(){
			if(tabMelodieBasse[0][i][j] >= 0){
				stop2(tabMelodieBasse[0][i][j]);
			}
			finish2 = true;
			
			//on passe a la note suivante
			if(j<tabMelodieBasse[0][i].length-1) runMelodie2(i,j+1,octave);

			if(firstExecMelodie == true){
				//We move on to the next score line
				if(j == tabMelodieBasse[0][i].length-1 && i < tabMelodieBasse[0].length-1) runMelodie2(i+1,0);
				//If it's the end we launch the two melodies
				if(j == tabMelodieBasse[0][i].length-1 && i == tabMelodieBasse[0].length-1){
					firstExecMelodie = false;
					runMelodieAll(0);
				}
			}else{
				//We move to the next partition line on both partitions
				if(j == tabMelodieBasse[0][i].length-1 && i < tabMelodieBasse[0].length-1){
					runMelodieAll(i+1);
				}
				//If it's the end we launch the two melodies
				if(j == tabMelodieBasse[0][i].length-1 && i == tabMelodieBasse[0].length-1){
					runMelodieAll(0);
				}
			}

			
			
		}, tabMelodieBasse[1][i][j]);
	}
}

function runMelodieAll(i){

	//runMelodie2(i,0);
	//runMelodie1(i,0);
	
	//crappy tricks to solve sync problems
	if(finish1 == true && finish2 == true) return Promise.all([runMelodie1(i,0),runMelodie2(i,0)]);
}




/**PART binding keys of keyboard **/
var tabNoteInfo = ['LA<br>2','LA<br>#2','SI<br>2','DO<br>3','DO<br>#3','RE<br>3','RE<br>#3','MI<br>3','FA<br>3','FA<br>#3','SOL<br>3','SOL<br>#3','LA<br>3','LA<br>#3','SI<br>3','DO<br>4'];
var tabTouches = ['q','z','s','d','r','f','t','g','h','u','j','i','k','o','l','m'];
var tabTouchesBool = [false,false,false,false,false,false,false,false,false,false,false,false,false,false,false,false];
//TODO to erase (mini note test table) #testNote //!\\ onclick events work with a delay, not like keys
var strTestNote = "<table><tr><td class='topPiano' id='topPiano0'>&nbsp;</td><td class='topPiano' id='topPiano2'>&nbsp;</td><td class='topPiano' id='topPiano3'>&nbsp;</td><td class='topPiano' id='topPiano5'>&nbsp;</td><td class='topPiano' id='topPiano7'>&nbsp;</td><td class='topPiano' id='topPiano8'>&nbsp;</td><td class='topPiano' id='topPiano10'>&nbsp;</td><td class='topPiano' id='topPiano12'>&nbsp;</td><td class='topPiano' id='topPiano14'>&nbsp;</td><td class='topPiano' id='topPiano15'>&nbsp;</td></tr><tr>";
var strTestNoteDiese = "<table><tr>";
for(var j=0; j<tabFrequences.length; j++){
	if(j !== 1 && j !== 4 && j !== 6 && j !== 9 && j !== 11 && j !== 13){
		strTestNote = strTestNote + "<td class='testNoteTD' id='testNoteTD"+j+"' onmousedown='play("+j+",false)' onmouseup='stop("+j+",false)' onmouseover='setPianoHover(" + j + ",1,true);' onmouseout='setPianoHover(" + j + ",1,false);'>" + tabTouches[j] + "<p class='pPiano'>" + tabNoteInfo[j] + "</p></td>";
	}else{
		strTestNoteDiese = strTestNoteDiese + "<td class='testNoteDieseTD' id='testNoteDieseTD"+j+"'  onmousedown='play("+j+",false)' onmouseup='stop("+j+",false);this.style.backgroundColor=\"black\"' onmouseover='setPianoHover(" + j + ",0,true);' onmouseout='setPianoHover(" + j + ",0,false);'>" + tabTouches[j] + "<p class='pPiano'>" + tabNoteInfo[j] + "</p></td>";
		if(j == 1 || j == 6) strTestNoteDiese = strTestNoteDiese + "<td class='testNoteDieseTDBlank'></td>";
	}
}
strTestNote = strTestNote + "</tr></table>";
strTestNoteDiese = strTestNoteDiese + "</tr></table>";



function playNoteKeyboard(freq){
	if(tabTouchesBool[freq] == false){
		noteToPlay = new SoundK(tabFrequences[freq], tabType[type], freq);
		tabTouchesBool[freq] = true;
	}
}

var playNoteK = function(event) {
    event.preventDefault();
  
    var keyCode = event.keyCode;
	if (typeof tabKeyNotes[keyCode] !== 'undefined') {
		var freq = tabKeyNotes[keyCode];
		if(tabTouchesBool[freq] == false){
			playNoteKeyboard(freq);
			setColorKeyboard(freq);
		}
	}
};

var endNoteK = function(event) {
	event.preventDefault();
	
	var keyCode = event.keyCode;
	if (typeof tabKeyNotes[keyCode] !== 'undefined') {
		// the variable is defined
		var freq = tabKeyNotes[keyCode];	
		stopK(freq);    
		unsetColorKeyboard(freq);
	}
};

function createKeyboardEvenement(){
	window.addEventListener('keydown', playNoteK);
	window.addEventListener('keyup', endNoteK);
}


window.addEventListener('load', function() {
    createKeyboardEvenement();
});

function setColorKeyboard(j){
	if(j !== 1 && j !== 4 && j !== 6 && j !== 9 && j !== 11 && j !== 13){		
		var id = "testNoteTD"+j;
		var id2 = 'topPiano'+j;
		document.getElementById(id2).style.backgroundColor = "cyan";
	}else{
		var id = "testNoteDieseTD"+j;
	}
	document.getElementById(id).style.backgroundColor = "cyan";
}

function unsetColorKeyboard(j){
	if(j !== 1 && j !== 4 && j !== 6 && j !== 9 && j !== 11 && j !== 13){
		var id = "testNoteTD"+j;
		document.getElementById(id).style.backgroundColor = "white";
		var id2 = 'topPiano'+j;
		document.getElementById(id2).style.backgroundColor = "white";
	}else{
		var id = "testNoteDieseTD"+j;
		document.getElementById(id).style.backgroundColor = "black";
	}
}


var effectAlreadyActive = false;
function stopK(i){
	safeDisconnect(oscillatorTab[i]);
	tabTouchesBool[i] = false;
}

function SoundK(frequency, type, i) {
    oscillatorTab[i].frequency.value = frequency;
    oscillatorTab[i].type = type;
    oscillatorTab[i].connect(lBand);
	oscillatorTab[i].connect(hBand);
	oscillatorTab[i].connect(mGain);
}


async function stopAllSounds(){
	document.getElementById('runMelodie1').style.backgroundColor = 'white';
	document.getElementById('runMelodieStarWars').style.backgroundColor = 'white';
	document.getElementById('runMelodie1').style.outline = 'none';
	document.getElementById('runMelodieStarWars').style.outline = 'none';
	stopMelodie = true;
	stopMelodie2 = true;
	stopMelodieBool = true;
	stopTheremin();
	stopDrumMachine();
}

async function stopAllSounds2(){
	document.getElementById('runMelodie1').style.backgroundColor = 'white';
	document.getElementById('runMelodieStarWars').style.backgroundColor = 'white';
	document.getElementById('runMelodie1').style.outline = 'none';
	document.getElementById('runMelodieStarWars').style.outline = 'none';
	stopMelodie = true;
	stopMelodie2 = true;
	stopTheremin();
	stopDrumMachine();
	if (audioCtx) await audioCtx.close();
	stopMelodieBool = true;
	audioCtx = new AudioContext();
  	if (audioCtx.state === 'suspended') await audioCtx.resume();
	initAudioContext2();
	paused = true;
	restartMp3IconColor();
	elapsedTimeSinceStart = 0;
}

function setDefaultVariableMelodie(){
	if(stopMelodie == true){
		firstExecMelodie = true;
		stopMelodie=false;
		finish1 = true;
		finish2 = true;
	}
	
	if(stopMelodie2 == true){
		stopMelodie2=false;
		finish0 = true;
	}
}


function manualUpdateFrequency(val){
	let sliderFreq = document.getElementById('frequencyRangeTest');
	let displaySliderFreq = document.getElementById('frequencyRangeTestDisplay');
	displaySliderFreq.textContent = val;
	//range 0 à 3000 en pourcentage
	let percent = val/3000*100;
	// CSS custom property pour le remplissage
	sliderFreq.style.setProperty('--value', `${percent}%`);
}


function setDefaultValues(){
	
	//FILTER
	var typeFiltre = document.getElementById('filterTest').value;
	changeEffect(typeFiltre);
	changeFrequency(document.getElementById('frequencyRangeTest').value);
	changeQuality(document.getElementById('qualityRangeTest').value);
	changeGain(document.getElementById('gainRangeTest').value);
	
	//EQUALIZER
	changeGainEg("33","lGain");
	changeGainEg("33","mGain");
	changeGainEg("33","hGain");
	
	//VOLUME
	changeVolume(document.getElementById('volumeRange'));
}

function callMelodie(title){
	if(title == "La Marche de Sacco et Vanzetti"){
		if(stopMelodie2 == true){
			setDefaultVariableMelodie();
			runMelodie2(0,0);
			var element = document.getElementById("runMelodie1");
			setBackgroundColor(element,'cyan');
			element.style.outline = "thick double #32a1ce";
		}
	}else if(title == "Star Wars"){
		if(stopMelodie == true){
			setDefaultVariableMelodie();
			runMelodieStarWars(0,0);
			var element = document.getElementById("runMelodieStarWars");
			setBackgroundColor(element,'cyan');
			element.style.outline = "thick double #32a1ce";
		}
	}
}


function loadInputSound(element) {
	
	loadAudio(element.files[0]);
	if(isUnlocked) document.getElementById("currentMp3").innerHTML = element.files[0].name;

	// Method 1: Create a completely new input (recommended)
	element.type = 'text';  // temporary change
	element.type = 'file';  // back to file – this clears it

}

async function loadAudio(file) {
	try {
	  // Load an audio file
	  // Decode it
	  audioCtx.decodeAudioData(await file.arrayBuffer(), playBuffer);
	} catch (err) {
	  console.error(`Unable to fetch the audio file. Error: ${err.message}`);
	}
}

soundMP3_is_loaded = false;

var mp3Buffer;
var source;

function playBuffer(buffer) {

	if(!isUnlocked) {
		openPopin();
		return;
	}
	
	safeDisconnect(source);
	source = audioCtx.createBufferSource();
	source.buffer = buffer;
	mp3Buffer = buffer;
	drawTrack(buffer,1,0);
	source.connect(lBand);
	source.connect(hBand);
	source.connect(mGain);
	source.connect(gainNode);

	source.loop = true;
	source.start();
	paused = false;
	restartMp3IconColor();

	lastTime = audioCtx.currentTime;

	soundMP3_is_loaded = true;
	elapsedTimeSinceStart = 0;
	animateTime();

	// Optional: configure
	source.loop = true;

	// Add ended handler (optional but recommended)
	source.onended = () => {
		source.disconnect(); // clean up
		source.buffer = null; // aide le garbage collector
	};
}

/**
*	POUR DESSINER LES COURBES
*	@see loadBuffer()
**/
function drawTrack(decodedBuffer,nb,nbI){	
	//alert("decodedBuffer ="+decodedBuffer);
	//alert("nb ="+nb);
	//alert("nbI ="+nbI);
	
	//var canvas = document.getElementById('canvasFront');
	var canvas = document.getElementById('spectreMP3');
	

	waveformDrawer = new WaveformDrawer();
	
	waveformDrawer.init(decodedBuffer, canvas, 'green');  
	// First parameter = Y position (top left corner)
	// second = height of the sample drawing
	waveformDrawer.drawWave((((canvas.getBoundingClientRect().height/nb)*(nbI))+(canvas.getBoundingClientRect().height/nb)*0.2), ((canvas.getBoundingClientRect().height/nb)-(canvas.getBoundingClientRect().height/nb)*0.4));
	//waveformDrawer.drawWave(0, canvas.height);
}



/** PART SPECTRUM MP3 */
function WaveformDrawer() {
    this.decodedAudioBuffer;
    this.peaks;
    this.canvas;
    this.displayWidth;
    this.displayHeight;
    this.sampleStep =  10;
    this.color = 'green';
    //test

    this.init = function(decodedAudioBuffer, canvas, color) {
		this.decodedAudioBuffer = decodedAudioBuffer;
        this.canvas = canvas;
        this.displayWidth = canvas.width;
        this.displayHeight = canvas.height;
        this.color = color;
        //this.sampleStep = sampleStep;

        // Initialize the peaks array from the decoded audio buffer and canvas size
        this.getPeaks();
    }

    this.max = function max(values) {
        var max = -Infinity;
        for (var i = 0, len = values.length; i < len; i++) {
            var val = values[i];
            if (val > max) { max = val; }
        }
        return max;
    }
    // Fist parameter : where to start vertically in the canvas (useful when we draw several
    // waveforms in a single canvas)
    // Second parameter = height of the sample
    this.drawWave = function(startY, height) {
		
		document.getElementById('spectreMP3').style.backgroundColor = 'black';
		
        var ctx = this.canvas.getContext('2d');

		// clear canvas
		ctx.clearRect(0, 0, this.canvas.getBoundingClientRect().width, this.canvas.getBoundingClientRect().height);

        ctx.save();
        ctx.translate(0, startY);

        //ctx.fillStyle = this.color;
        //ctx.strokeStyle = this.color;
		
		ctx.fillStyle = 'blue';
        ctx.strokeStyle = 'blue';

        var width = this.displayWidth;
        var coef = height / (2 * this.max(this.peaks));
        var halfH = height / 2;

        ctx.beginPath();
        ctx.moveTo(0, halfH);
        ctx.lineTo(width, halfH);
        console.log("drawing from 0, " + halfH + " to " + width + ", " + halfH);
        ctx.stroke();


        ctx.beginPath();
        ctx.moveTo(0, halfH);
       
        for (var i = 0; i < width; i++) {
            var h = Math.round(this.peaks[i] * coef);
            ctx.lineTo(i, halfH + h);
        }
        ctx.lineTo(width, halfH);

        ctx.moveTo(0, halfH);

        for (var i = 0; i < width; i++) {
            var h = Math.round(this.peaks[i] * coef);
            ctx.lineTo(i, halfH - h);
        }

        ctx.lineTo(width, halfH);

        ctx.fill();
        
        ctx.restore();
        }

    // Builds an array of peaks for drawing
    // Need the decoded buffer
    // Note that we go first through all the sample data and then
    // compute the value for a given column in the canvas, not the reverse
    // A sampleStep value is used in order not to look each indivudal sample
    // value as they are about 15 millions of samples in a 3mn song !
    this.getPeaks = function() {
        var buffer = this.decodedAudioBuffer;
        var sampleSize = Math.ceil(buffer.length / this.displayWidth);

        console.log("sample size = " + buffer.length);

        this.sampleStep = this.sampleStep || ~~(sampleSize / 10);

        var channels = buffer.numberOfChannels;
        // The result is an array of size equal to the displayWidth
        this.peaks = new Float32Array(this.displayWidth);

        // For each channel
        for (var c = 0; c < channels; c++) {
            var chan = buffer.getChannelData(c);

            for (var i = 0; i < this.displayWidth; i++) {
                var start = ~~(i * sampleSize);
                var end = start + sampleSize;
                var peak = 0;
                for (var j = start; j < end; j += this.sampleStep) {
                    var value = chan[j];
                    if (value > peak) {
                        peak = value;
                    } else if (-value > peak) {
                        peak = -value;
                    }
                }
                if (c > 1) {
                    this.peaks[i] += peak / channels;
                } else {
                    this.peaks[i] = peak / channels;
                }
            }
        }
    }
}

// requestAnim shim layer by Paul Irish, like that canvas animation works
// in all browsers
window.requestAnimFrame = (function() {
    return window.requestAnimationFrame ||
            window.webkitRequestAnimationFrame ||
            window.mozRequestAnimationFrame ||
            window.oRequestAnimationFrame ||
            window.msRequestAnimationFrame ||
            function(/* function */ callback, /* DOMElement */ element) {
                window.setTimeout(callback, 1000 / 60);
            };
})();

// Useful for memorizing when we paused the song
var lastTime = 0;
var currentTime;
var delta;

elapsedTimeSinceStart = 0;
var paused = true;

function animateTime() {
    if (!paused) {
        // Draw the time on the front canvas
        currentTime = audioCtx.currentTime;
        var delta = currentTime - lastTime;


        var totalTime;

		canvasMP3 = document.getElementById('spectreTimelineMP3');
		
        var frontCtx = canvasMP3.getContext('2d');

        frontCtx.clearRect(0, 0, canvasMP3.getBoundingClientRect().width, canvasMP3.getBoundingClientRect().height);
        frontCtx.fillStyle = 'white';
        frontCtx.font = '14pt Arial';

		if( elapsedTimeSinceStart < 100 ) {
			frontCtx.fillText(elapsedTimeSinceStart.toPrecision(3), 390, 15);
		} else {
			frontCtx.fillText(elapsedTimeSinceStart.toPrecision(4), 390, 15);
		}

        //console.log("dans animate");

        // at least one track has been loaded
        if (soundMP3_is_loaded != false) {

            var totalTime = mp3Buffer.duration;
            var x = elapsedTimeSinceStart * canvasMP3.getBoundingClientRect().width / totalTime;

            frontCtx.strokeStyle = "white";
            frontCtx.lineWidth = 3;
            frontCtx.beginPath();
            frontCtx.moveTo(x, 0);
            frontCtx.lineTo(x, canvasMP3.getBoundingClientRect().height);
            frontCtx.stroke();

            elapsedTimeSinceStart += delta;
            lastTime = currentTime;
        }
    }
    requestAnimFrame(animateTime);
}

function jumpTo(mousePos) {
	canvasMP3 = document.getElementById('spectreTimelineMP3');
    console.log("in jumpTo x = " + mousePos.x + " y = " + mousePos.y);
    // width - totalTime
    // x - ?
    //stopAllTracks();
    var totalTime = mp3Buffer.duration;
	//TODO fix bug souris
    var startTime = (mousePos.x * totalTime) / canvasMP3.getBoundingClientRect().width;
	elapsedTimeSinceStart = startTime;
	source.stop();
	safeDisconnect(source,gainNode);
	safeDisconnect(source,lBand);
	safeDisconnect(source,hBand);
	safeDisconnect(source,mGain);
	source = audioCtx.createBufferSource();
	source.buffer = mp3Buffer;
	source.connect(lBand);
	source.connect(hBand);
	source.connect(mGain);
	source.connect(gainNode);
	source.start(0,startTime);
}

let elapsedTimeFromPause = 0;

function pauseMp3(){
	source.stop();
	elapsedTimeFromPause = source.context.currentTime;
	paused = true;
	restartMp3IconColor();
}

function restartMp3IconColor() {
	let elem = document.getElementById('playMp3');
	if( paused == false ) {
		elem.classList.add('rainbow-icon');
	} else {
		elem.classList.remove('rainbow-icon');
	}
}

function restartMp3(buffer){
	if( mp3Buffer !== undefined ){
		paused = false;
		restartMp3IconColor();
		safeDisconnect(source,gainNode);
		safeDisconnect(source,lBand);
		safeDisconnect(source,hBand);
		safeDisconnect(source,mGain);
		source = audioCtx.createBufferSource();
		source.buffer = mp3Buffer;
		source.connect(lBand);
		source.connect(hBand);
		source.connect(mGain);
		source.connect(gainNode);
		source.start(0,elapsedTimeFromPause);
	}
}

function getMousePos(canvas, evt) {
    // get canvas position
    var obj = canvas;
    var top = 0;  
    var left = 0;
 
    while (obj && obj.tagName != 'BODY') {
        top += obj.offsetTop;
        left += obj.offsetLeft;
        obj = obj.offsetParent;
    }
    // return relative mouse position
    var mouseX = evt.clientX - left + window.pageXOffset;
    var mouseY = evt.clientY - top + window.pageYOffset;
    return {
        x:mouseX,
        y:mouseY
    };
}




	/** THEREMIN */

    // ────────────────────────────────────────────────
    //  NŒUDS AUDIO + EFFETS
    // ────────────────────────────────────────────────
    let osc, sourceGain, delayNode, feedbackGain, delayFilter, delayWetGain,
        reverbNode, reverbWetGain;

	// ────────────────────────────────────────────────
    //  UI + variables (le reste reste identique)
    // ────────────────────────────────────────────────

    const STEPS = 16;
    const MIN_FREQ = 80;
    const MAX_FREQ = 1200;

    let bpmTheremin = 130;
    let silencePercent = 20;
    let stepDurationMs = 60000 / bpmTheremin / 4;

    const stepsData = Array(STEPS).fill().map((_, i) => ({
      freq: 440,
      vol: 0.7,
      marker: null,
      enabled: true
    }));

    let currentStepTheremin = 0;

    function initAudioGraphTheremin() {
      sourceGain = audioCtx.createGain();
      sourceGain.gain.value = 0.72; // headroom

      // Delay (comme avant)
      delayNode = audioCtx.createDelay(1.2);
      delayNode.delayTime.value = 0.32;

      feedbackGain = audioCtx.createGain();
      feedbackGain.gain.value = 0.42;

      delayFilter = audioCtx.createBiquadFilter();
      delayFilter.type = "lowpass";
      delayFilter.frequency.value = 4200;
      delayFilter.Q.value = 0.707;

      delayWetGain = audioCtx.createGain();
      delayWetGain.gain.value = 0.28;

      // Reverb (convolver + mix)
      reverbNode = audioCtx.createConvolver();
      reverbWetGain = audioCtx.createGain();
      reverbWetGain.gain.value = 0.22;

      generateHallImpulse(); // crée l'impulsion de réverb

      // Connexions
      //sourceGain.connect(audioCtx.destination);           // dry

      // Delay send → return
      sourceGain.connect(delayNode);
      delayNode.connect(delayFilter);
      delayFilter.connect(feedbackGain);
      feedbackGain.connect(delayNode);
      delayNode.connect(delayWetGain);
      delayWetGain.connect(analyserNode);

      // Reverb send → return
      sourceGain.connect(reverbNode);
      reverbNode.connect(reverbWetGain);
      reverbWetGain.connect(analyserNode);

	  sourceGain.connect(lBand);
	  sourceGain.connect(hBand);
	  sourceGain.connect(mGain);

	  //delayWetGain.connect(lBand);
	  //delayWetGain.connect(hBand);
	  //delayWetGain.connect(mGain);

	  //reverbWetGain.connect(lBand);
	  //reverbWetGain.connect(hBand);
	  //reverbWetGain.connect(mGain);
    }

    // Génère une impulse response hall simple (procédurale)
    function generateHallImpulse() {
      const sampleRate = audioCtx.sampleRate;
      const length = sampleRate * 2.8; // ~2.8 secondes
      const impulse = audioCtx.createBuffer(2, length, sampleRate);

      const left = impulse.getChannelData(0);
      const right = impulse.getChannelData(1);

      for (let i = 0; i < length; i++) {
        const t = i / sampleRate;
        const decay = Math.exp(-t * 1.8) * (1 - t / 2.8);
        const noise = Math.random() * 2 - 1;
        left[i]  = noise * decay * (0.6 + Math.sin(t * 12) * 0.2);
        right[i] = noise * decay * (0.6 + Math.cos(t * 15) * 0.2);
      }

      reverbNode.buffer = impulse;
    }

	function preset(){
		for (let i = 0; i < STEPS; i++) {
			// on recupère l'element
			let rectElem = document.getElementById('rectStep'+i);
			let rect = rectElem.getBoundingClientRect();
			let cx = rect.left + Math.floor(Math.random() * (rect.right - rect.left));
			let cy = rect.top +Math.floor(Math.random() * (rect.bottom - rect.top));
			updatePreset(cx, cy, rect, i);
		}
	}

	function updatePreset(clientX, clientY, rect, i) {
        const x = Math.max(0, Math.min(rect.width, clientX - rect.left));
        const y = Math.max(0, Math.min(rect.height, clientY - rect.top));
        stepsData[i].freq = MIN_FREQ + (x / rect.width) * (MAX_FREQ - MIN_FREQ);
        stepsData[i].vol  = Math.max(0.05, 1 - (y / rect.height));
		let marker = document.getElementById('marker'+i);
        marker.style.left = x + 'px';
        marker.style.top  = y + 'px';
    }


	//TODO SET TIMEOUT 2 secondes ici
setTimeout(() => {

	const sequencer = document.getElementById('sequencer');
    const muteGrid = document.getElementById('muteGrid');
    const muteGrid2 = document.getElementById('muteGrid2');
    const playBtn = document.getElementById('play');

    // Mute checkboxes
    for (let i = 0; i < STEPS; i++) {
      const div = document.createElement('div');
      div.className = 'mute-item';
      const cb = document.createElement('input');
      cb.type = 'checkbox';
      cb.checked = true;
      cb.addEventListener('change', () => stepsData[i].enabled = cb.checked);
      const label = document.createElement('label');
      label.textContent = i+1;
      div.append(cb, label);
      cb.id = "checkbox"+i;
      if(i>7) {
        muteGrid2.appendChild(div);
      }else{
        muteGrid.appendChild(div);
      }
    }

    // Contrôles sliders
    document.getElementById('tempo').addEventListener('input', e => {
      bpmTheremin = +e.target.value;
      document.getElementById('bpmThereminDisplay').textContent = `${bpmTheremin} BPM`;
      stepDurationMs = 60000 / bpmTheremin / 4;
      if (isPlayingTheremin) restartInterval();
    });

    document.getElementById('silence').addEventListener('input', e => {
      silencePercent = +e.target.value;
      document.getElementById('silenceDisplay').textContent = `${silencePercent}%`;
    });

    document.getElementById('delayMix').addEventListener('input', e => {
      const v = e.target.value / 100;
      delayWetGain.gain.setValueAtTime(v, audioCtx.currentTime);
      document.getElementById('delayMixVal').textContent = `${e.target.value}%`;
    });

    document.getElementById('delayFeedback').addEventListener('input', e => {
      const v = e.target.value / 100;
      feedbackGain.gain.setValueAtTime(v, audioCtx.currentTime);
      document.getElementById('delayFbVal').textContent = `${e.target.value}%`;
    });

    document.getElementById('delayTime').addEventListener('input', e => {
      const ms = +e.target.value;
      delayNode.delayTime.linearRampToValueAtTime(ms / 1000, audioCtx.currentTime + 0.03);
      document.getElementById('delayTimeVal').textContent = `${ms} ms`;
    });

    // Reverb mix
    document.getElementById('reverbMix').addEventListener('input', e => {
      const v = e.target.value / 100;
      reverbWetGain.gain.setValueAtTime(v, audioCtx.currentTime);
      document.getElementById('reverbMixVal').textContent = `${e.target.value}%`;
    });

    // Création steps UI (inchangée)
    for (let i = 0; i < STEPS; i++) {
      const step = document.createElement('div');
      step.className = 'step';
	  step.id = 'rectStep'+i;
      step.dataset.index = i;

      const marker = document.createElement('div');
      marker.className = 'marker';
	  marker.id = 'marker'+i;
      step.appendChild(marker);

      const midX = 50, midY = 50;
      marker.style.left = midX + '%';
      marker.style.top  = midY + '%';

      stepsData[i].marker = marker;
      stepsData[i].freq = MIN_FREQ + (midX/100) * (MAX_FREQ - MIN_FREQ);
      stepsData[i].vol  = 1 - (midY/100);

      step.append

      const checkbox = document.createElement('div');
      const ctn = document.createElement('div');
      checkbox.id = "checkbtn"+i;
      checkbox.className = "checkbox";
      ctn.appendChild(checkbox);
      ctn.appendChild(step);
      if(i > 7 ) {
        ctn.appendChild(step);
        ctn.appendChild(checkbox);
        checkbox.style.top = '20px';    
      } else {
        ctn.appendChild(checkbox);
        ctn.appendChild(step);
        checkbox.style.top = '-20px';
      }
        
      ctn.addEventListener('mouseover', () => {
        checkElement = document.getElementById("checkbox"+i);
        if (checkElement.checked){
            checkbox.style.backgroundColor = 'blue'
        }
      });
      
      ctn.addEventListener('mouseout', () => {
        checkElement = document.getElementById("checkbox"+i);
        if (checkElement.checked){
            checkbox.style.backgroundColor = 'transparent'
        }
      });

      checkbox.addEventListener('click', () => {
        checkElement = document.getElementById("checkbox"+i);
        if (checkElement.checked){
          checkbox.style.backgroundColor = 'red';
          checkElement.checked = false;
          checkbox.parentElement.style.opacity = "0.1";
        } else {
          checkbox.style.backgroundColor = 'blue';
          checkElement.checked = true;
          checkbox.parentElement.style.opacity = "1.0";
        }
        stepsData[i].enabled = checkElement.checked;
      });

      sequencer.appendChild(ctn);

      let isDraggingTheremin = false;

      const update = (clientX, clientY, rect) => {
        const x = Math.max(0, Math.min(rect.width, clientX - rect.left));
        const y = Math.max(0, Math.min(rect.height, clientY - rect.top));
        stepsData[i].freq = MIN_FREQ + (x / rect.width) * (MAX_FREQ - MIN_FREQ);
        stepsData[i].vol  = Math.max(0.05, 1 - (y / rect.height));
        marker.style.left = x + 'px';
        marker.style.top  = y + 'px';
      };

      const start = (e, touch=false) => {
        isDraggingTheremin = true;
        const rect = step.getBoundingClientRect();
        const cx = touch ? e.touches[0].clientX : e.clientX;
        const cy = touch ? e.touches[0].clientY : e.clientY;
        update(cx, cy, rect);
      };

      step.addEventListener('mousedown', e => start(e));
      step.addEventListener('touchstart', e => { e.preventDefault(); start(e, true); }, {passive:false});

      const move = (e, touch=false) => {
        if (!isDraggingTheremin) return;
        const rect = step.getBoundingClientRect();
        const cx = touch ? e.touches[0].clientX : e.clientX;
        const cy = touch ? e.touches[0].clientY : e.clientY;
        update(cx, cy, rect);
      };

      document.addEventListener('mousemove', e => move(e));
      document.addEventListener('touchmove', e => move(e, true), {passive:false});

      document.addEventListener('mouseup', () => isDraggingTheremin = false);
      document.addEventListener('touchend', () => isDraggingTheremin = false);
    }

    function startOsc() {
      if (osc) osc.stop();
      osc = audioCtx.createOscillator();
      osc.type = 'sine';
      osc.connect(sourceGain);
      osc.start();
    }

    function playNextStep() {
      const now = audioCtx.currentTime;
      const step = stepsData[currentStepTheremin];

      document.querySelectorAll('.playing').forEach(el => el.classList.remove('playing'));
      const currentEl = document.querySelector(`.step[data-index="${currentStepTheremin}"]`);
      if (currentEl) currentEl.classList.add('playing');

      if (!step.enabled) {
        if (silencePercent === 0) {
          sourceGain.gain.linearRampToValueAtTime(0.001, now + 0.08);
        }
        currentStepTheremin = (currentStepTheremin + 1) % STEPS;
        return;
      }

      const silenceSec = (stepDurationMs / 1000) * (silencePercent / 100);
      const noteSec = (stepDurationMs / 1000) - silenceSec;

      osc.frequency.cancelScheduledValues(now);
      osc.frequency.setValueAtTime(osc.frequency.value || step.freq, now);
      osc.frequency.linearRampToValueAtTime(step.freq, now + 0.02);

      if (silencePercent === 0) {
        sourceGain.gain.cancelScheduledValues(now);
        sourceGain.gain.linearRampToValueAtTime(step.vol, now + 0.03);
      } else {
        sourceGain.gain.cancelScheduledValues(now);
        sourceGain.gain.setValueAtTime(step.vol, now);
        sourceGain.gain.linearRampToValueAtTime(0.001, now + noteSec * 0.8);
      }

      currentStepTheremin = (currentStepTheremin + 1) % STEPS;
    }

    function restartInterval() {
      if (!isPlayingTheremin) return;
      clearInterval(interval);
      interval = setInterval(playNextStep, stepDurationMs);
    }

    playBtn.addEventListener('click', async () => {
      if (isPlayingTheremin) {
			clearInterval(interval);
			if (osc) osc.stop();
			playBtn.textContent = 'PLAY LOOP';
			playBtn.classList.remove('active');
			document.querySelectorAll('.playing').forEach(el => el.classList.remove('playing'));
			isPlayingTheremin = false;
			return;
		}

      await audioCtx.resume();
      startOsc();
      currentStepTheremin = 0;
      playNextStep();

      interval = setInterval(playNextStep, stepDurationMs);

      playBtn.textContent = 'STOP';
      playBtn.classList.add('active');
      isPlayingTheremin = true;
    });

}, 2000);

function stopTheremin(){
	clearInterval(interval);
    if (osc) osc.stop();
	let playBtnEl = document.getElementById("play");
    playBtnEl.textContent = 'PLAY LOOP';
    playBtnEl.classList.remove('active');
    document.querySelectorAll('.playing').forEach(el => el.classList.remove('playing'));
    isPlayingTheremin = false;
    return;
}




	/** DRUM MACHINE */

 	let bpm = 120;
    let beatDuration = 60 / bpm;

	// Séquenceur
    let currentStep = 0;
    let nextBeatTime = 0;
    let isPlayingDrumMachine = false;

	const leds = [];
    const instruments = ['kick','snare','hihat','clap','tom','ride','crash'];

	// Pattern éditable – objet avec booléens
    const pattern = {
      kick:  Array(16).fill(false).map((_,i) => [0,4,8,12,15].includes(i)),
      snare: Array(16).fill(false).map((_,i) => i%4===2),
      hihat: Array(16).fill(false).map((_,i) => i%2===0),
      clap:  Array(16).fill(false).map((_,i) => i%8===6 || i%8===14),
      tom:   Array(16).fill(false),
      ride:  Array(16).fill(false).map((_,i) => i%4===3),
      crash: Array(16).fill(false).map((_,i) => i===0),
    };

	let masterGain, reverbWetDM, reverbDM, delayDM, feedbackDM, delayWetDM ;

	function initAudioGraphDrumMachine() {
		// Effets (comme avant)
		masterGain = audioCtx.createGain();
		masterGain.gain.value = 0.9;
		
		//masterGain.connect(audioCtx.destination);

		masterGain.connect(lBand);
	  	masterGain.connect(hBand);
	  	masterGain.connect(mGain);

		reverbDM = audioCtx.createConvolver();
		reverbDM.buffer = generateImpulse(1.4, 0.45);
		reverbWetDM = audioCtx.createGain();
		reverbWetDM.gain.value = 0.18;
		reverbDM.connect(reverbWetDM);
		reverbWetDM.connect(masterGain);

		delayDM = audioCtx.createDelay(0.6);
		delayDM.delayTime.value = 0.3;
		feedbackDM = audioCtx.createGain();
		feedbackDM.gain.value = 0.32;
		delayWetDM = audioCtx.createGain();
		delayWetDM.gain.value = 0.12;
		delayDM.connect(feedbackDM);
		feedbackDM.connect(delayDM);
		delayDM.connect(delayWetDM);
		delayWetDM.connect(masterGain);
	}

    function generateImpulse(seconds, decay) {
      const len = audioCtx.sampleRate * seconds;
      const buf = audioCtx.createBuffer(2, len, audioCtx.sampleRate);
      const l = buf.getChannelData(0);
      const r = buf.getChannelData(1);
      for (let i = 0; i < len; i++) {
        const amp = (Math.random() * 2 - 1) * Math.pow(1 - i/len, decay);
        l[i] = amp; r[i] = amp;
      }
      return buf;
    }

    function connectWithFX(src) {
      const dry = audioCtx.createGain();
      dry.gain.value = 1;
      src.connect(dry); dry.connect(masterGain);
      src.connect(reverbDM);
      src.connect(delayDM);
    }

    // Sons (comme avant – je les raccourcis pour la lisibilité)
    function playKick(t) { /* même code que précédemment */ 
      const o = audioCtx.createOscillator(); const g = audioCtx.createGain();
      o.type = 'sine'; o.frequency.setValueAtTime(180, t); o.frequency.exponentialRampToValueAtTime(55, t + 0.07);
      g.gain.setValueAtTime(1.4, t); g.gain.exponentialRampToValueAtTime(0.001, t + 0.14);
      o.connect(g); connectWithFX(g); o.start(t); o.stop(t + 0.18);
    }

    function playSnare(t) { /* même code */ 
      const n = audioCtx.createBufferSource(); const b = audioCtx.createBuffer(1, audioCtx.sampleRate*0.14, audioCtx.sampleRate);
      const d = b.getChannelData(0); for (let i=0;i<d.length;i++) d[i]=Math.random()*2-1;
      n.buffer = b; const g = audioCtx.createGain(); const f = audioCtx.createBiquadFilter();
      f.type='lowpass'; f.frequency.value=2400; g.gain.setValueAtTime(1.0, t); g.gain.exponentialRampToValueAtTime(0.001, t + 0.16);
      n.connect(f); f.connect(g); connectWithFX(g); n.start(t);
    }

    function playHiHat(t, closed=true) { /* même code */ 
      const n = audioCtx.createBufferSource(); const b = audioCtx.createBuffer(1, audioCtx.sampleRate*0.05, audioCtx.sampleRate);
      const d = b.getChannelData(0); for (let i=0;i<d.length;i++) d[i]=Math.random()*2-1;
      n.buffer = b; const g = audioCtx.createGain(); const f = audioCtx.createBiquadFilter();
      f.type='highpass'; f.frequency.value = closed?8500:4800;
      g.gain.setValueAtTime(closed?0.5:0.7, t); g.gain.exponentialRampToValueAtTime(0.001, t+(closed?0.04:0.10));
      n.connect(f); f.connect(g); connectWithFX(g); n.start(t);
    }

    function playClap(t) { playSnare(t); playHiHat(t+0.004,false); playHiHat(t+0.011,false); }
    function playTom(t) { /* même code tom */ 
      const o = audioCtx.createOscillator(); const g = audioCtx.createGain();
      o.type='sine'; o.frequency.setValueAtTime(130,t); o.frequency.exponentialRampToValueAtTime(70,t+0.14);
      g.gain.setValueAtTime(1.0,t); g.gain.exponentialRampToValueAtTime(0.001,t+0.28);
      o.connect(g); connectWithFX(g); o.start(t); o.stop(t+0.32);
    }

    function playRide(t) { /* même code ride */ 
      const n = audioCtx.createBufferSource(); const b = audioCtx.createBuffer(1, audioCtx.sampleRate*0.7, audioCtx.sampleRate);
      const d = b.getChannelData(0); for (let i=0;i<d.length;i++) d[i]=(Math.random()*2-1)*Math.pow(1-i/d.length,4);
      n.buffer = b; const g = audioCtx.createGain(); const f = audioCtx.createBiquadFilter();
      f.type='bandpass'; f.frequency.value=6200; f.Q.value=3; g.gain.setValueAtTime(0.4,t); g.gain.exponentialRampToValueAtTime(0.001,t+0.7);
      n.connect(f); f.connect(g); connectWithFX(g); n.start(t);
    }

    function playCrash(t) { playRide(t); }

	function scheduleStep(time) {
      instruments.forEach((inst, idx) => {
        
        const stepIndex = currentStep + idx * 16;
        if (pattern[inst][currentStep]) {
          const playFunc = {
            kick: playKick,
            snare: playSnare,
            hihat: playHiHat,
            clap: playClap,
            tom: playTom,
            ride: playRide,
            crash: playCrash
          }[inst];
          
          if (inst === 'hihat') playFunc(time, true); // closed par défaut
          else playFunc(time);

          //leds[stepIndex].app(title);

          //leds[stepIndex].classList.add('on'); // flash visuel
          //setTimeout(() => leds[stepIndex].classList.remove('on'), 120);
        }
      });

      leds.forEach((led, i) => {
        led.classList.toggle('playhead', i % 16 === currentStep);
      });

      currentStep = (currentStep + 1) % 16;
    }

    function sequencerLoop() {
      const now = audioCtx.currentTime;
      while (nextBeatTime < now + 0.2) {
        scheduleStep(nextBeatTime);
        nextBeatTime += beatDuration;
      }
      if (isPlayingDrumMachine) requestAnimationFrame(sequencerLoop);
    }
	

    function startDrumMachine() {
	  let btn = document.getElementById('playDrumMachine');
      if (isPlayingDrumMachine){
		btn.textContent = 'PLAY';
		btn.className = "play-dm";
		stopDrumMachine();
		return;
	  }
	  btn.textContent = 'STOP';
	  btn.className = "stop-dm";
      if (audioCtx.state === 'suspended') audioCtx.resume();
      currentStep = 0;
      nextBeatTime = audioCtx.currentTime + 0.1;
      isPlayingDrumMachine = true;
      sequencerLoop();
    }

    function stopDrumMachine() {
      isPlayingDrumMachine = false;
      leds.forEach(led => led.classList.remove('playhead'));
    }

    function setBPM(v) { bpm = +v; beatDuration = 60 / bpm; document.getElementById('bpm-value').textContent = bpm + ' BPM'; }
    function setReverb(v) { reverbWetDM.gain.value = v / 100; document.getElementById('reverb-value').textContent = v + '%'; }
    function setDelay(v) { delayWetDM.gain.value = v / 100; document.getElementById('delay-value').textContent = v + '%'; }



	//TODO SET TIMEOUT 2 secondes ici
	setTimeout(() => {

    // Création des LEDs + clic pour toggle
    const container = document.getElementById('steps');

    instruments.forEach(inst => {
      const title = document.createElement('div');
      title.innerHTML = inst;
      title.className = "title";
      container.appendChild(title);

      for (let step = 0; step < 16; step++) {

        
        const led = document.createElement('div');
       
        led.classList.add('led', inst);
        if (pattern[inst][step]) led.classList.add('on');
        
        led.addEventListener('click', () => {
          pattern[inst][step] = !pattern[inst][step];
          led.classList.toggle('on');
        });


        container.appendChild(led);

        leds.push(led);
      }
    });

    // Bindings
    document.getElementById('playDrumMachine').onclick = startDrumMachine;
    document.getElementById('bpm').oninput = e => setBPM(e.target.value);
    document.getElementById('reverb').oninput = e => setReverb(e.target.value);
    document.getElementById('delay').oninput = e => setDelay(e.target.value);

	}, 2000);


