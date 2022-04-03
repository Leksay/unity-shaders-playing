using UnityEngine;

[ExecuteInEditMode]
[RequireComponent(typeof(Camera))]
public class ApplyCameraEffect : MonoBehaviour
{
    [SerializeField] private Material _glowMaterial;
    private Camera _camera;

    private void Start()
    {
        _camera = GetComponent<Camera>();
        _camera.depthTextureMode = DepthTextureMode.Depth;
    }

    private void OnRenderImage(RenderTexture src, RenderTexture dest)
    {
        Graphics.Blit(src, dest, _glowMaterial);
    }
}
