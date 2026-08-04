# Manuel d'Utilisation de l'Application Partenaire

Ce manuel fournit un guide complet, étape par étape, pour utiliser l'Application Partenaire. Il détaille chaque écran, champ et processus disponible dans l'application.

---

## Table des Matières
1. [Authentification & Inscription](#1-authentification--inscription)
2. [Navigation du Tableau de Bord](#2-navigation-du-tableau-de-bord)
3. [Gestion des Utilisateurs](#3-gestion-des-utilisateurs)
4. [Gestion des Plans Internet](#4-gestion-des-plans-internet)
5. [Gestion des Sessions Actives](#5-gestion-des-sessions-actives)
6. [Gestion des Routeurs](#6-gestion-des-routeurs)
7. [Rapports Financiers & Retraits](#7-rapports-financiers--retraits)
8. [Paramètres & Configuration](#8-paramètres--configuration)

---

## 1. Authentification & Inscription

### 1.1 Inscription Partenaire
Pour devenir partenaire, vous devez remplir le formulaire d'inscription avec les détails précis de votre entreprise.

**Navigation**: Ouvrir l'app -> Appuyer sur "Créer un compte"

**Champs**:
- **Nom Complet**: Vos prénom et nom légaux.
- **Numéro de Téléphone**: Format international. Sélectionnez le code pays (drapeau) s'il n'est pas détecté automatiquement.
- **Adresse Email**: Votre identifiant de connexion et canal de communication.
- **Nom de l'Entreprise**: Le nom de votre structure FAI/Revendeur.
- **Adresse**: Adresse physique de l'entreprise.
- **Ville**: Ville d'opération.
- **Pays**: Détecté automatiquement via IP, ou sélectionnable manuellement.
- **Nombre de Routeurs**: Estimation du déploiement initial (défaut : 1).
- **Mot de Passe**: Minimum 6 caractères.
- **Confirmer le Mot de Passe**: Doit correspondre exactement.

**Processus**:
1. Remplissez tous les champs obligatoires.
2. Accords: Vous devez cocher la case pour accepter les **Conditions d'Utilisation** et la **Politique de Confidentialité**.
3. Appuyez sur **"Soumettre"**.
4. **Vérification**: Vous recevrez un lien de vérification par email (si configuré) ou serez connecté directement.

### 1.2 Connexion
**Champs**:
- **Email**: Adresse email enregistrée.
- **Mot de Passe**: Votre mot de passe sécurisé.

### 1.3 Récupération de Mot de Passe
**Navigation**: Écran de Connexion -> Appuyer sur "Mot de passe oublié ?"
**Processus**: Entrez votre email. Un lien de réinitialisation sera envoyé. Suivez les étapes pour créer un nouveau mot de passe.

---

## 2. Navigation du Tableau de Bord

Le Tableau de Bord est la page d'accueil après connexion, offrant une vue d'ensemble.

**Composants**:
- **Bannière d'État**: Affiche les avertissements ou l'état de la connexion.
- **Carte d'Abonnement**: Affiche votre niveau de partenaire actuel (ex: "Partenaire Or") et la date de renouvellement.
- **Tuiles de Métriques**:
    - **Revenu Total**: Revenu cumulé. Appuyer ouvre l'écran de [Rapports](#7-rapports-financiers--retraits).
    - **Utilisateurs Actifs**: Nombre de clients valides actuellement. Appuyer ouvre la liste des utilisateurs.
- **Actions Rapides**: Accès en un clic aux fonctionnalités courantes :
    - **Plans Internet**: Créer/Gérer les plans.
    - **Sessions Actives**: Surveiller les connexions en direct.
    - **Rapports**: Statistiques financières.
    - **Paramètres**: Préférences de l'application.
- **Carte d'Utilisation des Données**: Une barre visuelle montrant votre consommation globale de données par rapport à votre limite.

---

## 3. Gestion des Utilisateurs

**Navigation**: Menu Inférieur -> "Utilisateurs"

### 3.1 Recherche & Filtrage
- **Barre de Recherche**: Entrez un **Nom** ou un **Numéro de Téléphone** pour trouver un client.
- **Filtre**: Appuyez sur l'icône de filtre pour afficher uniquement **Clients**, **Agents**, ou **Administrateurs**.

### 3.2 Détails Utilisateur
Appuyez sur n'importe quel utilisateur pour voir :
- **En-tête de Profil**: Nom, Rôle, Statut de Connexion.
- **Statistiques Données**: Total Téléchargement/Envoi.
- **Portefeuille**: Solde actuel.
- **Transactions Récentes**: Les 5 derniers paiements.

### 3.3 Actions Utilisateur
Appuyez sur le **Menu à Trois Points** sur la carte d'un utilisateur :
- **Voir Détails**: Vue complète du profil.
- **Assigner Routeur**: Lier un routeur spécifique à cet utilisateur (employé/admin).
- **Bloquer Utilisateur**: Restreint l'accès immédiatement et déconnecte les sessions actives. Le statut passe à "Bloqué".
- **Débloquer Utilisateur**: Restaure l'accès. Le statut passe à "Actif".

---

## 4. Gestion des Plans Internet

**Navigation**: Tableau de Bord -> "Plans Internet"

### 4.1 Créer un Plan
Appuyez sur le bouton **"+" (Ajouter)**.

**Champs**:
- **Nom du Plan**: Nom commercial (ex: "Forfait Hebdo").
- **Prix**: Coût dans la devise locale.
- **Limite de Données**: Sélectionnez un plafond (ex: 50Go) ou **"Illimité"**.
- **Validité**: Durée (ex: 30 Jours).
- **Appareils Autorisés**: Nombre maximum d'appareils simultanés.
- **Profil Hotspot**: Lien vers un profil technique (configuration bande passante).

**Processus**: Appuyez sur "Créer le Plan". Le plan devient immédiatement disponible à l'achat.

### 4.2 Modification & Suppression
- **Éditer**: Appuyez sur l'icône crayon. Mettez à jour le Nom, Prix ou Config.
- **Supprimer**: Appuyez sur l'icône corbeille. *Note : Les plans avec des abonnés actifs ne peuvent généralement pas être supprimés.*

---

## 5. Gestion des Sessions Actives

**Navigation**: Tableau de Bord -> "Sessions Actives"

### 5.1 Onglets de Surveillance
- **Utilisateurs En Ligne**: Utilisateurs ayant acheté un plan via le portail de paiement.
- **Utilisateurs Assignés**: Utilisateurs ayant reçu un plan manuellement par un admin.

### 5.2 Détails de Session
Chaque carte affiche :
- **Nom Client**: L'identifiant de l'utilisateur.
- **Plan**: Le plan actif actuel.
- **Statut**: Point Vert (En Ligne) ou Point Gris (Hors Ligne).
- **Statistiques Techniques** (Si En Ligne) :
    - Nom Routeur : L'appareil spécifique auquel ils sont connectés.
    - Adresse IP.
    - Temps de connexion (Uptime).
    - Consommation Téléchargement/Envoi.

### 5.3 Déconnecter un Utilisateur
1. Identifiez un utilisateur avec un **Statut Vert** (En Ligne).
2. Basculez l'interrupteur sur **OFF**.
3. La session est terminée immédiatement.

---

## 6. Gestion des Routeurs

### 6.1 Assigner des Routeurs aux Employés
**Navigation**: Écran Utilisateurs -> Sélectionner Utilisateur -> Trois Points -> "Assigner Routeur"

**Processus**:
1. Recherchez un routeur par Nom ou ID.
2. **Sélection Multiple**: Cochez plusieurs routeurs si nécessaire.
3. Appuyez sur **"Enregistrer"**.
   *Impact*: L'utilisateur (ex: Technicien) ne verra et ne gérera que les routeurs que vous lui avez assignés.

### 6.2 Profils de Routeur
**Navigation**: Paramètres -> "Profils Hotspot"
Gérez les paramètres techniques comme les Limites de Vitesse et Délais d'Inactivité.

**Champs**:
- **Nom du Profil**: ex: "Standard 5Mbps".
- **Limite de Vitesse**: Vitesse max téléchargement/envoi.
- **Délai d'Inactivité**: Temps avant déconnexion automatique.
- **Promotionnel**: Indicateur pour offres spéciales.
- **Portée Routeur**: Routeur spécifique ou "Tous les Routeurs".

---

## 7. Rapports Financiers & Retraits

### 7.1 Historique des Transactions
**Navigation**: Tableau de Bord -> "Rapports"
- **Entrées**: Argent reçu (Ventes de plans).
- **Sorties**: Argent envoyé (Retraits, Dépenses).
- **Filtre de Date**: Sélection de période personnalisée.

### 7.2 Demander un Retrait
**Navigation**: Paramètres -> "Retraits" -> "Demander un Retrait"

**Champs**:
- **Solde**: Affiche le montant disponible pour retrait.
- **Montant**: Entrez une valeur ou appuyez sur **"Max"** pour tout retirer.
- **Méthode de Paiement**: Sélectionnez Mobile Money ou Virement Bancaire.
  - *Ajouter*: Vous pouvez ajouter des méthodes dynamiquement (Fournisseur, Numéro de Compte).
- **Calcul des Frais**:
  - **Mobile Money**: 2.0% de frais.
  - **Virement Bancaire**: 1.5% de frais.
  - *Résumé*: Affiche Montant Demandé - Frais = **Vous Recevrez**.

**Processus**: Appuyez sur "Demander le Retrait". Le temps de traitement varie (1-2 heures pour MoMo, 2-3 jours pour Banque).

---

## 8. Paramètres & Configuration

**Navigation**: Tableau de Bord -> Icône Engrenage "Paramètres"

- **Profil**: Mettre à jour Nom, Téléphone.
- **Sécurité**: Changer le mot de passe.
- **Méthodes de Paiement**: Gérer les comptes de retrait enregistrés.
- **Notifications**: Historique des alertes avec recherche.
- **Langue**: Basculer Anglais / Français (Mise à jour instantanée).
- **Thème**: Mode Sombre / Clair / Système.
- **Aide & Support**: Créez des tickets d'assistance directement dans l'application (Intégration CRM).

---
**Fin du Manuel**
