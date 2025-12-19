			
#define MAX_STEPS 90
#define MAX_DIST  60.0

#define PI 3.14159265359
#define FREQ 16
#define BANDS 128

vec4 values[FREQ];

// ──────────────────────────────────────────────────────────────
// ANIMATIONS, Partie SHAPES
// ──────────────────────────────────────────────────────────────

float sdBox( vec3 p, vec3 b ){
	vec3 d = abs(p) - b;
	return min(max(d.x,max(d.y,d.z)),0.0) + length(max(d,0.0));
}

float sdTorus( vec3 p, vec2 t ){
	vec2 q = vec2(length(p.xz)-t.x,p.y);
	return length(q)-t.y;
}

float lengthN(vec2 q, float n){
	//(x^n+y^n+z^n)^(1/n)
	float xP = float(pow(q.x,n));
	float yP = float(pow(q.y,n));
	float pP = xP+yP;
	float len = float(pow(pP,1.0/n));
	//float len = pow( (pow(q.x,n)+pow(q.y,n)) ,1/n );
	//float len = float(pow( float((pow(n,q.x)+pow(n,q.y))) ,1/n ));
	return len;
}


float sdTorus82( vec3 p, vec2 t ){
	vec2 q = vec2(lengthN(p.xz,2.0)-t.x,p.y);
	return lengthN(q,8.0)-t.y;
}

float sdTorus88( vec3 p, vec2 t ){
	vec2 q = vec2(lengthN(p.xz,8.0)-t.x,p.y);
	return lengthN(q,8.0)-t.y;
}

float sdHexPrism( vec3 p, vec2 h ){
	vec3 q = abs(p);
	return max(q.z-h.y,max((q.x*0.866025+q.y*0.5),q.y)-h.x);
}

float sdCone( vec3 p, vec2 c ){
	// c must be normalized
	float q = length(p.xy);
	return dot(c,vec2(q,p.z));
}

vec3 opTwist( vec3 p ){
	float twistFactor = 0.1;
	float dist = length(p);
	float angle = dist * twistFactor;
	float s = sin(angle);
	float c = cos(angle);
	mat2 rotationMatrix = mat2(c, s, -s, c);
	vec3  q = vec3(rotationMatrix*p.xz,p.y);
	return q;
}

vec3 opCheapBend( vec3 p ){
	float c = cos(20.0*p.y);
	float s = sin(20.0*p.y);
	mat2  m = mat2(c,-s,s,c);
	vec3  q = vec3(m*p.xy,p.z);
	return q;
}

vec3 opDisplacement( vec3 p ){
	float twistFactor = 0.1;
	float dist = length(p);
	float angle = dist * twistFactor;
	float s = sin(angle);
	float c = cos(angle);
	mat2 rotationMatrix = mat2(c, s, -s, c);
	vec3  q = vec3(rotationMatrix*p.xz,rotationMatrix*p.y);
	return q;
}

vec3 opTest( vec3 p ){
	float twistFactor = 0.33;
	float dist = length(p);
	float angle = dist * twistFactor;
	float s = sin(angle);
	float c = cos(angle);
	mat2 rotationMatrix = mat2(c, s, -s, c);
	vec3  q = vec3(rotationMatrix*p.xz,rotationMatrix*p.y);
	return q;
}

mat2 rot(in float a){
	return mat2(cos(a),sin(a),-sin(a),cos(a));	
}

// main distance function
float de(vec3 p){
	
	//demultiplier la figure
	if(uIntInfinity == 1) p = mod(p, vec3(20.0)) - vec3(10.0);
	//if(uIntEffect == 1) p = opCheapBend(p);
	if(uIntEffect == 2) p = opTwist(p);
	if(uIntEffect == 3) p = opDisplacement(p);
	if(uIntEffect == 4) p = opTest(p);
	
	float de = length(p) - 5.0;
	
	//type
	if(uIntType == 1){
		de = sdBox(p, vec3(5.0))-0.3;
	}
	if(uIntType == 2){
		de = sdBox(p, vec3(1.0))-0.8;
	}
	if(uIntType == 3){
		de = sdTorus(p, vec2(4.0))-0.3;
	}
	if(uIntType == 4){
		de = sdTorus(p, vec2(1.0))-0.3;
	}
	if(uIntType == 5){
		de = sdTorus82(p, vec2(2.0))+1.0;
	}
	if(uIntType == 6){
		de = sdTorus88(p, vec2(2.0))+1.0;
	}
	if(uIntType == 7){
		de = sdHexPrism(p, vec2(2.0))-1.0;
	}
	if(uIntType == 8) {
		de = sdCone(p, normalize(vec2(0.002,0.001))) -0.25;
		de = max(de, -2.0-p.z);
	}
	
	for (int i = 0 ; i < FREQ ; i++) {
		if(i == uIntFreq) break;
		
		float f = float(i) / float(FREQ-1);
		vec4 value = values[i];
		
		float theta = f * PI * 1.5;
		
		//effet displacement
		vec3 dir = vec3(cos(theta), sin(theta), 0);
		dir.yz *= rot(f*PI*1.0);
		float v = dot(p,dir);
		de += sin(v*2.0*pow(2.0, f) + iGlobalTime*1.0)*0.25*value.x;
	}
	return de;
} 


// normal function
vec3 normal(vec3 p) {
	vec3 e = vec3(0.0, 0.001, 0.0);
	return normalize(vec3(
		de(p+e.yxx)-de(p-e.yxx),
		de(p+e.xyx)-de(p-e.xyx),
		de(p+e.xxy)-de(p-e.xxy)));	
}



void mainImage( out vec4 fragColor, in vec2 fragCoord ){				
	vec2 uv = fragCoord.xy / iResolution.xy * 2.0 - 1.0;
	uv.y *= iResolution.y / iResolution.x;				
	vec3 from = vec3(-50, 0, 0);
	vec3 dir = normalize(vec3(uv*0.2, 1.0));
	dir.xz *= rot(3.1415*.5);				
	vec2 mouse=(iMouse.xy / iResolution.xy - 0.5) * 0.5;
	if (iMouse.z < 1.0) mouse = vec2(0.0);				
	mat2 rotxz = rot(iGlobalTime*0.0652+mouse.x*5.0);
	mat2 rotxy = rot(0.3-mouse.y*5.0);				
	from.xy *= rotxy;
	from.xz *= rotxz;
	dir.xy  *= rotxy;
	dir.xz  *= rotxz;
	float totdist = 0.0;
	bool set = false;
	vec3 norm = vec3(0);				
	if(uIntTypeTexture == 1){
		fragColor = texture2D(iChannel0, fragCoord.xy/iResolution.xy);
		return;
	}				
	for (int i = 0 ; i < FREQ ; i++) {
		if(i == uIntFreq) break;
		float f = float(i) / float(FREQ-1);		
		values[i] = texture2D(iChannel0, vec2(f, 0), -16.0);
	}				
	for (int steps = 0 ; steps < 200 ; steps++) {
		if (set) continue;
		vec3 p = from + totdist * dir;					
		float dist = de(p)*0.5;					
		totdist += dist;
		if (dist < 0.01) {
			set = true;
		}
	}				
	if (set) {    
		vec3 p = from + totdist * dir;
		norm = normal(p);
		vec3 light = normalize(vec3(-1, 2, 3));
		float l = max(dot(norm, light), 0.0);
		fragColor = vec4(vec3(l), 1.0);
		fragColor.rgb = norm*0.5+0.5;
	} else {
		fragColor = vec4(0, 0.2, 0, 1);
	}				
	if(uIntTypeTexture == 2){
		vec3 pp = vec3((fragCoord.xy-iResolution.xy*0.5)/iResolution.x, 0.0);
		pp *= 20.0;					
		pp.xy *= rot(iMouse.x*0.01);
		pp.xz *= rot(iMouse.y*0.01);					
		float dd = de(pp);
		fragColor.rgb = vec3(sin(dd*5.0)*0.5+0.5);
		fragColor.rgb /= abs(dd)+1.0;
		if (dd < 0.0) fragColor.r = 0.0;
		fragColor.a = 1.0;
	}
	return;								
}

