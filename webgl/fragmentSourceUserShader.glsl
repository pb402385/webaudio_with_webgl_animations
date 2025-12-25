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
	color = smoothstep(color, fragColorTexture.xyz, vec3(0.3, 0.3, 0.3));
	// Sortie finale
	fragColor = vec4(color, 1.0);
}


// ──────────────────────────────────────────────────────────────
// Galaxie Spirale Classique avec Matrice de Rotation
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
	color = mix(color, fragColorTexture.xyz, dustColor); // zones sombres entre bras				
	// Vignettage doux
	color *= 1.0 - smoothstep(0.6, 1.2, r);				
	fragColor = vec4(color, 1.0);
}



// ──────────────────────────────────────────────────────────────
// Galaxie 3D Elite Dangerous Style - Ray Marching + Matrice Spirale
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
// ──────────────────────────────────────────────────────────────
void mainImageFractal(out vec4 fragColor, in vec2 fragCoord){
	// Coordonnées normalisées centrées
	vec2 uv = (fragCoord - iResolution.xy * 0.25) / iResolution.y;
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);	

	// Temps pour animation fluide
	float time = iGlobalTime * 0.2;				
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

	// === Coloration ===
	float smoothIter = float(iter) + 1.0 - log(log(length(z))) / log(2.0);
	float color = smoothIter / float(maxIter);
	// Couleurs chaudes psychédéliques (ma préférée)
	vec3 col = 0.5 + 0.5 * cos(6.28318 * (color * 2.0 + vec3(0.0, 0.33, 0.67) + time * 0.1));
    // Coloration en fonction de la fréquence
	col = 0.5 + 0.5 * cos(6.28318 * (color * 2.0 + fragColorTexture.xyz + time * 0.1));

	// Effet de pulsation globale
	col *= 0.9 + 0.1 * sin(time * 3.0);
	// Vignettage doux
	col *= 1.0 - 0.3 * dot(uv, uv);
	fragColor = vec4(col, 1.0);
}





// ──────────────────────────────────────────────────────────────
// Vortex Black Hole Reactor - Par Grok 2025
// ──────────────────────────────────────────────────────────────
void mainImageInfiniteTunnel(out vec4 fragColor, in vec2 fragCoord) {
    vec2 uv = (fragCoord - iResolution.xy * 0.5) / iResolution.y;
    vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);
    float time = iGlobalTime * 0.5;
    
    // Vortex spiralé (réacteur tourbillonnant)
    float angle = atan(uv.y, uv.x) + time * 2.0;
    float radius = length(uv);
    float vortex = sin(angle * 8.0 + radius * 20.0 - time * 10.0) * 0.5 + 0.5;
    
    // Trou noir central + gravité
    float blackHole = smoothstep(0.1, 0.05, radius);  // Événement horizon
    float gravityPull = 1.0 / (radius * 10.0 + 0.1);
    
    // Disque d'accrétion pulsant
    float accretion = pow(vortex * gravityPull, 2.0) * (sin(time * 5.0 + radius * 10.0) * 0.5 + 1.0);
    
    // Couleurs reactor psychédéliques (néon plasma)
    vec3 col = vec3(0.0);
	col += accretion * vec3(1.0, 0.2, 0.8);  // Violet reactor
    if(fragColorTexture.x==0.0) col += accretion * vec3(1.0, 0.2, 0.8);  // Violet reactor
	if(fragColorTexture.x>0.0){
		vec3 values = vec3(min(1.0,fragColorTexture.x), min(0.2,fragColorTexture.y), min(0.8,fragColorTexture.z));
		// Avec anti-aliasing adaptatif
		vec3 aa = fwidth(values);                         // vec3 avec fwidth par composante
		vec3 soft = smoothstep(-aa, aa, values);
		col += accretion * soft;  // Violet reactor
	}
	//if(fragColorTexture.x>0.0) col = smoothstep(col, fragColorTexture.xyz, vec3(0.1));
    col += accretion * 0.5 * vec3(0.0, 1.0, 1.0) * sin(time + angle);  // Cyan pulsation
    col += pow(accretion, 3.0) * vec3(2.0, 0.5, 0.0);  // Orange glow intense
    
    // Effet lensing / distortion
    uv += uv * gravityPull * 0.2;
    
    // Fond étoilé + glow
    if(fragColorTexture.x==0.0) col = mix(col, vec3(0.0), vec3(blackHole));
	if(fragColorTexture.x>0.0) col = mix(col, fragColorTexture.xyz, vec3(blackHole));
    col += 0.1 * sin(uv.x * 100.0 + time) * sin(uv.y * 100.0);
    
    // Gamma + contraste reactor
    col = pow(col, vec3(0.8)) * 2.0;
    
    fragColor = vec4(col, 1.0);
}





