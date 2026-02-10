// Fragment shader for blending between two textures using a third mask texture 

#version 330

// Input vertex attributes (from vertex shader)
// TODO: is it possible to rename these?
in vec2 fragTexCoord;
in vec4 fragColor;

uniform sampler2D texture_a;
uniform sampler2D texture_b;
uniform sampler2D texture_mask;
uniform vec4 colDiffuse;

// Output fragment color
// TODO: rename to frag_color if we can rename the in variable fragColor above
out vec4 out_color;

void main()
{
    vec4 texel_a = texture(texture_a, fragTexCoord)*colDiffuse*fragColor;
    vec4 texel_b = texture(texture_b, fragTexCoord);
    float blend = texture(texture_mask, fragTexCoord).r;
    vec4 blended = mix(texel_a, texel_b, blend);

    out_color = blended * colDiffuse * fragColor;
}