import json
import os

langs = ['en', 'fr', 'es', 'pt']
new_keys = {
    'verify_and_continue': {
        'en': 'Verify & Continue',
        'fr': 'Vérifier et continuer',
        'es': 'Verificar y continuar',
        'pt': 'Verificar e continuar'
    },
    'didn_t_receive_code': {
        'en': "Didn't receive the code?",
        'fr': "Vous n'avez pas reçu le code?",
        'es': "¿No recibiste el código?",
        'pt': "Não recebeu o código?"
    }
}

for lang in langs:
    filepath = f"lib/l10n/{lang}.json"
    if os.path.exists(filepath):
        with open(filepath, 'r') as f:
            data = json.load(f)
            
        data['verify_and_continue'] = new_keys['verify_and_continue'][lang]
        data['didn_t_receive_code'] = new_keys['didn_t_receive_code'][lang]
        
        with open(filepath, 'w') as f:
            json.dump(data, f, indent=2, ensure_ascii=False)
            
print("Translations updated successfully.")