// ──────────────────────────────────────────────────────────────
// RADIAL BASS REACTOR - Ultra violent & magnifique
// ──────────────────────────────────────────────────────────────

float freqBassReactor() { 
	return texture2D(iChannel0, iResolution.xy, -16.0).r/2.0;
}

float bassReactor() {
	float b = 0.0;
	for(int i=0; i<16; i++) b += freqBassReactor();
	return pow(b/16.0, 3.0); // KICK HYPER PUNCHY
}

float midsReactor() {
	float m = 0.0;
	for(int i=20; i<60; i++) m += freqBassReactor();
	return m/40.0;
}

float trebleReactor() {
	float t = 0.0;
	for(int i=70; i<BANDS; i++) t += freqBassReactor();
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
	col *= smoothstep(1.4, 0.0, dist);			
	fragColor = vec4(col, 1.0);
}





// ──────────────────────────────────────────────────────────────
//  FUTURISTIC AUDIO WAVEFORM - Cyberpunk Edition
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
	}

	bloom /= 25.0;
	finalCol += bloom * vec3(0.3, 0.7, 1.0) * kick * 2.0;
		
	// Gamma + contraste cyberpunk
	finalCol = finalCol * 1.4 - 0.1;
	finalCol  = vec3(finalCol.x+fragColorTexture.x/3.0, finalCol.y+fragColorTexture.y/3.0, finalCol.z+fragColorTexture.z/3.0);
	fragColor = vec4(finalCol, 1.0);
}




// ──────────────────────────────────────────────────────────────
// KALEIDOSCOPE AUDIO ANALYZER - Psychédélique & réactif
// ──────────────────────────────────────────────────────────────

