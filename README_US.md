<a id="readme-top"></a>
<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/pb402385/webaudio_with_webgl_animations/">
    <img src="/favicon.ico" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">MP3/MP4 player with animations</h3>

  <p align="center">
    MP3/MP4 player with animations (JavaScript and WebGL) and web audio piano
    <br />
    <a href="https://github.com/pb402385/webaudio_with_webgl_animations">See Demo</a>
  </p>
</div>


[![Language: French](https://img.shields.io/badge/Language-French-blue)](./README.md)


<!-- TABLE OF CONTENTS -->
<details>
  <summary>Summary</summary>
  <ol>
    <li>
      <a href="#a-propos-du-projet">About project</a>
      <ul>
        <li><a href="#demo-video">Video demo</a></li>
        <li><a href="#technologies">Technologies</a></li>
      </ul>
    </li>
    <li>
      <a href="#commencer">Begin</a>
      <ul>
        <li><a href="#prérequis-et-installation">Prerequisites and installation</a></li>
      </ul>
    </li>
    <li><a href="#presentation">Application presentation</a></li>
    <li>
        <a href="#functionalities">Features</a>
      <ul>
        <li>
            <a href="#part-video">Video Section</a>
            <ul>
                <li><a href="#fonctionnement">How it works (in general)</a></li>
                <li><a href="#video_params">Video settings</a></li>
            </ul>
        </li>
        <li>
            <a href="#part-audio">Audio Section</a>
            <ul>
                <li><a href="#synthe">The onboard synthesizer</a></li>
                <li><a href="#melody">The melodies or the audio upload</a></li>
                <li><a href="#audio-params">Audio settings</a></li>
            </ul>
        </li>
      </ul>
    </li>
    <li>
        <a href="#codereview">Code walkthrough</a>
      <ul>
        <li><a href="#code-video">Vidéo Section</a></li>
        <li>
            <a href="#code-audio">Audio Section</a>
            <ul>
                <li><a href="#code-init-audio-context">Initializing the Web Audio Context</a></li>
                <li><a href="#code-synthe">Synthesizer implementation</a></li>
                <li><a href="#code-melody">Melodies Implementation</a></li>
                <li><a href="#code-audio-params">Audio Parameters and Effects implementation</a></li>
            </ul>
        </li>
      </ul>
    </li>
    <li><a href="#improvment">Potential improvements</a></li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Acknowledgments</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## About project
<a id="a-propos-du-projet"></a>

This project is an **MP3/MP4 audio player** featuring spectacular **animated visualizations**, built with JavaScript and **GLSL** shaders (WebGL).

It also includes a **virtual piano (synthesizer)** that lets you play notes live using your computer keyboard or mouse. Since playing accurately can sometimes be tricky, I have pre-recorded two famous melodies, faithfully reproduced from their original sheet music:

- **The Imperial March** (Darth Vader’s theme) – composed by John Williams  
- **The Ballad of Sacco and Vanzetti** (from the film *Sacco and Vanzetti*) – composed by Ennio Morricone

The animations are **audio-reactive**: they pulse, wave, and evolve in real time according to the sound stream. They are fully customizable (colors, intensity, shapes, etc.).

Additionally, the sound can be modified in real time with various **audio effects** (filters, reverb, distortion, etc.) using the Web Audio API.



<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Video demo
<a id="demo-video"></a>

Here is a demonstration of the final application rendering: (Click on the image to watch the video)



[![Miniature de la vidéo](https://img.youtube.com/vi/amGpBCkkSVQ/hqdefault.jpg)](https://youtu.be/amGpBCkkSVQ)

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Technologies
<a id="technologies"></a>

* [WebGL](https://fr.wikipedia.org/wiki/WebGL)
* [Three.js](https://threejs.org)
* [WebAudioAPI](https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)
* [JavaScript](https://en.wikipedia.org/wiki/JavaScript)
* [HTML](https://en.wikipedia.org/wiki/HTML)
* [CSS](https://en.wikipedia.org/wiki/CSS)


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Begin
<a id="commencer"></a>

### Prerequisites and installation
<a id="prérequis-et-installation"></a>

Install Node.js (https://nodejs.org/fr)

Download the project, then from the project root, type the following command to start the server:
  ```sh
  python -m http.server 8000
  ```

Next, open the following URL in your browser: <a href="http://localhost:8000/index.html">http://localhost:8000/index.html</a>

### Application presentation
<a id="presentation"></a>

You should now see the application page open in your browser

<img src="screenshots/application.png" alt="application.png" />

The application uses the **Web Audio API** to perform real-time analysis of the audio stream, whether it comes from a loaded file (MP3/MP4/M4A) or from the **built-in synthesizer/virtual piano**.

This stream is analyzed to extract various information (frequencies, amplitude, rhythm, etc.), which is then used to drive both:
- Real-time modifiable **audio effects**: filters (low-pass, high-pass…), equalizer, reverb, distortion, etc.  
- **Stunning 2D/3D visualizations** rendered with **WebGL** and **GLSL** shaders.

The audio data is converted into a dynamic texture that feeds the shaders, allowing the animations to react precisely and synchronously to the music.

All parameters are fully user-adjustable (intensity and type of audio effects, behavior of the visual animations, etc.).



<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Features
<a id="functionalities"></a>

### Video Section
<a id="part-video"></a>

As explained a bit earlier, the sound is transformed into a **texture2D** (an image) that represents the instantaneous variation of the audio at the current time **T**. This texture can then be used in GLSL (WebGL) to dynamically modify the vectors of the graphical animation in real time.



#### How it works (in general)
<a id="fonctionnement"></a>

<div align="center">
This is an example of what the generated texture2D looks like at time T
</div>
<br/>
<div align="center">
    <img src="screenshots/exemple_texture.png" alt="exemple_texture.png" />
</div>


Initially, the project started with **customizable 3D shapes**, displayed in three dimensions and animated in real time based on sound intensity.A **2D slice** (or cross-section) was then added to deform these shapes in a wavy, undulating manner, introducing an extra visual layer and dimension. In 3D mode, it is also possible to **repeat the shape infinitely, creating a mesmerizing**, hypnotic effect of endless duplication and replication.



<div align="center">
For example, here is a capture of the torus rendered in 3D
</div>
<br/>
<div align="center">
    <img src="screenshots/shape_torus_webgl.png" alt="shape_torus_webgl.png" />
</div>

<div align="center">
And this is what the 2D torus looks like
</div>
<br/>
<div align="center">
    <img src="screenshots/shape_torus_2d_webgl.png" alt="shape_torus_2d_webgl.png" />
</div>

<div align="center">
If audio is playing, the geometry of the figure is modulated by the 2D texture mentioned above. An illustration of this 3D deformation is shown below.
</div>
<br/>
<div align="center">
    <img src="screenshots/shape_square_3d_animated_webgl.png" alt="shape_square_3d_animated_webgl.png" />
</div>


<div align="center">
And this is what the 2D looks like
</div>
<br/>
<div align="center">
    <img src="screenshots/shape_square_2d_animated_webgl.png" alt="shape_square_2d_animated_webgl.png" />
</div>


<div align="center">
The shape can also be multiplied infinitely, as shown in the illustration below
</div>
<br/>
<div align="center">
    <img src="screenshots/shape_infinity_webgl.png" alt="shape_infinity_webgl.png" />
</div>


<div align="center">
We can also add a twist effect to the geometry of the shape
</div>
<br/>
<div align="center">
    <img src="screenshots/shape_twist_webgl.png" alt="shape_twist_webgl.png" />
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Video settings
<a id="video_params"></a>
Here are the different settings available for the video section

<div align="center">
    <img src="screenshots/video_params.png" alt="video_params.png" />
</div>

**Available settings :**

1. **Base Shape** (*): Allows you to select the basic geometric shape. **Available options:** Square, Small square, Torus, Small torus, Hexagon, Cone, and Circle.

2. **Animation** (*): Defines the rendering mode of the shape: **3D** or **2D**. If **NONE** option is selected, only the 2D texture generated in real time by the sound is displayed (a sound-reactive 2D image that can visually alter the animations).

3. **Ondulation** (*): Controls the intensity of the geometric shape’s deformation based on the audio signal.The higher the value, the more pronounced the deformation.

4. **Single/infinity** (*): Chooses between displaying a single shape or an infinite duplication of it in space, created through matrix repetition.

5. **Effect**: Effects marked as (SHAPE) directly influence the geometry of the base shape (*) by slightly deforming it. The other effects are independent animations that do not modify the base shape: their appearance reacts to the 2D texture, which helps enrich and diversify the overall visual result.

6. **Type**: Replaces the “Ondulation” parameter when not using a geometric shape (*). It allows you to modify the 3D animation slightly, giving a bit of control to produce subtly different visual renderings.


(*) Indicates that this parameter only applies to geometric shapes (SHAPE mode)

Here is a short video showing the different possible animations in their default state, without any influence from the real-time 2D sound-generated texture.

https://github.com/user-attachments/assets/ea8c63dd-818e-44c1-a017-e59964816623

You can trigger the generation of random animations by clicking the button located right next to the “Effect” title in the video menu (see screenshot)



<div align="center">
    <img src="screenshots/effect_video_webgl.png" alt="effect_video_webgl.png" />
</div>

Clicking this opens a pop-in window displaying the full list of animations. You can then select the ones you want to add to your playlist.

<div align="center">
    <img src="screenshots/video_random_animation.png" alt="video_random_animation.png" />
</div>

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Audio Section
<a id="part-audio"></a>

#### The onboard synthesizer
<a id="synthe"></a>

**The onboard synthesizer** generates the audio stream in real time. It is based on oscillators provided by the Web Audio API, allowing us to produce any desired note. You can change the **waveform type** (Triangle, Sine, Square, or Sawtooth) to significantly alter the timbre and overall tone of the sound.

Here is a short presentation video:

//TODO vidéo demo synthé
[![Miniature de la vidéo](https://img.youtube.com/vi/amGpBCkkSVQ/hqdefault.jpg)](https://youtu.be/amGpBCkkSVQ)

#### The melodies or the audio upload
<a id="melody"></a>

Pre-programmed melodies: these are simulated musical sequences, as if a score were being read and performed live by the synthesizer, without you having to play anything yourself.

Two melodies are currently available:  
- The Imperial March (from Star Wars)  
- The Sacco and Vanzetti March


<div align="center">
    <img src="screenshots/melodies_boutons.png" alt="melodies_boutons.png" />
</div>

Alternatively, you can directly load an audio file in MP3, MP4, or M4A format.

<div align="center">
    <img src="screenshots/upload.png" alt="upload.png" />
</div>

Once an audio file is loaded, the canvases automatically come to life:  The first two display real-time sound visualisations. The first one represents the amplitude of frequencies (frequency-domain view), the second shows the temporal waveform itself (time-domain view).

The bottom graph displays the complete audio spectrum of the uploaded file (full frequency distribution).



<div align="center">
    <img src="screenshots/canvas_audio.png" alt="canvas_audio.png" />
</div>


<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Audio settings
<a id="audio-params"></a>

<div align="center">
    <img src="screenshots/audio_params.png" alt="audio_params.png" />
</div>

The following parameters are available:

1. **Volume**: Allows you to increase or decrease the sound volume (**value between 0 and 100%**)
2. **Equalizer**: Lets you manually adjust the levels of the allowed frequencies (high, mid, and low) (**value between 0 and 100%** for each band)
3. **Filtre**:  Lets you choose the filter type, each associated with a characteristic frequency that can be adjusted. (Available filter types: **Low Pass** (120 Hz), **High Pass** (120 Hz), **Band Pass** (800 Hz), **Low Shelf** (180 Hz), **High Shelf** (6000 Hz), **Peaking** (1000 Hz), **Notch** (500 Hz) and **All Pass** (500 Hz))
4. **Effects**: Allows you to activate one effect from the following list (those marked with * can be further customized):

    - **MOOG**: Produces a creamy, fat, and musical filtered sound (especially effective with the built-in synthesizer or synth-heavy tracks).

    - **NOISE** (*): Intentionally adds a noise signal to create texture, enrich the sound, or achieve an artistic effect. 

    - **PITCH** (*): Shifts the pitch up (higher) or down (lower) while preserving the exact duration of the sound.

    - **BIT CRUSHER** (*): Simulates digital audio degradation by intentionally reducing bit depth and sample rate, mimicking old 8-bit consoles, vintage samplers, etc.

    - **SIMPLE LOWPASS**: Lets low frequencies pass while attenuating or cutting high frequencies.  

    - **COMPRESSOR** (*): Automatically reduces the dynamic range — the difference between the quietest and loudest parts.

    - **REVERB**: Simulates the natural acoustic resonance of a physical space (room, hall, cathedral, cave, etc.). 

    - **TREMOLO** (*): Periodically modulates the volume (amplitude), creating a regular loud–quiet–loud–quiet pulsing effect.  

    - **FFT FX** (*): Uses Fast Fourier Transform (FFT) algorithms to manipulate the frequency spectrum of the audio.

5. **Speed Melody**: Adjusts the playback speed of the two pre-recorded melodies (**range: 0.5× to 1.5×**)
6. **Type**: Selects the waveform type used by the oscillator (**Triangle**, **Sine**, **Square**, **Sawtooth**). Only applies to the pre-programmed melodies and the built-in synthesizer.

Advanced effect parameters:

<br/>
<div align="center">
    <img src="screenshots/audio_effets_params.png" alt="audio_effets_params.png" />
</div>
<br/>
Available settings per effect:

- **NOISE**: 4 noise types:
    * White noise – heavy rain, detuned TV static
    * Pink noise – wind, waterfalls, meditation / sleep sounds
    * Brown noise – distant thunder, stormy sea
    * Blue noise – high-pressure air jet, piercing his



- **PITCH**: 4 pitch-shift styles:
    * Octave up
    * Octave down
    * Demon / robot voice
    * Light choir



- **BIT CRUSHER**: 2 styles:
    * Super smooth (no hard aliasing)
    * Extreme lo-fi crunch



- **COMPRESSOR**: 5 presets:
    * Default
    * Gentle leveling
    * Bus glue / group glue
    * Drum squash
    * Transparent limiter



- **TREMOLO**: 3 styles:
    * Default
    * Wide & slow auto-panning (0.33 Hz)
    * Ultra-nervous 8 Hz square-wave tremolo (dub / techno vibe)



- **FFT FX**: 3 styles:
    * Spectral freeze
    * Spectral shimmer / blur
    * Formant-preserving pitch shifter ±2 octaves



<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Code walkthrough
<a id="codereview"></a>

### Vidéo Section
<a id="code-video"></a>

The core functionality is located in the file **webgl.js**

The code is initialized by loading the GLSL part at the very beginning. Every 3D object is processed in two main stages for the shaders: vertex shaders and fragment shaders. These are the two programs written in GLSL that run directly on the graphics card (GPU).

```javascript
async function loadShaders() {
  vertexSource = await fetch('webgl/vertexSource.glsl').then(res => res.text());
  fragmentSource = await fetch('webgl/fragmentSource.glsl').then(res => res.text());
  fragmentSourceUserShader = await fetch('webgl/fragmentSourceUserShader.glsl').then(res => res.text());
}
```

The file **fragmentSource.glsl** contains the mainImage function, which is executed to render our 3D animation. This file imports **fragmentSourceUserShader**, which contains the code for all available animations. The animation selected by the user will then override / replace the content of the mainImage function.

Loading the parameters required for the WebGL animation — as well as the real-time audio frequency array coming from the audio analyser — takes place at this level in the code.

```javascript
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
```

Mouse interactions with the 3D animation canvas (clicks, drags, zoom, etc.) are handled by functions located in the webgl.js file. This file is the ideal place to add new interactions or modify existing behavior.

```javascript
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
```

**Intégrer une animation GLSL et utiliser la texture audio en temps réel**

Je vais maintenant expliquer comment, en pratique, ajouter une nouvelle animation GLSL au projet, et surtout comment récupérer dans le code du shader la texture 2D générée à partir du son. Cette texture nous permettra de modifier les vecteurs (positions, déplacements, déformations, etc.) en fonction des variations du flux audio, créant ainsi des animations réactives au rythme et aux fréquences.

Pour commencer, la première étape consiste à **récupérer cette texture 2D**, qui est générée en temps réel à partir du tableau de fréquences issu de l’analyse audio :

```glsl
vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);
```

A titre informatif, on peut accéder soit à la position du vecteur de texture généré via les champs x, y et z (exemple: fragColorTexture.xy), soit également à leur couleur RGB via les champs r, g et b (exemple: fragColorTexture.rgb)

Ensuite il faut trouver l'endroit de l'animation qui nous interesse et à l'aide des informations que la texture nous envoit, réaliser des opérations qui altèrent notre animation (de préférence de manière harmonieuse)

On peut par exemple utiliser la fonction **mix** est une des fonctions les plus utiles et utilisées en GLSL (le langage des shaders dans WebGL, Three.js, OpenGL, etc.). Elle permet de faire une interpolation linéaire entre deux valeurs.

```glsl
    fragColor = mix(color, vec3(0.5), fragColorTexture.xyz);
```

On peut également utiliser la fonction **smoothstep** en GLSL (utilisée dans Three.js, WebGL, shaders en général) qui permet de créer des transitions douces (smooth transitions) entre deux valeurs. Elle est parfaite pour les animations fluides, les masques progressifs, les effets de fondu, etc.

```glsl
    fragColor = smoothstep(color, vec3(0.5), fragColorTexture.xyz);
```

Attention toutefois au **problème d’anti-aliasing** : il peut parfois provoquer des artefacts sur la partie gauche de l’animation ou générer des bords en escalier (staircasing) très visibles et peu esthétiques, surtout après l’utilisation d’un **smoothstep**.

Pas de panique, ce problème est facilement contournable avec la solution suivante !


```glsl
    // l'operation que l'on souhaite réaliser
    vec3 values = vec3(min(1.0,fragColorTexture.x), min(0.2,fragColorTexture.y), min(0.8,fragColorTexture.z));
    // Avec anti-aliasing adaptatif
    vec3 aa = fwidth(values);                         // vec3 avec fwidth par composante
    vec3 smooth = smoothstep(-aa, aa, values);
    col *=  smooth; 
```

On peut également modifier l'animation simplement en modifiant un nombre flottant, ou en faisant une multiplication de vecteurs, par exemple:

```glsl
    // modifier un flottant
    float dist = 0.5 + (fragColorTexture.x * 25.0);
    //multiplication de vecteurs
    vec3 fragColor = color * fragColorTexture.xyz;
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Audio Section
<a id="code-audio"></a>

Le fonctionnement principal se situe dans le fichier webaudio.js

#### Initializing the Web Audio Context
<a id="code-init-audio-context"></a>

Tout d'abord il nous faut **initialiser le contexte Web Audio**, car depuis plusieurs années (Chrome 66+, puis tous les navigateurs), les politiques autoplay des navigateurs bloquent la lecture audio automatique pour éviter les pubs sonores intrusives, le contexte Web Audio est souvent créé en état suspended (suspendu) si pas initié directement par une interaction utilisateur (comme un clic ou un touch)

```javascript
// Fonction à appeler sur le premier clic/touch de l’utilisateur
async function unlockAudio() {
    if (isUnlocked) return;

    // Crée ou reprend l’AudioContext
    audioCtx = new AudioContext();

    // Start when user clicks or after resume (required on most browsers)
    document.documentElement.addEventListener('click', () => {
        if (audioCtx.state === 'suspended') audioCtx.resume();
        initAudio().then(() => {
            console.log("AudioContext débloqué et prêt !");
            isUnlocked = true;

            // Mets ici tout ce qui a besoin du son
            initAudioContext2();
        });

    }, { once: true });

    // Nettoyage : on ne veut appeler ça qu’une seule fois
    document.removeEventListener('click', unlockAudio);
    document.removeEventListener('touchstart', unlockAudio);
    document.removeEventListener('keydown', unlockAudio);
}
```

Une fois notre contexte Web Audio actif, on doit **charger tous les modules** qui nous seront nécessaires lors de la future création de notre graphe audio, ces audioWorklet Processor nous permettent de remplacer les javascriptNodes obsolètes et d'avoir un code spécifique par effet audio que l'on pourra utiliser dans nos modifications du flux audio

```javascript
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
```

On arrive au moment où on peut enfin créer les nœuds nécessaires pour monter notre graphe audio.

```javascript
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
```

On peut maintenant assembler notre graphe audio : configuration des nœuds d’égaliseur, de gain (volume), de filtre et d’analyse, lancement des deux méthodes permettant de dessiner les deux courbes d'analyse de l'audio en temps réel et enfin, connexion finale au nœud de destination.

```javascript
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
            console.log("mouse click on canvas, let's jump to another position in the song")
            var mousePos = getMousePos(frontCanvasTimeline, event);
            // will compute time from mouse pos and start playing from there...
            jumpTo(mousePos);
        })
}
```

Voici une capture d’écran de notre graphe Web Audio, présenté de manière simplifiée. Je n’ai pas représenté tous les AudioWorkletNode (car il y en a un très grand nombre en raison des nombreux effets), ni tous les OscillatorNode (un par touche du synthétiseur intégré, ce qui rendrait le graphe beaucoup trop chargé et illisible).

<div align="center">
    <img src="screenshots/graphe_audio.png" alt="graphe_audio.png" />
</div>

Notre graphe étant enfin terminé, notre application est opérationnelle! On remarque que l'on a deux fonctions draw qui sont exécutées permettant de dessiner nos courbes en temps réel. Il est à noter un point important, c'est dans la méthode **draw** que nous obtenons le tableau de fréquences que nous envoyons en temps réel à la partie vidéo 3D

```javascript
    if(analyser.frequencyBinCount){
        frequencyData = new Uint8Array(analyser.frequencyBinCount);
        analyser.getByteFrequencyData(frequencyData);
    } 

    ..........

    arrayFreqToOpenGL = frequencyData;
```

Ce code permet de charger un fichier audio (**MP3, MP4, M4A**) via un champs input de type file. Ensuite, on decode le contexte audio et on crée le noeud source, ensuite on connecte ce noeud source à notre graphe audio, on dessine son spectre et enfin on démarre la lecture de la musique via source.start().

```javascript
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
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Synthesizer implementation
<a id="code-synthe"></a>

Quant au synthétiseur intégré, il est entièrement généré par du code JavaScript.

```javascript
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
```

Ensuite, une fois que le synthétiseur est créé au niveau de la vue (interface utilisateur), il suffit d’appeler cette méthode pour jouer une note.

```javascript
    function playNoteKeyboard(freq){
        if(tabTouchesBool[freq] == false){
            noteToPlay = new SoundK(tabFrequences[freq], tabType[type], freq);
            tabTouchesBool[freq] = true;
        }
    }
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Melodies Implementation
<a id="code-melody"></a>

Les mélodies, c’est tout simplement une **série de notes jouées les unes après les autres** à un certain rythme. Dans le code, on utilise juste des tableaux qui listent les notes, et on les joue au bon tempo grâce à des **setTimeout**.

Par exemple, voici la partie du code qui nous crée les données pour représenter la première mélodie (The Imperial March).

```javascript
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
```

Et voici la partie du code qui nous permet de lancer cette mélodie tout en suivant un tempo bien précis grâce au setTimeout.

```javascript
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
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Audio Parameters and Effects implementation
<a id="code-audio-params"></a>

Pour les paramètres, certains sont **gérés nativement** par les composants de l’API Web Audio. Par exemple, sans le cas de volume, il est contrôlé directement par le nœud de gain : un input utilisateur permet de modifier sa valeur en temps réel, la mise à jour s’effectuant dès que la valeur de l’input change en exécutant cette fonction.

```javascript
    //Manage volume
    function changeVolume(element){
        var volume = element.value;
        var fraction = parseInt(element.value) / parseInt(element.max);
        gainNode.gain.value = fraction * fraction;
    }
```

D’autres paramètres, en revanche, sont implémentés à l’aide d’**AudioWorkletNode** personnalisés. Il s’agit de nœuds que nous codons nous-mêmes **pour créer des effets sur mesure**, comme des filtres spécifiques ou divers traitements audio. Dans ce cas, nous devons développer l’intégralité du composant. Par exemple, dans l’application, je vais vous expliquer comment j’ai implémenté mon propre effet de bruit (noise).


```javascript
// White, Pink, Brownian, Blue, Violet + filtre passe-bas premier ordre contrôlable
class NoiseProcessor extends AudioWorkletProcessor {
  static get parameterDescriptors() {
    return [
      {
        name: 'type',           // 0=white, 1=pink, 2=brown, 3=blue, 4=violet
        defaultValue: 1,
        minValue: 0,
        maxValue: 4,
        automationRate: 'a-rate'
      },
      {
        name: 'cutoff',         // fréquence de coupure du filtre passe-bas (Hz), 0 = pas de filtre
        defaultValue: 800,
        minValue: 0,
        maxValue: 22050,        // un peu au-dessus de Nyquist
        automationRate: 'a-rate'
      },
      {
        name: 'gain',
        defaultValue: 0.25,     // niveau de sortie global
        minValue: 0,
        maxValue: 1,
        automationRate: 'a-rate'
      }
    ];
  }

  constructor() {
    super();
    
    // État pour chaque type de bruit
    this.pinkB0 = this.pinkB1 = this.pinkB2 = this.pinkB3 = this.pinkB4 = this.pinkB5 = this.pinkB6 = 0;
    this.brown = 0;
    
    // Pour blue (+3 dB/oct) : simple différentiateur
    this.lastWhite = 0;
    
    // Pour violet (+6 dB/oct) : seconde différence
    this.whiteM1 = 0;
    this.whiteM2 = 0;
    
    // Filtre passe-bas 1er ordre (exponentiel moving average)
    this.z = 0;
    
    // Dernière valeur de cutoff pour détecter les changements
    this.lastCutoff = 0;
  }

  process(inputs, outputs, parameters) {
    const output = outputs[0];
    const typeParam = parameters.type;
    const cutoffParam = parameters.cutoff;
    const gainParam = parameters.gain;
    const applyFilter = cutoffParam[0] > 20; // on ignore les très basses fréquences

    for (let channel = 0; channel < output.length; ++channel) {
      const out = output[channel];

      for (let i = 0; i < out.length; ++i) {
        // Récupération des paramètres (a-rate support)
        const type = Math.round(typeParam.length > 1 ? typeParam[i] : typeParam[0]) | 0;
        const cutoff = cutoffParam.length > 1 ? cutoffParam[i] : cutoffParam[0];
        const gain = gainParam.length > 1 ? gainParam[i] : gainParam[0];

        let noise = Math.random() * 2 - 1; // bruit blanc [-1, 1]

        switch (type) {
          case 0: // White - rien à faire
            break;

          case 1: // Pink - méthode Voss (7 accumulateurs)
            this.pinkB0 = this.pinkB0 * 0.99886 + noise * 0.055;
            this.pinkB1 = this.pinkB1 * 0.99332 + noise * 0.075;
            this.pinkB2 = this.pinkB2 * 0.96900 + noise * 0.153;
            this.pinkB3 = this.pinkB3 * 0.86650 + noise * 0.310;
            this.pinkB4 = this.pinkB4 * 0.55000 + noise * 0.532;
            this.pinkB5 = this.pinkB5 * 0.31000 + noise * 0.775;
            this.pinkB6 = this.pinkB6 * 0.11500 + noise * 0.923;
            
            noise = (this.pinkB0 + this.pinkB1 + this.pinkB2 + this.pinkB3 +
                     this.pinkB4 + this.pinkB5 + this.pinkB6 + noise * 0.125) * 0.125;
            break;

          case 2: // Brownian (Brown / Red)
            this.brown += noise * 0.02;
            this.brown *= 0.99;
            noise = this.brown;
            break;

          case 3: // Blue - différentiateur simple
            noise = noise - this.lastWhite;
            this.lastWhite = noise * 0.5 + this.lastWhite * 0.5; // léger lissage pour éviter l'explosion
            noise *= 4.0; // compensation de gain
            break;

          case 4: // Violet - seconde différence
            const secondDiff = noise - 2 * this.whiteM1 + this.whiteM2;
            this.whiteM2 = this.whiteM1;
            this.whiteM1 = noise;
            noise = secondDiff * 8.0; // compensation de gain
            break;
        }

        // Filtre passe-bas 1er ordre (si cutoff > 20 Hz)
        if (applyFilter && cutoff > 20) {
          const normalizedCutoff = Math.min(cutoff / (sampleRate * 0.5), 0.99);
          const alpha = normalizedCutoff < 0.001 ? 0.001 : 1 - Math.exp(-2 * Math.PI * normalizedCutoff * 0.1);
          
          this.z += alpha * (noise - this.z);
          noise = this.z;
        }

        out[i] = noise * gain;
      }
    }

    return true;
  }
}

registerProcessor('noise', NoiseProcessor);
```

Comme vous pouvez le voir, on crée une classe NoiseProcessor qui extends AudioWorkletProcessor, au début on a une méthode get **parameterDescriptors()** qui permet de déclarer des paramètres automatisables personnalisés (AudioParam) pour notre AudioWorkletNode.

Ensuite, nous disposons de la fonction **process(inputs, outputs, parameters)**, qui est responsable du traitement du son en temps réel, bloc par bloc (généralement 128 échantillons). Cette fonction reçoit trois paramètres :  
- **inputs** : un tableau contenant les entrées audio ;  
- **outputs** : un tableau contenant les sorties audio (c’est ici que nous écrivons le signal traité) ;  
- **parameters** : un objet regroupant les valeurs des AudioParam personnalisés, tels que ceux déclarés précédemment via parameterDescriptors().

Dans l’exemple de l’effet Noise, nous avons trois paramètres : le type, le cutoff et le gain. Nous codons ensuite l’effet proprement dit et, lorsque plusieurs paramètres sont présents, nous utilisons souvent un switch-case pour gérer les différents cas selon la valeur active.



<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Potential improvements
<a id="improvment"></a>

Voici une liste de points à améliorer pour optimiser cette application :  

- Une meilleure gestion de la mémoire RAM.  
- Supprimer les nœuds oscillateurs individuels du synthétiseur intégré et les remplacer par un AudioWorkletNode dédié, ce qui permettra de jouer plusieurs notes simultanément (polyphonie) sans dégrader la qualité du son en sortie.
- Optimiser les effets basés sur AudioWorkletNode pour obtenir un rendu sonore plus harmonieux, en affinant notamment leurs paramètres (certains problèmes actuels tenant uniquement à un réglage suboptimal).  
- Autoriser l'application simultanée de plusieurs effets, contrairement à l'implémentation actuelle qui limite à un seul effet à la fois.
- Pourquoi pas, ajouter une boîte à rythme pour accompagner le synthétiseur intégré.

## License
<a id="license"></a>

Le projet est entièrement **open source et gratuit**. Aucune restriction : Simplement du code libre au service de tous, offert à la communauté.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact
<a id="contact"></a>

Informations de contact:

**Nom**: Porta <br/>
**Prénom**: Benjamin <br/>
**Pays**: FRANCE <br/>
**Ville**: Nice <br/>
**E-mail**: pb402385@gmail.com <br/>
**Github**: https://github.com/pb402385

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments
<a id="acknowledgments"></a>

Tout d’abord, je tiens à remercier mon ami **Klem**, qui m’a initié au WebGL il y a plusieurs années. Sans lui, l’idée de combiner WebGL et Web Audio ne me serait jamais venue à l’esprit.  

Pour la partie Web Audio, un grand merci à mon professeur de Master, **Michel Buffa**, qui me l’a fait découvrir pendant mes études.  

Je souhaite également remercier les développeurs dont j’ai pu m’inspirer et emprunter du code WebGL sur **Shadertoy** (https://www.shadertoy.com/).  

* Remerciements à **BigWIngs** de qui j'ai pu récupérer l'animation **Trou Noir** dont le lien original de l'animation se situe à l'addresse suivante: https://www.shadertoy.com/view/3d2SWK
* Remerciements à **Inigo Quilez** de qui j'ai pu récupérer l'animation **3D Sierpinski Triangle** dont le lien original de l'animation se situe à l'addresse suivante: https://www.shadertoy.com/view/4dl3Wl
* Remerciements à **GarlicGraphix** de qui j'ai pu récupérer l'animation **3D Sierpinski Infinite** dont le lien original de l'animation se situe à l'addresse suivante: https://www.shadertoy.com/view/wc23zR
* Remerciements à **Shane** de qui j'ai pu récupérer l'animation **3D Sierpinski Mobius** dont le lien original de l'animation se situe à l'addresse suivante: https://www.shadertoy.com/view/XsGXDV
* Remerciements une seconde fois à  **Shane** de qui j'ai pu récupérer l'animation **Mandelbrot Decoration** dont le lien original de l'animation se situe à l'addresse suivante: https://www.shadertoy.com/view/ttscWn

Enfin, pour les autres animations, j’ai été principalement aidé par **l'IA Grok (xAI)** et un peu également de **ChatGPT**.


<p align="right">(<a href="#readme-top">back to top</a>)</p>
