import 'dart:async';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_auth/firebase_auth.dart';

import 'auth/auth_service.dart';
import 'auth/email_auth_page.dart';
import 'customer_action_page.dart';
import 'firebase_options.dart';
import 'models/shop_type.dart';
export 'models/shop_type.dart';
import 'services/app_state.dart';
import 'services/matrix_firestore_service.dart';

// 20 Application Screens
import 'screens/screen01_fnb_home.dart';
import 'screens/screen02_menu_home.dart';
import 'screens/screen03_gasimzansi_matrix.dart';
import 'screens/screen04_choose_shop.dart';
import 'screens/screen05_main_hub.dart';
import 'screens/screen06_scanner.dart';
import 'screens/screen07_voice_capture.dart';
import 'screens/screen08_scanned_spaza.dart';
import 'screens/screen09_scanned_liquor.dart';
import 'screens/screen10_markdown.dart';
import 'screens/screen11_empties_tracker.dart';
import 'screens/screen12_spaza_progress.dart';
import 'screens/screen13_liquor_progress.dart';
import 'screens/screen14_spaza_price_list.dart';
import 'screens/screen15_liquor_price_list.dart';
import 'screens/screen16_sassa_overview.dart';
import 'screens/screen17_mid_month_overview.dart';
import 'screens/screen18_payday_overview.dart';
import 'screens/screen19_month_end_overview.dart';
import 'screens/screen20_fnb_microloan.dart';
import 'widgets/fnb_brand_header.dart';

// Brand Color Palette constants for backward-compatibility with tests:
const teal = fnbTeal;
const ink = fnbDark;
const paleTeal = fnbPaleTeal;
const soft = fnbSoft;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  try {
    await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  } catch (_) {
    // Allows running in local/test/offline mode without crash
  }
  MatrixFirestoreService.ensureInitialized();
  runApp(const FnbApp());
}

class FnbApp extends StatefulWidget {
  const FnbApp({super.key});

  @override
  State<FnbApp> createState() => _FnbAppState();
}

class _FnbAppState extends State<FnbApp> {
  final MzansiAppState _appState = MzansiAppState();

  @override
  Widget build(BuildContext context) {
    return AppStateScope(
      state: _appState,
      child: MaterialApp(
        title: 'FNB Mzansi Matrix',
        debugShowCheckedModeBanner: false,
        theme: ThemeData(
          useMaterial3: true,
          scaffoldBackgroundColor: Colors.white,
          colorScheme: ColorScheme.fromSeed(seedColor: fnbTeal),
          fontFamily: 'Arial',
          textTheme: const TextTheme(
            bodyMedium: TextStyle(fontSize: 12, color: fnbDark),
            labelSmall: TextStyle(fontSize: 9, color: fnbDark),
          ),
        ),
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatelessWidget {
  const AuthGate({super.key});

  @override
  Widget build(BuildContext context) {
    if (Firebase.apps.isEmpty) return const FnbShell();

    return StreamBuilder<User?>(
      stream: AuthService().authStateChanges,
      builder: (context, snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Scaffold(
            body: Center(child: CircularProgressIndicator(color: fnbTeal)),
          );
        }
        return snapshot.hasData ? const FnbShell() : const EmailAuthPage();
      },
    );
  }
}

class FnbShell extends StatefulWidget {
  const FnbShell({super.key});

  @override
  State<FnbShell> createState() => _FnbShellState();
}

class _FnbShellState extends State<FnbShell> with SingleTickerProviderStateMixin {
  int tab = 0;
  late final AnimationController _animController;
  late Animation<double> _slideAnimation;
  int _prevTab = 0;

  static const _navItems = <(IconData, IconData, String)>[
    (Icons.home_outlined, Icons.home, 'Home'),
    (Icons.menu_book_outlined, Icons.menu_book, 'F&B Menu'),
    (Icons.storefront_outlined, Icons.storefront, 'Merchant Hub'),
    (Icons.insights_outlined, Icons.insights, 'My progress'),
    (Icons.grid_view_outlined, Icons.grid_view, 'More'),
  ];

  @override
  void initState() {
    super.initState();
    _animController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
    _slideAnimation = Tween<double>(begin: 0, end: 0).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
  }

  @override
  void dispose() {
    _animController.dispose();
    super.dispose();
  }

  void _onTabTap(int index) {
    if (index == tab) return;
    _prevTab = tab;
    _slideAnimation = Tween<double>(
      begin: _prevTab.toDouble(),
      end: index.toDouble(),
    ).animate(
      CurvedAnimation(parent: _animController, curve: Curves.easeOutCubic),
    );
    _animController.forward(from: 0);
    setState(() => tab = index);
  }

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);
    final isSpaza = state.activeShop == ShopType.spaza;

    final pages = [
      const Screen01FnbHome(),
      const Screen02MenuHome(),
      const Screen05MainHub(),
      isSpaza ? const Screen12SpazaProgress() : const Screen13LiquorProgress(),
      MoreDirectoryPage(onNavigateToTab: (t) => setState(() => tab = t)),
    ];

    return Scaffold(
      extendBody: true,
      body: SafeArea(
        bottom: false,
        child: AnimatedSwitcher(
          duration: const Duration(milliseconds: 250),
          child: KeyedSubtree(key: ValueKey(tab), child: pages[tab]),
        ),
      ),
      bottomNavigationBar: _FloatingNavBar(
        currentIndex: tab,
        onTap: _onTabTap,
        items: _navItems,
        slideAnimation: _slideAnimation,
      ),
    );
  }
}

class _FloatingNavBar extends StatelessWidget {
  const _FloatingNavBar({
    required this.currentIndex,
    required this.onTap,
    required this.items,
    required this.slideAnimation,
  });

