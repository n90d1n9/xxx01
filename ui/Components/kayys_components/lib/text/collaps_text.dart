import 'package:flutter/material.dart';

class CollapsText extends StatelessWidget {
  final String? content;
  final double fontSize;
  final String seeMoreText;
  final String seeLessText;
  final ValueNotifier<bool> expanded = ValueNotifier(false);
  final int maxLinesToShow;
  final TextStyle style;

  CollapsText(
      {super.key,
      this.content,
      this.seeMoreText = 'See More',
      this.seeLessText = 'See Less',
      this.maxLinesToShow = 3,
      this.style = const TextStyle(
        fontStyle: FontStyle.normal,
        fontWeight: FontWeight.w400,
        fontSize: 2,
        color: Colors.black,
      ),
      this.fontSize = 14.0});

  @override
  Widget build(BuildContext context) {
    final TextSpan textSpan = TextSpan(
      text: content ?? "",
      style: style,
    );

    final TextPainter textPainter = TextPainter(
      text: textSpan,
      maxLines: expanded.value ? null : maxLinesToShow,
      textDirection: TextDirection.ltr,
    );

    textPainter.layout(maxWidth: MediaQuery.of(context).size.width);

    final int numberOfLines = textPainter.computeLineMetrics().length;

    return ValueListenableBuilder(
      valueListenable: expanded,
      builder: (context, values, _) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            LayoutBuilder(
              builder: (BuildContext context, BoxConstraints constraints) {
                if (!expanded.value && numberOfLines >= maxLinesToShow) {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content ?? "",
                        maxLines: maxLinesToShow,
                        overflow: TextOverflow.ellipsis,
                        style: style,
                      ),
                      /* See More :: type 1 - See More | 2 - See Less */
                      SeeMoreLessWidget(
                        textData: seeMoreText,
                        type: 1,
                        section: 1,
                        onSeeMoreLessTap: () {
                          expanded.value = true;
                        },
                      ),
                      /* See More :: type 1 - See More | 2 - See Less */
                    ],
                  );
                } else {
                  return Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        content ?? "",
                        style: style,
                      ),
                      if (expanded.value && numberOfLines >= maxLinesToShow)
                        /* See Less :: type 1 - See More | 2 - See Less */
                        SeeMoreLessWidget(
                          textData: seeLessText,
                          type: 2,
                          section: 1,
                          onSeeMoreLessTap: () {
                            expanded.value = false;
                          },
                        ),
                      /* See Less :: type 1 - See More | 2 - See Less */
                    ],
                  );
                }
              },
            ),
          ],
        );
      },
    );
  }
}

class SeeMoreLessWidget extends StatelessWidget {
  final String? textData;
  final int? type;
  final Function? onSeeMoreLessTap;
  final int? section;

  const SeeMoreLessWidget({
    super.key,
    required this.textData,
    required this.type,
    required this.onSeeMoreLessTap,
    required this.section,
  });

  @override
  Widget build(BuildContext context) {
    return Align(
      alignment: Alignment.centerRight,
      child: Padding(
        padding: const EdgeInsets.only(top: 12.0),
        child: InkWell(
          onTap: () {
            if (onSeeMoreLessTap != null) {
              onSeeMoreLessTap!();
            }
          },
          child: Text.rich(
            softWrap: true,
            style: const TextStyle(
              fontStyle: FontStyle.normal,
              fontWeight: FontWeight.w500,
              fontSize: 13.0,
              color: Colors.blue,
            ),
            textAlign: TextAlign.start,
            TextSpan(
              text: "",
              children: [
                TextSpan(
                  text: textData,
                  style: const TextStyle(
                    fontStyle: FontStyle.normal,
                    fontWeight: FontWeight.w500,
                    fontSize: 10.0,
                    color: Colors.blue,
                  ),
                ),
                const WidgetSpan(
                  child: SizedBox(
                    width: 3.0,
                  ),
                ),
                WidgetSpan(
                  child: Icon(
                    (type == 1)
                        ? Icons.keyboard_arrow_down
                        : Icons.keyboard_arrow_up,
                    color: Colors.blue,
                    size: 17.5,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // ... (see the full SeeMoreLessWidget code below)
}
