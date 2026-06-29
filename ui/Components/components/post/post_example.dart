import 'package:flutter/widgets.dart';
import 'package:kayys_components/components/post/post_item.dart';
import 'package:kayys_components/components/post/post_page.dart';

class PostListExample extends StatelessWidget {
  const PostListExample({super.key});

  @override
  Widget build(BuildContext context) {
    return PostPage(
      list: list,
    );
  }
}

List<PostModel> list = [
  PostModel(
      name: 'Aba Nahdhan',
      title: "Developer",
      subtitle: 'Ini subtitle',
      postAge: '3d',
      link: 'https://kayys.tech',
      content: 'ini adalah percobaan posting untuk melihat hasil nya di widget post item ini adalah percobaan posting untuk melihat hasil nya di widget post item ini adalah percobaan posting untuk melihat hasil nya di widget post item ini adalah percobaan posting untuk melihat hasil nya di widget post item ini adalah percobaan posting untuk melihat hasil nya di widget post item ini adalah percobaan posting untuk melihat hasil nya di widget post item',
      avatar: const NetworkImage('https://robohash.org/urang'),
      likes: 234),
  PostModel(
      name: 'Fulanah',
      title: "Developer",
      postAge: '3d',
      subtitle: 'Ini subtitle',
      content: 'ini adalah percobaan posting untuk melihat hasil nya di widget post item',
      avatar: const NetworkImage('https://robohash.org/urang'),
      likes: 234),
  PostModel(
      name: 'Si Paling',
      title: "Developer",
      postAge: '3d',
      subtitle: 'Ini subtitle',
      content: 'ini adalah percobaan posting untuk melihat hasil nya di widget post item',
      avatar: const NetworkImage('https://robohash.org/urang'),
      likes: 234),
  PostModel(
      name: 'Nama Aku',
      title: "Developer",
      postAge: '3d',
      link: 'https://kayys.tech',
      subtitle: 'Ini subtitle',
      content: 'ini adalah percobaan posting untuk melihat hasil nya di widget post item',
      avatar: const NetworkImage('https://robohash.org/urang'),
      likes: 234)
];
/* 
const Text(
                  'How to fetch a user’s birthday in a microservice-heavy environment. Source:'), */