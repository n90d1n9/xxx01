import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:share_plus/share_plus.dart';
import 'package:syirkah/modules/social_preneur/widgets/data.dart';
import 'package:go_router/go_router.dart';

import '../widgets/post_item.dart';
import '../widgets/post_search.dart';

class BursaSyirkahPage extends ConsumerStatefulWidget {
  const BursaSyirkahPage({super.key});

  @override
  ConsumerState<BursaSyirkahPage> createState() => _BursaSyirkahPageState();
}

class _BursaSyirkahPageState extends ConsumerState<BursaSyirkahPage> {
  final List<PostModel> list = listPost;

  @override
  Widget build(BuildContext contextw) {
    return Scaffold(
        appBar: AppBar(
          actions: [
            IconButton(
                onPressed: () {
                  context.go('/');
                },
                icon: const Icon(Icons.arrow_back_ios_rounded))
          ],
        ),
        body: Container(
            color: Colors.black12,
            child: SingleChildScrollView(
                child: Column(
              children: [const PostSearch(), ...items(list)],
            ))));
  }

  List<PostItem> items(List<PostModel> list) {
    List<PostItem> postItems = [];
    for (var el in list) {
      postItems.add(PostItem(
        data: el,
        onLikePressed: (i) {},
        onSharePressed: () {
          Share.share('check out my website https://syirkah.com');
        },
      ));
    }
    return postItems;
  }
}
