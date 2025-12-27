<a id="readme-top"></a>
<!-- PROJECT LOGO -->
<br />
<div align="center">
  <a href="https://github.com/github_username/repo_name">
    <img src="/favicon.ico" alt="Logo" width="80" height="80">
  </a>

<h3 align="center">Chargeur MP3/MP4 avec animations</h3>

  <p align="center">
    Chargeur MP3/MP4 avec animations (javascript et webGl) et piano en web audio
    <br />
    <a href="https://github.com/pb402385/webaudio_with_webgl_animations">Voir Demo</a>
  </p>
</div>

<!-- TABLE OF CONTENTS -->
<details>
  <summary>Sommaire</summary>
  <ol>
    <li>
      <a href="#a-propos-du-projet">A propos du projet</a>
      <ul>
        <li><a href="#technologies">Technologies</a></li>
      </ul>
    </li>
    <li>
      <a href="#commencer">Commencer</a>
      <ul>
        <li><a href="#prérequis-et-installation">Prérequis et installation</a></li>
      </ul>
    </li>
    <li><a href="#presentation">Presentation de l'application</a></li>
    <li>
        <a href="#functionalities">Fonctionnalités</a>
      <ul>
        <li><a href="#part-video">Partie Vidéo</a></li>
        <li><a href="#part-audio">Partie Audio</a></li>
      </ul>
    </li>
    <li>
        <a href="#codereview">Explication du code</a>
      <ul>
        <li><a href="#code-video">Partie Vidéo</a></li>
        <li><a href="#code-audio">Partie Audio</a></li>
      </ul>
    </li>
    <li><a href="#license">License</a></li>
    <li><a href="#contact">Contact</a></li>
    <li><a href="#acknowledgments">Remerciements</a></li>
  </ol>
</details>

<!-- ABOUT THE PROJECT -->
## A propos du projet