float freqKaleidoscope(float f) { 
	return texture2D(iChannel0, iResolution.xy, 0.5).r/2.0;
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
	//col += vec3(4.0, 1.0, 6.0) * pow(kick, 4.0);				
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
// ──────────────────────────────────────────────────────────────

float freqGridPulse() { 
	return texture2D(iChannel0, iResolution.xy, 1.0).r/2.0;
}

// Kick ultra-punchy + volume global
float kick() {
	float b = 0.0;
	for(int i = 0; i < 20; i++) b += freqGridPulse();
	return pow(b/20.0, 4.0) * 8.0;
}

// Volume général (pour la hauteur globale du grid)
float volume() {
	float v = 0.0;
	for(int i = 0; i < 256; i++) v += freqGridPulse();
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
		float f = freqGridPulse();
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
// Trou Noir
// source https://www.shadertoy.com/view/3d2SWK
// Créé par BigWIngs
// ──────────────────────────────────────────────────────────────
// "Second Image of a Black Hole" by Martijn Steinrucken aka BigWings - 2019
// License Creative Commons Attribution-NonCommercial-ShareAlike 3.0 Unported License.
// Email:countfrolic@gmail.com Twitter:@The_ArtOfCode
//
// In honor of the amazing achievement of the photographing of a real black hole,
// behold my 100% fake one. I know next to nothing about black holes other than
// that it distorts spacetime so much that it visibly affects light.
//
// Just marching the light rays and bending them towards the hole bulges the accretion disc
// over the top when you look at it from the side, similar to the way it looked in
// interstellar. I didn't specifically code this, it just came out that way
// so I figure my 'physics' is not completely wrong ;)
//
// The jets coming out the top and bottom I just added because lots of black hole 
// illustrations have them and they look cool :)
//
// Code is a bit of a mess. It annoys me that step size has to be super small in order
// for it to look halfway decent. 

#define SURFDIST .001
#define MAXSTEPS 200
#define MAXDIST 20.
#define TAU 6.2832

#define USEDISC
#define USESTREAM

mat2 Rot(float a) {
	float s = sin(a), c = cos(a);
    
    return mat2(c, -s, s, c);
}

float N21(vec2 p) {
    p = fract(p*vec2(123.34,345.35));
    p += dot(p, p+34.53);
    return fract(p.x*p.y);
}

float NoiseBH(vec2 p) {
	vec2 gv = fract(p);
    vec2 id = floor(p);
    
    gv = smoothstep(0.,1.,gv);
    
    float b = mix(N21(id+vec2(0,0)), N21(id+vec2(1, 0)), gv.x);
    float t = mix(N21(id+vec2(0,1)), N21(id+vec2(1, 1)), gv.x);
    
    return mix(b, t, gv.y);
}

float Noise3(vec2 p) {
    return 
        (NoiseBH(p) + 
        .50*NoiseBH(p*2.12*Rot(1.)) +
        .25*NoiseBH(p*4.54*Rot(2.)))/1.75;
}

vec3 GetRd(vec2 uv, vec3 ro, vec3 lookat, vec3 up, float zoom, inout vec3 bBend) {
    vec3 f = normalize(lookat-ro),
        r = normalize(cross(up, f)),
        u = cross(f, r),
        c = ro + zoom * f,
        i = c + uv.x*r + uv.y*u,
        rd = normalize(i-ro);
 	
    vec3 offs = normalize(uv.x*r + uv.y*u);
    bBend = rd-.1*offs/(1.+dot(uv,uv));
    return rd;   
}

vec3 GetBg(vec3 rd, vec4 fct) {
	float x = atan(rd.x, rd.z);
    float y = dot(rd, vec3(0,1,0));
    
    float size = 10.;
    vec2 uv = vec2(x, y)*size;
    float m = abs(y);
    
    float side = Noise3(uv);
    float stars = pow(NoiseBH(uv*20.)*NoiseBH(uv*23.), 10.);
    
    vec2 puv = rd.xz*size;
    float poles = Noise3(rd.xz*size);
    float stars2 = pow(NoiseBH(puv*21.)*NoiseBH(puv*13.), 10.);
    
    stars = mix(stars, stars2, m*m);
    float n = mix(side, poles, m*m);
    n = pow(n, 5.);
    
    vec3 nebulae = n * vec3(1., .7, .5);

	float starsReturn =  stars*4.;
	if(fct.x>0.0) starsReturn =  stars*(4.*(1.0+mix(0.1, fct.x, 10.0)));
    
    return nebulae + starsReturn;
}

float GetDist(vec3 p) {
    float d = length(p)-.15;
    
    //d = min(d, max(length(p.xz)-2., abs(p.y)));
    return d;
}

float GetDisc(vec3 p, vec3 pp) {
	
    float t = iGlobalTime;
    
    // calculate plane intersection point
    vec3 rd = p-pp;			// local ray direction
    vec3 c = pp + rd*pp.y;	// intersection point
    rd = normalize(rd)*.5;
    p = c-rd;
    rd *= 2.;
    
    // myeah this seemed like a good idea at some point... doesn't add as much as it should
    float m = 0.;
    const float numSamples = 3.;
    for(float i=0.; i<1.; i+=1./numSamples) {
    	c = p + i*rd;
        
        float d = length(c.xz);
    	float l = smoothstep(3.5, .6, d);
    	l *= smoothstep(.1, .6, d);
    	
        float x = atan(c.x, c.z);
    	l *= sin(x*floor(5.)+d*20.-t)*.3+.7;
        m += l;
    }
    
    return 1.5*m/numSamples;
}

void mainImageFunBlackHole( out vec4 fragColor, in vec2 fragCoord )
{
    vec2 uv = (fragCoord-.5*iResolution.xy)/iResolution.y;
	vec2 m = iMouse.xy/iResolution.xy;

	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy)/2.0;

	if(uIntFreq == 2) {
		m = vec2(0.0,0.0);
	}
	if(uIntFreq == 4) {
		m = vec2(0.5,0.0);
	}
	if(uIntFreq == 8) {
		m = vec2(0.5,0.5);
	}
	if(uIntFreq == 12) {
		m = vec2(0.5,0.1);
	}
	if(uIntFreq == 16) {
		m = vec2(0.25,0.75);
	}
    
    vec3 col = vec3(0);
	
    vec3 ro = vec3(0, 0, -4.+sin(iGlobalTime*.2));
    ro.yz *= Rot(m.y*TAU+iGlobalTime*.05);
    ro.xz *= Rot(-m.x*TAU+iGlobalTime*.1);
    
    vec3 lookat = vec3(0);
    float zoom = .8;
    vec3 up = normalize(vec3(.5, 1,0));
    vec3 bBend;
    vec3 rd = GetRd(uv, ro, lookat, up, zoom, bBend);
    vec3 eye = rd;
    
    float dS, dO;
    float disc = 0.;
    vec3 p=ro;
    p += N21(uv)*rd*.05;
    vec3 pp;
    
    float stream = 0.;
    
    for(int i=0; i<MAXSTEPS; i++) {
        rd -= .01*p/dot(p,p);		// bend ray towards black hole
        
        pp = p;
        p += dS*rd;
        
        if(p.y*pp.y<0.)
            disc += GetDisc(p, pp);
			//if(fragColorTexture.x==0.0) disc += GetDisc(p, pp);
			//if(fragColorTexture.x>0.0) disc += GetDisc(p, pp)*(1.0 - smoothstep(0.05, 0.20, fragColorTexture.x/255.));
        
        float y = abs(p.y)*.2;
        stream += smoothstep(.1+y, 0., length(p.xz))*
            smoothstep(0., .2, y)*
            smoothstep(1., .5, y)*.05;
        
        dS = GetDist(p);
        dS = min(.05, dS);
        dO += dS;
        if(dS<SURFDIST || dO>MAXDIST) break;
    }
    
    col = GetBg(bBend,fragColorTexture);
    
    if(dS<SURFDIST) {
        col = vec3(0);      // its black!
    }

	vec2 poss = vec2(0.5, 0.3);  // Centre-bas de l'écran
	vec4 valeurAuCentre = texture2D(iChannel0, poss);
    
    #ifdef USEDISC
    //col += disc*vec3(1,.8,.5)*1.5;
	if(fragColorTexture.x>=0.0){
		vec3 pattern = disc*((0.7+abs(mix(0.01, 0.5,fragColorTexture.x))))*vec3(1,.8,.5);
		vec3 aa = fwidth(pattern);
		vec3 smoothed = mix(-aa, aa, pattern);
		col += smoothed;
	}
	//if(fragColorTexture.x>0.0) col += disc*((0.5+abs(mix(0.01, 0.5,valeurAuCentre.x))))*vec3(1,.8,.5);
	//if(fragColorTexture.x>0.0) col += disc*(vec3(1.0)-smoothstep(vec3(1,.8,.5),vec3(fragColorTexture.xyz),vec3(fragColorTexture.xyz)))*(1.5 - smoothstep(0.01, 1.5, fragColorTexture.x/255.));
    #endif
    #ifdef USESTREAM
    col += min(.5, stream)*vec3(.7, .7, 1.);
    #endif
    
    fragColor = vec4(col,1.0);
}




// ──────────────────────────────────────────────────────────────
// Pleine Lune Animée - 100% procédural - Novembre 2025
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
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy)/2.0;
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
	float cloudCover = clouds(uv, iGlobalTime);				
	float cloudOcclusion = smoothstep(0.3, 0.8, cloudCover);
	cloudOcclusion *= moonMask;				
	vec3 moonWithPhase = moonColor * moonMask * fragColorTexture.xyz;
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
// ──────────────────────────────────────────────────────────────

