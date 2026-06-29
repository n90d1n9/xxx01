import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kayys_components/models/menu.dart';
//import 'package:syirkah/modules/utility/image_editor/pages/bingkai_page.dart';


import '../../../core/modules/module_model.dart';

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
        /* GoRoute(
            path: '/imageEditor2',
            builder: (BuildContext context, GoRouterState state) =>
                const BingkaiPage()), */
      ];

  @override
  List<StatefulShellBranch> branches() => [
        /* Routes.shellBranch(
            'Image Editor', '/imageEditor', const ImageEditorPage(), []),
    Routes.shellBranch(
            'Mergeimage Page', '/img2',  MergeImagePage(), []), */
      ];
}
