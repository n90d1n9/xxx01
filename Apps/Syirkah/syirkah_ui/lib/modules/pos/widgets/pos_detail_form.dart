import 'package:flutter/material.dart';

class PosDetailForm extends StatelessWidget {
  final double? width;
  final double? height;
  final String struckNo;
  const PosDetailForm({super.key, this.struckNo = '', this.width, this.height});

 

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
            
            field('customerType', 'Jenis Pelanggan'),
            field('customer', 'Pelanggan'),
            field('member', 'Member'),
            field('discount', 'Discount'),
            
            field('itemTotal', 'Jumlah Item'),
            field('description', 'Keterangan'),
           // radioPPN()
          ]),
        ));
  }

  Widget field(id, lable) {
    return Container(
        padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
        width: 250,
        height: 50,
        child: TextField(
            style: const TextStyle(),
            decoration: InputDecoration(
                label: Text(
              lable, //style: const TextStyle(fontSize: 12),
            )),
            // keyboardType: TextInputType.phone,
            onChanged: (value) => {} //field.didChange(value),
            ));
  }

  Widget field2(id, lable) {
    return FormField<String?>(
     // name: id,
      builder: (FormFieldState field) {
        return Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              //Text(lable),
              Container(
                  padding: const EdgeInsets.fromLTRB(0, 0, 0, 0),
                  width: 200,
                  height: 50,
                  child: TextField(
                    decoration: InputDecoration(
                        label: Text(
                      lable,
                      style: const TextStyle(fontSize: 9),
                    )),
                    // keyboardType: TextInputType.phone,
                    onChanged: (value) => field.didChange(value),
                  ))
            ]);
      },
    );
  }

}
