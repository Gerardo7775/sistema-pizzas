GitHub Copilot Chat Assistant — README sugerido:

# Sistema Pizzas — Documentación Técnica

Portal de documentación técnica del ecosistema de pizzería: Inventario y Contabilidad, Controladora de Pedidos y Repartidor. Publicado con MkDocs + GitHub Actions + GitHub Pages. Incluye especificaciones, anexos, casos de uso y diagramas (UML, secuencias, actividades, clases) en Markdown y PDF.

[![GitHub Actions](https://img.shields.io/github/actions/workflow/status/Gerardo7775/sistema-pizzas/ci.yml?branch=main)]()
[![GitHub Pages](https://img.shields.io/github/deployments/Gerardo7775/sistema-pizzas/github-pages?label=gh-pages)]()
[![License](https://img.shields.io/github/license/Gerardo7775/sistema-pizzas)]()

Descripción
------------
Este repositorio centraliza la documentación técnica del ecosistema de pizzería. Está pensado como referencia para desarrolladores, analistas y operadores: contiene requerimientos, diseño, diagramas UML, flujos de proceso, casos de uso, anexos y artefactos exportados en PDF.

Características principales
--------------------------
- Documentación modularizada por componente (Inventario/Contabilidad, Controladora de Pedidos, Repartidor).
- Diagramas UML y diagramas de secuencia/actividad integrados en Markdown.
- Publicación automática con GitHub Actions a GitHub Pages.
- Formato y navegación generada con MkDocs (configuración en mkdocs.yml).

Estructura del repositorio
--------------------------
- docs/                 — Contenido de la documentación (Markdown, imágenes, PDFs).
- mkdocs.yml            — Configuración de MkDocs y del tema.
- .github/workflows/    — Flujos de CI/CD (build y despliegue a GitHub Pages).
- assets/               — Recursos compartidos (imágenes, plantillas).
- README.md             — Este archivo.

Cómo visualizar la documentación (local)
----------------------------------------
1. Clona el repositorio:
   git clone https://github.com/Gerardo7775/sistema-pizzas.git
   cd sistema-pizzas

2. Instala MkDocs y, opcionalmente, el tema recomendado:
   pip install mkdocs mkdocs-material

3. Ejecuta el servidor local:
   mkdocs serve

4. Abre en tu navegador:
   http://127.0.0.1:8000

5. Para generar los archivos estáticos:
   mkdocs build
   Los archivos resultantes estarán en site/.

Cómo contribuir
----------------
- Lee las guías y convenciones en docs/ antes de proponer cambios.
- Para correcciones menores: crea una rama feature/tu-cambio, realiza cambios en docs/, y abre un Pull Request.
- Para cambios estructurales o de contenido mayor: abre primero un issue describiendo la propuesta para discutir alcance y formato.
- Usa formatos Markdown claros y, cuando añadas diagramas, incluye la fuente (ej. archivos .drawio o exportes en /assets).

Despliegue
----------
La publicación a GitHub Pages está automatizada mediante GitHub Actions. Cada push a la rama principal (main) dispara el workflow que construye con MkDocs y despliega el sitio. Revisa .github/workflows/ para ver y ajustar la configuración del pipeline.

Buenas prácticas de documentación
---------------------------------
- Mantén cada sección enfocada en un objetivo: propósito, actores, flujos, excepciones.
- Incluye diagramas junto a explicaciones textuales.
- Versiona cambios importantes en la documentación y registra el autor y la fecha.
- Proporciona ejemplos y casos de uso claros para cada componente.

Licencia
--------
Revisa el archivo LICENSE en el repositorio para detalles sobre la licencia aplicable.

Contacto y soporte
------------------
- Abre un issue en este repositorio para reportar errores, pedir mejoras o solicitar clarificaciones.
- Para consultas directas: usa el perfil de GitHub (https://github.com/Gerardo7775).

Notas finales
-------------
Este README es una plantilla sugerida; ajusta las secciones (badges, comandos, rutas) según las herramientas y convenciones específicas de tu proyecto. ¿Quieres que lo adapte con enlaces directos (sitio publicado, workflows exactos o licencia) viendo los archivos del repo? Puedo hacerlo si deseas.