// Fonction principale du fragment
void mainImageGalaxy(out vec4 fragColor, in vec2 fragCoord){
	vec4 fragColorTexture = texture2D(iChannel0, fragCoord.xy*iResolution.xy);
	// Coordonnées normalisées (UV) centrées
	vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
	uv *= 1.5; // Zoom pour voir la galaxie
	// Paramètres de la galaxie
	float formuparam = 12.0 + 100.0; // Densité des étoiles
	float stepsize = 0.18;   // Pas d'itération
	float zoom = 0.8 + 0.2 * sin(iGlobalTime * 0.1); // Animation de zoom
	float tile = 0.85;
	float brightness = 0.0015;
	float darkmatter = 0.25;
	float distfading = 0.7333;
	float saturation = 0.85;
	if(uIntFreq == 2) {
		stepsize = stepsize / 10.0;
	}
	if(uIntFreq == 4) {
		stepsize = stepsize / 2.0;
	}
	if(uIntFreq == 8) {
		stepsize = stepsize;
	}
	if(uIntFreq == 12) {
		stepsize = stepsize * 10.0;
	}
	if(uIntFreq == 16) {
		stepsize = stepsize * 16.0;
	}
	// Initialisation
	float s = 0.1;
	float v = 0.0;
	float t = iGlobalTime * 0.2; // Temps pour l'animation
	// Boucle d'itération fractale (simule la profondeur galactique)
	// int stopIter = FREQ;
	for (int i = 0; i < 5; i++) { // Remplacez par 45 pour plus de détail (mais plus lent)
		vec3 p;
		float p2 = 0.0;
		// Position 3D simulée
		p = vec3(uv / zoom, s - 1.5);					
		// *** MATRICE DE ROTATION pour l'effet spirale ***
		// Matrice 2x2 de rotation (mat2) appliquée aux coordonnées XY
		float angle = t * (1.0 + 0.5 * s); // Angle variant avec la distance
		float si = sin(angle);
		float co = cos(angle);
		mat2 ma = mat2(co, -si, si, co); // Matrice de rotation standard
		p.xy *= ma; // Applique la rotation spirale					
		// Ajout d'un offset pour le centre galactique
		p += vec3(0.22, 0.3, s * 0.1);
		// Itérations pour la fractalisation (effet nébuleux)
		for (int i = 0; i < 8; i++) {
			p = abs(p) / dot(p, p) - 0.659; // Transformation itérative
			p = vec3(p.x+0.01*fragColorTexture.x, p.y+0.01*fragColorTexture.y, p.z+0.01*fragColorTexture.z);
		}
		// Accumulation de densité
		p2 += dot(p, p);
		v += p2 * brightness * (1.0 + sin(uv.x * 13.0 + t) * 0.5); // Bruit stellaire
		// Mise à jour de la distance
		s += stepsize;
	}
	// Assombrissement avec la distance
	v = clamp(v, 0.0, 1.0);
	v *= (1.0 - (s - 1.5) * distfading); // Fade-out
	// Couleurs galactiques (bleu-violet pour les bras)
	vec3 color = vec3(v * 0.5, v * 0.8, v); // Teinte basique
	color = mix(color, vec3(1.0), darkmatter); // Ajout de "matière noire" (étoiles)				
	// Saturation
	color = mix(vec3(dot(color, vec3(0.333))), color, saturation);
	//vec4 fragColorTexture = texture2D(iChannel0, fragCoord.xy*iResolution.xy);
	//color = vec3(color.x+0.5*fragColorTexture.x, color.y+0.5*fragColorTexture.y, color.z+0.5*fragColorTexture.z);
	color = smoothstep(color, fragColorTexture.xyz, vec3(0.3, 0.3, 0.3));
	// Sortie finale
	fragColor = vec4(color, 1.0);
}


// ──────────────────────────────────────────────────────────────
// Galaxie Spirale Classique avec Matrice de Rotation
// Auteur : adaptation simple et claire pour vous
// Date : 2025
// ──────────────────────────────────────────────────────────────
void mainImageSpiralGalaxy( out vec4 fragColor, in vec2 fragCoord ){
	// Coordonnées centrées et normalisées (-1 à +1)
	vec2 uv = (fragCoord - 0.5*iResolution.xy) / iResolution.y;				
	float time = iGlobalTime * 0.1;  // vitesse de rotation lente				
	// === 1. Conversion en coordonnées polaires ===
	float r = length(uv);                    // distance au centre
	float theta = atan(uv.y, uv.x);          // angle				
	// === 2. Application d'une spirale logarithmique avec MATRICE ===
	// On utilise une matrice de rotation qui dépend de la distance (r)
	// Plus on est loin, plus on tourne → bras spiraux				
	float spiralStrength = 4.0;   // nombre de bras / force de la spirale
	float angleOffset = spiralStrength * log(r + 0.5) - time * 2.0;				
	// Construction de la matrice 2x2 de rotation qui varie avec r
	float cosA = cos(angleOffset);
	float sinA = sin(angleOffset);
	mat2 rot = mat2(cosA, -sinA,
					sinA,  cosA);
	// On applique la rotation aux coordonnées uv
	vec2 rotatedUV = rot * uv;				
	// On recalcule l'angle après rotation (c'est lui qui va dessiner les bras)
	float spiralAngle = atan(rotatedUV.y, rotatedUV.x);				
	// === 3. Bras spiraux (2 bras principaux + 2 secondaires) ===
	float arms = 2.0;  // nombre de bras principaux
	if(uIntFreq == 2) {
		arms = 2.0;
	}
	if(uIntFreq == 4) {
		arms = 4.0;
	}
	if(uIntFreq == 8) {
		arms = 8.0;
	}
	if(uIntFreq == 12) {
		arms = 12.0;
	}
	if(uIntFreq == 16) {
		arms = 16.0;
	}
	float armPhase = cos(spiralAngle * arms) * 0.5 + 0.5;				
	// Ajout d'un peu de bruit pour les détails
	armPhase += 0.15 * sin(spiralAngle * 20.0 + r*30.0 + time*3.0);				
	// === 4. Densité de la galaxie (exponentielle vers le centre) ===
	float density = exp(-r * 3.0);                    // disque central lumineux
	density += armPhase * smoothstep(0.05, 0.7, r) * exp(-r * 2.5);  // bras				
	// Bulge central (noyau jaune/orangé)
	float core = exp(-r * 12.0);				
	// Poussière / matière sombre entre les bras
	density = mix(density * 0.3, density, armPhase);				
	// === 5. Étoiles scintillantes aléatoires ===
	float stars = 0.0;				
	// === 6. Couleur finale ===
	vec4 fragColorTexture = texture2D(iChannel0, fragCoord.xy*iResolution.xy);
	vec3 galaxyColor = vec3(0.8, 0.7, 1.0);     // teinte bleutée des bras
	//vec3 coreColor   = vec3(1.0, 0.9, 0.6);     // noyau doré
	vec3 coreColor   = vec3(1.0*fragColorTexture.x, 0.5*fragColorTexture.y, 0.2*fragColorTexture.z);     // noyau doré
	vec3 dustColor   = vec3(0.6, 0.4, 0.3) * 0.5;				
	vec3 color = density * galaxyColor;
	color += core * coreColor * 3.0;
	color += stars * 4.0;
	//color = mix(color, dustColor, 1.0 - armPhase * 0.8); // zones sombres entre bras
	color = mix(color, fragColorTexture.xyz, dustColor); // zones sombres entre bras				
	// Vignettage doux
	color *= 1.0 - smoothstep(0.6, 1.2, r);				
	fragColor = vec4(color, 1.0);
}



// ──────────────────────────────────────────────────────────────
// Galaxie 3D Elite Dangerous Style - Ray Marching + Matrice Spirale
// Auteur : adaptation 2025 pour vous
// ──────────────────────────────────────────────────────────────
// Hash simple pour étoiles procédurales
float hash(vec3 p) {
	p = fract(p * vec3(0.1031, 0.1030, 0.0973));
	p += dot(p, p.yzx + 33.33);
	return fract((p.x + p.y) * p.z);
}
// Bruit 3D basique pour densité
float noise(vec3 p) {
	vec3 i = floor(p);
	vec3 f = fract(p);
	f = f * f * (3.0 - 2.0 * f);
	return mix(mix(mix(hash(i + vec3(0,0,0)), hash(i + vec3(1,0,0)), f.x),
				mix(hash(i + vec3(0,1,0)), hash(i + vec3(1,1,0)), f.x), f.y),
			mix(mix(hash(i + vec3(0,0,1)), hash(i + vec3(1,0,1)), f.x),
				mix(hash(i + vec3(0,1,1)), hash(i + vec3(1,1,1)), f.x), f.y), f.z);
}
// Matrice de rotation 3D (axe Z)
mat3 rotZ(float a) {
	float c = cos(a), s = sin(a);
	return mat3(c, -s, 0.0,
				s,  c, 0.0,
				0.0, 0.0, 1.0);
}
// Fonction de densité galactique 3D
float density(vec3 p) {
	float r = length(p.xz);
	float y = p.y;				
	// Distance au plan galactique
	float height = exp(-abs(y)*3.0);				
	// === SPIRALE LOGARITHMIQUE avec matrice ===
	float spiralStrength = 3.8;           // nombre de bras
	float tightness = 0.25;
	float angle = atan(p.z, p.x);
	float spiral = angle + spiralStrength * log(r + 0.8) - tightness * r;				
	// Matrice de rotation qui varie avec r → crée la spirale parfaite
	mat2 rotSpiral = mat2(cos(spiral), -sin(spiral),
						sin(spiral),  cos(spiral));
	vec2 spiralCoord = rotSpiral * p.xz;
	float arm = cos(spiralCoord.x * 2.0) * 0.5 + 0.5;  // 4 bras (2 principaux + 2 secondaires)				
	// Profil radial (disque + bulge)
	float radial = exp(-r * 0.4) * (1.0 + 10.0 * exp(-r*4.0)); // bulge central				
	// Densité finale
	float d = radial * height * (0.4 + arm * 2.5);				
	// Poussière entre les bras
	d *= 0.6 + 0.4 * arm;				
	return d * 0.1;
}

