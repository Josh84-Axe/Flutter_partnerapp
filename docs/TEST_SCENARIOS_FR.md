# Scénarios de Test Application Partenaire (QA)

Ce document fournit une liste détaillée des cas de test pour valider les fonctionnalités de l'Application Partenaire.

---

## Environnement de Test
- **Support Appareil**: Android, iOS, Navigateur Web.
- **Pré-requis**: Connexion Internet stable, branche "fix/token-storage-windows" ou dernière version de production.

---

## 1. Authentification & Inscription

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **AUTH-01** | Connexion | Connexion Valide | Compte Enregistré | 1. Entrer email valide.<br>2. Entrer mot de passe valide.<br>3. Appuyer sur Connexion. | L'utilisateur est redirigé vers le Tableau de Bord. |
| **AUTH-02** | Connexion | Mot de passe Invalide | - | 1. Entrer email valide.<br>2. Entrer mauvais mot de passe.<br>3. Connexion. | Erreur "Identifiants invalides" affichée. |
| **AUTH-03** | Inscription | **Validation Complète** | - | 1. Ouvrir Inscription.<br>2. Laisser "Nom Complet" vide.<br>3. Mot de passe < 6 cars.<br>4. Soumettre. | Erreurs affichées pour Nom Requis et Longueur Min Mot de passe. |
| **AUTH-04** | Inscription | Inscription Réussie | - | 1. Remplir tout (Nom, Tél, Email, Adresse, Ville, Routeurs=1).<br>2. Accepter Conditions.<br>3. Soumettre. | Compte créé. Redirection vers Accueil ou Vérification Email. |
| **AUTH-05** | Auth | Détection IP | - | 1. Ouvrir Inscription. | Le pays est auto-sélectionné selon l'IP utilisateur. |

## 2. Tableau de Bord

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **DASH-01** | Métriques | Actualisation | - | 1. Tirer pour rafraîchir. | Chargement visible, les chiffres se mettent à jour. |
| **DASH-02** | Nav | Navigation | - | 1. Paramètres -> Retour -> Plans Internet. | Navigation fluide sans crash. |
| **DASH-03** | Données | Barre Visuelle | Usage existant | 1. Vérifier Carte Données. | La barre de progression reflète le % (Utilisé / Total). |

## 3. Gestion Utilisateurs

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **USER-01** | Recherche | Filtre par Nom | Utilisateurs existent | 1. Taper "Jean" dans la recherche. | La liste n'affiche que "Jean". |
| **USER-02** | Recherche | Filtre par Tél | Utilisateurs existent | 1. Taper "055" dans la recherche. | La liste affiche les numéros commençant par "055". |
| **USER-03** | Actions | **Bloquer Utilisateur** | Utilisateur Actif | 1. Sélectionner -> Trois Points -> Bloquer.<br>2. Confirmer. | Statut devient "Bloqué". Sessions déconnectées. |
| **USER-04** | Actions | **Débloquer** | Utilisateur Bloqué | 1. Sélectionner -> Trois Points -> Débloquer. | Statut devient "Actif". |
| **USER-05** | Routeur | **Assigner Routeur** | Utilisateur Employé | 1. Assigner Routeur.<br>2. Sélectionner "Routeur A".<br>3. Sauvegarder. | Succès. L'employé ne voit que ce routeur. |

## 4. Plans Internet

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **PLAN-01** | Créer | Plan Illimité | - | 1. Ajouter Plan.<br>2. Limite Données: "Illimité".<br>3. Remplir Prix/Validité.<br>4. Sauvegarder. | Plan créé avec badge infini. |
| **PLAN-02** | Créer | Plan Limité | - | 1. Ajouter Plan.<br>2. Limite Données: "50 Go".<br>3. Sauvegarder. | Plan créé avec limite 50Go. |
| **PLAN-03** | Éditer | MAJ Prix | Plan existant | 1. Éditer Plan.<br>2. Changer Prix.<br>3. Sauvegarder. | Le prix est mis à jour dans la liste. |
| **PLAN-04** | Logique | Supprimer Plan Actif | Plan a des abonnés | 1. Tenter de supprimer. | Erreur "Impossible de supprimer plan avec abonnés actifs". |

## 5. Sessions Actives

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **SESS-01** | Affichage | Vérification Champs | En Ligne | 1. Étendre carte utilisateur. | Vérifier IP, Uptime, Nom Routeur non nuls. |
| **SESS-02** | Action | **Déconnecter** | En Ligne | 1. Basculer Switch OFF. | Session retirée de la liste immédiatement. |

## 6. Finances (Retraits)

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **PAY-01** | Demande | **Calcul Frais (MoMo)** | Solde > 100 | 1. Demander Retrait.<br>2. Sélectionner "Mobile Money".<br>3. Entrer 100. | Résumé montre Frais: 2.00, Reçu: 98.00 (2%). |
| **PAY-02** | Demande | **Calcul Frais (Banque)** | Solde > 100 | 1. Demander Retrait.<br>2. Sélectionner "Banque".<br>3. Entrer 100. | Résumé montre Frais: 1.50, Reçu: 98.50 (1.5%). |
| **PAY-03** | Demande | Bouton Max | Solde = 500 | 1. Appuyer "Max". | Le champ montant se remplit avec 500.00. |
| **PAY-04** | Ajout | Ajout Dynamique | - | 1. Appuyer "Ajouter".<br>2. Remplir détails.<br>3. Sauvegarder. | Nouvelle méthode sélectionnée. |

## 7. Paramètres & Config

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **CONF-01** | Profil | Profil Hotspot | - | 1. Créer Profil.<br>2. Définir Vitesse + Délai.<br>3. Sauvegarder. | Profil utilisable dans Création de Plan. |
| **CONF-02** | Langue | Changer Langue | - | 1. Paramètres -> Langue -> Français. | L'interface change immédiatement en Français. |
| **CONF-03** | Thème | Mode Sombre | - | 1. Paramètres -> Thème -> Sombre. | Le fond devient noir, le texte blanc. |

## 8. CRM & Support

| ID | Fonction | Cas de Test | Pré-conditions | Étapes de Test | Résultat Attendu |
|:---|:---|:---|:---|:---|:---|
| **SUPP-01** | Ticket | **Créer un Ticket** | - | 1. Paramètres -> Aide & Support -> Créer Ticket.<br>2. Remplir Sujet, Priorité, Desc.<br>3. Soumettre. | Message de succès affiché. La boîte de dialogue se ferme. |
| **SUPP-02** | Ticket | Validation | - | 1. Créer Ticket.<br>2. Laisser champs vides.<br>3. Soumettre. | Erreurs de validation affichées. |

---
**Fin des Scénarios de Test**
