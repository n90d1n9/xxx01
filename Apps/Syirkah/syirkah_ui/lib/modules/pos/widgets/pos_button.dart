// ignore_for_file: avoid_print

import 'package:flutter/material.dart';

import 'button/gicon_button.dart';

class PosButton extends StatelessWidget {
  const PosButton({super.key});
  get groupValue => null;
  @override
  Widget build(BuildContext context) {
     
    return Expanded(
      //flex: 1,
      child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              GIconButton(
                  onPressed: (v) => print(''),
                  icon:Icons.paid,
                  label: 'Bayar'),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 5,0,0)),
              GIconButton(
                  onPressed: (v) => print(''),
                  icon:Icons.calculate,
                  label: 'Calculator'),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 5,0,0)),
              GIconButton(
                  onPressed: (v) => print(''),
                  radius: 50,
                  icon:Icons.perm_data_setting,
                  label: 'Calculator \n Ctrl-C'),
                  const Padding(padding: EdgeInsets.fromLTRB(0, 5,0,0)),
             /*  GIconButton(
                radius: 50,
                  onPressed: (v) => print(''),
                  icon:Icons.data_saver_on,
                  label: 'Calculator'),
              GIconButton(
                  onPressed: (v) => print(''),
                  icon: Icons.note,
                  label: 'Calculator'), */
            ],
          ),);
  }
}
