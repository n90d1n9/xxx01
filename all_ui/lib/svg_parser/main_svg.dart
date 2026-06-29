import 'package:flutter/material.dart';

import 'svg/widgets/svg_painter_widget.dart';

void main() {
  runApp(
    MaterialApp(
      home: Scaffold(
        body: Center(
          child: SvgPainterWidget(
            svgCode: '''
            
<svg width="101px" height="61px" viewBox="0 0 101 61" version="1.1" xmlns="http://www.w3.org/2000/svg" xmlns:xlink="http://www.w3.org/1999/xlink">
    <g id="Page-1" stroke="none" stroke-width="1" fill="none" fill-rule="evenodd">
        <g id="Frame" transform="translate(-281, -539)" fill="#40E65F" fill-rule="nonzero" stroke="#979797">
            <path d="M381.5,539.5 L381.5,599.5 L314.454545,599.5 C305.354399,599.5 297.115763,596.142136 291.152163,590.713203 C285.188563,585.284271 281.5,577.784271 281.5,569.5 C281.5,561.215729 285.188563,553.715729 291.152163,548.286797 C297.115763,542.857864 305.354399,539.5 314.454545,539.5 L381.5,539.5 Z" id="Rectangle-2"></path>
        </g>
    </g>
</svg>
          ''',
            width: 400,
            height: 400,
            fit: BoxFit.contain,
          ),
        ),
      ),
    ),
  );
}
