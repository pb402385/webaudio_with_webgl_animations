/**
	Global variables (customizable options)
**/
var camera, scene, renderer, controls;
var geometry, mesh;

var webAudioRunning = false;

var arrayFreqToOpenGL = [];
var freqToOpenGL = 8;
var typeToOpenGL = 1;
var typeTextureToOpenGL = 0;
var infinityToOpenGL = 0;
var effectToOpenGL = 0;

var canvasClicked;

var dataTex;
var side = 16;

function generateInitTabFreqSound(size){
	var array = new Uint8Array(size);
	for(var i=0; i<size; i++){
		if(i!== 0 && (i+1)%4 == 0){
			array[i] = 255;
		}else{
			array[i] = 0;
		}
	}
	return array;
}

function app() {

	if ( ! Detector.webgl ) {
		Detector.addGetWebGLMessage();
	}
	
	loadShaders();
	setTimeout(() => init(), 1000);
}

let vertexSource;
let fragmentSource;
let fragmentSourceUserShader;

async function loadShaders() {
  vertexSource = await fetch('webgl/vertexSource.glsl').then(res => res.text());
  fragmentSource = await fetch('webgl/fragmentSource.glsl').then(res => res.text());
  fragmentSourceUserShader = await fetch('webgl/fragmentSourceUserShader.glsl').then(res => res.text());
}

function init() {
	
	camera = new THREE.Camera();
	camera.position.z = 1;

	scene = new THREE.Scene();

	geometry = new THREE.BufferGeometry();
	
	//Square that will contain the animation
	var vertices = new Float32Array([
	  -1, -1, 
	   1, -1, 
	  -1,  1, 
	  -1,  1, 
	   1, -1, 
	   1,  1, 
	]);

	geometry.addAttribute( 'position', new THREE.BufferAttribute( vertices, 2 ) );
	
	arrayFreqToOpenGL = generateInitTabFreqSound(1024);

	dataTex = new THREE.DataTexture(arrayFreqToOpenGL, side, side, THREE.RGBAFormat);
	
	_uniforms = {
		iChannel0:			{ type: "t", value: dataTex },
		uIntEffect:			{ type: "i", value: effectToOpenGL},
		uIntInfinity:		{ type: "i", value: infinityToOpenGL},
		uIntFreq:			{ type: "i", value: freqToOpenGL },
		uIntType:			{ type: "i", value: typeToOpenGL },
		uIntTypeTexture:	{ type: "i", value: typeTextureToOpenGL },
		iGlobalTime:    	{ type: "f", value: 1.0 },
		iResolution: 		{ type: "v3", value: new THREE.Vector3() },
		iMouse: 			{ type: 'v4', value: new THREE.Vector2() },
	}
	
	var shaderMaterial = new THREE.RawShaderMaterial( {
		uniforms: _uniforms,
		vertexShader: vertexSource,
		fragmentShader: fragmentSource.replace('${usershader}', fragmentSourceUserShader),
	} );
	
	mesh = new THREE.Mesh(geometry, shaderMaterial);
	scene.add(mesh);
	
	mesh.material.uniforms.iChannel0.value.wrapS = mesh.material.uniforms.iChannel0.value.wrapT = THREE.RepeatWrapping;

	renderer = new THREE.WebGLRenderer();
	
	//mouse effect management
	document.getElementById("shaderPixelAnim").appendChild(renderer.domElement);
	canvasClicked = false;
	renderer.domElement.addEventListener('mousemove', function(e) {
		if(canvasClicked == true){
			var canvas = renderer.domElement;
			var rect = canvas.getBoundingClientRect();
			mesh.material.uniforms.iMouse.value.x = -parseFloat((e.clientX - rect.left));
			mesh.material.uniforms.iMouse.value.y = -parseFloat((e.clientY - rect.top));
		}
	});
	renderer.domElement.addEventListener('mousedown', function(e) {
			var canvas = renderer.domElement;
			var rect = canvas.getBoundingClientRect();
			mesh.material.uniforms.iMouse.value.x = -parseFloat((e.clientX - rect.left));
			mesh.material.uniforms.iMouse.value.y = -parseFloat((e.clientY - rect.top));
			canvasClicked = true;
	});
	renderer.domElement.addEventListener('mouseup', function(e) {
		canvasClicked = false;
		var canvas = renderer.domElement;
		var rect = canvas.getBoundingClientRect();
		mesh.material.uniforms.iMouse.value.z = parseFloat((e.clientX - rect.left));
		mesh.material.uniforms.iMouse.value.w = parseFloat((e.clientY - rect.top));
	});
	renderer.domElement.addEventListener('wheel', function(e) {
		canvasClicked = false;
		if(e.wheelDelta > 0) {
			mesh.material.uniforms.iResolution.value.x = mesh.material.uniforms.iResolution.value.x + 50;
		} else {
			mesh.material.uniforms.iResolution.value.x = mesh.material.uniforms.iResolution.value.x - 50;
		}
	});
	
	//Resize and render
	resize(true);
	// On désactive la bounding sphere car inutilisée et cela nous retire l'erreur provoquée par Three.min.js
	geometry.boundingSphere = new THREE.Sphere(new THREE.Vector3(0,0,0), 100);  // Ajustez selon vos besoins
	render(0);

}