float map(vec3 p) {
	p *= 0.15;                     // échelle globale de la galaxie
	p *= rotZ(iGlobalTime * 0.05);       // rotation lente
	return density(p);
}

// Ray marching avec accumulation volumétrique
vec3 render(vec3 ro, vec3 rd) {
	float t = 0.0;
	vec3 color = vec3(0.0);
	float transmittance = 0.8;
	if(uIntFreq == 2) {
		transmittance = 0.1;
	}
	if(uIntFreq == 4) {
		transmittance = 0.3;
	}
	if(uIntFreq == 8) {
		transmittance = 0.8;
	}
	if(uIntFreq == 12) {
		transmittance = 1.0;
	}
	if(uIntFreq == 16) {
		transmittance = 2.0;
	}				
	for(int i = 0; i < MAX_STEPS; i++) {
		vec3 p = ro + rd * t;
		float d = map(p);					
		// Absorption + émission
		vec3 light = vec3(1.2, 0.9, 0.7) * 3.0;           // lumière chaude du noyau
		light += vec3(0.6, 0.7, 1.2) * (d*10.0);          // reflets bleus des jeunes étoiles					
		color += light * d * transmittance * 0.25;
		transmittance *= exp(-d * 0.15);  // extinction					
		t += 0.4 + t*0.03;  // step size adaptatif					
		if(t > MAX_DIST || transmittance < 0.01) break;
	}				
	// Fond noir + ÉTOILES PROCÉDURALES (remplace texture() pour éviter l'erreur)
	// Génération d'étoiles lointaines avec hash et bruit
	vec3 stars = vec3(0.0);
	float starDensity = 0.0;
	for(int i = 0; i < 3; i++) {  // Multi-échelles pour plus de variété
		vec3 starP = rd * (20.0 + float(i) * 15.0);  // Positions lointaines
		float n = noise(starP * 0.5 + iGlobalTime * 0.1);  // Animation subtile
		starDensity += n * (0.5 / float(i+1));  // Densité décroissante
	}				
	stars = vec3(pow(starDensity, 8.0)) * 30.0 * vec3(1.0, 0.9, 0.8);  // Étoiles blanches/jaunes twinkling
	color += stars * transmittance; 
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);
	color = mix(color, vec3(0.2, 0.2, 0.2), fragColorTexture.xyz);
	//color = smoothstep(color, vec3(0.5, 0.5, 0.5), fragColorTexture.xyz);
	//color = vec3(color.x+fragColorTexture.x, color.y+fragColorTexture.y, color.z+fragColorTexture.z);
	//color = vec3(color.x, color.y, color.z);				
	return color;
}

void mainImageSpiralGalaxy3D(out vec4 fragColor, in vec2 fragCoord) {
	vec2 uv = (fragCoord - 0.5*iResolution.xy) / iResolution.y;				
	// Caméra orbitante (comme dans Elite Dangerous)
	float camDist = 18.0;
	float camTime = iGlobalTime * 0.1;
	vec3 ro = vec3(sin(camTime)*camDist, sin(camTime*0.7)*3.0, cos(camTime)*camDist);
	vec3 target = vec3(0.0, 0.0, 0.0);
	vec3 forward = normalize(target - ro);
	vec3 right = normalize(cross(forward, vec3(0.0,1.0,0.0)));
	vec3 up = cross(right, forward);
	vec3 rd = normalize(forward + uv.x*right + uv.y*up);				
	// Auto-exposure simple
	vec3 col = render(ro, rd);
	col = col / (1.0 + col);           // tone mapping
	col = pow(col, vec3(0.8));         // gamma léger				
	fragColor = vec4(col, 1.0);
}



// ──────────────────────────────────────────────────────────────
// Julia Fractale Animée — Ultra fluide & hypnotique
// Par Grok, 2025 - 100 % fonctionnel sur ShaderToy
// ──────────────────────────────────────────────────────────────
void mainImageFractal(out vec4 fragColor, in vec2 fragCoord){
	// Coordonnées normalisées centrées
	vec2 uv = (fragCoord - iResolution.xy * 0.25) / iResolution.y;
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);				
	// Temps pour animation fluide
	float time = iGlobalTime * 0.2;				
	// === PARAMÈTRE C ANIMÉ (c’est ça qui fait toute la beauté) ===
	// Essaie aussi ces classiques en décommentant :
	// vec2 c = vec2(-0.8, 0.156);           // Avion classique
	// vec2 c = vec2(-0.7269, 0.1889);      // Spirale
	// vec2 c = vec2(-0.4, 0.6);            // Dendrite
	vec2 c = 0.35 * cos(time * 0.7 + vec2(0.0, 1.57)) + vec2(-0.7, 0.0);
	if(uIntFreq == 2) {
		c = 0.35 * cos(time * 0.7 + vec2(0.0, 1.57)) + vec2(-0.7, 0.0);
	}
	if(uIntFreq == 4) {
		c = vec2(-0.8, 0.156);  
	}
	if(uIntFreq == 8) {
		//c = 0.35 * cos(time * 0.7 + vec2(0.0, 1.57)) + vec2(-0.7, 0.0);
		c = vec2(-0.7269, 0.1889); 
	}
	if(uIntFreq == 12) {
		c = vec2(-0.4, 0.6); 
	}
	if(uIntFreq == 16) {
		c = vec2(-0.3, 0.8); 
	}				
	// Zoom automatique + rotation lente
	float zoom = pow(0.5, sin(time * 0.3) * 2.0); // va de 1x à 100x environ
	float angle = time * 0.05;
	mat2 rot = mat2(cos(angle), -sin(angle), sin(angle), cos(angle));
	vec2 z = rot * uv * zoom + vec2(0.0, 0.0);
	// === Calcul de la fractale Julia ===
	const int maxIter = 256;
	int iter = 0;
	for (int i = 0; i < maxIter; i++)
	{
		// z = z² + c
		z = vec2(z.x * z.x - z.y * z.y, 2.0 * z.x * z.y) + c;
		
		if (dot(z, z) > 4.0) break;
		iter++;
	}
	// === Coloration magique (mes préférées) ===
	float smoothIter = float(iter) + 1.0 - log(log(length(z))) / log(2.0);
	float color = smoothIter / float(maxIter);
	// Palette 1 — Couleurs chaudes psychédéliques (ma préférée)
	vec3 col = 0.5 + 0.5 * cos(6.28318 * (color * 2.0 + vec3(0.0, 0.33, 0.67) + time * 0.1));
	col = 0.5 + 0.5 * cos(6.28318 * (color * 2.0 + fragColorTexture.xyz + time * 0.1));
	//col = 0.5 + 0.5 * cos(6.28318 * (color * 2.0 + cos(fragColorTexture.x) + time * 0.1));
	//col = mix(col, fragColorTexture.xyz, vec3(0.1,0.1,0.1));
	// Palette 2 — Bleu électrique (décommenter pour changer)
	// vec3 col = vec3(0.0, 0.3, 0.8) + vec3(1.0, 0.7, 0.0) * pow(color, 0.3);
	// Palette 3 — Arc-en-ciel infini
	// vec3 col = 0.5 + 0.5 * sin(10.0 * color + time + vec3(0.0, 2.0, 4.0));
	// Effet de pulsation globale
	col *= 0.9 + 0.1 * sin(time * 3.0);
	// Vignettage doux
	col *= 1.0 - 0.3 * dot(uv, uv);
	fragColor = vec4(col, 1.0);
}










// ──────────────────────────────────────────────────────────────
// Vortex Black Hole Reactor - Par Grok 2025
// iChannel0 → ta texture FFT / waveform (1 ligne = spectre, 256 ou 512 px de large)
// ──────────────────────────────────────────────────────────────

