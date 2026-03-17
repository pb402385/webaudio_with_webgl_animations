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
                <li><a href="#drum-machine">Drum Machine</a></li>
                <li><a href="#theremin">Theremin</a></li>
                <li><a href="#sequencer">Sequencer</a></li>
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
                <li><a href="#code-drum-machine-theremin">Drum Machine, Theremin and Sequencer implementation</a></li>
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

[![Miniature de la vidéo](https://img.youtube.com/vi/amGpBCkkSVQ/hqdefault.jpg)](https://youtu.be/amGpBCkkSVQ)

#### The melodies or the audio upload
<a id="melody"></a>

Pre-programmed melodies: these are simulated musical sequences, as if a score were being read and performed live by the synthesizer, without you having to play anything yourself.

Two melodies are currently available:  
- The Imperial March (from Star Wars)  
- The Sacco and Vanzetti March

The **STOP** button allows you to **kill the entire audio context** (works at any time).

Two other buttons have also been added: the first opens a pop-in with a **Theremin**, and the second opens a pop-in with a **Drum Machine**, finally the third button allows you to open a pop-in with a **Sequencer** of 4 instruments (guitar, bass, trumpet and saxophone).


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

#### Drum Machine
<a id="drum-machine"></a>

<div align="center">
    <img src="screenshots/drum-machine.png" alt="drum-machine.png" />
</div>

The **Drum Machine** is an electronic instrument designed **to generate percussive rhythms**, typically imitating a drum kit or other percussion instruments such as cymbals, triangle, or cabasa. It combines a sequencer (for programming rhythmic patterns) with multiple sound generators.

The **sequence consists of 16 samples per sound generation**, which are triggered when the corresponding step is activated. The available sound types are as follows:

1. **KICK**: The Kick (or Bass Drum) is the most prominent element of the drum kit — the large vertical drum in front of the drummer. It often provides the main pulse and tempo for the entire band or orchestra through deep, powerful impacts in the low frequencies.
2. **SNARE**: The Snare corresponds to the snare drum. It is the essential rhythmic element of the drum kit, positioned between the drummer's legs. It can be thought of as the modern equivalent of a side drum.
3. **HIHAT**: The Hi-hat (or high-hat) is known in French as the "charleston" or more colloquially "charley". It consists of two cymbals mounted on a vertical rod, usually placed to the left of the drummer, and is played with a foot pedal.
4. **CLAP**: The Clap is a sharp, short, and percussive sound simulating hand claps.
5. **TOM**: These are the other toms of the drum kit besides the snare and bass drum. The most common setup includes three toms: high tom, mid tom, and floor tom.
6. **RIDE**: The Ride is a cymbal placed to the right of the drummer. It can be used to mark the tempo instead of the hi-hat. It is struck either on the top with the tip of the stick or on the edge with the shaft.
7. **CRASH**: The Crash is a cymbal usually positioned to the left of the drummer. It is primarily used to accentuate strong beats or to mark transitions into new sections or measures.

The drum machine includes **3 effects**:
1. **REVERB**: The reverb effect on a drum machine adds depth, space, and cohesion to the electronic drums (value **between 0 and 60%**).
2. **DELAY**: The delay effect adds timed repetitions to certain sounds, creating depth or rhythmic motifs (value **between 0 and 50%**).
3. **TEMPO**: The tempo determines the speed of the rhythm, expressed in BPM (beats per minute). It serves as the temporal foundation to synchronize all sounds and patterns (value **between 70 and 180 beats per minute**).

There is also the option to select **PRESETS**, which are example patterns I used to create demos (see screenshot).



<div align="center">
    <img src="screenshots/drum-machine-presets.png" alt="drum-machine-presets.png" />
</div>

Here is an example video of the drum machine:

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Theremin
<a id="theremin"></a>

<div align="center">
    <img src="screenshots/theremin.jpeg" alt="theremin.png" />
</div>

Voici un exemple vidéo du thérémine:

The **theremin** is an electronic musical instrument invented in 1920 by the Russian physicist Léon Theremin (also known as Lev Termen). It is played without any physical contact: the performer moves their hands near two antennas — one controls the pitch (frequency/height of the note), the other controls the volume. The sound is generated by the variation of electromagnetic fields created by the musician's body, which disturbs the internal oscillators of the device. In this application, **pitch and volume are determined by the chosen XY axis**.

It features **6 effects**:
1. **TEMPO**: Like on the drum machine, it serves as the temporal foundation to synchronize sounds and patterns (value **between 60 and 180 beats per minute**).
2. **SILENCE**: Allows precise control of volume to create sharp attacks, rhythmic silences, and articulation effects, essential for structuring a melody (value **between 0 and 70%**).
3. **DELAY MIX**: Controls the mix level between the dry (original) signal and the delayed/reverberated signal (value **between 0 and 60%**).
4. **DELAY FEEDBACK**: Adjusts the number of echo repetitions (value **between 0 and 75%**).
5. **DELAY TIME**: Provides precise control over the delay time (value **between 80 and 800 milliseconds**).
6. **REVERB MIX**: Adjusts the intensity of the reverb effect (value **between 0 and 70%**).

You can also **load PRESETS** to take advantage of the theremin's sequencer. Additionally, you can **mute certain notes** to optimize the instrument.Here is an example video of the theremin:

<p align="right">(<a href="#readme-top">back to top</a>)</p>

#### Sequencer
<a id="sequencer"></a>

<div align="center">
    <img src="screenshots/sequencer.jpg" alt="sequencer.png" />
</div>

The **sequencer** is a kind of drum machine but which simulates notes from different musical instruments (guitar, bass, trumpet and saxophone). The notes played correspond to the following frequencies in the tempered scale:
- C5: 523.25 Hz
- A4: 440 Hz (standard pitch)
- G4: 392Hz
- E4: 329.63 Hz
- D4: 293.66 Hz
- C4: 261.63 Hz (middle C)
- A3: 220Hz
- G3: 196Hz

It has **2 effects**:
1. **BPM**: As with the drum machine, it serves as a time base to synchronize the sounds (value between **between 60 and 180 beats per minute**).
2. **Volume**: Allows volume control, common to the 4 instruments (value between **between 0 and 100%**).

You can also **load PRESETS** (useful for quick tests)

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

**Integrating a GLSL animation and using the real-time audio texture**

I will now explain, step by step, how to practically add a new GLSL animation to the project — and above all, how to retrieve and use the real-time 2D audio texture inside your shader code.This texture is generated in real time from the audio frequency analysis array. It allows you to modulate vectors (positions, displacements, deformations, etc.) based on the audio’s rhythm and frequency variations, creating truly sound-reactive animations.

The first thing to do is to **retrieve this 2D texture**.

```glsl
vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);
```

For information, you can access it either via its vector components (x, y, z fields) — example: fragColorTexture.xy or via its color components (RGB) — example: fragColorTexture.rgb (Both ways are valid depending on what you want to control in your animation).

Next, you need to locate the part of the animation you want to affect, and — using the information provided by the texture — perform operations that modify your animation (preferably in a smooth and harmonious way).

For example, one of the most useful and commonly used functions in GLSL (the shading language used in WebGL, Three.js, OpenGL, etc.) is **mix()**. The mix() function performs a linear interpolation (lerp) between two values, based on a third parameter that acts as a blending factor (usually between 0.0 and 1.0).

```glsl
    fragColor = mix(color, vec3(0.5), fragColorTexture.xyz);
```

You can also use the **smoothstep()** function in GLSL (commonly used in Three.js, WebGL, and shaders in general). It creates smooth, S-shaped transitions between two threshold values. This function is perfect for fluid animations, progressive masks, fade effects, soft edges, and anything where you want to avoid abrupt or harsh changes.

```glsl
    fragColor = smoothstep(color, vec3(0.5), fragColorTexture.xyz);
```

However, watch out for the **anti-aliasing issue**: It can sometimes cause artifacts on the left part of the animation or produce very visible and unaesthetic staircased / jagged edges (staircasing), especially after using **smoothstep()**.

No need to panic — this problem is very easy to work around with the following solution!

```glsl
    // l'operation que l'on souhaite réaliser
    vec3 values = vec3(min(1.0,fragColorTexture.x), min(0.2,fragColorTexture.y), min(0.8,fragColorTexture.z));
    // Avec anti-aliasing adaptatif
    vec3 aa = fwidth(values);                         // vec3 avec fwidth par composante
    vec3 smooth = smoothstep(-aa, aa, values);
    col *=  smooth; 
```

You can also modify the animation very simply by adjusting a floating-point number, or by performing multiplications on vectors, for example:

```glsl
    // modifier un flottant
    float dist = 0.5 + (fragColorTexture.x * 25.0);
    //multiplication de vecteurs
    vec3 fragColor = color * fragColorTexture.xyz;
```

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Audio Section
<a id="code-audio"></a>

The main functionality is located in the file webaudio.js

#### Initializing the Web Audio Context
<a id="code-init-audio-context"></a>

First of all, we need to **initialize the Web Audio context**. For several years now (since Chrome 66+, and then adopted by all major browsers), browsers enforce strict autoplay policies to prevent intrusive automatic audio playback (mostly to block unwanted advertisement sounds).  As a result, the Web Audio context is very often created in a suspended state if it is not explicitly started / resumed following a user gesture (such as a click, tap, key press, or any other direct user interaction).

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

Once our Web Audio context is active, we need to **load all the modules** that will be required later when building our audio graph.These AudioWorklet Processors allow us to replace the now-deprecated ScriptProcessorNode / JavaScriptNode, while offering much better performance (code runs on a separate thread in the audio context) and lower latency.Each AudioWorklet gives us a dedicated, custom processor for a specific audio effect or processing task, which we can then insert into our audio signal chain to modify the audio stream in real time.

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

Here we finally reach the stage where we can create the necessary nodes to build our audio graph.

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

We can now assemble our audio graph: configuring the equalizer nodes, gain (volume), filter, and analyser nodes, launching the two methods that draw the two real-time audio analysis curves, and finally connecting everything to the destination node.

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

Here is a screenshot of our Web Audio graph, presented in a simplified way. I have not represented all the AudioWorkletNodes (there are a very large number of them due to the many available effects), nor all the OscillatorNodes (one per key of the built-in synthesizer, which would make the graph far too cluttered and unreadable).

<div align="center">
    <img src="screenshots/graphe_audio.png" alt="graphe_audio.png" />
</div>

Since we added the drum machine and the theremin, the new graph looks like this (the image is in 2 parts because it is much too large to fit on a single image):

<div align="center">
    <img src="screenshots/graphe_audio_v2_p2.png" alt="graphe_audio_v2_p2.png" />
</div>

<div align="center">
    <img src="screenshots/graphe_audio_v2_p1.png" alt="graphe_audio_v2_p1.png" />
</div>

Our audio graph is now complete, and the application is fully operational! We can observe that two draw functions are being executed, allowing us to render our analysis curves in real time.An important detail to note: it is precisely inside this **draw** method that we retrieve the frequency data array (via analyserNode.getByteFrequencyData()) and send it in real time to the 3D video/WebGL part.

```javascript
    if(analyser.frequencyBinCount){
        frequencyData = new Uint8Array(analyser.frequencyBinCount);
        analyser.getByteFrequencyData(frequencyData);
    } 

    ..........

    arrayFreqToOpenGL = frequencyData;
```

This code allows loading an audio file (**MP3, MP4, M4A**) via a file input field. It then decodes the audio data into the Web Audio context, creates the source node, connects this source node to our existing audio graph, draws its frequency spectrum (visualization), and finally starts playback using source.start().

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

As for the built-in synthesizer, it is entirely generated by JavaScript code.

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

Then, once the synthesizer has been created at the view level (user interface), you simply need to call this method to play a note.

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

The melodies are simply a **series of notes played one after another at a certain rhythm**. In the code, we just use arrays that list the notes, and we play them at the right tempo using setTimeout (or more precisely, chained timeouts or a scheduled timing loop).

For example, here is the part of the code that creates the data to represent the first melody (The Imperial March).

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

And here is the part of the code that allows us to launch this melody while following a precise tempo using setTimeout.

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

For the parameters, some are **handled natively** by the components of the Web Audio API. For example, in the case of volume, it is controlled directly by the gain node: a user input (such as a slider or knob) allows real-time modification of its value. The update takes effect immediately whenever the input value changes, by executing the corresponding function.

```javascript
    //Manage volume
    function changeVolume(element){
        var volume = element.value;
        var fraction = parseInt(element.value) / parseInt(element.max);
        gainNode.gain.value = fraction * fraction;
    }
```

Other parameters, on the other hand, are implemented using custom **AudioWorkletNodes**. These are nodes that we code ourselves **to create tailor-made audio effects**, such as specific filters or various types of audio processing that are not available natively in the Web Audio API. In these cases, we have to develop the entire component from scratch (both the JavaScript part and the audio-thread processor code). For example, in the application, I will now explain how I implemented my own noise effect.

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

As you can see, we create a class called NoiseProcessor that extends AudioWorkletProcessor.  At the beginning, we define a static method **parameterDescriptors()** which allows us to declare custom automatable parameters (AudioParam) for our AudioWorkletNode.

Next, we implement the **process(inputs, outputs, parameters)** function, which is responsible for real-time audio processing, block by block (typically 128 samples per call). This function receives three arguments:
- **inputs**: an array containing the audio input buffers;  
- **outputs**: an array containing the audio output buffers (this is where we write the processed signal);  
- **parameters**: an object containing the current values of the custom AudioParams declared earlier via parameterDescriptors().

In the case of our Noise effect example, we have three parameters: type, cutoff, and gain.  We then implement the actual noise generation logic, and when multiple parameter values are involved, we commonly use a switch statement (or equivalent logic) to handle the different behaviors depending on the currently active value (especially for the type parameter).

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Drum Machine and Theremin implementation
<a id="code-drum-machine-theremin"></a>

These three instruments were coded using **Grok AI**. I first built them in separate files (theremin.html and drum-machine.html) until I reached satisfactory versions, then I integrated them into the main application.For the integration, I split the code into three parts:

- A **CSS part** that can be found in the **css folder**
- A **view-related part** in the file **index.html**
- And finally the **JavaScript part**, simply added to the file **webaudio.js**.

Of course, I had to move some of the JavaScript code to connect it properly to my Web Audio graph by adding the following two methods during the initialization of my audio context: **initAudioGraphTheremin()** and **initAudioGraphDrumMachine()**.

``` javascript
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

  .........

```

Since AI is not yet advanced enough to provide all the features I was asking for, I had to code them myself within the code generated by Grok.

Regarding the drum machine, I added the ability to **create my own PRESETS**, and I also had to fix several **issues caused by the asynchronous nature of the code**. It is now possible to add as many patterns as desired by creating pattern variables and making them accessible in the changePattern function.

``` javascript
  let patternNull = {
      kick:  Array(16).fill(false),
      snare: Array(16).fill(false),
      hihat: Array(16).fill(false),
      clap:  Array(16).fill(false),
      tom:   Array(16).fill(false),
      ride:  Array(16).fill(false),
      crash: Array(16).fill(false),
    };

	let patternBase = {
      kick:  Array(16).fill(false).map((_,i) => [0,4,8,12,15].includes(i)),
      snare: Array(16).fill(false).map((_,i) => i%4===2),
      hihat: Array(16).fill(false).map((_,i) => i%2===0),
      clap:  Array(16).fill(false).map((_,i) => i%8===6 || i%8===14),
      tom:   Array(16).fill(false),
      ride:  Array(16).fill(false).map((_,i) => i%4===3),
      crash: Array(16).fill(false).map((_,i) => i===0),
    };

	let pattern = patternNull;

	function changePattern(id) {
		if(id==0) pattern = patternBase;
		initPattern(pattern);
	}

	function initPattern(pattern){
		// console.log(pattern);
		for( let i=0; i < instruments.length; i++ ) {
			// on récupère les elements du DOM
			let instrumentDOM = document.getElementsByClassName(instruments[i]);
			let patternInstrumentValue = pattern[instruments[i]];
			for( let j=0; j < instrumentDOM.length; j++ ) {
				if(patternInstrumentValue[j] == true) {
					instrumentDOM[j].classList.add('on');
				} else {
					instrumentDOM[j].classList.remove('on');
				}
			}
		}
	}
```

Regarding the theremin, I also created a **preset()** function to **generate a random PRESET**.

``` javascript
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
```

Additionally, I modified the sequencer generation **to allow muting certain notes**, and I added the corresponding JavaScript events. I also had to resolve several **issues related to the asynchronous nature of the code**, but I won’t go into detail here — I find the code quite readable if you have a decent level in JavaScript. I also updated the CSS for both instruments so that their look and feel is consistent with the rest of my application.

The **sequencer does not require initialization of the graph** because each note is linked to an oscillator that we use only once, we recreate it each time we need to play a note. The main part of the instrument is located in the **playSynthNote(freq, startTime, duration, type)** function, the sequence is executed with a **setTimeout** via the call of the **schedulerSeq()** function

``` javascript
    function playSynthNote(freq, startTime, duration, type) {
      let osc1, osc2, gainEnv, filterSeq, distortion;

      const masterGainSeq = audioCtx.createGain();
      masterGainSeq.gain.setValueAtTime(volumeSeq/100, startTime);

      switch (type) {
        case 'guitar':
          osc1 = audioCtx.createOscillator(); osc1.type = 'sawtooth'; osc1.frequency.value = freq;
          osc2 = audioCtx.createOscillator(); osc2.type = 'square'; osc2.frequency.value = freq * 0.99; // léger detune
          gainEnv = audioCtx.createGain();
          gainEnv.gain.setValueAtTime(volumeSeq/100, startTime);
          gainEnv.gain.linearRampToValueAtTime(0.8, startTime + 0.005); // fast attack
          gainEnv.gain.exponentialRampToValueAtTime(0.01, startTime + duration);

          filterSeq = audioCtx.createBiquadFilter();
          filterSeq.type = 'bandpass';
          filterSeq.frequency.value = freq * 3;
          filterSeq.Q.value = 2;

          distortion = audioCtx.createWaveShaper();
          distortion.curve = new Float32Array(65536).map((_, i) => {
            const x = (i - 32768) / 32768;
            return Math.tanh(x * 3); // soft clip
          });

          osc1.connect(distortion);
          osc2.connect(distortion);
          distortion.connect(filterSeq);
          filterSeq.connect(gainEnv);
          gainEnv.connect(masterGainSeq);
          break;

        case 'bass':
          osc1 = audioCtx.createOscillator(); osc1.type = 'sawtooth'; osc1.frequency.value = freq;
          osc2 = audioCtx.createOscillator(); osc2.type = 'square'; osc2.frequency.value = freq;
          gainEnv = audioCtx.createGain();
          gainEnv.gain.setValueAtTime(volumeSeq/100, startTime);
          gainEnv.gain.linearRampToValueAtTime(1.0, startTime + 0.01);
          gainEnv.gain.exponentialRampToValueAtTime(0.001, startTime + duration * 0.6);

          filterSeq = audioCtx.createBiquadFilter();
          filterSeq.type = 'lowpass';
          filterSeq.frequency.value = freq * 4;
          filterSeq.Q.value = 1;

          osc1.connect(filterSeq);
          osc2.connect(filterSeq);
          filterSeq.connect(gainEnv);
          gainEnv.connect(masterGainSeq);
          break;

        case 'trumpet':
          osc1 = audioCtx.createOscillator(); osc1.type = 'sawtooth'; osc1.frequency.value = freq;
          gainEnv = audioCtx.createGain();
          gainEnv.gain.setValueAtTime(volumeSeq/100, startTime);
          gainEnv.gain.linearRampToValueAtTime(0.9, startTime + 0.03);
          gainEnv.gain.linearRampToValueAtTime(0.6, startTime + 0.15);
          gainEnv.gain.exponentialRampToValueAtTime(0.01, startTime + duration);

          filterSeq = audioCtx.createBiquadFilter();
          filterSeq.type = 'peaking';
          filterSeq.frequency.value = freq * 2.5;
          filterSeq.gain.value = 8;
          filterSeq.Q.value = 3;

          const vibrato = audioCtx.createOscillator();
          vibrato.type = 'sine';
          vibrato.frequency.value = 5;
          const vibratoGain = audioCtx.createGain();
          vibratoGain.gain.value = 8;
          vibrato.connect(vibratoGain);
          vibratoGain.connect(osc1.frequency);
          vibrato.start(startTime);

          osc1.connect(filterSeq);
          filterSeq.connect(gainEnv);
          gainEnv.connect(masterGainSeq);
          break;

        case 'sax':
          osc1 = audioCtx.createOscillator(); osc1.type = 'triangle'; osc1.frequency.value = freq;
          osc2 = audioCtx.createOscillator(); osc2.type = 'sawtooth'; osc2.frequency.value = freq; osc2.detune.value = -20;
          gainEnv = audioCtx.createGain();
          gainEnv.gain.setValueAtTime(volumeSeq/100, startTime);
          gainEnv.gain.linearRampToValueAtTime(0.7, startTime + 0.08);
          gainEnv.gain.linearRampToValueAtTime(0.4, startTime + 0.3);
          gainEnv.gain.exponentialRampToValueAtTime(0.001, startTime + duration);

          filterSeq = audioCtx.createBiquadFilter();
          filterSeq.type = 'bandpass';
          filterSeq.frequency.value = freq * 1.8;
          filterSeq.Q.value = 4;

          // Breath noise
          const noise = audioCtx.createBufferSource();
          const noiseBuffer = audioCtx.createBuffer(1, audioCtx.sampleRate * 2, audioCtx.sampleRate);
          const data = noiseBuffer.getChannelData(0);
          for (let i = 0; i < data.length; i++) data[i] = Math.random() * 2 - 1;
          noise.buffer = noiseBuffer;
          const noiseGain = audioCtx.createGain();
          noiseGain.gain.value = 0.08;
          noise.connect(noiseGain);
          noiseGain.connect(filterSeq);

          osc1.connect(filterSeq);
          osc2.connect(filterSeq);
          filterSeq.connect(gainEnv);
          gainEnv.connect(masterGainSeq);
          noise.start(startTime);
          noise.stop(startTime + duration);
          break;
      }

      //masterGain.connect(audioCtx.destination);
	  masterGainSeq.connect(lBand);
	  masterGainSeq.connect(hBand);
	  masterGainSeq.connect(mGain);

      if (osc1) osc1.start(startTime);
      if (osc2) osc2.start(startTime);
      if (osc1) osc1.stop(startTime + duration + 0.1);
      if (osc2) osc2.stop(startTime + duration + 0.1);
    }

    function schedulerSeq() {
      while (nextStepTime < audioCtx.currentTime + scheduleAheadTime) {

        for(let col = 0; col < cols; col++) {
          // On annule l'effet sur les autres
          document.querySelectorAll('.stepSeq').forEach(element => {
            element.style.opacity = "1.0";
          });
          // On appliquer un effet sur la colonne currentStepSeq
          document.querySelectorAll('.stepSeq.col'+currentStepSeq).forEach(element => {
            element.style.opacity = "0.5";
          });
        }

        for (let row = 0; row < rows; row++) {
          if (pattern_guitar[row][currentStepSeq]) {
            playSynthNote(noteFreqs[row], nextStepTime, 0.45, 'guitar'); // durée ~8n à 120bpm
          }
          if (pattern_bass[row][currentStepSeq]) {
            playSynthNote(noteFreqs[row], nextStepTime, 0.45, 'bass'); // durée ~8n à 120bpm
          }
          if (pattern_trumpet[row][currentStepSeq]) {
            playSynthNote(noteFreqs[row], nextStepTime, 0.45, 'trumpet'); // durée ~8n à 120bpm
          }
          if (pattern_sax[row][currentStepSeq]) {
            playSynthNote(noteFreqs[row], nextStepTime, 0.45, 'sax'); // durée ~8n à 120bpm
          }
        }
        nextNote();
      }
      timerID = setTimeout(schedulerSeq, lookahead * 1000);
    }
```

Regarding the presets, we simply use a table which contains 8 tables (1 per note) and the number of desired sequences (16 in our case), the value of the element of the table is 1 if the note is played, 0 otherwise. This allows you to have a pattern for an instrument, in the presets that I use, I have 1 pattern per instrument, so 4 patterns for 1 preset.

``` javascript
    const patternFunkGuitar = [
      [0,1,0,0,1,0,0,0,0,1,0,0,1,0,0,0],
      [0,0,0,1,0,0,1,0,0,0,1,0,0,0,1,0],
      [0,0,0,0,0,1,0,0,0,0,0,1,0,0,0,0],
      [0,0,0,0,0,0,0,1,0,0,0,0,0,1,0,0],
      [0,0,1,0,0,0,0,0,1,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0],
      [0,0,0,0,0,0,0,0,0,0,0,0,0,0,0,0]
    ];
```


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Potential improvements
<a id="improvment"></a>

Here is a list of points to improve in order to optimize this application:Better RAM / memory management.

- Reduce memory leaks, optimize texture/buffer allocations in WebGL, clean up unused nodes/buffers, and monitor heap usage especially during long sessions or when switching between many audio files/melodies.)
- Remove individual OscillatorNodes from the built-in synthesizer and replace them with a dedicated AudioWorkletNode. This would enable true polyphony (playing multiple notes simultaneously) without degrading output audio quality.
    * Current per-note OscillatorNode approach creates too many nodes when polyphony increases → context overload, potential glitches, higher CPU.
    * A custom AudioWorkletProcessor can handle multiple voices internally (sum of waveforms + per-voice envelopes) in a much more efficient way on the audio thread.
- Optimize the AudioWorkletNode-based effects to achieve a more harmonious / musical sound output. Many current issues stem purely from suboptimal parameter tuning (thresholds, Q values, filter curves, gain staging, oversampling if applicable, etc.).
    * Refine algorithms, add anti-denormalization, improve interpolation, test with real musical content, adjust default presets.
- Allow applying multiple effects simultaneously, unlike the current implementation which restricts to only one active effect at a time.
    * Introduce a proper effect chain (array of AudioWorkletNodes or a single multi-effect processor).
    * Add UI for ordering effects, enabling/disabling, dry/wet per effect, global bypass.
    * Manage dynamic insertion/removal without audio glitches (disconnect/reconnect safely).
- ~~Optionally: add a drum machine / beatbox / sequencer to accompany the built-in synthesizer.~~
    * ~~Simple 4/4 patterns with kick, snare, hi-hat, clap/perc.~~
    * ~~Could be implemented via another AudioWorklet (for sample playback or synthesized drums) or using basic Web Audio nodes (noise + filters + envelopes).~~
    * ~~Sync it with melody tempo (BPM), allow pattern editing or preset grooves.~~



## License
<a id="license"></a>

The project is entirely **open source and free**.  No restrictions whatsoever: it’s simply free code made available to everyone, offered to the community for the benefit of all.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Contact
<a id="contact"></a>

Developer / Contact

**Name**: Porta <br/>
**First Name**: Benjamin <br/>
**Country**: FRANCE <br/>
**City**: Nice <br/>
**Email**: pb402385@gmail.com <br/>
**GitHub**: https://github.com/pb402385

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Acknowledgments
<a id="acknowledgments"></a>

First and foremost, I want to thank my friend **Klem**, who introduced me to WebGL several years ago. Without him, the idea of combining WebGL and Web Audio would never have crossed my mind.

For the Web Audio part, a huge thank you to my Master’s professor, **Michel Buffa**, who introduced me to it during my studies.

I would also like to thank the developers whose work inspired me and from whom I borrowed WebGL code on **Shadertoy** (https://www.shadertoy.com/).

* Thanks to **BigWIngs** from whom I adapted the Black Hole animation, original link: https://www.shadertoy.com/view/3d2SWK  
* Thanks to **Inigo Quilez** from whom I adapted the 3D Sierpinski Triangle animation, original link: https://www.shadertoy.com/view/4dl3Wl  
* Thanks to **GarlicGraphix** from whom I adapted the 3D Sierpinski Infinite animation, original link: https://www.shadertoy.com/view/wc23zR  
* Thanks to **Shane** from whom I adapted the 3D Sierpinski Mobius animation, original link: https://www.shadertoy.com/view/XsGXDV  
* Thanks once again to **Shane** from whom I adapted the Mandelbrot Decoration animation, original link: https://www.shadertoy.com/view/ttscWn

Concerning the 3 new instruments (drum machine, theremin and sequencer), I developed them using **the Grok AI (xAI)**, I then modified the code and the design so that it corresponded to my needs and I then divided the code into 3 parts (CSS/HTML/JS) for integration into the application.

Finally, for the other animations, I was mainly assisted by **Grok (xAI)** and to a lesser extent by **ChatGPT**.

<p align="right">(<a href="#readme-top">back to top</a>)</p>
