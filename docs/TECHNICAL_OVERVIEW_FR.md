# Aperçu Technique & Documentation des Flux
## Application Partenaire Tiknet

### 1. Introduction
L'**Application Partenaire Tiknet** est une application mobile complète conçue pour les partenaires fournisseurs d'accès Internet (FAI) afin de gérer efficacement leurs opérations commerciales. Construite avec Flutter, elle offre des outils pour la gestion des utilisateurs, la configuration des forfaits Internet, la surveillance du parc de routeurs et le suivi financier.

### 2. Stack Technologique

*   **Framework**: [Flutter](https://flutter.dev) (Dart)
*   **Gestion d'État**: Patron [Provider](https://pub.dev/packages/provider) (ChangeNotifier)
*   **Réseau**: [Dio](https://pub.dev/packages/dio) pour les requêtes HTTP
*   **Stockage Local**: `shared_preferences` et `flutter_secure_storage` pour la gestion des tokens
*   **UI/UX**: Material Design 3 (M3) avec thèmes personnalisés
*   **Localisation**: `easy_localization` (Support Anglais & Français)
*   **Graphiques**: `fl_chart` pour la visualisation des données

### 3. Architecture de l'Application
L'application suit une architecture en couches propre pour assurer l'évolutivité et la maintenabilité.

#### 3.1. Structure en Couches
1.  **Couche de Présentation (Écrans & Widgets)** : Gère le rendu UI et les interactions utilisateur.
2.  **Couche de Gestion d'État (Providers)** :
    *   `AuthProvider` : Gère l'état d'authentification (connexion, déconnexion, session utilisateur).
    *   `UserProvider` : Gère les données clients, les rôles et les abonnements.
    *   `BillingProvider` : Gère le portefeuille, les transactions et les méthodes de paiement.
    *   `NetworkProvider` : Contrôle la configuration des routeurs, les hotspots et les sessions.
    *   `ThemeProvider` : Gère les thèmes de l'application (Modes Clair/Sombre).
3.  **Couche Repository** : Abstrait les sources de données et gère les transformations de logique métier.
    *   Exemples : `AuthRepository`, `PartnerRepository`, `WalletRepository`, `RouterRepository`.
4.  **Couche de Données (Services)** :
    *   `ApiClient` : Client HTTP centralisé avec intercepteurs pour les en-têtes d'authentification et la gestion des erreurs.
    *   `TokenStorage` : Persiste de manière sécurisée les tokens d'accès et de rafraîchissement.

### 4. Flux Principaux

#### 4.1. Flux d'Authentification
*   **Écran Splash** : Vérifie les tokens d'authentification existants.
*   **Onboarding** : Les nouveaux utilisateurs sont guidés à travers un flux d'introduction (suivi via `shared_preferences`).
*   **Connexion** : Les utilisateurs s'authentifient avec email/mot de passe.
    *   *Mécanisme* : `AuthRepository` envoie les identifiants -> Reçoit les tokens OAuth2 -> Stocke dans `TokenStorage`.
*   **Mot de Passe Oublié** : Flux de réinitialisation basé sur OTP (`ResetPasswordScreen`, `VerifyPasswordResetOtpScreen`).
*   **Déconnexion Auto** : Les réponses 401 illégales déclenchent une déconnexion globale via les intercepteurs `ApiClient`.

#### 4.2. Tableau de Bord & Navigation
*   **Écran d'Accueil** : Agit comme la coquille principale avec une barre de navigation inférieure (mobile) ou un rail de navigation (tablette).
*   **Tableau de Bord** : Affiche les KPI en temps réel (Total Utilisateurs, Sessions Actives, Revenus, Routeurs Actifs).

#### 4.3. Gestion des Utilisateurs
*   **Vue Liste** : Liste consultable et filtrable de tous les clients (`UsersScreen`).
*   **Détails Utilisateur** : Vue complète d'un utilisateur spécifique incluant les forfaits Internet, les appareils assignés et l'historique des paiements.
*   **Gestion de Profil** : Création et édition de profils utilisateurs avec des rôles et permissions spécifiques.

#### 4.4. Gestion des Forfaits Internet
*   **Création de Forfait** : Les partenaires peuvent définir des forfaits avec des contraintes spécifiques :
    *   Vitesse de Téléchargement/Envoi (Mbps)
    *   Limites de Données (Go/Mo)
    *   Périodes de Validité (Jours/Heures)
    *   Limites de Sessions Simultanées
*   **Assignation** : Les forfaits peuvent être assignés de manière significative aux utilisateurs ou aux routeurs.

#### 4.5. Gestion Réseau & Routeurs
*   **Enregistrement de Routeur** : Scan de code QR ou entrée manuelle pour ajouter de nouveaux routeurs Mikrotik/compatibles (`RouterRegistrationScreen`).
*   **Surveillance** : Vérifications de santé en temps réel (`RouterHealthScreen`) affichant CPU, Mémoire et Disponibilité.
*   **Configuration** : Configuration à distance des paramètres du routeur comme les délais d'inactivité et les limites de débit.

#### 4.6. Facturation & Finance
*   **Portefeuille** : Aperçu du solde actuel et des gains totaux (`WalletOverviewScreen`).
*   **Paiements** : Les partenaires peuvent demander des versements vers des comptes mobile money ou bancaires (`PayoutRequestScreen`).
*   **Historique** : Journaux détaillés des transactions pour les audits et la réconciliation (`TransactionHistoryScreen`).

#### 4.7. Paramètres & Configuration
*   **Paramètres App** : Bascule de langue (EN/FR), sélection de Thème, préférences de Notification.
*   **Paramètres Business** : Configurations de forfait par défaut, configurations de profils employés.

### 5. Mesures de Sécurité
*   **Stockage de Token** : Mécanisme de stockage sécurisé pour les tokens d'authentification sensibles.
*   **HTTPS** : Toute la communication API est chiffrée.
*   **Contrôle d'Accès Basé sur les Rôles (RBAC)** : Les fonctionnalités de l'application sont verrouillées en fonction des permissions du partenaire connecté.

### 6. Déploiement
*   **Versionnement** : Versionnement sémantique suivi dans `pubspec.yaml` (actuellement `1.0.0+1`).
*   **Plateformes** : Optimisé pour Android et iOS, avec des capacités de support Web.
