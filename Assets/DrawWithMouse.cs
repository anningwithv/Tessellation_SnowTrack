using System.Collections;
using System.Collections.Generic;
using UnityEngine;

public class DrawWithMouse : MonoBehaviour
{
    public Camera camera;
    public Shader drawShader;

    private RenderTexture m_SplatMap;
    private Material m_ShowMaterial, m_DrawMaterial;

    private void Start()
    {
        m_DrawMaterial = new Material(drawShader);
        m_DrawMaterial.SetVector("_Color", Color.red);

        m_ShowMaterial = GetComponent<MeshRenderer>().material;
        m_SplatMap = new RenderTexture(1024, 1024, 0, RenderTextureFormat.ARGBFloat);
        m_ShowMaterial.SetTexture("_SplatMap", m_SplatMap);
    }

    private void Update()
    {
        if (Input.GetKey(KeyCode.Mouse0))
        {
            RaycastHit hit;
            if (Physics.Raycast(camera.ScreenPointToRay(Input.mousePosition), out hit))
            {
                m_DrawMaterial.SetVector("_Coordinate", new Vector4(hit.textureCoord.x, hit.textureCoord.y, 0, 0));
                RenderTexture tmp = RenderTexture.GetTemporary(m_SplatMap.width, m_SplatMap.height, 0, RenderTextureFormat.ARGBFloat);
                Graphics.Blit(m_SplatMap, tmp);
                Graphics.Blit(tmp, m_SplatMap, m_DrawMaterial);
                RenderTexture.ReleaseTemporary(tmp);
            }
        }
    }

    private void OnGUI()
    {
        GUI.DrawTexture(new Rect(0, 0, 256, 256), m_SplatMap, ScaleMode.ScaleToFit, false, 1);
    }
}