// Récupère l’amplitude à une fréquence normalisée (0.0 → 1.0)
float freqInfiniteTunnel(float f) {
	// return f;
	return texture2D(iChannel0, vec2(f, 0.25), -16.0).r;
}

// Moyennes utiles
float bassInfiniteTunnel()     { return (freqInfiniteTunnel(0.0) + freqInfiniteTunnel(0.05) + freqInfiniteTunnel(0.1)) / 3.0; }      // kick
float lowMidInfiniteTunnel()   { return (freqInfiniteTunnel(0.15) + freqInfiniteTunnel(0.25)) / 2.0; }               // basse/mid
float trebleInfiniteTunnel()   { return (freqInfiniteTunnel(0.7) + freqInfiniteTunnel(0.85) + freqInfiniteTunnel(0.95)) / 3.0; }   // hats

void mainImageInfiniteTunnel( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = (fragCoord - iResolution.xy*0.5) / iResolution.y;
	vec4 fragColorTexture = texture2D(iChannel0, uv.xy*iResolution.xy);
	float time = iGlobalTime * 0.8;				
	// ——— Réactivité au son ———
	float kick   = pow(bassInfiniteTunnel(), 3.0);           // très punchy sur le kick
	float energy = pow(lowMidInfiniteTunnel(), 2.0);         // énergie globale
	float spark  = pow(trebleInfiniteTunnel(), 4.0);         // scintillements aigus			
	// Distance et angle polaire
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);				
	// Spirale qui tourne + s’accélère avec l’énergie
	float spiral = angle + time * (1.0 + energy*6.0) + 1.0/dist * (3.0 + kick*15.0);
	float arms = smoothstep(0.4, 0.0, abs(fract(spiral*2.0 + 0.5) - 0.5));				
	// Accretion disk qui pulse
	float disk = smoothstep(0.7, 0.1, dist);
	disk *= smoothstep(0.0, 0.4, dist);
	disk *= 1.0 + kick*8.0; // énorme flash sur chaque kick				
	// Event horizon (trou noir)
	float hole = smoothstep(0.12 - kick*0.08, 0.08, dist);				
	// Particules / plasma aspirées
	float particles = 0.0;
	for(int i = 0; i < 16; i++)
	{
		float fi = float(i)/16.0;
		float t = time*0.5 + fi*10.0;
		vec2 off = vec2(cos(t), sin(t*1.618)) * (0.3 + fi*0.7 + kick);
		particles += 0.004 / length(uv - off * (1.0 - fi*0.5));
	}
	particles = pow(particles, 2.0) * (1.0 + spark*20.0);				
	// Gravitational lensing simple (distorsion autour du trou)
	vec2 lensUV = uv / (1.0 + dist*2.0);
	//float stars = texture(iChannel0, lensUV*0.5 + vec2(time*0.01, 0.0)).r; // iChannel0 = bruit ou étoiles
	float stars = 0.1;
	if(uIntFreq == 2) {
		stars = 0.1;
		particles = pow(particles, 1.0) * (1.0 + spark);
	}
	if(uIntFreq == 4) {
		stars = 1.0;
		particles = pow(particles, 1.0) * (1.0 + spark*5.0);
	}
	if(uIntFreq == 8) {
		stars = 0.1;
		stars = pow(stars, 20.0) * (1.0 - hole);
	}
	if(uIntFreq == 12) {
		stars = 1.0;
		stars = pow(stars, 50.0) * (1.0 - hole);
	}
	if(uIntFreq == 16) {
		stars = 2.0;
		stars = pow(stars, 50.0) * (1.0 - hole);
	}				
	// Couleurs plasma
	vec3 col = vec3(0.0);
	col += arms * vec3(1.5, 0.4, 2.0);           // bras violets
	col += disk * vec3(2.0, 0.8, 0.1) * 2.0;     // disque orange incandescent
	col += particles * vec3(0.6, 1.0, 2.0);     // plasma bleu-cyan
	col += stars * vec3(1.0, 0.9, 2.0);         // étoiles déformées
	col = mix(col, vec3(8.0, 2.0, 0.0), kick*0.8); // énorme flash rouge/orange sur kick
	col = mix(col, vec3(0.9, 0.9, 0.9), fragColorTexture.xyz);				
	// Vignettage + glow final
	col *= 1.0 - dist*0.7;
	// col += pow(1.0 - dist, 10.0) * (1.0 + kick*10.0); // halo blanc au centre			
	// Gamma
	col = pow(col, vec3(0.4545));				
	fragColor = vec4(col, 1.0);
}





// ──────────────────────────────────────────────────────────────
// RADIAL BASS REACTOR - Ultra violent & magnifique
// iChannel0 = ta texture FFT / waveform
// Par Grok - 2025
// ──────────────────────────────────────────────────────────────

float freqBassReactor(float x) { 
	// return texture(iChannel0, vec2(x, 0.25)).r;
	// return 0.5;
	return texture2D(iChannel0, vec2(x, 0.25), -16.0).r;
}

float bassReactor() {
	float b = 0.0;
	for(int i=0; i<16; i++) b += freqBassReactor(float(i)/float(BANDS));
	return pow(b/16.0, 3.0); // KICK HYPER PUNCHY
}

float midsReactor() {
	float m = 0.0;
	for(int i=20; i<60; i++) m += freqBassReactor(float(i)/float(BANDS));
	return m/40.0;
}

float trebleReactor() {
	float t = 0.0;
	for(int i=70; i<BANDS; i++) t += freqBassReactor(float(i)/float(BANDS));
	return pow(t/float(BANDS-70), 4.0);
}

void mainImageBassReactor( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = (fragCoord - iResolution.xy*0.5) / iResolution.y;
	vec4 fragColorTexture = texture2D(iChannel0, uv.xy*iResolution.xy);
	float time = iGlobalTime;			
	float kick   = bassReactor();      // 0 → ~5.8 sur un gros kick
	float energy = midsReactor();
	float spark  = trebleReactor();			
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);			
	// Gros cercle central qui explose avec le kick
	float shock = 1.0 / (dist*30.0 + 0.001);
	shock *= smoothstep(0.8, 0.0, fract(dist*8.0 - kick*20.0 - time*3.0)); // onde de choc
	shock = pow(shock, 2.0);				
	// Cercle central incandescent
	float core = exp(-dist * (8.0 + kick*40.0));				
	// Anneaux concentriques qui pulsent
	float rings = abs(sin(dist*25.0 - time*5.0 - kick*30.0));
	rings = pow(1.0 - rings, 8.0) * (1.0 + kick*15.0);				
	// Particules radiales qui fusent sur les kicks
	float particles = 0.0;
	for(int i=0; i<32; i++) {
		float fi = float(i);
		float a = fi/32.0 * 6.28 + time*0.5 + kick*10.0;
		float r = fract(dist*10.0 + fi*0.1 - time*2.0 - kick*8.0);
		particles += 0.01 / (abs(r) + 0.01) * exp(-dist*3.0);
	}				
	// Rayons qui tournent et s’allongent avec les mids
	float rays = abs(sin(angle*12.0 + time*2.0 + energy*10.0));
	if(uIntFreq == 2) {
		rays = pow(1.0 - rays, 1.0) * (1.0 + energy*2.0);
	}
	if(uIntFreq == 4) {
		rays = pow(1.0 - rays, 3.0) * (1.0 + energy*4.0);
	}
	if(uIntFreq == 8) {
		rays = pow(1.0 - rays, 6.0) * (1.0 + energy*8.0);
	}
	if(uIntFreq == 12) {
		rays = pow(1.0 - rays, 12.0) * (1.0 + energy*16.0);
	}
	if(uIntFreq == 16) {
		rays = pow(1.0 - rays, 24.0) * (1.0 + energy*32.0);
	}				
	// Scintillements aigus
	float glitter = pow(spark, 3.0) * 0.03 / (dist + 0.1);			
	// Couleurs
	vec3 col = vec3(0.0);
	col += core * vec3(3.0, 1.5, 0.3);                 // centre blanc/orange brûlant
	col += shock * vec3(2.0, 0.8, 4.0);                // onde de choc violette
	col = mix(col, vec3(0.1, 0.5, 0.9), fragColorTexture.xyz);
	col += rings * vec3(0.0, 1.5, 3.0);                // anneaux cyan
	col += rays * vec3(3.0, 0.5, 1.0);                 // rayons magenta
	col += particles * vec3(0.5, 2.0, 4.0);            // particules bleues
	col += glitter * vec3(1.0, 1.0, 2.0);				
	// Flash global blanc total sur les plus gros kicks
	// col += vec3(8.0, 6.0, 4.0) * pow(kick, 6.0);				
	// Vignettage + glow final
	col *= smoothstep(1.4, 0.0, dist);
	// col += pow(1.0 - dist, 16.0) * (3.0 + kick*30.0);				
	// col = pow(col, vec3(0.4545)); // gamma				
	fragColor = vec4(col, 1.0);
}





