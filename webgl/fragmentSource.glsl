#extension GL_OES_standard_derivatives : enable
//#extension GL_EXT_shader_texture_lod : enable
#ifdef GL_ES
precision highp float;
#endif

varying vec2 vUv;

uniform int 	uIntFreq;		
uniform int 	uIntType;
uniform int 	uIntTypeTexture;
uniform int 	uIntInfinity;
uniform int 	uIntEffect;

uniform vec3	iResolution;
uniform float	iGlobalTime;
uniform vec4 	iMouse;

uniform sampler2D 	iChannel0;

void mainImage( out vec4 c,  in vec2 f );

${usershader}

void main( void ){
	vec4 color = vec4(0.0,0.0,0.0,1.0);
	if(uIntEffect <= 4){
		mainImage( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 5){
		mainImageGalaxy( color, gl_FragCoord.xy );
		// vec4 col = texture2D(iChannel0, gl_FragCoord.xy);
		// mainImageGalaxy( col, gl_FragCoord.xy );
	}
	if(uIntEffect == 6){
		mainImageSpiralGalaxy( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 7){
		mainImageSpiralGalaxy3D( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 8){
		mainImageFractal( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 9){
		mainImageBassReactor( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 10){
		mainImageWaveForm( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 11){
		mainImageFunBlackHole( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 12){
		mainImageMoon( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 13){
		mainImageSun( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 14){
		mainImageInfiniteTunnel( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 15){
		mainImageKaleidoscope( color, gl_FragCoord.xy );
	}
	if(uIntEffect == 16){
		mainImageGridPulse( color, gl_FragCoord.xy );
	}
	// color.w = 1.0;
	gl_FragColor = color;
}