[![Product Name Screen Shot][product-screenshot]](https://example.com)

Here's a blank template to get started. To avoid retyping too much info, do a search and replace with your text editor for the following: `github_username`, `repo_name`, `twitter_handle`, `linkedin_username`, `email_client`, `email`, `project_title`, `project_description`, `project_license`

<p align="right">(<a href="#readme-top">back to top</a>)</p>

### Technologies

* [Three.js](https://threejs.org)
* [WebAudioAPI] (https://developer.mozilla.org/en-US/docs/Web/API/Web_Audio_API)


<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Commencer

### Prérequis et installation
Installez nodejs
Téléchargez le projet, puis depuis la racine du projet, tapez la commande suivante afin de lancer le serveur
  ```sh
  python -m http.server 8000
  ```

Ensuite, rendez-vous à l'url suivante: <a href="http://localhost:8000/index.html">http://localhost:8000/index.html</a>

### Presentation de l'application

Vous arrivez sur la page de l'application
<br/>
<img src="screenshots/application.png" alt="application.png" />
<br/>
L'application peut grâce à l'API Web Audio prendre en entrée un flux audio ou un son provenant du synthétiseur, le flux permet d'afficher plusieurs informations qui nous sont envoyées par le son qui peut également être altéré via divers paramètres (filtre, equalizer, effet), ce flux est ensuite transformé en une texture qui nous permettra de modifier des fonctions glsl (Web GL) afin de faire varier de très belles animations 2D/3D que l'on peut également paramétrer afin d'altérer le rendu visuel.

<p align="right">(<a href="#readme-top">back to top</a>)</p>

## Fonctionnalités

### Partie Vidéo

Voici les différents paramètres possibles pour la partie vidéo
<br/>
<img src="screenshots/video_params.png" alt="application.png" />
<br/>

Comme expliqué un peut plus haut, le son est transformé en une texture2D (une image) qui représente l'instant t de la variation du son, cette texture peut être utilisée en glsl (Web GL) afin de modifier en temps réels les vecteurs de l'animation graphique.

Voici à quoi ressemble un exemple de cette texture à un instant t
<br/>
<img src="screenshots/exemple_texture.png" alt="application.png" />
<br/>

Initialement, le projet fonctionne sur des formes (shapes) que l'on peut changer et afficher en 3D et celles-ci varient en fonction de l'intensité du flux audio, il a été rajouté une coupe 2D afin également de déformer ondulairement les formes. On peut également pour le cas 3D, répéter l'affichage de la forme à l'infini

La liste des formes possibles: Square, small Square, Torus, small Torus, Hexagone, Cone et Circle

Par exemple, voici une capture du Torus en 3D
<br/>
<img src="screenshots/shape_torus_webgl.png" alt="application.png" />
<br/>

Et de sa version 2D
<br/>
<img src="screenshots/shape_torus_2d_webgl.png" alt="application.png" />
<br/>

Si un son est en cours, la figure se fait déformer par la texture2D citée plus haut et voici un exemple de sa déformation en 3D
<br/>
<img src="screenshots/shape_square_3d_animated_webgl.png" alt="application.png" />
<br/>

Et de sa version 2D
<br/>
<img src="screenshots/shape_square_2d_animated_webgl.png" alt="application.png" />
<br/>

On peut également démultiplier la figure à l'infini comme sur la capture ci-dessous:
<br/>
<img src="screenshots/shape_infinity_webgl.png" alt="application.png" />
<br/>

On peut également ajouter un effet de twist sur les formes
<br/>
<img src="screenshots/shape_twist_webgl.png" alt="application.png" />
<br/>



Sinon il existe d'autres animations entièrement automatisées et ne nécessitant aucun paramétrage qui ne sont pas basées sur des formes et qui seront abordés un peu plus loin, mais on peut lancer une génération d'animations aléatoires en cliquant sur la bouton juste à côté du titre effet dans le menu vidéo (voir capture) 
<br/>
<img src="screenshots/effect_video_webgl.png" alt="application.png" />
<br/>
Celui-ci nous ouvre une popin listant toutes les animations et nous permettant de les sélectionner afin qu'elles soit dans une liste de lecture
<br/>
<img src="screenshots/video_random_animation.png" alt="application.png" />
<br/>
Si la fonctionnalité est activé, les animations sélectionnées défileront comme dans la vidéo ci-dessous par exemple: 

//TODO lien video youtube

### Partie Audio

#### Le synthé
Le synthé permet de générer notre flux audio, il fonctionne à l'aide d'oscillateur que l'API web audio nous founit et avec ceux ci nous pouvons jouer toutes les notes. On peut changer le type de l'onde afin d'en modifier sensiblement la tonalité ( Triangle, Sine, Square, Sawtooth )

Voici une petite vidéo afin de le présenter:
//TODO vidéo demo synthé

#### Les mélodies ou l'upload audio
Pour générer notre flux audio, nous pouvons soit utiliser un les mélodies, soit charger directement un fichier son qui peut être au format mp3,mp4 ou m4a1. Corcernant les mélodie (les mélodies sont la simulation d'une partition lue et jouée automatiquement au synthé sans qu'il n'y ait besoin que l'humain joue vraiment). Deux melodies sont disponibles, la marche impériale de Star wars et la marche de sacco et vanzetti
<br/>
<img src="screenshots/melodies_boutons.png" alt="application.png" />
<br/>
Sinon on peut upload un son
<br/>
<img src="screenshots/upload.png" alt="application.png" />
<br/>
Une fois le son uploadé, les  canvas s'animent, les deux premier concernent le son en temps réel et représentent l'amplitude. le graphe du bas représente le spectre du fichier uploadé
<br/>
<img src="screenshots/canvas_audio.png" alt="application.png" />
<br/>

#### Les paramètres audio
<br/>
<img src="screenshots/audio_params.png" alt="application.png" />
<br/>
Concernant les paramètres audio, les paramètres suivants sont disponibles:

1. Volume: permet de monter ou diminuer le son (valeur comprise entre 0 et 100%)
2. Equalizer: permet de paramétrer manuellement la valeur des fréquences autorisées (high,mid et low) (valeur comprise entre 0 et 100% pour chaque type)
3. Filtre: permet de choisir le filtre utilisé, il est associé à une fréquence qui peut être modifiée (les différents filtres sont: Low Pass (120hz), High Pass (120hz), Band Pass (800hz), Low Shelf (180hz), High Shelf (6000hz), Peaking (1000hz), Notch (500hz) et All Pass (500hz))
4. Effects: permet d'activer 1 effet sur le son parmi la liste suivante: ( ceux ayant un astérisque peuvent être paramétrés )

 - MOOG: le filtre produit un son "crémeux" (creamy), gras et musical (utile avec le synthé ou certaines musique utilisant des synthés).

 - NOISE (*): le filtre produit l'ajout intentionnel d’un signal de bruit (noise) pour créer une texture sonore, enrichir un son ou produire un effet artistique.

 - PITCH (*): le filtre modifie le son qui devient plus aigu (pitch plus haut) ou plus grave (pitch plus bas) tout en gardant exactement la même longueur.

 - BIT CRUSHER (*): le filtre produit un effet audio numérique qui simule la dégradation sonore d’un signal audio en réduisant volontairement sa qualité, comme le faisaient les vieux équipements numériques à faible résolution (consoles 8-bit, samplers anciens, etc.).

 - SIMPLE LOWPASS: le filtre produit un effet audio qui laisse passer les basses fréquences (les graves) tout en atténuant ou en coupant les hautes fréquences (les aigus).

 - COMPRESSOR (*): le filtre produit un effet audio qui réduit automatiquement la dynamique d’un signal audio, c’est-à-dire l’écart entre les parties les plus faibles et les plus fortes.

 - REVERB: le filtre produit un effet audio qui simule la résonance naturelle d’un espace acoustique (comme une pièce, une salle, une cathédrale, une grotte, etc.).

 - TREMOLO (*): le filtre produit un effet audio qui consiste à moduler périodiquement le volume (amplitude) d’un signal sonore, créant une variation régulière de loudness (fort → faible → fort → faible…).

 - FFT FX (*): le filtre produit un effet audio basé sur la Fast Fourier Transform (Transformation de Fourier Rapide), une algorithmique mathématique qui décompose un signal audio temporel en ses composantes fréquentielles (spectre de fréquences)



5. Speed Melody: permet d'ajuster la vitesse des 2 mélodies pré enregistrée
6. Type: type de l'onde jouée par l'oscillateur ( Triangle, Sine, Square, Sawtooth ) ne concerne que les melodies et le synthé


## Explication du code

### Partie Vidéo

### Partie Audio

## License

## Contact

## Remerciements