  final int currentIndex;
  final ValueChanged<int> onTap;
  final List<(IconData, IconData, String)> items;
  final Animation<double> slideAnimation;

  @override
  Widget build(BuildContext context) {
    final bottomPadding = MediaQuery.of(context).padding.bottom;

    return Container(
      margin: EdgeInsets.fromLTRB(16, 0, 16, 12 + bottomPadding),
      height: 64,
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(22),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.08),
            blurRadius: 20,
            offset: const Offset(0, 6),
          ),
          BoxShadow(
            color: fnbTeal.withValues(alpha: 0.08),
            blurRadius: 10,
            offset: const Offset(0, 2),
          ),
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(22),
        child: LayoutBuilder(
          builder: (context, constraints) {
            final itemWidth = constraints.maxWidth / items.length;
            return Stack(
              children: [
                AnimatedBuilder(
                  animation: slideAnimation,
                  builder: (context, child) {
                    final pos = slideAnimation.value;
                    return Positioned(
                      left: pos * itemWidth + (itemWidth - 44) / 2,
                      top: 6,
                      child: Container(
                        width: 44,
                        height: 30,
                        decoration: BoxDecoration(
                          color: fnbPaleTeal,
                          borderRadius: BorderRadius.circular(15),
                        ),
                      ),
                    );
                  },
                ),
                Row(
                  children: List.generate(items.length, (i) {
                    final isSel = currentIndex == i;
                    final item = items[i];
                    return Expanded(
                      child: InkWell(
                        onTap: () => onTap(i),
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              isSel ? item.$2 : item.$1,
                              color: isSel ? fnbTeal : Colors.black45,
                              size: 20,
                            ),
                            const SizedBox(height: 2),
                            Text(
                              item.$3,
                              style: TextStyle(
                                fontSize: 9,
                                fontWeight: isSel ? FontWeight.bold : FontWeight.normal,
                                color: isSel ? fnbTeal : Colors.black54,
                              ),
                            ),
                          ],
                        ),
                      ),
                    );
                  }),
                ),
              ],
            );
          },
        ),
      ),
    );
  }
}

/// More Page: Comprehensive 20-Screen Navigator & Direct Action Hub
class MoreDirectoryPage extends StatelessWidget {
  const MoreDirectoryPage({super.key, required this.onNavigateToTab});
  final ValueChanged<int> onNavigateToTab;

