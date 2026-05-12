import 'package:go_router/go_router.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/screens/login_screen.dart';
import 'package:tenken_engiflow/presentation/screens/role_based_dashboard.dart';
import 'package:tenken_engiflow/presentation/screens/splash_screen.dart';

GoRouter createRouter(AuthProvider auth) => GoRouter(
      refreshListenable: auth,
      initialLocation: '/',
      redirect: (context, state) {
        final loading = auth.isLoading && auth.firebaseUser == null;
        final loggedIn = auth.firebaseUser != null;
        final loc = state.matchedLocation;

        // Still determining auth state — stay on splash
        if (loading) return null;

        // Not logged in and not already heading to login
        if (!loggedIn && loc != '/login') return '/login';

        // Logged in but stuck on splash or login
        if (loggedIn && (loc == '/' || loc == '/login')) return '/dashboard';

        return null;
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/login',
          builder: (context, state) => const LoginScreen(),
        ),
        GoRoute(
          path: '/dashboard',
          builder: (context, state) => const RoleBasedDashboard(),
        ),
      ],
    );
