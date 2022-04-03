using UnityEngine;

[ExecuteInEditMode]
public class CustomGlowObj : MonoBehaviour
{
    public Material GlowMaterial;

    private void OnEnable() => CustomGlowSystem.Instance.Add(this);
    private void OnDisable() => CustomGlowSystem.Instance.Remove(this);

    private void Start()
    {
        CustomGlowSystem.Instance.Add(this);
    }
}