void mainImageSun( out vec4 fragColor, in vec2 fragCoord ){
	vec2 uv = (fragCoord - iResolution.xy) / iResolution.y;
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy)/2.0;
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
	if(sunDisk > 0.0){
		vec2 suv = (uv - sunPos) * 18.0;
		float angle = atan(suv.y, suv.x);
		float noise = fragColorTexture.x;
		noise = pow(noise, 2.0);					
		// Taches solaires sombres
		float spots = smoothstep(0.6, 0.0, fragColorTexture.x);
		spots *= smoothstep(0.9, 0.3, length(suv));					
		vec3 photosphere = mix(vec3(1.0, 0.95, 0.8), vec3(1.0, 0.7, 0.3), noise*0.6);
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
	for(int i = 0; i < samples; i++){
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



// ──────────────────────────────────────────────────────────────
// 3D Sierpinski Triangle
// source : https://www.shadertoy.com/view/4dl3Wl
// The MIT License
// Copyright © 2013 Inigo Quilez
// ──────────────────────────────────────────────────────────────

// return distance and address
vec2 mapSierpinski( vec3 p ){
    const vec3 va = vec3(  0.0,  0.57735,  0.0 );
    const vec3 vb = vec3(  0.0, -1.0,  1.15470 );
    const vec3 vc = vec3(  1.0, -1.0, -0.57735 );
    const vec3 vd = vec3( -1.0, -1.0, -0.57735 );
    
	float a = 0.0;
    float s = 1.0;
    float r = 1.0;
    float dm;
    for( int i=0; i<9; i++ ){
        vec3 v;
	    float d, t;
		d = dot(p-va,p-va);            { v=va; dm=d; t=0.0; }
        d = dot(p-vb,p-vb); if( d<dm ) { v=vb; dm=d; t=1.0; }
        d = dot(p-vc,p-vc); if( d<dm ) { v=vc; dm=d; t=2.0; }
        d = dot(p-vd,p-vd); if( d<dm ) { v=vd; dm=d; t=3.0; }
		p = v + 2.0*(p - v); r*= 2.0;
		a = t + 4.0*a; s*= 4.0;
	}
	return vec2( (sqrt(dm)-1.0)/r, a/s );
}

const float precis = 0.0002;

vec3 intersect( in vec3 ro, in vec3 rd ){
	const float maxd = 5.0;
	vec3 res = vec3( 1e20, 0.0, 0.0 );
    float t = 0.5;
	float m = 0.0;
    vec2 r;
	for( int i=0; i<100; i++ ){
	    r = mapSierpinski( ro+rd*t );
        if( r.x<precis || t>maxd ) break;
		m = r.y;
        t += r.x;
    }

    if( t<maxd && r.x<precis ) res = vec3( t, 2.0, m );

	return res;
}

vec3 calcNormal( in vec3 pos ){
    vec3 eps = vec3(precis,0.0,0.0);
	return normalize( vec3(
           mapSierpinski(pos+eps.xyy).x - mapSierpinski(pos-eps.xyy).x,
           mapSierpinski(pos+eps.yxy).x - mapSierpinski(pos-eps.yxy).x,
           mapSierpinski(pos+eps.yyx).x - mapSierpinski(pos-eps.yyx).x ) );
}

float calcOcclusion( in vec3 pos, in vec3 nor ){
	float ao = 0.0;
    float sca = 1.0;
    for( int i=0; i<8; i++ ){
        float h = 0.001 + 0.5*pow(float(i)/7.0,1.5);
        float d = mapSierpinski( pos + h*nor ).x;
        ao += -(d-h)*sca;
        sca *= 0.95;
    }
    return clamp( 1.0 - 0.8*ao, 0.0, 1.0 );
}


vec3 renderSierpinski( in vec3 ro, in vec3 rd ){
    vec3 col = vec3(0.0);
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);

	// raymarch
    vec3 tm = intersect(ro,rd);
    if( tm.y>0.5 ){
        // geometry
        vec3 pos = ro + tm.x*rd;
		vec3 nor = calcNormal( pos );
		vec3 maa = vec3( 0.0 );
		
        maa = 0.5 + 0.5*cos( 6.2831*tm.z + vec3(0.0,1.0,2.0) );

		float occ = calcOcclusion( pos, nor );

		// lighting
        const vec3 lig = normalize(vec3(1.0,0.7,0.9));
		float amb = (0.5 + 0.5*nor.y);
		float dif = max(dot(nor,lig),0.0);

        // lights
		vec3 lin = amb*vec3(3.0) * occ;
		if( fragColorTexture.x>0.0 ) lin = mix(fragColorTexture.xyz, lin, vec3(0.66));	
		// surface-light interacion
		col = maa * lin;
		//if( fragColorTexture.x>0.0 ) col = smoothstep(fragColorTexture.xyz, col, vec3(0.66));	
	}

    // gamma
	col = pow( clamp(col,0.0,1.0), vec3(0.45) );

	//col = mix(fragColorTexture.xyz, col, vec3(1.0,1.0,1.0));	

    return col;
}

void mainImageSierpinski( out vec4 fragColor, in vec2 fragCoord ){
    vec2 p = (2.0*fragCoord-iResolution.xy)/iResolution.y;;
    vec2 m = vec2(0.5);
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);

	if(uIntFreq == 2) {
		m = vec2(0.1);
	}
	if(uIntFreq == 4) {
		m = vec2(0.2);
	}
	if(uIntFreq == 8) {
		m = vec2(0.5);
	}
	if(uIntFreq == 12) {
		m = vec2(1.0);
	}
	if(uIntFreq == 16) {
		m = vec2(5.0);
	}	

    // camera
	float an = 3.2 + 0.5*iGlobalTime - 6.2831*(m.x-0.5);
	vec3 ro = vec3(2.5*sin(an),0.0,2.5*cos(an));
    vec3 ta = vec3(0.0,-0.5,0.0);
    vec3 ww = normalize( ta - ro );
    vec3 uu = normalize( cross(ww,vec3(0.0,1.0,0.0) ) );
    vec3 vv = normalize( cross(uu,ww));
	vec3 rd = normalize( p.x*uu + p.y*vv + 5.0*ww*m.y );

    // render
    vec3 col = renderSierpinski( ro, rd );
	//col = mix(col, vec3(0.3, 0.1, 0.0), fragColorTexture.xyz);	
    
    fragColor = vec4( col, 1.0 );
}



