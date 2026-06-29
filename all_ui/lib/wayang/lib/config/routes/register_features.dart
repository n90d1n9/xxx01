import 'package:go_router/go_router.dart';

import '../../core/features/features_base.dart';

List<FeaturesBase> registerFeatures() {
  return [];
}

registerBranches() {
  return [];
}

List<List<GoRoute>> registerRoutes() => [
  //AppModule().goroutes(),
  /*  ...GoRoute(
          path: '/signin',
          builder: (context, state) => ,
        ), */
  /* GoRoute(
          path: '/splash',
          builder: (BuildContext context, GoRouterState state) =>
              const SplashScreen(),
        ),
        GoRoute(
          path: '/introduction',
          builder: (context, state) => const IntroductionScreen(),
        ),


        GoRoute(
          path: '/forgot-password',
          builder: (context, state) => const ForgotPasswordPage(),
        ),
        GoRoute(
          path: '/',
          builder: (context, state) =>
              const FileManagerScreen() //const GalleryScreen(),
          ),
      GoRoute(
        path: '/detail/:id',
        builder: (context, state) {
          final id = state.pathParameters['id']!;
          return MediaDetailScreen(mediaId: id);
        },
      ),
      GoRoute(
        path: '/search',
        builder: (context, state) => const SearchScreen(),
      ),
      GoRoute(
        path: '/preview/:path',
        builder: (context, state) => FilePreviewScreen(
          filePath: state.pathParameters['path']!,
        ),
      ),
 */
];
