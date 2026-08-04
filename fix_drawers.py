import os

files = [
    'lib/screens/family_dashboard_screen.dart',
    'lib/screens/campus_dashboard_screen.dart',
    'lib/screens/dashboard_screen.dart'
]

for filepath in files:
    with open(filepath, 'r') as f:
        content = f.read()

    # Remove drawer: const AppDrawer()
    content = content.replace("drawer: const AppDrawer(),", "")
    
    # Change Scaffold.of(context).openDrawer()
    content = content.replace(
        "Scaffold.of(context).openDrawer()", 
        "context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer()"
    )
    
    # Change context.push('/settings') to openDrawer for partner
    if filepath == 'lib/screens/dashboard_screen.dart':
        content = content.replace(
            "context.push('/settings')",
            "context.findRootAncestorStateOfType<ScaffoldState>()?.openDrawer()"
        )

    with open(filepath, 'w') as f:
        f.write(content)
        print(f"Fixed {filepath}")