// ──────────────────────────────────────────────────────────────
// 3D Sierpinski Mobius
// source : https://www.shadertoy.com/view/XsGXDV
// ──────────────────────────────────────────────────────────────

// Standard Mobius transform: f(z) = (az + b)/(cz + d). Slightly obfuscated.
vec2 Mobius(vec2 p, vec2 z1, vec2 z2){

	z1 = p - z1; p -= z2;
	return vec2(dot(z1, p), z1.y*p.x - z1.x*p.y)/dot(p, p);
}

// Standard spiral zoom.
vec2 spiralZoom(vec2 p, vec2 offs, float n, float spiral, float zoom, vec2 phase){
	
	p -= offs;
	float a = atan(p.y, p.x)/6.283 - iGlobalTime*.25;
	float d = log(length(p));
	return vec2(a*n + d*spiral, a - d*zoom) + phase;
}

// Mobius, spiral zoomed, Sierpinski Carpet pattern.
vec3 pattern(vec2 uv){

	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);
    
    // A subtlely spot-lit background. Performed on uv prior to tranformation,
    float bg = max(1. - length(uv), 0.)*.025; 
    
    // Transform the screen coordinates. Comment out the following two lines and 
    // you'll be left with a standard Sierpinski pattern.
    uv = Mobius(uv, vec2(-.75, cos(iGlobalTime)*.25), vec2(.5, sin(iGlobalTime)*.25));
    uv = spiralZoom(uv, vec2(-.5), 5., 3.14159*.2, .5, vec2(-1, 1)*iGlobalTime*.25);
    
     
    vec3 col = vec3(bg); // Set the canvas to the background.
    
    // Sierpinski Carpet - Essentially, space is divided into 3 each iteration, and a 
    // shape of some kind is rendered. In this case, it's a smooth rectangle
    // with a bit of shading around the side.
    //
    // There's some extra steps in there (the "l" and "mod" bits) due to the 
    // shading and coloring, but it's pretty simple.
    //
    // By the way, there are other combinations you could use.
    //
    for(float i=0.; i<4.; i++){
        
        uv = fract(uv)*3.; // Subdividing space.
        
        vec2 w = .5 - abs(uv - 1.5); // Prepare to make a square. Other shapes are also possible.

		if(uIntFreq == 2) {
			w = .2 - abs(uv - 0.5); 
		}
		if(uIntFreq == 4) {
			w = .3 - abs(uv - 1.0); 
		}
		if(uIntFreq == 8) {
			w = .5 - abs(uv - 1.5); 
		}
		if(uIntFreq == 12) {
			w = sin(w)*PI; 
		}
		if(uIntFreq == 16) {
			w = sin(w)*2.0*PI; 
		}	

		if( fragColorTexture.x>0.0 ) w = smoothstep(w, fragColorTexture.xy, vec2(0.0));
        
        float l = sqrt(max(16.0*w.x*w.y*(1.0-w.x)*(1.0-w.y), 0.)); // Vignetting (edge shading).
        
        if( fragColorTexture.x==0.0 ) w = smoothstep(0., length(fwidth(w)), w); // Smooth edge stepping.
        
        vec3 lCol = vec3(1)*w.x*w.y*l; // White shaded square with smooth edges.
        
        if(mod(i, 3.)<.5) lCol *= vec3(0.1, 0.8, 1); // Color layers zero and three blue.
        
        col = max(col, lCol); // Taking the max of the four layers.
        
    } 
    
    return col;
    
}


