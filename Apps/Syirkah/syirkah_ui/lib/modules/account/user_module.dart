import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:syirkah/modules/account/pages/profile_page.dart';
import 'package:syirkah/modules/account/pages/user_detail.dart';
import 'package:kayys_components/kayys_components.dart';

import '../../core/modules/module_model.dart';
import '../../core/routes/routes.dart';
import 'pages/user_form.dart';
import 'pages/user_list.dart';

class UserModule implements Module {
  @override
  String? name = 'User';
  static String users = '/users';
  static String detail = 'detail';
  static String form = '/form';

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
  List<StatefulShellBranch> branches() {
    return [
      Routes.shellBranch('Profile', '/profile', const ProfilePage(), []),
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
  List<GoRoute> goroutes() => [];

  @override
  void services() {}
}
