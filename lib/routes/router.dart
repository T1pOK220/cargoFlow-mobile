import 'package:cargo_flow/screens/login_screen.dart';
import 'package:cargo_flow/screens/registration_screen.dart';
import "package:cargo_flow/screens/cargos_screen.dart";
import 'package:go_router/go_router.dart';
import 'package:provider/provider.dart';

import '../widgets/main_shell.dart';

import 'package:cargo_flow/providers/auth_provider.dart';
import 'package:cargo_flow/screens/create_cargo_screen.dart';
import 'package:cargo_flow/screens/vehicles_screen.dart';
import 'package:cargo_flow/screens/vehicle_details_screen.dart';
import 'package:cargo_flow/screens/cargo_details_screen.dart';
import 'package:cargo_flow/screens/profile_screen.dart';
import 'package:cargo_flow/screens/create_vehicle_screen.dart';
import 'package:cargo_flow/screens/update_vehicle_screen.dart';
import 'package:cargo_flow/models/vehicle.dart';
import 'package:cargo_flow/screens/home_screen.dart';

final appRouter = GoRouter(
  initialLocation: '/login',
  redirect: (context, state) {
    final loggedIn = context.read<AuthProvider>().isAuthorized;
    final goingToAuth =
        state.matchedLocation == '/login' ||
        state.matchedLocation == '/registration';

    if (!loggedIn && !goingToAuth) return '/login';
    if (loggedIn && goingToAuth) return '/home';
    return null;
  },
  routes: [
    GoRoute(
      path: '/registration',
      builder: (context, state) => const RegistrationScreen(),
    ),
    GoRoute(path: '/login', builder: (context, state) => const LoginScreen()),
    GoRoute(
      path: '/cargos/info/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;

        return CargoDetailsScreen(id: int.parse(id));
      },
    ),
    GoRoute(
      path: '/vehicles/edit',
      builder: (context, state) =>
          VehicleEditScreen(vehicle: state.extra as Vehicle),
    ),
    GoRoute(
      path: '/vehicles/:id',
      builder: (context, state) {
        final id = state.pathParameters['id']!;
        return VehicleDetailsScreen(id: int.parse(id));
      },
    ),
    GoRoute(
      path: '/vehicle/add',
      builder: (context, state) => const VehicleCreateScreen(),
    ),
    StatefulShellRoute.indexedStack(
      builder: (context, state, navigationShell) {
        return MainShell(navigationShell: navigationShell);
      },
      branches: [
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/home',
              builder: (context, state) => const HomeScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cargos',
              builder: (context, state) => const CargosScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/cargo/create',
              builder: (context, state) => const CreateCargoScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/vehicles',
              builder: (context, state) => const VehiclesScreen(),
            ),
          ],
        ),
        StatefulShellBranch(
          routes: [
            GoRoute(
              path: '/profile',
              builder: (context, state) => const ProfileScreen(),
            ),
          ],
        ),
      ],
    ),
  ],
);
