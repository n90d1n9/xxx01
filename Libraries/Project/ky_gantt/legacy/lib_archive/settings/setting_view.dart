import 'package:flutter/material.dart';

class SettingView extends StatelessWidget {
  
  const SettingView({super.key});

  @override
  Widget build(BuildContext context) {
    return Column(children: [
      SwitchListTile.adaptive(
                value: showDaysRow,
                title: const Text('Show Days Row ?'),
                onChanged: (v) => setState(() => showDaysRow = v),
              ),
              SwitchListTile.adaptive(
                value: showStickyArea,
                title: const Text('Show Sticky Area ?'),
                onChanged: (v) => setState(() => showStickyArea = v),
              ),
              SwitchListTile.adaptive(
                value: customStickyArea,
                title: const Text('Custom Sticky Area ?'),
                onChanged: (v) => setState(() => customStickyArea = v),
              ),
              SwitchListTile.adaptive(
                value: customWeekHeader,
                title: const Text('Custom Week Header ?'),
                onChanged: (v) => setState(() => customWeekHeader = v),
              ),
              SwitchListTile.adaptive(
                value: customDayHeader,
                title: const Text('Custom Day Header ?'),
                onChanged: (v) => setState(() => customDayHeader = v),
              ),
    ],);
  }
}