import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:provider/provider.dart';
import 'package:google_fonts/google_fonts.dart';

import 'providers/app_state.dart';
import 'widgets/sidebar_navigation.dart';
import 'views/dashboard_view.dart';
import 'views/billing_pos_view.dart';
import 'views/inventory_view.dart';
import 'views/invoices_view.dart';
import 'views/customers_view.dart';
import 'views/suppliers_view.dart';
import 'views/reports_view.dart';
import 'views/settings_view.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  runApp(
    ChangeNotifierProvider(
      create: (_) => AppState(),
      child: const ShaBillingApp(),
    ),
  );
}

class ShaBillingApp extends StatelessWidget {
  const ShaBillingApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Sha Electronics - Inventory & POS Billing',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB), // Blue 600
          primary: const Color(0xFF2563EB),
          surface: Colors.white,
        ),
        textTheme: GoogleFonts.interTextTheme(Theme.of(context).textTheme),
        scaffoldBackgroundColor: const Color(0xFFF1F5F9),
        appBarTheme: const AppBarTheme(
          backgroundColor: Colors.white,
          elevation: 0,
        ),
      ),
      home: const MainShell(),
    );
  }
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  final List<Widget> _views = const [
    DashboardView(),
    BillingPosView(),
    InventoryView(),
    InvoicesView(),
    CustomersView(),
    SuppliersView(),
    ReportsView(),
    SettingsView(),
  ];

  @override
  Widget build(BuildContext context) {
    final state = context.watch<AppState>();

    if (state.isLoading) {
      return const Scaffold(
        backgroundColor: Color(0xFF0F172A),
        body: Center(
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              CircularProgressIndicator(color: Color(0xFF3B82F6)),
              SizedBox(height: 16),
              Text(
                'Starting Sha Billing & Inventory...',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ),
      );
    }

    return Shortcuts(
      shortcuts: <LogicalKeySet, Intent>{
        LogicalKeySet(LogicalKeyboardKey.f1): const _NavigateIntent(1),
        LogicalKeySet(LogicalKeyboardKey.f2): const _NavigateIntent(2),
        LogicalKeySet(LogicalKeyboardKey.f3): const _NavigateIntent(3),
        LogicalKeySet(LogicalKeyboardKey.f4): const _NavigateIntent(4),
      },
      child: Actions(
        actions: <Type, Action<Intent>>{
          _NavigateIntent: CallbackAction<_NavigateIntent>(
            onInvoke: (intent) => state.setViewIndex(intent.index),
          ),
        },
        child: Focus(
          autofocus: true,
          child: Scaffold(
            body: Row(
              children: [
                SidebarNavigation(
                  selectedIndex: state.currentViewIndex,
                  onDestinationSelected: (index) => state.setViewIndex(index),
                ),
                Expanded(
                  child: IndexedStack(
                    index: state.currentViewIndex,
                    children: _views,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _NavigateIntent extends Intent {
  final int index;
  const _NavigateIntent(this.index);
}
