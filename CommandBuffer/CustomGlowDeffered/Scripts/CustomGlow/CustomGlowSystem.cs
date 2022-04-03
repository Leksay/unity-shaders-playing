using System.Collections.Generic;
using UnityEngine;

public class CustomGlowSystem
{
    private static CustomGlowSystem _instance;

    public static CustomGlowSystem Instance
    {
        get
        {
            if (_instance == null)
            {
                _instance = new();
            }

            return _instance;
        }

        private set => _instance = value;
    }

    internal HashSet<CustomGlowObj> GlowObjs = new();

    public void Add(CustomGlowObj glowObject)
    {
        Remove(glowObject);
        Instance.GlowObjs.Add(glowObject);
    }

    public void Remove(CustomGlowObj glowObject) => Instance.GlowObjs.Remove(glowObject);
}