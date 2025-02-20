import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:flutter_ithub/bloc/favorite/favorite_bloc.dart';
import 'package:flutter_ithub/repositories/favorite_repository.dart';
import 'bloc/crypto/crypto_bloc.dart';
import 'models/crypto_currency.dart';
import 'repositories/crypto_repository.dart';
import 'screens/crypto_screen.dart';
import 'screens/profile_screen.dart';
import 'screens/favorites_screen.dart';
import 'screens/crypto_detail_screen.dart';


void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  if(kIsWeb) {
  await Firebase.initializeApp(options: FirebaseOptions(
      apiKey: "AIzaSyD01umSwp2Q9UpSLcQCYz6c6NtocIJwZLQ",
      authDomain: "flutter-83894.firebaseapp.com",
      projectId: "flutter-83894",
      storageBucket: "flutter-83894.firebasestorage.app",
      messagingSenderId: "557147264910",
      appId: "1:557147264910:web:2338d11da784a1e548f6df"
  ));
  } else {
    await Firebase.initializeApp();
  }

  //runApp(MyApp());
   runApp(MultiBlocProvider(
    providers: [
      BlocProvider(
        create: (context) => FavoriteBloc(repository: FavoriteRepository())
          ..add(LoadFavoritesEvent())),
      BlocProvider(
        create: (context) => CryptoBloc(CryptoRepository())),
    ],
    child: MyApp(),
  ));
}

class MyApp extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return RepositoryProvider(
      create: (context) => CryptoRepository(),
      child: BlocProvider(
        create: (context) => CryptoBloc(context.read<CryptoRepository>())
          ..add(LoadCryptoEvent()),
        child: MaterialApp(
          title: 'Курсы криптовалют',
          theme: ThemeData(
            colorScheme: ColorScheme.fromSeed(seedColor: Colors.deepPurple),
            useMaterial3: true,
          ),
          home: MainNavigator(),
          routes: {
            '/crypto-detail': (context) => CryptoDetailScreen(
              crypto: ModalRoute.of(context)!.settings.arguments as CryptoCurrency,
            ),
          },
        ),
      ),
    );
  }
}

class MainNavigator extends StatefulWidget {
  @override
  State<MainNavigator> createState() => _MainNavigatorState();
}

class _MainNavigatorState extends State<MainNavigator> {
  int _selectedIndex = 0;
  final PageController _pageController = PageController();

  final List<Widget> _screens = [
    CryptoScreen(),
    ProfileScreen(),
    FavoritesScreen(),
  ];

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: PageView(
        controller: _pageController,
        physics: const NeverScrollableScrollPhysics(),
        children: _screens,
      ),
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _selectedIndex,
        selectedItemColor: Colors.deepPurple,
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() => _selectedIndex = index);
          _pageController.jumpToPage(index);
        },
        items: const [
          BottomNavigationBarItem(
            icon: Icon(Icons.currency_bitcoin),
            label: 'Криптовалюты',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.person),
            label: 'Профиль',
          ),
          BottomNavigationBarItem(
            icon: Icon(Icons.star),
            label: 'Избранное',
          ),
        ],
      ),
    );
  }

  @override
  void dispose() {
    _pageController.dispose();
    super.dispose();
  }
}