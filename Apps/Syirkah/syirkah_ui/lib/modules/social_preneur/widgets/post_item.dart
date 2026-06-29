import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:kayys_components/kayys_components.dart';

class PostItem extends StatefulWidget {
  final int startTotal;

  const PostItem(
      {super.key,
      required this.data,
      this.startTotal = 0,
      this.followText = 'Follow',
      this.visitMyWeb = 'See my Page',
      this.imageURL = '',
      required this.onSharePressed,
      required this.onLikePressed});
  final PostModel data;
  final Function(int) onLikePressed;
  final Function onSharePressed;
  final String imageURL;
  final String visitMyWeb;
  final String followText;

  @override
  State<PostItem> createState() => _PostItemState();
}

class _PostItemState extends State<PostItem> {
  void onTapTotalLikes() {}

  void onTapTotalComments() {}

  void onTapVisit() {}

  @override
  Widget build(BuildContext context) {
    return Container(
        padding: const EdgeInsets.fromLTRB(15, 0, 15, 5),
        margin: const EdgeInsets.fromLTRB(0, 5, 0, 5),
        color: Colors.white,
        child: Column(
          children: [
            topBar(),
            profile(context),
            content(context),
            feedbackInfo(),
            const Divider(
              thickness: 1.0,
              color: Colors.black12,
            ),
            bottomBar(widget.onSharePressed)
          ],
        ));
  }

  void onPressed() {
    
  }

  Widget topBar() => Row(
        mainAxisAlignment: MainAxisAlignment.end,
        children: [
          IconButton(onPressed: onPressed, icon: const Icon(Icons.more_horiz))
        ],
      );

  Widget profile(context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.start,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Column(children: [
              CircleAvatar(
                backgroundImage: NetworkImage(widget.imageURL),
                radius: 20,
              ),
              GButton(
                  label: '${widget.startTotal}',
                  labelPosition: GLabelPosition.right,
                  iconColor: Colors.yellow[300]!,
                  icon: Icons.star_rate_rounded,
                  onPressed: onPressed)
            ]),
            const SizedBox(width: 0),
            Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  widget.data.name!, 
                  style: Theme.of(context).textTheme.titleSmall
                  ), /* TextStyle(
                      fontSize: , fontWeight: FontWeight.bold),
                ), */
                Text(widget.data.title!),// style: Theme.of(context).textTheme.bodySmall),
                widget.data.link != null
                    ? RichText(
                        text: TextSpan(
                          
                          style: const TextStyle(color: Colors.black),
                         // style: Theme.of(context).listTileTheme.titleTextStyle,
                          text: widget.visitMyWeb,
                          recognizer: TapGestureRecognizer()
                            ..onTap = () => onTapVisit,
                        ),
                      )
                    : const SizedBox(),
                Text(
                  widget.data.postAge,
                  
                  style: const TextStyle(fontSize: 8.0),
                ),
              ],
            ),
            const Spacer(),
            GButton(
                label: widget.followText,
                spaceSize: 5,
                fontSize: 12,
                labelPosition: GLabelPosition.right,
                icon: Icons.group_add,
                onPressed: onPressed)
          ],
        ),
      );

  Widget content(context) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            CollapsText(content: widget.data.content,
            style: Theme.of(context).textTheme.bodySmall!,),
            /* TextStyle(
              fontSize: Theme.of(context).textTheme.bodySmall
            )), */
            const SizedBox(height: 16),
            widget.data.attachment != null
                ? attachmentWidget(widget.data.attachment!)
                : Container()
            //const SizedBox(height: 16),
          ],
        ),
      );

  Widget feedbackInfo() => Padding(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                const Icon(Icons.thumb_up),
                const SizedBox(width: 8),
                RichText(
                  text: TextSpan(
                    style: const TextStyle(color: Colors.black),
                    text: '${widget.data.likes} likes',
                    recognizer: TapGestureRecognizer()
                      ..onTap = () => onTapTotalLikes,
                  ),
                )
              ],
            ),
            RichText(
              text: TextSpan(
                style: const TextStyle(color: Colors.black),
                text: '${widget.data.comments} comments',
                recognizer: TapGestureRecognizer()
                  ..onTap = () => onTapTotalComments,
              ),
            )
          ],
        ),
      );

  Widget bottomBar(onSharePressed) => Padding(
        padding: const EdgeInsets.fromLTRB(0, 1, 0, 5),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: [
            GButton(
              icon: Icons.favorite,
              label: 'Like',
              onPressed: () {},
            ),
            GButton(
              label: 'Comment',
              icon: Icons.chat_rounded,
              onPressed: () {},
            ),

            /* TextButton(
              onPressed: () {},
              child: const Text('Repost'),
            ), */
            GButton(
              icon: Icons.share,
              label: 'Share',
              onPressed: onSharePressed                          
            )
          ],
        ),
      );

  Widget attachmentWidget(PostAttachment data) {
    return Container(
      height: 200,
      decoration: const BoxDecoration(
        color: Colors.white,
      ),

      //child: data,
    );
  }

  Widget likeThis() => const Padding(
        padding: EdgeInsets.all(16.0),
        child: Row(
          children: [
            CircleAvatar(
              radius: 20,
              backgroundColor: Colors.orange,
            ),
            SizedBox(width: 16),
            Text('likes this'),
          ],
        ),
      );
}

enum AttachmentType { images, link }

class AttachImage {
  final String? imagePath;
  final String? caption;
  AttachImage({this.caption, this.imagePath});
}

class PostAttachment {
  final List<AttachImage>? images;
  final String? description;
  final AttachmentType? type;

  PostAttachment({this.type, this.images, this.description});
}

class PostModel {
  final String? name;
  final String? title;
  final String? subtitle;
  final String content;
  final ImageProvider<Object>? avatar;
  final int likes;
  final int comments;
  final int reposts;
  final String postAge;
  final String? link;
  final PostAttachment? attachment;

  PostModel(
      {this.title,
      this.subtitle,
      this.content = '',
      this.avatar,
      this.comments = 0,
      this.reposts = 0,
      this.postAge = '',
      this.link,
      this.name,
      this.attachment,
      this.likes = 0});
}
