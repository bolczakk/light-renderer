#version 330 core

in vec3 FragPos;  
in vec3 Normal;

out vec4 FragColor;

uniform vec3 color;

struct DirLight {
    vec3 direction;
    vec3 ambient;
    vec3 diffuse;
    vec3 specular;
};

struct Material {
    vec3 ambient;
	vec3 diffuse;
	vec3 specular;
	float shininess;
};

uniform DirLight dirLight;
uniform vec3 viewPos;
uniform Material material;
uniform sampler2D shadowMap;
uniform mat4 lightSpaceMatrix;

float ShadowCalculation(vec4 fragPosLightSpace, vec3 norm, vec3 lightDir)
{
    // transform z clip space [-1,1] → [0,1]
    vec3 projCoords = fragPosLightSpace.xyz / fragPosLightSpace.w;
    projCoords = projCoords * 0.5 + 0.5;

    // jeśli poza mapą cieni → brak cienia
    if(projCoords.z > 1.0)
        return 0.0;

    // pobranie głębokości z shadow mapy
    float currentDepth = projCoords.z;

    // bias żeby uniknąć shadow acne
    float bias = max(0.005 * (1.0 - dot(norm, lightDir)), 0.0005);

    // Percentage Closer Filtering (PCF)
    float shadow = 0.0;
    vec2 texelSize = 1.0 / textureSize(shadowMap, 0);
    for(int x = -1; x <= 1; ++x)
    {
        for(int y = -1; y <= 1; ++y)
        {
            float pcfDepth = texture(shadowMap, projCoords.xy + vec2(x, y) * texelSize).r; 
            shadow += currentDepth - bias > pcfDepth ? 1.0 : 0.0;  
        }
    }
    shadow /= 9.0; // uśrednienie z 9 próbek

    return shadow;
}



void main()
{
    vec3 lightDir = normalize(-dirLight.direction);
    vec3 norm = normalize(Normal);

    vec3 ambient = dirLight.ambient * material.diffuse;

    float diff = max(dot(norm, lightDir), 0.0);
    vec3 diffuse = diff * dirLight.diffuse * material.diffuse;

    vec3 viewDir = normalize(viewPos - FragPos);
    vec3 reflectDir = reflect(-lightDir, norm);
    float spec = pow(max(dot(viewDir, reflectDir), 0.0), material.shininess*256);
    vec3 specular = spec * dirLight.specular * material.specular;

    vec4 fragPosLightSpace = lightSpaceMatrix * vec4(FragPos, 1.0);
    float shadow = ShadowCalculation(fragPosLightSpace, norm, lightDir);

    vec3 lighting = (ambient + (1.0 - shadow) * (diffuse + specular));
    FragColor = vec4(lighting, 1.0);
}
