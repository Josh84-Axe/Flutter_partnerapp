import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../providers/split/auth_provider.dart';
import 'shells/shell_strategies.dart';
import '../widgets/app_drawer.dart';
import 'auth_wrapper.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  int _currentIndex = 0;

  @override
  Widget build(BuildContext context) {
    final authProvider = context.watch<AuthProvider>();
    final currentUser = authProvider.currentUser;
    
    // On web refresh/reload directly to /home, state is lost. 
    // If currentUser is null, delegate back to AuthWrapper to restore the session.
    if (currentUser == null) {
      return const AuthWrapper();
    }
    
    final isTablet = MediaQuery.of(context).size.width >= 600;
    final appVariant = currentUser.appVariant;
    
    final strategy = getStrategy(appVariant);
    
    // Ensure index doesn't go out of bounds if switching variants
    final screens = strategy.getScreens(context, (idx) => setState(() => _currentIndex = idx));
    if (_currentIndex >= screens.length) {
      _currentIndex = 0;
    }

    return strategy.wrapShell(
      Scaffold(
        body: Row(
          children: [
            if (isTablet)
              Builder(
                builder: (context) => NavigationRail(
                  leading: IconButton(
                    icon: const Icon(Icons.menu),
                    onPressed: () => Scaffold.of(context).openDrawer(),
                  ),
                  selectedIndex: _currentIndex,
                  onDestinationSelected: (index) {
                    setState(() {
                      _currentIndex = index;
                    });
                  },
                  labelType: NavigationRailLabelType.all,
                  destinations: strategy.getRailDestinations(),
                ),
              ),
            Expanded(
              child: IndexedStack(
                index: _currentIndex,
                children: screens,
              ),
            ),
          ],
        ),
        bottomNavigationBar: isTablet
            ? null
            : NavigationBar(
                selectedIndex: _currentIndex,
                onDestinationSelected: (index) {
                  setState(() {
                    _currentIndex = index;
                  });
                },
                destinations: strategy.getDestinations(),
              ),
        drawer: const AppDrawer(),
      )
    );
  }
}