// ──────────────────────────────────────────────────────────────
//  FUTURISTIC AUDIO WAVEFORM - Cyberpunk Edition
//  Mettre iChannel0 = Sound (upload une track ou micro)
// ──────────────────────────────────────────────────────────────
void mainImageWaveForm( out vec4 fragColor, in vec2 fragCoord )
{
	vec2 uv = fragCoord / iResolution.xy;
	vec2 q = uv - 0.5;
	q.x *= iResolution.x / iResolution.y;       // correction aspect ratio
	vec4 fragColorTexture = texture2D(iChannel0, uv.xy*iResolution.xy);			
	vec3 finalCol = vec3(0.0);		
	// ───── 1. Récupération du waveform et du spectre ─────
	float time = iGlobalTime * 0.8;				
	float rawWave = texture2D(iChannel0, iResolution.xy).x/10.0;     // waveform brut
	float wave    = (rawWave - 0.5) * 2.0;                     // -1..1				
	float fftLow  = texture2D(iChannel0,  uv.xy*iResolution.xy).x/10.0;    // basses (~60 Hz)
	float fftMid  = texture2D(iChannel0,  uv.xy*iResolution.xy).y/10.0;    // mids
	float fftHigh = texture2D(iChannel0,  uv.xy*iResolution.xy).z/10.0;     // aigus
	float kick    = smoothstep(0.0, 0.7, fftLow);             // détection kick/bass				
	// ───── 2. Onde principale futuriste ─────
	float centerY = 0.5 + wave * 0.35 * (1.0 + kick*2.0);      // amplitude boostée sur les kicks				
	// Distance à l’onde centrale avec effet de "glow épais"
	float distToWave = abs(uv.y - centerY);
	float glow = exp(-distToWave * 18.0);                     // cœur très lumineux
	glow += exp(-distToWave * 8.0) * 0.5;                      // halo moyen
	glow += exp(-distToWave * 3.0) * 0.3;                      // halo large				
	// Ondulation temporelle (effet liquide néon)
	float wavy = sin(uv.x*12.0 + time*3.0 + wave*10.0) * 0.015;
	distToWave += wavy;
	glow *= 1.0 + sin(uv.x*40.0 + time*10.0)*0.1;             // micro-vibrations				
	vec3 neon = vec3(0.0, 0.9, 1.0);                           // cyan principal
	neon = mix(neon, vec3(1.0, 0.0, 1.0), kick*0.7);           // flash magenta sur kick
	finalCol += glow * neon * (1.0 + kick*4.0);
	// ───── 3. Hologramme / Reflets multiples ─────
	if(uIntFreq == 2) {
		neon = vec3(0.0, 0.1, 0.1);
	}
	if(uIntFreq == 4) {
		neon = vec3(0.0, 0.5, 0.5);
	}
	if(uIntFreq == 8) {
		neon = vec3(0.0, 0.9, 1.0);
	}
	if(uIntFreq == 12) {
		neon = vec3(0.0, 1.5, 2.0);
	}
	if(uIntFreq == 16) {
		neon = vec3(0.0, 4.9, 5.0);
	}
	neon = mix(neon, vec3(1.0, 0.0, 1.0), kick*0.7);           // flash magenta sur kick
	finalCol += glow * neon * (1.0 + kick*4.0);
	for(float i = 1.0; i < 10.0; i++){
		float offset = (1.0/i) * 0.07 * (1.0 + fftMid);
		float refl = abs(uv.y - centerY - offset);
		float reflGlow = exp(-refl*20.0) * (1.0/i);
		//finalCol += reflGlow * vec3(0.3, 0.7, 1.0) * 0.8;
		finalCol += reflGlow * vec3(texture2D(iChannel0, iResolution.xy).x, texture2D(iChannel0, iResolution.xy).y, texture2D(iChannel0, iResolution.xy).z) * 0.8;
	}				
	// ───── 4. Glitch rythmique ─────
	float glitch = step(0.96, sin(time*150.0)*kick);          // glitchs très rapides sur kick
	if (fract(uv.y*200.0 + time*20.0) < 0.03 && glitch > 0.5)
		uv.x += sin(uv.y*100.0)*0.1;				
	// ───── 5. Scanlines + Vignette CRT ─────
	//float scanline = sin(uv.y * 800.0) * 0.04;
	//finalCol -= scanline;				
	float vignette = smoothstep(0.7, 0.0, length(q));
	finalCol *= vignette;				
	// ───── 6. Bloom final ─────
	vec2 uvBloom = fragCoord.xy / iResolution.xy;
	vec3 bloom = vec3(0.0);
    //TODO verifier l'interet de la boucle
	for(float dx=-2.0; dx<=2.0; dx+=1.0)
	for(float dy=-2.0; dy<=2.0; dy+=1.0){
		vec2 offset = vec2(dx, dy) * 0.005;
		bloom += texture2D(iChannel0, uvBloom + offset).xxx;
		//bloom += texture2D(iChannel0, iResolution.xy).xyz;
	}
	bloom /= 25.0;
	//bloom  = vec3(bloom.x*fragColorTexture.x, bloom.y*fragColorTexture.y, bloom.z*fragColorTexture.z);
	finalCol += bloom * vec3(0.3, 0.7, 1.0) * kick * 2.0;				
	// Gamma + contraste cyberpunk
	//finalCol = pow(finalCol, vec3(0.75));
	finalCol = finalCol * 1.4 - 0.1;
	finalCol  = vec3(finalCol.x+fragColorTexture.x/3.0, finalCol.y+fragColorTexture.y/3.0, finalCol.z+fragColorTexture.z/3.0);
	fragColor = vec4(finalCol, 1.0);
}




// ──────────────────────────────────────────────────────────────
// KALEIDOSCOPE AUDIO ANALYZER - Psychédélique & réactif
// iChannel0 = ta texture FFT
// Par Grok - 2025
// ──────────────────────────────────────────────────────────────

float freqKaleidoscope(float f) { 
	// return texture(iChannel0, vec2(f, 0.25)).r; 
	// return 0.25;
	return texture2D(iChannel0, vec2(f, 0.25), 1.0).r;
}

float bassKaleidoscope()   { float s=0.0; for(int i=0;i<20;i++) s+=freqKaleidoscope(float(i)/256.0); return pow(s/20.0,3.0); }
float midKaleidoscope()    { float s=0.0; for(int i=30;i<100;i++) s+=freqKaleidoscope(float(i)/256.0); return s/70.0; }
float highKaleidoscope()   { float s=0.0; for(int i=120;i<256;i++) s+=freqKaleidoscope(float(i)/256.0); return pow(s/136.0,4.0); }