var widthC;
var heightC;

function resize(force) {
  var canvas = renderer.domElement;
  var width  = 500;
  var height = 500;
  if (force || width != widthC || height != heightC) {
	renderer.setSize( width, height, false );
    mesh.material.uniforms.iResolution.value.x = renderer.domElement.width;
    mesh.material.uniforms.iResolution.value.y = renderer.domElement.height;
  }
  widthC = width;
  heightC = height;
}

function render(time) {
  resize();
  mesh.material.uniforms.iGlobalTime.value = time * 0.001;
  mesh.material.uniforms.uIntFreq.value = freqToOpenGL;
  mesh.material.uniforms.iChannel0.value.needsUpdate = true;
  mesh.material.uniforms.iChannel0.value.image.data = arrayFreqToOpenGL;
  mesh.material.uniforms.uIntType.value = typeToOpenGL;
  mesh.material.uniforms.uIntTypeTexture.value = typeTextureToOpenGL;
  mesh.material.uniforms.uIntInfinity.value = infinityToOpenGL;
  mesh.material.uniforms.uIntEffect.value = effectToOpenGL;

  renderer.render(scene, camera);
  requestAnimationFrame(render);
}


function setTypeToOpenGL(val){
	typeToOpenGL = parseInt(val);
}
function setTypeTextureToOpenGL(val){
	typeTextureToOpenGL = parseInt(val);
}

function setFreqToOpenGL(val){
	freqToOpenGL = parseInt(val);
}

function setInfinityToOpenGL(val){
	infinityToOpenGL = parseInt(val);
	//reset du zoom
	mesh.material.uniforms.iResolution.value.x = 500;
}

function setEffectToOpenGL(val){
	effectToOpenGL = parseInt(val);
	// si la valeur est superieur à 5 on disable certains champs
	if( parseInt(val) >= 5 ) {
		document.getElementById("buttonTypeAnim").disabled = true;
		document.getElementById("buttonTypeTextureAnim").disabled = true;
		document.getElementById("buttonInfinityAnim").disabled = true;
		//reset du zoom
		mesh.material.uniforms.iResolution.value.x = 500;
	} else {
		//sinon on les enable
		document.getElementById("buttonTypeAnim").disabled = false;
		document.getElementById("buttonTypeTextureAnim").disabled = false;
		document.getElementById("buttonInfinityAnim").disabled = false;
	}

}


/** inutiliszed **/
function readAndReturn(array){
	var arrayReturn = new Uint8Array(1024);
	for(var i=0; i<array.length; i++){
		if(i!== 0 && (i+1)%4 == 0){
			arrayReturn[i] = 255;
		}else{
			arrayReturn[i] = array[i];
		}
	}
	return arrayReturn;
}



// Fonction pour passer en plein écran
function enterFullScreen() {
	let divCanvas = document.getElementById('shaderPixelAnim');
	divCanvas.width = window.innerWidth;
    divCanvas.height = window.innerHeight;
	let canvas = document.querySelector('#shaderPixelAnim > canvas');
    if (canvas.requestFullscreen) {
        canvas.requestFullscreen();
    } 
    else if (canvas.mozRequestFullScreen) { // Firefox
        canvas.mozRequestFullScreen();
    } 
    else if (canvas.webkitRequestFullscreen) { // Chrome, Safari, Opera
        canvas.webkitRequestFullscreen();
    } 
    else if (canvas.msRequestFullscreen) { // IE/Edge
        canvas.msRequestFullscreen();
    }
}

// Optionnel : ajuster la taille du canvas quand on entre/sort du plein écran
document.addEventListener('fullscreenchange', adjustCanvas);
document.addEventListener('webkitfullscreenchange', adjustCanvas);
document.addEventListener('mozfullscreenchange', adjustCanvas);
document.addEventListener('MSFullscreenChange', adjustCanvas);

function adjustCanvas() {
	let divCanvas = document.getElementById('shaderPixelAnim');
	let canvas = document.querySelector('#shaderPixelAnim > canvas');
    if (document.fullscreenElement || document.webkitFullscreenElement || 
        document.mozFullScreenElement || document.msFullscreenElement) {
        // En plein écran → on redimensionne le canvas à la taille de l'écran
		divCanvas.width = window.innerWidth;
        divCanvas.height = window.innerHeight;
        canvas.width = window.innerWidth;
        canvas.height = window.innerHeight;
    } else {
        // Retour à la taille normale
		divCanvas.width = 500;
        divCanvas.height = 500;
        canvas.width = 500;
        canvas.height = 500;
    }
	//Resize and render
	resize(true);
	render(0);
}