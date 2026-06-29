import 'package:go_router/go_router.dart';
import 'package:kayys_components/components/rating/rating_dialog.dart';
import 'package:flutter/material.dart';

class RatingDialogExample extends StatelessWidget {
  const RatingDialogExample({super.key});

  @override
  Widget build(BuildContext context) {
    // double width = MediaQuery.of(context).size.width;
    return RatingDialog(
      productName: 'Handphone alus',
      onRatingUpdate: (v) {
        print(v);
      },
      onTap: () async {
       context.go('/');
      },
    );
  }
}
