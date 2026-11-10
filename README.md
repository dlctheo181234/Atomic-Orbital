# Atomic-Orbital — « Orbitale »

Logiciel de simulation d'orbitales atomiques (systèmes hydrogénoïdes : H, He⁺, Li²⁺),
réalisé par William Darnaud, Théo de la Chapelle et Samuel Soliman.

Support de l'activité 5 « Mais où est passé l'électron ? » (Seconde générale, Mme Pasquet).

## Utilisation

Ouvrir `index.html` dans un navigateur (ou servir le dossier avec `python -m http.server`).

Le site comporte trois pages :

- **Accueil** — choix entre les deux modèles.
- **Modèle classique** — modèle planétaire de Rutherford : orbite stable de Newton,
  ou « modèle réel » où l'électron spirale vers le noyau en émettant des photons
  (adaptation web de `rutherford.py` et `rutherford_limite.py` de Mme Pasquet,
  https://github.com/jpasquet/orbitale). Le bouton « ? » explique l'effondrement
  (équations de Maxwell, loi de Larmor).
- **Modèle quantique** — nuage de probabilité de présence en 3D : choix de l'atome
  hydrogénoïde (configuration électronique 1s¹), des orbitales (1s, 2s, 3s, 2px, 2py, 2pz)
  et du nombre de points, puis « Générer ». Le bouton « ? » donne l'aide en trois fenêtres.

## Fichiers

- `index.html` — l'application web complète (les trois pages).
- `rutherford.py`, `rutherford_limite.py` — codes Python de référence de Mme Pasquet
  (animations matplotlib du modèle classique et de sa limite).
- `orbitale.py`, `orbital_server.py`, `atom_server.py`, `main.py` — versions Python
  historiques du calcul d'orbitales.

------------------------------------
---(c)2026 - Tous droits réservés---
------------------------------------