void mainImageKaleidoscope( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = (fragCoord - iResolution.xy*0.5) / iResolution.y;
	float time = iGlobalTime;			
	float kick  = bassKaleidoscope();     // 0 → 6+ sur gros kick
	float vibe  = midKaleidoscope();
	float spark = highKaleidoscope();				
	float dist = length(uv);
	float angle = atan(uv.y, uv.x);
	float SEGMENTS = 8.0;
	if(uIntFreq == 2) {
		SEGMENTS = 2.0;
	}
	if(uIntFreq == 4) {
		SEGMENTS = 4.0;
	}
	if(uIntFreq == 8) {
		SEGMENTS = 8.0;
	}
	if(uIntFreq == 12) {
		SEGMENTS = 12.0;
	}
	if(uIntFreq == 16) {
		SEGMENTS = 20.0;
	}			
	// === Kaleidoscope magique ===
	float segment = angle / (3.141592*2.0) * SEGMENTS;
	segment = fract(segment);
	segment = min(segment, 1.0-segment);           // symétrie miroir
	angle = segment * 3.141592*2.0 / SEGMENTS;			
	vec2 kuv = vec2(cos(angle), sin(angle)) * dist;			
	// Rotation globale + accélération sur kick
	float rot = time * 0.5 + kick*8.0;
	float c = cos(rot), s = sin(rot);
	kuv = vec2(kuv.x*c - kuv.y*s, kuv.x*s + kuv.y*c);			
	// === Forme centrale réactive ===
	float shape = 0.0;
	// Cercle central qui pulse
	shape += exp(-dist * (10.0 + kick*60.0));			
	// Anneaux spectraux
	for(int i=1; i<8; i++){
		float fi = float(i);
		float f = freqKaleidoscope(fi/24.0);
		float ring = abs(dist - (0.2 + fi*0.03 + vibe*0.4 + kick*0.2));
		shape += 0.03 / (ring + 0.01) * f * (1.0 + kick*1.0);
	}				
	// Rayons radiaux qui tournent avec les mids
	float rays = abs(sin(angle*16.0 + time*3.0 + vibe*15.0));
	shape += pow(1.0 - rays, 6.0) * (0.5 + vibe*6.0);				
	// Scintillements aigus
	shape += spark * 30.0 * exp(-dist*8.0);				
	// === Couleurs psyché ===
	vec3 col = vec3(0.0);				
	// Base néon qui change avec la musique
	col += shape * vec3(2.0, 0.3, 1.5);                                      // magenta dominant
	col += shape * 0.5 * vec3(sin(time + dist*10.0), sin(time*1.3 + dist*8.0), sin(time*1.7)) * vibe;				
	// Flash blanc/violet sur kick
	col += vec3(4.0, 1.0, 6.0) * pow(kick, 4.0);				
	// Bordures irisées
	col += vec3(0.5, 2.0, 3.0) * pow(shape * exp(-dist*2.0), 3.0);				
	// Glow externe doux
	col += vec3(0.3, 0.1, 2.0) * exp(-dist*2.0) * (1.0 + kick*5.0);				
	// Vignettage circulaire
	col *= 1.0 - smoothstep(0.6, 1.4, dist);				
	// Gamma + boost contraste
	col = pow(col, vec3(0.4545));
	col += pow(col, vec3(0.25)) * 0.1; // petit HDR				
	fragColor = vec4(col, 1.0);
}



// ──────────────────────────────────────────────────────────────
// NEON GRID PULSE - Cyber Reactor 2025
// iChannel0 = ta texture FFT
// Par Grok
// ──────────────────────────────────────────────────────────────

float freqGridPulse(float f) { 
	//return texture(iChannel0, vec2(f, 0.25)).r;
	// return 0.25;
	return texture2D(iChannel0, vec2(f, 0.25), 1.0).r;
}

// Kick ultra-punchy + volume global
float kick() {
	float b = 0.0;
	for(int i = 0; i < 20; i++) b += freqGridPulse(float(i)/256.0);
	return pow(b/20.0, 4.0) * 8.0;
}

// Volume général (pour la hauteur globale du grid)
float volume() {
	float v = 0.0;
	for(int i = 0; i < 256; i++) v += freqGridPulse(float(i)/256.0);
	return v/256.0;
}

