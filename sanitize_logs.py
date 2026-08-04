import os
import re

def process_directory(directory):
    for root, _, files in os.walk(directory):
        for file in files:
            if file.endswith('.dart'):
                filepath = os.path.join(root, file)
                with open(filepath, 'r') as f:
                    content = f.read()
                
                # Check if it has print
                # We want to match exactly print( ... ) but not things like _print( or someprint(
                # Word boundary before print
                if re.search(r'\bprint\(', content):
                    # Replace print( with debugPrint(
                    new_content = re.sub(r'\bprint\(', 'debugPrint(', content)
                    
                    # If we replaced, ensure foundation is imported
                    if 'import \'package:flutter/foundation.dart\';' not in new_content and \
                       'import "package:flutter/foundation.dart";' not in new_content:
                        # Find the last import
                        imports = re.findall(r'^import .*?;', new_content, re.MULTILINE)
                        if imports:
                            last_import = imports[-1]
                            new_content = new_content.replace(
                                last_import, 
                                last_import + '\nimport \'package:flutter/foundation.dart\';',
                                1
                            )
                        else:
                            # No imports at all, just add at the top
                            new_content = 'import \'package:flutter/foundation.dart\';\n' + new_content
                    
                    with open(filepath, 'w') as f:
                        f.write(new_content)
                    print(f"Updated {filepath}")

process_directory('lib')
