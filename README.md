# Pour bypasser les règles de CORS:

Brave/Chrome/Edge built-in (2024+ have this):
Open DevTools → Application tab → Service Workers → check “Bypass for network” is off, then just use any of the servers above.

That’s it. After 6 years of fighting this, the entire web-audio community has settled on “just use localhost”. There is no longer a magic bullet that works from file:// on all browsers.
Do it once, bookmark localhost:8000, and you’ll never see another AudioWorklet CORS or blob:null error again.


# run server
- install nodejs
- run prompt: python -m http.server 8000


# todo list
-bon paramètrage web audio

- revue de code
- documentation
- video de demo
- push sur git version full front et la version avec serveur

reouveller ass

