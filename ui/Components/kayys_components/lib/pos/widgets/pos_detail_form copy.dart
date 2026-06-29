import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';

class PosDetailForm extends StatelessWidget {
  final double? width;
  final double? height;
  const PosDetailForm({super.key, this.width, this.height});

  get groupValue => null;

  @override
  Widget build(BuildContext context) {
    final formKey = GlobalKey<FormState>();

    return Form(
        key: formKey,
        child: Container(
          padding: const EdgeInsets.fromLTRB(5, 10, 5, 5),
          width: width,
          height: height,
          child: Column(children: [
            FormField<String?>(
            //  name: 'noStruck',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('No Struck'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
             // name: 'customerType',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jenis Pelanggan'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
              //name: 'customer',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Pelanggan'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
              //name: 'member',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Member'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
             // name: 'discount',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Discount'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
              //name: 'netto',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Netto'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
              //name: 'total',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Total Bayar'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
              //name: 'itemTotal',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Jumlah Item'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            FormField<String?>(
              //name: 'description',
              builder: (FormFieldState field) {
                return Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: [
                      const Text('Keterangan'),
                      Container(
                          padding: const EdgeInsets.fromLTRB(5, 5, 0, 0),
                          width: 200,
                          child: CupertinoTextField(
                            keyboardType: TextInputType.phone,
                            onChanged: (value) => field.didChange(value),
                          ))
                    ]);
              },
            ),
            radioPPN()
          ]),
        ));
  }

  Widget radioPPN() {
    const textStyle = TextStyle(fontSize: 1);
    return Row(
      children: [
        Row(children: [
          Radio(value: true, groupValue: groupValue, onChanged: (val) => {}),
          const Text('Non PPN', style: textStyle,)
        ]),
        Row(children: [
          Radio(value: true, groupValue: groupValue, onChanged: (val) => {}),
          const Text('Include PPN', style: textStyle,)
        ]),
        Row(children: [
          Radio(value: true, groupValue: groupValue, onChanged: (val) => {}),
          const Text('Exclude PPN', style: textStyle,)
        ]),
      ],
    );
  }

  Widget ppnRadio(width) {
    const textStyle = TextStyle(fontSize: 12);
    return Expanded(
        flex: 1,
        child: SizedBox(
            width: width,
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                FormField<bool>(
                  //name: 'nonePPN',
                 // onChanged: (val) => debugPrint(val.toString()),
                  builder: (FormFieldState field) {
                    return RadioListTile(
                      title: const Text(
                        'Non PPN',
                        style: textStyle,
                      ),
                      value: true,
                      groupValue: groupValue,
                      onChanged: (value) => field.didChange(value),
                    );
                  },
                ),
                FormField<bool>(
                 // name: 'includePPN',
                  //onChanged: (val) => debugPrint(val.toString()),
                  builder: (FormFieldState field) {
                    return RadioListTile(
                      title: const Text(
                        'Include PPN',
                        style: textStyle,
                      ),
                      value: true,
                      groupValue: groupValue,
                      onChanged: (value) => field.didChange(value),
                    );
                  },
                ),
                FormField<bool>(
                 // name: 'excludePPN',
                 // onChanged: (val) => debugPrint(val.toString()),
                  builder: (FormFieldState field) {
                    return RadioListTile(
                      title: const Text(
                        'Exclude PPN',
                        style: textStyle,
                      ),
                      value: true,
                      groupValue: groupValue,
                      onChanged: (value) => field.didChange(value),
                    );
                  },
                ),
              ],
            )));
  }
}
