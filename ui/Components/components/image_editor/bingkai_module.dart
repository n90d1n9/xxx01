import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kayys_components/models/menu.dart';
import 'package:syirkah/modules/image_editor/pages/image_editor_demo.dart';

import 'package:syirkah/utils/routes.dart';

import '../../utils/modules/module_model.dart';

class BingkaiModule implements Module {
  @override
  String? name = 'Dashboard';

  @override
  pages(BuildContext context) => [
        const Menu(title: 'Image Editor 2', path: '/imageEditor2'),
      ];

  @override
  services() {}

  @override
  goroutes() => [
        GoRoute(
            path: '/imageEditor2',
            builder: (BuildContext context, GoRouterState state) =>
                ImageEditorDemo()),
      ];

  @override
  List<StatefulShellBranch> branches() => [
        /* Routes.shellBranch(
            'Image Editor', '/imageEditor', const ImageEditorPage(), []),
    Routes.shellBranch(
            'Mergeimage Page', '/img2',  MergeImagePage(), []), */
      ];
}