void mainImageGridPulse( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = (fragCoord - iResolution.xy*0.5) / iResolution.y;
	float GRID_SIZE = 20.0;
	if(uIntFreq == 2) {
		GRID_SIZE = 5.0;
	}
	if(uIntFreq == 4) {
		GRID_SIZE = 10.0;
	}
	if(uIntFreq == 8) {
		GRID_SIZE = 20.0;
	}
	if(uIntFreq == 12) {
		GRID_SIZE = 36.0;
	}
	if(uIntFreq == 16) {
		GRID_SIZE = 50.0;
	}
	vec2 p = uv * GRID_SIZE;				
	float time = iGlobalTime;
	float k = kick();
	float vol = pow(volume(), 1.5);				
	// Grille 3D infinie vue de dessus
	vec3 pos = vec3(p.x, 4.0 + vol*25.0 + k*15.0, p.y - time*8.0);				
	// Lignes horizontales (profondeur)
	float gridZ = abs(fract(pos.z) - 0.5) * 2.0;
	gridZ = smoothstep(0.0, 0.5, gridZ);
	float depth = 1.0 / (0.1 + abs(fract(pos.z + 0.5) - 0.5)*10.0);				
	// Lignes verticales
	float gridX = abs(fract(pos.x) - 0.5) * 2.0;
	gridX = smoothstep(0.0, 0.48, gridX);				
	// Pulse central : onde de choc qui monte
	float shockwave = abs(length(uv) - (k*0.4 + vol*0.2));
	float shock = 0.03 / (shockwave + 0.02) * k;				
	// Hauteur des barres verticales selon le spectre
	float barHeight = 0.0;
	float nearest = floor(pos.x + 0.5);
	if (abs(nearest - (pos.x + 0.5)) < 8.0) {
		float f = freqGridPulse(abs(nearest)/40.0);
		barHeight = f * (12.0 + k*20.0);
	}
	float bars = smoothstep(0.0, 1.5, barHeight - abs(pos.y - 4.0));				
	// Fusion de tout
	float glow = 0.0;
	glow += (1.0 - gridZ) * depth * 3.0;           // lignes profondeur
	glow += (1.0 - gridX) * 4.0;                   // lignes latérales
	glow += shock * 8.0;                          // onde de choc
	glow += bars * 8.0;                           // barres égaliseur verticales				
	// Couleurs néon qui bougent
	vec3 col = vec3(0.0);
	col += glow * vec3(0.0, 1.8, 3.0);                                 // cyan principal
	col += glow * vec3(2.0, 0.1, 3.0) * sin(time*2.0 + pos.z*0.2);     // magenta qui court
	col += shock * vec3(10.0, 4.0, 0.0);                               // flash orange sur kick
	col += bars * vec3(0.0, 3.0, 1.5);                                 // barres vert-cyan				
	// Fog + perspective
	col *= depth * 0.5;				
	// Vignettage + bloom
	col *= 1.0 - length(uv)*0.6;
	col += pow(glow, 3.0) * 0.3;				
	col = pow(col, vec3(0.4545));				
	fragColor = vec4(col, 1.0);
}




			// ──────────────────────────────────────────────────────────────
			// Trou Noir avec Disque d'Accrétion + Jets de Matière
			// Par Grok, inspiré des meilleurs shaders black hole (2025 version)
			// Clique et déplace la souris pour tourner autour !
			// ──────────────────────────────────────────────────────────────

			void mainImageFunBlackHole( out vec4 fragColor, in vec2 fragCoord )
			{
				vec2 uv = (fragCoord - iResolution.xy*0.5) / iResolution.y;
				vec3 rd = normalize(vec3(uv, -1.8));           // direction du rayon
				vec3 ro = vec3(0.0, 0.0, 12.0);                // position caméra

				vec4 fragColorTexture = texture2D(iChannel0, uv.xy*iResolution.xy);
				
				// Rotation souris + animation automatique
				float time = iGlobalTime * 0.15;
				float mouseY = iMouse.y == 0.0 ? 0.3 : (iMouse.y / iResolution.y - 0.5)*3.0;
				float ry = time + (iMouse.x / iResolution.x)*12.0;
				float rx = mouseY;
				rx = 0.0;
				ry = time + (1.0 / iResolution.x)*12.0;
				
				mat3 rotY = mat3(cos(ry),0.0,sin(ry), 0.0,1.0,0.0, -sin(ry),0.0,cos(ry));
				mat3 rotX = mat3(1.0,0.0,0.0, 0.0,cos(rx),-sin(rx), 0.0,sin(rx),cos(rx));
				ro = rotY * rotX * ro;
				rd = rotY * rotX * rd;
				
				// Paramètres du trou noir (Schwarzschild + rotation Kerr simplifiée)
				float rs = 1.5;                    // rayon de Schwarzschild
				vec3 bhPos = vec3(0.0);            // centre du trou noir
				float spin = 0.85;                 // rotation du trou noir (0 = statique, 1 = extrême)
				
				vec3 color = vec3(0.0);
				float t = 0.0;
				const int steps = 128;
				float minDist = 100.0;

				if(uIntFreq == 2) {
					rs = 1.0;
					spin = 0.15;
					minDist = 100.0;
				}
				if(uIntFreq == 4) {
					rs = 1.0;
					spin = 0.35;
					minDist = 100.0;
				}
				if(uIntFreq == 8) {
					rs = 1.5;
					spin = 0.55;
					minDist = 100.0;
				}
				if(uIntFreq == 12) {
					rs = 2.0;
					spin = 0.85;
					minDist = 100.0;
				}
				if(uIntFreq == 16) {
					rs = 2.5;
					spin = 1.0;
					minDist = 100.0;
				}

				// color = fragColorTexture.xyz/10.0;
				
				// Raymarching dans le champ gravitationnel
				for(int i = 0; i < steps; i++)
				{
					vec3 p = ro + rd * t;
					// p = vec3(0.0,p.x,p.y);
					vec3 r = p - bhPos;
					// r = vec3(0.0,r.x,r.y);
					float rlen = length(r);
					
					minDist = min(minDist, rlen);
					
					// Effet de lentille gravitationnelle (approximation)
					float grav = rs / (rlen*rlen*0.8);
					//grav = grav + cos( fragColorTexture.x + fragColorTexture.y +fragColorTexture.z );
					rd += grav * normalize(r) * 0.04;
					//rd = rd * cos( fragColorTexture.x + fragColorTexture.y +fragColorTexture.z );
					rd = normalize(rd);
					
					// Absorption par l'horizon
					if(rlen < rs*1.01)
					{
						color = vec3(0.0);
						break;
					}

					//color = fragColorTexture.xyz;
					//color = vec3(fragColorTexture.x, fragColorTexture.y, fragColorTexture.z);
					
					// Disque d'accrétion (plan XZ incliné)
					float disk = 0.0;
					float diskDist = abs(p.y);
					float radial = length(p.xz);
					if(diskDist < 2.5 && radial > rs*2.0 && radial < 25.0)
					{
						// Température → couleur (plus chaud près du centre)
						float heat = 8.0 / (radial - rs*1.5);
						vec3 hot  = vec3(1.0, 0.3, 0.1);
						vec3 warm = vec3(1.0, 0.7, 0.2);
						vec3 cold = vec3(0.3, 0.6, 1.0);

						vec3 diskCol = mix(mix(hot, warm, heat*0.2), cold, heat*0.05);
						
						// Doppler boosting (effet relativiste)
						float doppler = dot(normalize(p.xz), vec2(sin(time*2.0), cos(time*2.0)));
						diskCol *= 1.0 + 3.0 * doppler * spin;
						// *  cos( fragColorTexture.x + fragColorTexture.y +fragColorTexture.z )*10.0;
						
						// Épaisseur et densité
						float density = exp(-diskDist*2.0) * exp(-(radial-10.0)*(radial-10.0)*0.01);
						color = vec3(0.0, color.y, color.z);
						//color = vec3(fragColorTexture.x, fragColorTexture.y, fragColorTexture.z);
						// diskCol = vec3(0.0);
						color += diskCol * density * 0.18;
						//color += diskCol * density * cos( fragColorTexture.x + fragColorTexture.y +fragColorTexture.z );
					}
					
					// Jets de matière (cônes le long de Y)
					float jetRadius = 0.8 + 0.6*sin(time*3.0 + radial*0.5);
					//jetRadius = 0.8+(0.1*cos(fragColorTexture.x) + 0.1*cos(fragColorTexture.y) + 0.1*cos(fragColorTexture.z))*25.0;
					if(abs(p.y) > 3.0 && length(p.xz) < jetRadius * (abs(p.y)*0.05))
					{
						float jetIntensity = exp(-abs(p.y)*0.07) * (0.7 + 0.3*sin(time*10.0 + p.y*3.0));
						vec3 jetCol = vec3(1.2, 0.8, 2.5); // violet/bleu plasma
						//color += jetCol * jetIntensity * 0.4;
						//color = vec3(cos(fragColorTexture.x), cos(fragColorTexture.y), cos(fragColorTexture.z));
						//color = jetCol;
						
					}
					
					t += 0.15 - 0.09 * grav; // pas adaptatif
					if(t > 60.0){
						break;
					}
				}
				
				// Étoile de fond + lueur du disque
				vec3 stars = vec3(pow(abs(sin(rd.x*123.0)+cos(rd.y*97.0+rd.z*67.0)), 80.0)*0.8);
				// stars = vec3(0.5,0.5,0.5);
				color += stars * 0.3;
				// color += stars * cos( fragColorTexture.x + fragColorTexture.y +fragColorTexture.z );
				
				// Absoption finale si trop près
				if(minDist < rs*1.02) color = vec3(0.0);
				
				// Effet de gamma + contraste
				color = pow(color, vec3(0.75));
				color *= 1.2;

				//float newColorX = color.x + cos(fragColorTexture.x);
				//float newColorY = color.y + cos(fragColorTexture.y);
				//float newColorZ = color.z + cos(fragColorTexture.z);
				//if( newColorX > 1.0 ) {
				//	newColorX = color.x - cos(fragColorTexture.x);
				//}
				//if( newColorY > 1.0 ) {
				//	newColorY = color.y - cos(fragColorTexture.y);
				//}
				//if( newColorZ > 1.0 ) {
				//	newColorZ = color.z - cos(fragColorTexture.z);
				//}
				//color = vec3(newColorX, newColorY, newColorZ);
				
				vec3 newColor = mix(color, fragColorTexture.xyz, vec3(0.5,0.5,0.5));

				fragColor = vec4(newColor, 1.0);
			}




			// ──────────────────────────────────────────────────────────────
			// Pleine Lune Animée - 100% procédural - Novembre 2025
			// Par Grok (xAI) - à toi avec plaisir 🌕
			// Fonctions de bruit pour les nuages et les étoiles
			// ──────────────────────────────────────────────────────────────

			float hashMoon(vec2 p) {
				return fract(sin(dot(p, vec2(127.1, 311.7))) * 43758.5453);
			}

			float noiseMoon(vec2 p) {
				vec2 i = floor(p);
				vec2 f = fract(p);
				f = f * f * (3.0 - 2.0 * f);
				
				float a = hashMoon(i);
				float b = hashMoon(i + vec2(1.0, 0.0));
				float c = hashMoon(i + vec2(0.0, 1.0));
				float d = hashMoon(i + vec2(1.0, 1.0));
				
				return mix(mix(a, b, f.x), mix(c, d, f.x), f.y);
			}

			float fbm(vec2 p) {
				float value = 0.0;
				float amplitude = 0.5;
				float frequency = 1.0;
				
				value += amplitude * noiseMoon(p * frequency); amplitude *= 0.5; frequency *= 2.0;
				value += amplitude * noiseMoon(p * frequency); amplitude *= 0.5; frequency *= 2.0;
				value += amplitude * noiseMoon(p * frequency); amplitude *= 0.5; frequency *= 2.0;
				value += amplitude * noiseMoon(p * frequency); amplitude *= 0.5; frequency *= 2.0;
				value += amplitude * noiseMoon(p * frequency); amplitude *= 0.5; frequency *= 2.0;
				value += amplitude * noiseMoon(p * frequency);
				
				return value;
			}

			float starsMoon(vec2 uv) {
				vec2 starCoord = uv * 250.0;
				vec2 i = floor(starCoord);
				vec2 f = fract(starCoord);
				
				float star = 0.0;
				
				for(int y = -1; y <= 1; y++) {
					for(int x = -1; x <= 1; x++) {
						vec2 offset = vec2(float(x), float(y));
						vec2 starPos = i + offset;
						
						float brightness = hashMoon(starPos);
						
						if(brightness > 0.995) {
							vec2 delta = f - offset - 0.5;
							float dist = length(delta);
							
							float starMask = 1.0 - smoothstep(0.4, 0.5, dist);
							starMask *= exp(-dist * 6.0);
							
							float intensity = pow(brightness, 4.0);
							starMask *= intensity;
							
							star = max(star, starMask);
						}
					}
				}
				
				return star;
			}

			float clouds(vec2 uv, float time) {
				vec2 cloudOffset = vec2(time * 0.04, time * 0.015);
				
				float cloud1 = fbm(uv * 3.5 + cloudOffset * 1.1);
				float cloud2 = fbm(uv * 5.5 + cloudOffset * 0.7);
				float cloud3 = fbm(uv * 7.5 + cloudOffset * 1.4);
				
				float cloudDensity = cloud1 * 0.6 + cloud2 * 0.3 + cloud3 * 0.1;
				return smoothstep(0.25, 0.75, cloudDensity);
			}

			float moonDisk(vec2 uv, vec2 center, float radius) {
				return 1.0 - smoothstep(radius - 0.03, radius, length(uv - center));
			}

			void mainImageMoon(out vec4 fragColor, in vec2 fragCoord) {
				vec2 uv = (fragCoord - 0.5 * iResolution.xy) / iResolution.y;
				vec4 fragColorTexture = texture2D(iChannel0, uv.xy*iResolution.xy);
				float starField = starsMoon(uv);
				vec3 skyColor = mix(vec3(0.08, 0.12, 0.22), vec3(0.02, 0.05, 0.14), 
								smoothstep(-0.4, 0.4, uv.y));
				
				vec3 color = skyColor + vec3(0.95, 0.92, 0.85) * starField * 3.0;
				
				vec2 moonCenter = vec2(-0.15, 0.15);
				float moonRadius = 0.20;
				
				float moonMask = moonDisk(uv, moonCenter, moonRadius);
				
				vec2 localUV = uv - moonCenter;
				float surfaceNoise = fbm(localUV * 12.0);
				float detailNoise = fbm(localUV * 25.0);
				
				float surfaceDetail = surfaceNoise * 0.6 + detailNoise * 0.3;
				
				vec3 moonColor = mix(vec3(0.78, 0.75, 0.78), vec3(0.9, 0.8, 0.9), surfaceDetail);
				//vec3 moonColor = mix(vec3(0.78 + cos(fragColorTexture.x), 0.75 + cos(fragColorTexture.y), 0.78 + cos(fragColorTexture.z)), vec3(1.0, 1.0, 1.0), surfaceDetail);
				
				float cloudCover = clouds(uv, iGlobalTime);
				
				float cloudOcclusion = smoothstep(0.3, 0.8, cloudCover);
				cloudOcclusion *= moonMask;
				
				vec3 moonWithPhase = moonColor * moonMask * fragColorTexture.xyz;

				// vec3 moonRecolored = mix(moonWithPhase, fragColorTexture.xyz, 1.5);
				vec3 moonRecolored = smoothstep(fragColorTexture.xyz, moonWithPhase, vec3(1.0,1.0,1.0));
				
				vec3 finalMoonColor = mix(moonRecolored, color, cloudOcclusion);
				finalMoonColor = mix(finalMoonColor, moonWithPhase, moonMask * (1.0 - cloudOcclusion));
				
				float thinClouds = smoothstep(0.6, 0.8, cloudCover);
				float halo = thinClouds * moonMask * 0.3;
				finalMoonColor += vec3(0.95, 0.92, 0.85) * halo;

				 // === Eau (très visible maintenant) ===
				float waterLevel = -0.15;                          // ligne d’eau bien plus haute
				float waterMask = smoothstep(waterLevel+0.05, waterLevel-0.3, uv.y);

				if(uIntFreq == 2) {
					waterLevel = 0.05;
				}
				if(uIntFreq == 4) {
					waterLevel = -0.05;
				}
				if(uIntFreq == 8) {
					waterLevel = -0.15;
				}
				if(uIntFreq == 12) {
					waterLevel = -0.25;
				}
				if(uIntFreq == 16) {
					waterLevel = -0.35;
				}

				if(waterMask > 0.01){
					vec2 wuv = uv;
					// Animation des vagues
					wuv.x += sin(uv.y*10.0 + iGlobalTime*2.0)*0.04;
					wuv.x += sin(uv.y*4.5  + iGlobalTime*1.4)*0.02;
					
					// Reflet de la lune déformé
					vec2 refl = wuv - moonCenter;
					refl.y = abs(refl.y + 0.45);                     // miroir parfait sous l’eau
					float moonRefl = exp(-length(refl)*5.0) * moonMask;
					moonRefl *= 1.5 + 2.0*sin(wuv.y*30.0 + iGlobalTime*4.0); // ondulation verticale du reflet

					// Couleur eau + caustics
					vec3 water = vec3(0.0,0.04,0.12);
					water += vec3(0.1,0.25,0.4) * fbm(wuv*12.0);
					water += vec3(0.8,0.9,1.0) * moonRefl * 2.5;
					water += vec3(0.3,0.6,0.8) * pow(fbm(wuv*30.0 + iGlobalTime*2.0), 5.0) * 0.4;

					// Bord de mer plus clair
					water = mix(water, vec3(0.15,0.4,0.5), smoothstep(waterLevel, waterLevel+0.2, uv.y));

					water = mix(color, water, fragColorTexture.xyz);
					color = mix(color, water, waterMask);
				}

				
				color = mix(color, finalMoonColor, moonMask);
				
				color = pow(color, vec3(0.85));
				color *= 1.05;
				
				fragColor = vec4(color, 1.0);
			}



			// ──────────────────────────────────────────────────────────────
			// Soleil animé + Halo + Éruptions solaires - 4K 60fps
			// Grok (xAI) - Novembre 2025
			// 100% procédural, zéro texture externe
			// ──────────────────────────────────────────────────────────────

			void mainImageSun( out vec4 fragColor, in vec2 fragCoord )
			{
				vec2 uv = (fragCoord - iResolution.xy) / iResolution.y;

				vec4 fragColorTexture = texture2D(iChannel0, uv.xy*iResolution.xy);

				vec2 mo =  vec2(0.5, 0.48)/iResolution.xy;
				
				float time = iGlobalTime * 0.3;
				
				// Position du Soleil (légèrement déplacé avec la souris)
				vec2 sunPos = mo - vec2(0.5, 0.5);
				sunPos.x *= iResolution.x/iResolution.y;
				vec3 rd = normalize(vec3(uv - sunPos, -1.2));
				
				float dist = length(uv - sunPos);
				
				vec3 color = vec3(0.0);
				
				// === 1. Photosphère + taches solaires ===
				float sunDisk = smoothstep(0.32, 0.30, dist);
				if(sunDisk > 0.0)
				{
					vec2 suv = (uv - sunPos) * 18.0;
					float angle = atan(suv.y, suv.x);
					//float noise = texture(iChannel0, vec2(angle*0.2, length(suv)*0.1 + time*0.1)).r;
					float noise = fragColorTexture.x;
					noise = pow(noise, 2.0);
					
					// Taches solaires sombres
					//float spots = smoothstep(0.6, 0.0, texture(iChannel0, suv*0.07 + vec2(time*0.05)).r);
					float spots = smoothstep(0.6, 0.0, fragColorTexture.x);
					spots *= smoothstep(0.9, 0.3, length(suv));
					
					vec3 photosphere = mix(vec3(1.0, 0.95, 0.8), vec3(1.0, 0.7, 0.3), noise*0.6);
					//photosphere = mix(photosphere, vec3(0.3, 0.1, 0.0), spots*0.8);
					photosphere = mix(photosphere, vec3(0.3, 0.1, 0.0), fragColorTexture.xyz);
					
					color += photosphere * sunDisk;
				}
				
				// === 2. Chromosphère (bord rouge) ===
				float chromo = smoothstep(0.30, 0.33, dist) * smoothstep(0.40, 0.31, dist);
				color += vec3(1.0, 0.35, 0.1) * chromo * 2.5;

				color = mix(color, vec3(0.3, 0.1, 0.0), fragColorTexture.xyz);
				
				// === 3. Couronne douce ===
				float corona = exp(-dist*2.5) * 0.8;
				color += vec3(1.0, 0.9, 0.7) * corona * 0.4;
				
				// === 4. HALO DE RAYONS CRÉPUSCULARES (God Rays) ===
				float rays = 0.0;
				const int samples = 32;
				float density = 0.94;
				float weight = 0.12;
				float decay = 0.96;
				float exposure = 0.28;

				if(uIntFreq == 2) {
					density = 0.24;
					weight = 0.012;
					decay = 0.46;
					exposure = 0.1;
				}
				if(uIntFreq == 4) {
					density = 0.54;
					weight = 0.052;
					decay = 0.66;
					exposure = 0.2;
				}
				if(uIntFreq == 8) {
					density = 0.94;
					weight = 0.12;
					decay = 0.96;
					exposure = 0.28;
				}
				if(uIntFreq == 12) {
					density = 1.94;
					weight = 0.32;
					decay = 1.26;
					exposure = 0.5;
				}
				if(uIntFreq == 16) {
					density = 2.94;
					weight = 0.92;
					decay = 1.96;
					exposure = 0.7;
				}

				
				vec2 rayUV = uv - sunPos;
				float illuminationDecay = 1.0;
				
				for(int i = 0; i < samples; i++)
				{
					float stepDist = float(i) * 0.07;
					vec2 sampleUV = sunPos + rayUV * stepDist;
					float sampleDist = length(sampleUV - sunPos);
					
					// Occultation par le disque solaire
					float occult = 1.0 - smoothstep(0.0, 0.35, sampleDist);
					
					// Motif radial des rayons (avec rotation lente)
					float angle = atan(sampleUV.y - sunPos.y, sampleUV.x - sunPos.x);
					float rayPattern = sin(angle*24.0 + time*2.0)*0.5 + 0.5;
					rayPattern = pow(rayPattern, 3.0);
					
					rays += occult * rayPattern * illuminationDecay * weight;
					illuminationDecay *= decay;
				}
				
				vec3 rayColor = vec3(1.0, 0.85, 0.6);
				color += rayColor * rays * exposure * 3.0;
				
				// === 5. Légère lueur globale + vignettage ===
				color += vec3(1.0, 0.7, 0.4) * pow(sunDisk, 4.0) * 2.0;
				color *= 1.0 - 0.3*length(uv); // vignettage doux
				
				// Gamma
				color = pow(color, vec3(0.9));
				
				fragColor = vec4(color, 1.0);

			}