void mainImageMobius(out vec4 fragColor, in vec2 fragCoord){ // my attempt to code-golf it (137chars)

    // Screen coordinates.
    vec2 uv = (fragCoord - iResolution.xy*.5)/iResolution.y;
    
    // Transformed Sierpinski pattern.
    vec3 col = pattern(uv);
    
    // Rough gamma correction.
    fragColor = vec4(sqrt(col), 1);
}




// ──────────────────────────────────────────────────────────────
// 3D Sierpinski Mobius
// source : https://www.shadertoy.com/view/XsGXDV
// Shader generated using ChatGPT
// Original promot > Create code for a shadertoy shader that creates colorful animated fractal patterns.
// Some code and parameters slightly modified manually.
// ──────────────────────────────────────────────────────────────

void mainImageMandelbrot( out vec4 fragColor, in vec2 fragCoord ){
	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);
    float time = iGlobalTime * 0.5;
    vec2 z = (fragCoord.xy / iResolution.x) * 1.0 - 0.5;
    vec2 c = vec2(-0.2 + 0.25*sin(time), 0.6 + 0.03*cos(time));
    float d = 0.0;
    float n = 0.0;

	if(uIntFreq == 2) {
		n = -1.0;
	}
	if(uIntFreq == 4) {
		n = -0.5;
	}
	if(uIntFreq == 8) {
		n = 0.0;
	}
	if(uIntFreq == 12) {
		n = 0.5;
	}
	if(uIntFreq == 16) {
		n = 1.0;
	}	

    for (int i = 0; i < 200; i++)  
    {
        z = vec2(z.x*z.x - z.y*z.y, 2.0*z.x*z.y) + c; 
        d = dot(z,z);
        n += 0.0002/ d; 
        if (d > 200.0) break;
    }
    vec3 color = vec3(abs(sin(n*20.0)), abs(cos(n*10.0)), abs(sin(n*5.0))); //
	if( fragColorTexture.x>0.0 ) color = smoothstep(color, fragColorTexture.xyz, vec3(0.66));
    fragColor = vec4(color,1.0);
}

