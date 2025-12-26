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