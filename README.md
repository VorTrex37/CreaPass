# CreaPass

CreaPass est une API hautement paramétrable permettant la génération simple et rapide de mots de passe.


## Installation & Déploiement 📦

### Cloner CreaPass

```bash
git clone https://github.com/VorTrex37/CreaPass.git
```

```bash
cd creapass
```

## Usage

### Choix de l'environnement

Par défaut, le projet se lance en mode production. Pour changer l'environnement du projet il vos faudra créer un fichier ENV à la racine du projet et y écrire l'environnement dans lequel vous souhaitez lancer le projet. 2 environnements sont disponibles :

* development
* production

```bash
echo dev > ENV # Environnement de développement
echo prod > ENV # Environnement de production
```
### Création des fichiers d'environnement

Les fichiers d'environnement se trouvent dans le dossier config à la racine, vous devez copier les fichiers dans le dossier config ".dist" et les renommer en supprimer le ".dist" du nom.
Puis spécifier les variables d'environnement dans ces nouveaux fichiers.

## Makefile

### Lancer le projet

Pour build l'environnement Docker, il vous faudra installer [Docker](https://www.docker.com/get-started).
Et enfin, il ne vous restera plus qu'a taper la commande suivante dans un terminal :

```bash
make
```

## Utilisation 📝

### Génération d'un mot de passe

Route : `POST /generate`

La route renvoie directement le mot de passe généré sous forme d'une chaîne de caractères.

Peuvent être spécifiés dans la requête POST les paramètres suivants :

---
__Taille__

Nom du paramètre : `size`

Par défaut : `20`

Valeur attendue : Entier positif

Exemples : 
- `100` : Mot de passe de 100 caractères


---
__Jeux de caractères utilisés__

Nom du paramètre : `allowed`

Par défaut : `Tous`

Valeur attendue :
| Code  | Jeu de caractères        |
|-------|--------------------------|
| **a** | Lettres [a-z] minuscules |
| **A** | Lettres [A-Z] majuscules |
| **D** | Chiffres [0-9]           |
| **S** | Caractères spéciaux      |

Exemples : 
- `aA` : Uniquement les lettres minuscules et majuscules
- `AD` : Uniquement les lettres majuscules et les chiffres


---
__Caractères ignorés__

Nom du paramètre : `filter`

Par défaut : `Aucun`

Valeur attendue : Chaîne de caractères contenant tous ceux devant être ignorés

Exemples : 
- `!&` : Mot de passe sans ! et &
- `abc8` : Mot de passe sans lettre a, b, c et sans chiffre 8


## Contributeurs

- Thomas ASPA
- Soren MARCELINO 
- Anthony NAVARRO
- Milan VERY-GRIETTE
  
