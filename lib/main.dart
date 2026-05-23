import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'app_theme.dart';
import 'providers/auth_provider.dart';
import 'providers/programa_provider.dart';
import 'providers/tareas_provider.dart';
import 'screens/login_screen.dart';
import 'screens/encargado/encargado_home_screen.dart';
import 'screens/voluntario/voluntario_home_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // Descomenta cuando configures Firebase:
  // await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const FundecodesApp());
}

class FundecodesApp extends StatelessWidget {
  const FundecodesApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => AuthProvider()),
        ChangeNotifierProvider(create: (_) => TareasProvider()),
        ChangeNotifierProvider(create: (_) => ProgramaProvider()),
      ],
      child: MaterialApp(
        title: 'FUNDECODES',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.theme,
        home: const AuthGate(),
      ),
    );
  }
}

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<AuthProvider>().checkSession();
    });
  }

  @override
  Widget build(BuildContext context) {
    return Consumer<AuthProvider>(
      builder: (context, auth, _) {
        switch (auth.status) {
          case AuthStatus.initial:
          case AuthStatus.loading:
            return const Scaffold(
              body: Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    CircularProgressIndicator(),
                    SizedBox(height: 16),
                    Text('Cargando...', style: TextStyle(color: Colors.grey)),
                  ],
                ),
              ),
            );
          case AuthStatus.authenticated:
            if (auth.user!.isEncargado) return const EncargadoHomeScreen();
            return const VoluntarioHomeScreen();
          case AuthStatus.unauthenticated:
          case AuthStatus.error:
            return const LoginScreen();
        }
      },
    );
  }
}
