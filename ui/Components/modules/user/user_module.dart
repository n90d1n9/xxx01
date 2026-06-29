import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart';
import 'package:go_router/go_router.dart';
import 'package:syirkah/modules/user/pages/user_detail.dart';
import 'package:kayys_components/kayys_components.dart';

import '../../utils/modules/module_model.dart';
import '../../utils/routes.dart';
import 'pages/user_form.dart';
import 'pages/user_list.dart';
import 'user_routes.dart';

class UserModule implements Module {
  @override
  String? name = 'User';

  @override
  pages(BuildContext context) => [
        Menu(
            title: AppLocalizations.of(context)!.users,
            icon: "home",
            path: "/users",
            items: const [
              Menu(title: "Users", icon: "home", path: "/users"),
              Menu(title: "Users Detail", icon: "home", path: "/users/3")
            ]),
      ];

  @override
  String? baseRoute;

  @override
  List<StatefulShellBranch> branches() {
    return [
      Routes.shellBranch('User Form', '/form', const UserForm(), []),
      Routes.shellBranch('Users List', '/users', const UserListPage(), [
        GoRoute(
            name: 'User Detail',
            path: ':did',
            pageBuilder: (context, state) {
              return MaterialPage(
                  child: UserDetailPage(
                id: state.pathParameters['did']!,
              ));
            })
      ])
    ];
  }

  @override
  List<GoRoute> goroutes() {
    return UserRoutes.goroutes;
  }

  @override
  void services() {}
}
