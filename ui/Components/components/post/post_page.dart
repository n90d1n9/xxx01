import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

import 'post_item.dart';
import 'post_search.dart';

class PostPage extends StatefulWidget {
  const PostPage({super.key, required this.list});
  final List<PostModel> list;
  @override
  State<PostPage> createState() => _PostPageState();
}

class _PostPageState extends State<PostPage> {
  @override
  Widget build(BuildContext context) {
    return Container(
        color: Colors.black12,
        child: SingleChildScrollView(
            child: Column(
          children: [const PostSearch(), ...items(widget.list)],
        )));
  }

  List<PostItem> items(List<PostModel> list) {
    List<PostItem> postItems = [];
    for (var el in list) {
      postItems.add(PostItem(
        data: el,
        onLikePressed: (i) {},
      ));
    }
    return postItems;
  }
}

/* 
Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.home),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.people),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.add),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.notifications),
              ),
              IconButton(
                onPressed: () {},
                icon: const Icon(Icons.work),
              ),
            ],
          ),
        ),
 */

/* Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: [
              ElevatedButton(
                onPressed: () {},
                child: const Text('Like'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Comment'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Repost'),
              ),
              ElevatedButton(
                onPressed: () {},
                child: const Text('Send'),
              ),
            ],
          ),
        ), */
/* 
Padding(
          padding: const EdgeInsets.all(16.0),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    onPressed: () {},
                    icon: const Icon(Icons.thumb_up),
                  ),
                  const SizedBox(width: 8),
                  Text('39'),
                ],
              ),
              Text('1 repost'),
            ],
          ),
        ), */