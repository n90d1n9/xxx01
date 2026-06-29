import 'package:flutter/widgets.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:syirkah/modules/pos/widgets/pos_button.dart';
import 'package:syirkah/modules/pos/widgets/pos_detail_form.dart';
import 'package:syirkah/modules/pos/widgets/pos_footer.dart';
import 'package:syirkah/modules/pos/widgets/pos_header.dart';
import 'package:syirkah/modules/pos/widgets/pos_layout.dart';
import 'package:syirkah/modules/pos/widgets/pos_numeric_key.dart';
import 'package:syirkah/modules/pos/widgets/pos_order.dart';
import 'package:syirkah/modules/pos/widgets/pos_subtotal.dart';

import '../../logic/amount.dart';
import '../../logic/button_key.dart';
import '../../logic/keyboard_input.dart';
import '../../widgets/table/table_data_model.dart';

class PosFnBLargePage extends ConsumerStatefulWidget {
  const PosFnBLargePage({super.key});

  @override
  ConsumerState<PosFnBLargePage> createState() => _PosFnBLargePageState();
}

class _PosFnBLargePageState extends ConsumerState<PosFnBLargePage> {
  @override
  Widget build(BuildContext context) {
    final fc = FocusNode();
    var mediaWidth = MediaQuery.of(context).size.width;
    var mediaHeight = MediaQuery.of(context).size.height;
    var orderWidth = mediaWidth * 0.50;
    var orderHeight = mediaHeight * 0.50;
    var formWidth = mediaWidth - orderWidth;
    final ww = ref.watch(buttonKeyProvider);
    ww.keyLabel;
    const columnWidths = {
      0: FixedColumnWidth(50),
      1: FixedColumnWidth(200),
      4: FixedColumnWidth(120),
      6: FixedColumnWidth(120),
    };

    var cellConfig = {
      0: TextAlign.center,
      4: TextAlign.center,
      3: TextAlign.center,
      2: TextAlign.center,
      5: TextAlign.center,
      6: TextAlign.center,
      7: TextAlign.center
    };

    List<List<GCell>> data = [
      [
        GCell(value: 1),
        GCell(value: 'ini item'),
        GCell(value: 5),
        GCell(value: 'Kg'),
        GCell(value: 4500000),
        GCell(value: 10),
        GCell(value: 23000),
        GCell(value: 4)
      ],
      [
        GCell(value: 2),
        GCell(value: 'ini item kedua'),
        GCell(value: 4),
        GCell(value: 'Kg'),
        GCell(value: 11500000),
        GCell(value: 7),
        GCell(value: 35000),
        GCell(value: 5)
      ]
    ];
    return KeyboardListener(
        focusNode: fc,
        autofocus: true,
        onKeyEvent: (value) {
          ref
              .read(keyboardInputProvider.notifier)
              .inputKey(value.logicalKey.keyId, value.logicalKey.keyLabel);
          // value.character!);
        },
        child: PosLayout(
          header: PosHeader(
            height: 200,
            amount: ref.watch(amountProvider),
          ),
          order: PosOrder(
            width: orderWidth,
            height: orderHeight,
            data: data,
            columnWidths: columnWidths,
            config: cellConfig,
          ),
          subtotal: const Subtotal(
            subtotal: 2800.0,
            tax: 20,
          ),
          detailForm: PosDetailForm(
            width: formWidth,
            height: orderHeight,
          ),
          button: const PosButton(),
          numericKeyboard: PosNumericKey(
            onTapBtn: (key) =>
                ref.read(buttonKeyProvider.notifier).inputKey(key, 4),
          ),
          footer: const PosFooter(),
        ));
  }
}
