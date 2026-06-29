import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'pages/user_detail.dart';
import 'pages/user_form.dart';
import 'pages/user_list.dart';
import '../../utils/routes.dart';

class UserRoutes {
  UserRoutes._();
  static String users = '/users';
  static String detail = 'detail';
  static String form = '/form';

  static final List<GoRoute> goroutes = <GoRoute>[
    //Routes.pageFadeTrans(detail, const UserDetail()),
    Routes.pageFadeTrans(form, const UserForm()),
    Routes.pageFadeTrans(users, const UserListPage())
  ];

  static final List<StatefulShellBranch> branches = [
    //Routes.shellBranch('Use Detail', detail, const UserDetail()),
    Routes.shellBranch('User Form', form, const UserForm(), []),
    Routes.shellBranch('Users List', users, const UserListPage(), [
      GoRoute(
        name: 'User Detail',
        path: ':did',
        pageBuilder: (context, state) {
          return MaterialPage(child: UserDetailPage(
            id: state.pathParameters['did']!,
          ));
        } 
      ) 
    ])
  ];
}