// ──────────────────────────────────────────────────────────────
// Mandelbrot Decoration
// source : https://www.shadertoy.com/view/ttscWn
// created by Shane
// ──────────────────────────────────────────────────────────────
/*


	Mandelbrot Pattern Decoration
	-----------------------------


	After looking at Fabrice's Mandelbrot derivative example, it occurred
	to me that I have a heap of simple Mandelbrot and Julia related 
    demonstrations that I've never gotten around to posting, so here's one 
    of them. I put it together a long time ago using the standard base code, 
    which you'll find in countless examples on the internet. I'm pretty sure 
    I started with IQ's "Orbit Traps" shader, which is a favorite amongst 
    many on here, then added a few extra lines to produce the effect you 
	see. There's not a lot to this at all, so hopefully, it'll be easy to 
    consume.

    Producing Mandelbrot and Julia patterns is pretty straight forward. At 
    it's core, you're simply transforming each point on the screen in a 
    certain way many times over, then representing the transformed point 
    in the form of shades and colors.

    In particular, you treat each point as if it were on a 2D complex plane, 
    then perform an iterative complex operation -- which, ironically, is not 
    complex at all. :) In this particular example, the iterative complex 
    derivative is recorded also, which is used for a bit of shading.

    In regard to the shading process itself, most people tend to set a 
    bailout, then provide a color based on the transformed point distance,
	and leave it at that. However, with barely any extra code, it's 
    possible to makes things look more interesting.    

    The patterns look pretty fancy, but they're nothing more than repeat 
    circles and grid boundaries applied after transforming the coordinates. 
    The shading and highlights were made up on the spot, but none of it was
    complex, nor was it based on reality (no pun intended).

*/

