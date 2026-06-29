import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:go_router/go_router.dart';
import 'package:intl/intl.dart';
//import 'package:slide_digital_clock/slide_digital_clock.dart';
import 'package:syirkah/modules/pos/logic/keyboard_input.dart';
import 'package:syirkah/modules/pos/widgets/textfield/search_bar.dart';

import 'display_amount.dart';

class PosHeader extends ConsumerWidget {
  final String? keyValue;
  final double? height;
  final double? amount;
  const PosHeader({super.key, this.keyValue, this.amount, this.height});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    const dateStyle = TextStyle(fontSize: 16, color: Colors.white);
    // final f =  DateFormat('yyyy-MM-dd hh:mm');
    //var currentDate = f.format(DateTime.now());
    var currentDate = DateFormat.yMMMd().format(DateTime.now());
    return Container(
      padding: const EdgeInsets.fromLTRB(10, 5, 20, 5),
      decoration: const BoxDecoration(
        color: Colors.lightBlueAccent,
      ),
      // height: height,
      child: Column(children: [
        IconButton(onPressed: ()=> context.go('/'), icon: const Icon(Icons.arrow_back)),
        Row(
          mainAxisAlignment: MainAxisAlignment.end,
          children: [
            label(context, currentDate, dateStyle, ref),
            const Text('Fulan'),
            const Text('Logout')
          ],
        ),
        Expanded(
            flex: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                logo(),
                const GSearchBar(
                  height: 50,
                  width: 200,
                  borderRadius: 10,
                  hintText: 'Cari product...',
                ),
                const GSearchBar(
                  height: 50,
                  width: 200,
                  fillColor: Colors.white,
                  borderRadius: 10,
                  hintText: 'Cari pelanggan...',
                ),
                DisplayAmount(height: 60, width: 400, amount: amount!)
              ],
            )),
      ]),
    );
  }

//goto(path) => context.go(path);

  Widget logo() => const FlutterLogo(
        size: 70,
      );


  Widget label(context, currentDate, dateStyle, ref) {
    return Container(
        margin: const EdgeInsets.fromLTRB(0, 0, 20, 0),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Text(ref.watch(keyboardInputProvider)),
            Row(children: [
              Text(
                '$currentDate',
                style: dateStyle,
              ),
              Text(
                ' | ',
                style: dateStyle,
              ),
              clock(context, dateStyle),
            ])
          ],
        ));
  }

  Widget clock(context, dateStyle) => const Row(
        mainAxisAlignment: MainAxisAlignment.start,
        children: [
          /* DigitalClock(
            hourMinuteDigitTextStyle: dateStyle,
            colon: const Text(
              ':',
              style: TextStyle(fontSize: 18, color: Colors.white),
            ),
            secondDigitTextStyle: Theme.of(context)
                .textTheme
                .bodySmall!
                .copyWith(color: Colors.white),
          ), */
        ],
      );
}
