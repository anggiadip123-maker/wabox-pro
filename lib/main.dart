import 'package:flutter/material.dart';

import 'screens/qr_generator_screen.dart';
import 'screens/direct_chat_screen.dart';
import 'screens/status_saver_screen.dart';

void main() {
  runApp(const WaBoxProApp());
}

class WaBoxProApp extends StatelessWidget {
  const WaBoxProApp({super.key});

  @override
  Widget build(BuildContext context) {
    const seedColor = Color(0xFF1AA34A);
    return MaterialApp(
      title: 'WaBox Pro',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        colorScheme: ColorScheme.fromSeed(seedColor: seedColor),
        useMaterial3: true,
        appBarTheme: const AppBarTheme(
          backgroundColor: seedColor,
          foregroundColor: Colors.white,
          centerTitle: true,
        ),
      ),
      home: const HomeShell(),
    );
  }
}

class HomeShell extends StatefulWidget {
  const HomeShell({super.key});

  @override
  State<HomeShell> createState() => _HomeShellState();
}

class _HomeShellState extends State<HomeShell> {
  int _index = 0;

  static const _titles = ['Generator QR', 'Direct Chat', 'Status Saver'];

  static const _screens = [
    QrGeneratorScreen(),
    DirectChatScreen(),
    StatusSaverScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text(_titles[_index])),
      body: IndexedStack(index: _index, children: _screens),
      bottomNavigationBar: NavigationBar(
        selectedIndex: _index,
        onDestinationSelected: (i) => setState(() => _index = i),
        destinations: const [
          NavigationDestination(icon: Icon(Icons.qr_code_2), label: 'QR'),
          NavigationDestination(icon: Icon(Icons.chat), label: 'Chat'),
          NavigationDestination(icon: Icon(Icons.image), label: 'Status'),
        ],
      ),
    );
  }
}
