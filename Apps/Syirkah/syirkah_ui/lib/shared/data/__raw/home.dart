/* import 'package:adaptive_screen/device_info.dart';
import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:syirkah/utils/modules/modules.dart';
import 'package:kayys_components/kayys_components.dart';

import '../../../layout/adaptive_layout.dart';
import '../../../data/data.dart';
import '../../../utils/modules/modules_registry.dart';
import '../../auth/blogic/auth_bloc.dart';
import '../../settings/settings_bloc.dart';
import '../../dashboard/bloc/menu_bloc.dart';
import '../../../widgets/dropdown_widget.dart';
import '../../../widgets/profile_widget.dart';

class HomePage extends ConsumerStatefulWidget {
  const HomePage({Key? key, required this.navigationShell}) : super(key: key);
  final StatefulNavigationShell navigationShell;
  //final Widget child;
  @override
  HomePageState createState() => HomePageState();
}

class HomePageState extends ConsumerState<HomePage> {
  int pageIndex = 0;
  String account = 'Fulan';
  String title = 'Dashboard';
  List<Menu> menus = [];
  bool _isSearchExpanded = false;
  Locale _locale = const Locale('id', 'ID'); // Default locale
  Locale? _selectedLanguage;

  var isConnected = true;

  @override
  void initState() {
    super.initState();
    _selectedLanguage = _locale;
  }

  void _changeLocale(Locale locale) {
    setState(() {
      _locale = locale;
      _selectedLanguage = locale;
    });
  }

  @override
  void dispose() {
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    menus = ModulesRegistry.routes(context);
    var settings = ref.watch(settingsBloc);
    return SafeArea(
        child: AdaptiveLayout(
      title: const Text('Golok...'),
      actions: header(context, title, settings),
      currentIndex: pageIndex,
      menuItems: menus,
      body: widget.navigationShell,
      onMenuClick: (menu) {
        context.go(menu.path!);
      },
      onBottomTap: (value) => setState(() {
        pageIndex = value;
      }),
      //floatingActionButton: _hasFAB ? _buildFab(context) : null,
    ));
  }

  List<Widget> header(context, title, settings) => [
        // Search Bar
        IconButton(
          icon: const Icon(Icons.search),
          onPressed: () {
            setState(() {
              _isSearchExpanded = !_isSearchExpanded;
            });
          },
        ),
        AnimatedContainer(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.white,
              shape: BoxShape.rectangle),
          duration: const Duration(milliseconds: 250),
          height: 40,
          width: _isSearchExpanded ? 150 : 0,
          child: _isSearchExpanded
              ?  TextField(
                  decoration: InputDecoration(
                    hintText: AppLocalizations.of(context)!.search,
                    border: InputBorder.none,
                    contentPadding: const EdgeInsets.symmetric(horizontal: 10),
                  ),
                )
              : null,
        ),

        // Title
        //if (!DeviceScreen.isPhone(context)) Text(title),

        // Space
        if (!DeviceScreen.isPhone(context))
          Spacer(flex: DeviceScreen.isLargeScreen(context) ? 2 : 1),

        // Switch them button
        IconButton(
            splashRadius: 15,
            icon: settings.isLightTheme
                ? const Icon(Icons.dark_mode)
                : const Icon(Icons.light_mode),
            onPressed: () => ref.read(settingsBloc).switchTheme()),

        // Switch language menu
        /* Dropdown(items: [
          DropdownItem(
              title: 'Bahasa',
              onTap: () => ref.read(settingsBloc).switchLocale('ID')),
          DropdownItem(
              title: 'English',
              onTap: () => ref.read(settingsBloc).switchLocale('EN'))
        ]), */
        localeSwitch(),
        const SizedBox(
          width: 10,
        ),
        // Profile Menu
        profileMenu(),
        const SizedBox(
          width: 20,
        )
        /*  if (!DeviceScreen.isLargeScreen(context))
          IconButton(
            icon: const Icon(Icons.menu),
            onPressed: ref.read(menuBloc).controlMenu,
          ),
        ProfileCard(
          accountName: account,
          onTap: () => _handleSignOut(context),
        ), */
      ];

  bool get _hasFAB {
    if (pageIndex == 2) return false;
    return true;
  }

  FloatingActionButton _buildFab(BuildContext context) {
    return FloatingActionButton(
      child: const Icon(Icons.chat_rounded),
      onPressed: () => _handleFabPressed(),
    );
  }

  void _handleFabPressed() {}

  _showLogoutDialog() {
    showDialog(
      context: context,
      builder: (BuildContext context) {
        return AlertDialog(
          title:  Text(AppLocalizations.of(context)!.sign_out),
          content:  Text(AppLocalizations.of(context)!.want_sign_out),
          actions: <Widget>[
            TextButton(
              onPressed: () => Navigator.of(context).pop(),
              child:  Text(AppLocalizations.of(context)!.cancel),
            ),
            TextButton(
              onPressed: () {
                ref.read(loginState.notifier).logout(context);
              },
              child:  Text(AppLocalizations.of(context)!.sign_out),
            ),
          ],
        );
      },
    );
  }

  Future<void> _handleSignOut(context) async {
    //ref.watch(authBloc.notifier).signOut();
    //var shouldSignOut = await (
    showDialog<bool>(
      context: context,
      builder: (context) => AlertDialog(
        title:  Text(AppLocalizations.of(context)!.want_sign_out),
        actions: [
          TextButton(
            child: const Text('No'),
            onPressed: () {
              //  Navigator.of(context).pop(false);
            },
          ),
          TextButton(
            child: const Text('Yes'),
            onPressed: () {
              // ref.watch(authBloc.notifier).signOut();
            },
          ),
        ],
      ),
    );
  }

  localeSwitch() =>
      // Locale Switch Button

      DropdownButton<Locale>(
        value: _locale,
        //icon: const Icon(Icons.language),
        items: [
          DropdownMenuItem(
            value: const Locale('id', 'ID'),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/flags/id.jpg',
                      width: 25,
                      height: 15,
                    )),
                const SizedBox(width: 8),
                const Text('ID'),
              ],
            ),
          ),
          DropdownMenuItem(
            value: const Locale('en', 'US'),
            child: Row(
              children: [
                IconButton(
                    onPressed: () {},
                    icon: Image.asset(
                      'assets/flags/en.jpg',
                      width: 25,
                      height: 15,
                    )),
                const SizedBox(width: 8),
                const Text('EN'),
              ],
            ),
          ),
        ],
        onChanged: (newValue) {
          setState(() {
            _selectedLanguage = newValue;
            _changeLocale(newValue!);
            ref
                .read(settingsBloc)
                .switchLocale(_selectedLanguage!.languageCode);
          });
        },
      );

  profileMenu() => PopupMenuButton(
        onSelected: (value) {
          print('Selected Value: $value');
        },
        itemBuilder: (context) => [
          const PopupMenuItem(
            value: 'profile',
            child: Text('Profile'),
          ),
          const PopupMenuItem(
            value: 'settings',
            child: Text('Settings'),
          ),
          PopupMenuItem(
            value: 'logout',
            onTap: _showLogoutDialog,
            child: const Text('Logout'),
          ),
        ],
        child: isConnected
            ? const CircleAvatar(
                backgroundImage: NetworkImage(
                    'https://images.unsplash.com/photo-1535713875002-d1d0cf377fde?ixlib=rb-4.0.3&ixid=MnwxMjA3fDB8MHxwaG90by1wYWdlfHx8fGVufDB8fHx8&auto=format&fit=crop&w=1170&q=80'),
              )
            : const Icon(Icons.person),
      );
}
 */