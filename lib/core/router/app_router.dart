import 'package:go_router/go_router.dart';
import 'package:tenken_engiflow/presentation/providers/auth_provider.dart';
import 'package:tenken_engiflow/presentation/screens/login_screen.dart';
import 'package:tenken_engiflow/presentation/screens/public_home_screen.dart';
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

        if (loggedIn) {
          // Logged-in users bypass all public screens
          if (loc == '/' || loc == '/home' || loc == '/login') return '/dashboard';
          return null;
        }

        // Not logged in:
        if (loc == '/') return '/home'; // splash → public home
        if (loc == '/home' || loc == '/login') return null; // allowed public screens
        return '/home'; // anything else → public home
      },
      routes: [
        GoRoute(
          path: '/',
          builder: (context, state) => const SplashScreen(),
        ),
        GoRoute(
          path: '/home',
          builder: (context, state) => const PublicHomeScreen(),
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
