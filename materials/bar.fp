varying mediump vec2 var_texcoord0;

uniform lowp sampler2D texture_sampler;
uniform lowp vec4 tint;
uniform lowp vec4 value;

void main()
{
    if (var_texcoord0.x > value.x)    
    //if (var_texcoord0.x > 0.28125)
    {
        gl_FragColor = texture2D(texture_sampler, var_texcoord0.xy) * vec4(1, 0, 0, tint.w);
    }
    else
    {
        gl_FragColor = texture2D(texture_sampler, var_texcoord0.xy) * vec4(0 , 1, 0, tint.w);
    }

}