  @override
  Widget build(BuildContext context) {
    final state = MzansiAppState.of(context);
    final isSpaza = state.activeShop == ShopType.spaza;

    final allScreens = [
      ('Screen 1: FNB Home Screen', Icons.home_outlined, () {
        onNavigateToTab(0);
      }),
      ('Screen 2: F&B Menu Home', Icons.menu_book_outlined, () {
        onNavigateToTab(1);
      }),
      ('Screen 3: GasiMzansi Matrix', Icons.grid_on_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen03GasiMzansiMatrix()));
      }),
      ('Screen 4: Choose Your Shop', Icons.swap_horiz_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen04ChooseShop()));
      }),
      ('Screen 5: Main Application Home', Icons.storefront_outlined, () {
        onNavigateToTab(2);
      }),
      ('Screen 6: Scanner', Icons.camera_alt_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen06Scanner()));
      }),
      ('Screen 7: Voice Capture', Icons.mic_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen07VoiceCapture()));
      }),
      ('Screen 8: Scanned Spaza Items', Icons.inventory_2_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen08ScannedSpaza()));
      }),
      ('Screen 9: Scanned Liquor Items', Icons.local_bar_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen09ScannedLiquor()));
      }),
      ('Screen 10: Markdown Alerts', Icons.warning_amber_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen10Markdown()));
      }),
      ('Screen 11: Liquor Empties Tracker', Icons.recycling_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen11EmptiesTracker()));
      }),
      ('Screen 12: My Progress (Spaza)', Icons.insights_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen12SpazaProgress()));
      }),
      ('Screen 13: My Progress (Liquor)', Icons.bar_chart_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen13LiquorProgress()));
      }),
      ('Screen 14: Spaza Price List', Icons.receipt_long_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen14SpazaPriceList()));
      }),
      ('Screen 15: Liquor Price List', Icons.local_drink_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen15LiquorPriceList()));
      }),
      ('Screen 16: SASSA Financial Overview', Icons.calendar_today_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen16SassaOverview()));
      }),
      ('Screen 17: Mid-Month Financial Overview', Icons.show_chart_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen17MidMonthOverview()));
      }),
      ('Screen 18: 25th-Day Financial Overview', Icons.paid_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen18PaydayOverview()));
      }),
      ('Screen 19: Month-End Financial Overview', Icons.event_repeat_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen19MonthEndOverview()));
      }),
      ('Screen 20: FNB Microloan', Icons.monetization_on_outlined, () {
        Navigator.of(context).push(MaterialPageRoute(builder: (_) => const Screen20FnbMicroloan()));
      }),
    ];

    return Scaffold(
      backgroundColor: Colors.white,
      appBar: AppBar(
        backgroundColor: Colors.white,
        elevation: 0,
        title: const Text('All 20 Screens & Navigation Hub', style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16)),
        bottom: PreferredSize(
          preferredSize: const Size.fromHeight(1),
          child: Container(color: const Color(0xffe2eeee), height: 1),
        ),
      ),
      body: ListView(
        padding: const EdgeInsets.fromLTRB(16, 12, 16, 96),
        children: [
          Container(
            padding: const EdgeInsets.all(14),
            decoration: BoxDecoration(
              color: fnbPaleTeal,
              borderRadius: BorderRadius.circular(10),
            ),
            child: Row(
              children: [
                Icon(
                  isSpaza ? Icons.storefront_outlined : Icons.local_bar_outlined,
                  color: fnbTeal,
                ),
                const SizedBox(width: 10),
                Expanded(
                  child: Text(
                    'Active Context: ${state.activeShop.label} (${state.activeLanguage.displayName})',
                    style: const TextStyle(fontSize: 12, fontWeight: FontWeight.bold, color: fnbDark),
                  ),
                ),
                TextButton(
                  onPressed: () => Navigator.of(context).push(
                    MaterialPageRoute(builder: (_) => const Screen04ChooseShop()),
                  ),
                  child: const Text('Switch', style: TextStyle(color: fnbTeal, fontWeight: FontWeight.bold)),
                ),
              ],
            ),
          ),
          const SizedBox(height: 16),
          const Text(
            'FIGMA SPECIFICATION SCREEN CATALOGUE',
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.bold, color: fnbTeal, letterSpacing: 0.5),
          ),
          const SizedBox(height: 8),

          for (final item in allScreens)
            Card(
              elevation: 0,
              margin: const EdgeInsets.only(bottom: 6),
              color: fnbSoft,
              child: ListTile(
                dense: true,
                leading: Icon(item.$2, color: fnbTeal, size: 20),
                title: Text(item.$1, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w600)),
                trailing: const Icon(Icons.arrow_forward_ios, size: 12, color: Colors.black26),
                onTap: item.$3,
              ),
            ),
          const SizedBox(height: 16),
          ListTile(
            leading: const Icon(Icons.settings_outlined, color: fnbTeal),
            title: const Text('Settings'),
            onTap: () => Navigator.of(context).push(
              MaterialPageRoute(builder: (_) => const SettingsPage()),
            ),
          ),
        ],
      ),
    );
  }
}
