﻿using System.Collections;
using System.Collections.Generic;
using UnityEngine;

[AddComponentMenu("Rendering/SetRenderQueue")]
public class renderque : MonoBehaviour {

    [SerializeField]
    protected int[] m_queues = new int[] { 3000 };

    protected void Awake()
    {
        Material[] materials = GetComponent<MeshRenderer>().materials;
        for (int i = 0; i < materials.Length && i < m_queues.Length; ++i)
        {
            materials[i].renderQueue = m_queues[i];
        }
    }
}
