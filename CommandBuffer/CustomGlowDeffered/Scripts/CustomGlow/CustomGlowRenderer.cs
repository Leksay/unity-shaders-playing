using System.Collections.Generic;
using UnityEngine;
using UnityEngine.Rendering;

[ExecuteInEditMode]
public class CustomGlowRenderer : MonoBehaviour
{
    private CommandBuffer _glowCommandBuffer;
    private Dictionary<Camera, CommandBuffer> _cameras = new();

    private void Cleanup()
    {
        foreach (var cam in _cameras)
        {
            if (cam.Key)
            {
                cam.Key.RemoveCommandBuffer(CameraEvent.BeforeLighting, cam.Value);
            }
        }

        _cameras.Clear();
    }

    private void OnEnable() => Cleanup();
    private void OnDisable() => Cleanup();

    private void OnPreRender()
    {
        var render = gameObject.activeInHierarchy && enabled;
        if (!render)
        {
            Cleanup();
            return;
        }

        var cam = Camera.current;
        if (!cam || _cameras.ContainsKey(cam))
        {
            return;
        }

        _glowCommandBuffer = new CommandBuffer();
        _glowCommandBuffer.name = "Glow map buffer";
        _cameras[cam] = _glowCommandBuffer;

        var glowSystem = CustomGlowSystem.Instance;
        var tempID = Shader.PropertyToID("_Temp1");

        // -1 == Camera.width/height
        // draw all glow objects to it
        _glowCommandBuffer.GetTemporaryRT(tempID, -1, -1, 24, FilterMode.Bilinear);
        _glowCommandBuffer.SetRenderTarget(tempID);

        //clear before drawing to it each frame
        _glowCommandBuffer.ClearRenderTarget(true, true, Color.clear);

        //draw all glow objects to it
        foreach (var glowObj in glowSystem.GlowObjs)
        {
            var renderer = glowObj.GetComponent<Renderer>();
            var glowMaterial = glowObj.GlowMaterial;

            if (renderer && glowMaterial)
            {
                _glowCommandBuffer.DrawRenderer(renderer, glowMaterial);
            }
        }

        // set render texture as globally accessable 'glow map' texture
        _glowCommandBuffer.SetGlobalTexture("_GlowMap", tempID);

        //add this command buffer to the pipeline
        cam.AddCommandBuffer(CameraEvent.BeforeLighting, _glowCommandBuffer);
    }
}

