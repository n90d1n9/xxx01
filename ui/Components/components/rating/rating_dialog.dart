import 'package:kayys_components/app_properties.dart';
import 'package:flutter/material.dart';
import 'package:flutter_rating_bar/flutter_rating_bar.dart';

class RatingDialog extends StatelessWidget {
  final String hint;
  final String productName;
  final Color feedBGColor;
  final String congratText;
  final String textToProduct;

  final String btnLabel;

  final double initialRating;

  final Function(double) onRatingUpdate;

  final Function() onTap;

  const RatingDialog(
      {super.key,
      this.hint = 'Say something about the product.',
      this.feedBGColor = Colors.black12,
      required this.productName,
      this.congratText = 'Thank You!',
      this.textToProduct = 'You rated ',
      this.btnLabel = "Pay Now",
      this.initialRating = 1,
      required this.onRatingUpdate,
      required this.onTap});

  @override
  Widget build(BuildContext context) {
    double width = MediaQuery.of(context).size.width;

    Widget payNow = InkWell(
      onTap: onTap,
      child: Container(
        height: 60,
        width: width / 1.5,
        decoration: BoxDecoration(
            gradient: mainButton,
            boxShadow: const [
              BoxShadow(
                color: Color.fromRGBO(0, 0, 0, 0.16),
                offset: Offset(0, 5),
                blurRadius: 10.0,
              )
            ],
            borderRadius: BorderRadius.circular(9.0)),
        child: Center(
          child: Text(btnLabel,
              style: const TextStyle(
                  color: Color(0xfffefefe),
                  fontWeight: FontWeight.w600,
                  fontStyle: FontStyle.normal,
                  fontSize: 20.0)),
        ),
      ),
    );

    return SingleChildScrollView(
      physics: const ClampingScrollPhysics(),
      child: Container(
          decoration: const BoxDecoration(
              borderRadius: BorderRadius.all(Radius.circular(10)),
              color: Colors.grey),
          padding: const EdgeInsets.all(24.0),
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            Text(
              congratText,
              style: const TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16.0),
              child: RichText(
                text: TextSpan(
                    style: const TextStyle(
                      fontFamily: 'Montserrat', //color: Colors.grey
                    ),
                    children: [
                      TextSpan(
                        text: textToProduct,
                      ),
                      TextSpan(
                          text: productName,
                          style: TextStyle(
                              fontWeight: FontWeight.bold,
                              color: Colors.grey[600]))
                    ]),
              ),
            ),
            RatingBar(
              itemSize: 32,
              allowHalfRating: false,
              initialRating: initialRating,
              itemPadding: const EdgeInsets.symmetric(horizontal: 4.0),
              onRatingUpdate: onRatingUpdate, //(value) {},
              ratingWidget: RatingWidget(
                empty: const Icon(Icons.favorite_border,
                    color: Color(0xffFF8993), size: 20),
                full: const Icon(
                  Icons.favorite,
                  color: Color(0xffFF8993),
                  size: 20,
                ),
                half: const SizedBox(),
              ),
            ),
            feedbackField(),
            payNow
          ])),
    );
  }

  Widget feedbackField() => Container(
      margin: const EdgeInsets.symmetric(vertical: 16.0),
      padding: const EdgeInsets.all(16.0),
      decoration: BoxDecoration(
          color: feedBGColor,
          borderRadius: const BorderRadius.all(Radius.circular(5))),
      child: TextField(
        controller: TextEditingController(),
        decoration: InputDecoration(
            border: InputBorder.none,
            contentPadding: EdgeInsets.zero,
            hintText: hint),
        style: TextStyle(fontSize: 12, color: Colors.grey[600]),
        maxLength: 200,
      ));
}
