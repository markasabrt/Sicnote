shader_type spatial;
render_mode skip_vertex_transform;
void vertex() {
	//enable wireframe perspective to see each individual vertice moving around
	float Jeremy = 60.0; //edit jeremy to change how dramatic the vertex snapping is (higher number is more subtle)
	vec4 Special = vec4(0, 0, 0, 1.0);
	VERTEX = (MODELVIEW_MATRIX * vec4(VERTEX, 1.0)).xyz;
	Special = (PROJECTION_MATRIX * vec4(VERTEX, 1.0));
	VERTEX = vec4(Special / Special.w).xyz;
	VERTEX = vec3(VERTEX.xyz * Jeremy).xyz;
	VERTEX = vec3(round(VERTEX.xy), VERTEX.z);
	VERTEX = vec3(VERTEX.xyz / Jeremy).xyz;
	VERTEX = vec3(VERTEX.xyz * Special.w).xyz;
	POSITION = vec4(VERTEX.xyz, Special.w);
    NORMAL = (MODELVIEW_MATRIX * vec4(NORMAL, 0.0)).xyz;

	
	//PROJECTION_MATRIX Projection(Vector4(0, 0, 0, 1); 	
	//round(VERTEX.x);
}

void fragment() {
	// Called for every pixel the material is visible on.
}
