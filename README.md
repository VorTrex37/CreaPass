# CreaPass

CreaPass est une API hautement paramétrable permettant la génération simple et rapide de mots de passe.


## Installation & Déploiement 📦

*// TODO*


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
  
