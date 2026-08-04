import json
import os

# Define the new keys for english
en_onboarding = {
    "welcomeTitle": "Welcome to Tiknetafrica.\nHow do you want to use the app?",
    "welcomeSubtitle": "Choose the experience that fits your needs.",
    "commercialTitle": "Commercial Hotspot",
    "commercialSubtitle": "Manage vouchers, billing & bandwidth.",
    "familyTitle": "Home & Family",
    "familySubtitle": "Manage kids' devices & screen time.",
    "campusTitle": "Campus & Education",
    "campusSubtitle": "Track student data & campus networks.",
    "selectOption": "Select an option to continue",
    "continueWith": "Continue with {}",
    "campus": "Campus",
    "commercial": "Commercial",
    "login": "I already have an account - Log In",
    "tour": {
        "skip": "Skip",
        "createAccount": "Create Account",
        "next": "Next",
        "family": {
            "slide1Title": "Pause the Internet",
            "slide1Subtitle": "Instantly pause devices during dinner time or family moments.",
            "slide2Title": "Bedtime Schedules",
            "slide2Subtitle": "Set up automatic internet cut-offs to ensure a good night's rest."
        },
        "campus": {
            "slide1Title": "Track Daily Quotas",
            "slide1Subtitle": "Keep a close eye on your daily data usage and academic network policies.",
            "slide2Title": "Fast-Path Data",
            "slide2Subtitle": "Easily top up your account with high-speed data passes when you need them most."
        },
        "partner": {
            "slide1Title": "Create Vouchers Fast",
            "slide1Subtitle": "Generate and sell WiFi access vouchers in seconds.",
            "slide2Title": "Monitor Network Health",
            "slide2Subtitle": "Keep track of your router status, active users, and network performance."
        }
    }
}

# Define the new keys for french (using english as fallback for now, maybe auto translate some basic ones)
fr_onboarding = {
    "welcomeTitle": "Bienvenue sur Tiknetafrica.\nComment souhaitez-vous utiliser l'application ?",
    "welcomeSubtitle": "Choisissez l'expérience qui correspond à vos besoins.",
    "commercialTitle": "Hotspot Commercial",
    "commercialSubtitle": "Gérer les bons, la facturation et la bande passante.",
    "familyTitle": "Maison & Famille",
    "familySubtitle": "Gérer les appareils et le temps d'écran des enfants.",
    "campusTitle": "Campus & Éducation",
    "campusSubtitle": "Suivre les données des étudiants et les réseaux du campus.",
    "selectOption": "Sélectionnez une option pour continuer",
    "continueWith": "Continuer avec {}",
    "campus": "Campus",
    "commercial": "Commercial",
    "login": "J'ai déjà un compte - Se connecter",
    "tour": {
        "skip": "Passer",
        "createAccount": "Créer un compte",
        "next": "Suivant",
        "family": {
            "slide1Title": "Mettre Internet en pause",
            "slide1Subtitle": "Mettez instantanément en pause les appareils pendant le dîner ou en famille.",
            "slide2Title": "Horaires de coucher",
            "slide2Subtitle": "Configurez des coupures Internet automatiques pour garantir une bonne nuit de repos."
        },
        "campus": {
            "slide1Title": "Suivre les quotas",
            "slide1Subtitle": "Gardez un œil sur votre consommation de données et vos politiques.",
            "slide2Title": "Données Fast-Path",
            "slide2Subtitle": "Rechargez facilement votre compte avec des pass haut débit."
        },
        "partner": {
            "slide1Title": "Créer des bons",
            "slide1Subtitle": "Générer et vendre des bons d'accès WiFi en quelques secondes.",
            "slide2Title": "Surveiller la santé du réseau",
            "slide2Subtitle": "Gardez une trace du statut de votre routeur et des performances du réseau."
        }
    }
}

def update_json(file_path, new_data):
    with open(file_path, 'r', encoding='utf-8') as f:
        data = json.load(f)
    
    data['onboarding'] = new_data
    
    # Also replace Tiknet with Tiknetafrica anywhere it might occur, although doing this safely in dict:
    def replace_tiknet(d):
        for k, v in d.items():
            if isinstance(v, dict):
                replace_tiknet(v)
            elif isinstance(v, str):
                d[k] = v.replace('Tiknet', 'Tiknetafrica')
    
    replace_tiknet(data)
    
    with open(file_path, 'w', encoding='utf-8') as f:
        json.dump(data, f, ensure_ascii=False, indent=2)

update_json('lib/l10n/en.json', en_onboarding)
update_json('lib/l10n/fr.json', fr_onboarding)
print("Updated en.json and fr.json successfully.")