void mainImageMandelbrotDecoration(out vec4 fragColor, in vec2 fragCoord ){

	vec4 fragColorTexture = texture2D(iChannel0, iResolution.xy);
    
    // Base color.
    vec3 col = vec3(0);
    
    // Anitaliasing: Just a 2 by 2 sample. You could almost get away with not using
    // it at all, but it is necessary.
    #define AA 2
    for(int j=0; j<AA; j++){
        for(int i=0; i<AA; i++){

            // Offset centered coordinate -- Standard AA stuff.
            vec2 p = (fragCoord + vec2(i, j)/float(AA) - iResolution.xy*.5)/iResolution.y;
            
            // Time, rotating back and forth.
            float ttm = cos(sin(iGlobalTime/8.))*6.2831;
           
            // Rotating and translating the canvas... More effort needs to be put in here,
            // but it does the job.
            p *= mat2(cos(ttm), sin(ttm), -sin(ttm), cos(ttm));
            p -= vec2(cos(iGlobalTime/2.)/2., sin(iGlobalTime/3.)/5.);
                       
            // Jump off point and zoom... Where and how much you zoom in greatly effects what
            // you see, so I probably should have put more effort in here as well, but this
            // shows you enough.
            float zm = (200. + sin(iGlobalTime/7.)*50.);
            vec2 cc = vec2(-.57735 + .004, .57735) + p/zm;
 
            // Position and derivative. Initialized to zero.
            vec2 z = vec2(0), dz = vec2(0);

            // Iterations: Not too many. You could get away with fewer, if need be.
            const int iter = 128;
            int ik = 128; // Bail out value. Set to the largest to begin with.
            vec3 fog = vec3(0); //vec3(.01, .02, .04);
             
            for(int k=0; k<iter; k++){
                // Derivative: z' = z*z'*2. + 1.
                // Imaginary partial derivatives are similar to real ones.
                dz = mat2(z, -z.y, z.x)*dz*2. + vec2(1, 0); // A better way. Thanks, Fabrice. :)
                //dz = vec2(z.x*dz.x - z.y*dz.y, z.x*dz.y + z.y*dz.x)*2. + vec2(1, 0);
                           
                // Position: z = z*z + c.
                // Squaring an imaginary point is slightly different to squaring a real
                // one, but at the end of the day, it's just a transformation.
                z =  mat2(z, -z.y, z.x)*z + cc;
                //z = (vec2(z.x*z.x - z.y*z.y, 2.*z.x*z.y)) + cc;
                               
                // Experimental transformation with twisting... It's OK, but I wasn't
                // feeling it.
                //float l = (float(k)/500.);
                //z = mat2(cos(l), sin(l), -sin(l), cos(l))*mat2(z, -z.y, z.x)*z + cc;
               
                // If the length (squared to save cycles) of the transformed point goes 
                // out of bounds, break. In layperson's terms, points that stay within 
                // the set boundaries longer appear brighter... or darker, depending what
                // you're trying to achieve.
                if(dot(z, z) > 1./.005){
                    ik = k; // Record the break number, or however you say it.
                    break;
                }
                
            }
                      
            // Lines and shading. There'd be a few ways to represent a boundary line, and
            // I'd imagine there'd be better ways than this, but it works, so it'll do.
            float ln = step(0., length(z)/15.5  - 1.);
                     
            // Distance... shade... It's made up, but there's a bit of logic there. Smooth 
            // coloring involves the log function. I remember reading through a proof a few 
            // years back, when I used to like that kind of thing. It made sense at the time. :)
            float d = sqrt(1./max(length(dz), .0001))*log(dot(z, z));
            // Mapping the distance from zero to one.
            d = clamp(d*50., 0., 1.); 
            
            // Flagging successive layers. You can use this to reverse directions, alternate
            // colors, etc.
            float dir = mod(float(ik), 2.)<.5? -1. : 1.;
            
            // Layer coloring and shading. Also made up.
            float sh = (float(iter - ik))/float(iter); // Shade.
            vec2 tuv = z/320.; // Transformed UV coordinate.
            
            // Rotating the coordinates, based on the global canvas roations and distance
            // for that parallax effect to aid the depth illusion.
            float tm = (-ttm*sh*sh*16.);
            // Rotated, repeat coordinates.
            tuv *= mat2(cos(tm), sin(tm), -sin(tm), cos(tm));
            tuv = abs(mod(tuv, 1./8.) - 1./16.); 
          
            // Rendering a grid of circles, and showing the grid boundaries. Anything is 
            // possible here: Truchets, Voronoi, etc.
            float pat = smoothstep(0., 1./length(dz), length(tuv) - 1./32.);
            pat = min(pat, smoothstep(0., 1./length(dz), abs(max(tuv.x, tuv.y) - 1./16.) - .04/16.));
            
            // Coloring the layer. These are based on the shaded distance value, but you can
            // choose anything you want.
            //vec3 lCol = (.55 + .45*cos(6.2831*(d*d)/3. + vec3(0, 1, 2) - 4.))*1.25;
            vec3 lCol = pow(min(vec3(1.5, 1, 1)*min(d*.85, .96), 1.), vec3(1, 3, 16))*1.15;
            
            // Appolying the circular grid pattern to the color, based on successive layer count.
            // We're also applying a boundary line.
            lCol = dir<.0? lCol*min(pat, ln) : (sqrt(lCol)*.5 + .7)*max(1. - pat, 1. - ln);
                  
            // A fake unit direction vector to provide a fake reflection vector in order
            // to produce a fake glossy diffuse value for fake highlights. The knowledge
            // behind all this is also fake. :D
            vec3 rd = normalize(vec3(p, 1.));
            rd = reflect(rd, vec3(0, 0, -1));
            // Synchronizing the gloss movement... It wasn't for me.
            // rd.xy = mat2(cos(tm), sin(tm), -sin(tm), cos(tm))*rd.xy; 
            float diff = clamp(dot(z*.5 + .5, rd.xy), 0., 1.)*d;
                    
            // Fake reflective pattern, which has been offset slightly, and moved in a 
            // reflective manner.
            tuv = z/200.;
            tm = -tm/1.5 + .5;
            tuv *= mat2(cos(tm), sin(tm), -sin(tm), cos(tm));
            tuv = abs(mod(tuv, 1./8.) - 1./16.); 
            pat = smoothstep(0., 1./length(dz), length(tuv) - 1./32.);
            pat = min(pat, smoothstep(0., 1./length(dz), abs(max(tuv.x, tuv.y) - 1./16.) - .04/16.));
        
            // Adding the fake gloss. The "ln" variable is there to stop the gloss from 
            // reaching the outer fringe, since I thought that looked a little better.
            lCol += mix(lCol, vec3(1)*ln, .5)*diff*diff*.5*(pat*.6 + .6);

			if( fragColorTexture.x>0.0 ) lCol = smoothstep(lCol, fragColorTexture.xyz, vec3(0.1));
            
            // Swizzling the color on every sixth layer -- I thought it might break up the
            // orange and red a little.
            if (mod(float(ik), 6.)<.5) lCol = lCol.yxz;
            lCol = mix(lCol.xzy, lCol, d/1.2); // Shade based coloring, for something to do.
            
            // This was a last minute addition. I put some deep black lined fringes on the layers
            // to add more illusion of depth. Comment it out to see what it does.
            lCol = mix(lCol, vec3(0), (1. - step(0., -(length(z)*.05*float(ik)/float(iter)  - 1.)))*.95);
           
            // Applying the fog.
            lCol = mix(fog, lCol, sh*d);
                       
            // Used for colored fog.
            //lCol *= step(0., d - .25/(1. + float(ik)*.5));
			//if( fragColorTexture.x>0.0 ) lCol = smoothstep(lCol, fragColorTexture.xyz, vec3(0.1));
            
            // Applying the color sample.
            col += min(lCol, 1.);
        }
    }
    
    // Divide by the sample number.
	col /= float(AA*AA);
     
    // Toning down the highlights... but I'm going to live on the edge and leave it as is. :D
    //col = (1. - exp(-col))*1.25;
    
     // Subtle vignette.
    vec2 uv = fragCoord/iResolution.xy;
    col *= pow(16.*(1. - uv.x)*(1. - uv.y)*uv.x*uv.y, 1./8.)*1.15;
    
	fragColor = vec4(sqrt(max(col, 0.)), 1.0 );
}