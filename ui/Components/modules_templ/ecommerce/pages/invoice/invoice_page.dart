import 'dart:math';

import 'package:flutter/material.dart';

class InvoiceScreen extends StatefulWidget {
  InvoiceScreen({Key? key}) : super(key: key);

  @override
  _InvoiceScreenState createState() => _InvoiceScreenState();
}

class _InvoiceScreenState extends State<InvoiceScreen> {
  @override
  Widget build(BuildContext context) {
    final textTheme = Theme.of(context).textTheme;
    return Scaffold(
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: SingleChildScrollView(
          child: Column(
            children: <Widget>[
              SizedBox(height: 30),
              Row(
                children: <Widget>[
                  RichText(
                    text: TextSpan(
                      children: [
                        TextSpan(text: "Hello, ", style: textTheme.headlineSmall),
                        TextSpan(
                          text: "Vince",
                          style: textTheme.headlineSmall!.copyWith(
                            fontWeight: FontWeight.w300,
                          ),
                        ),
                      ],
                    ),
                  ),
                  Spacer(),
                  Icon(
                    Icons.search,
                    color: Colors.black26,
                  )
                ],
              ),
              SizedBox(
                height: 24,
              ),
              ProgressTracker(textTheme: textTheme),
              SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: <Widget>[
                  Text(
                    "Ongoing Project",
                    style: textTheme.headlineSmall!.copyWith(
                      fontWeight: FontWeight.w600,
                    ),
                  ),
                  Text(
                    "See all",
                    style: TextStyle(
                      color: Colors.blue,
                      fontWeight: FontWeight.w600,
                    ),
                  )
                ],
              ),
              SizedBox(
                height: 12,
              ),
              Container(
                height: MediaQuery.of(context).size.height / 3.2,
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(
                    color: Colors.black12,
                  ),
                ),
                child: Column(
                  children: <Widget>[
                    ProjectClientName(textTheme: textTheme),
                    ProjectDescription(textTheme: textTheme),
                    Spacer(),
                    ProjectBudget(textTheme: textTheme)
                  ],
                ),
              ),
              SizedBox(height: 16),
              Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                      color: Color(0xFF597aff),
                      borderRadius: BorderRadius.circular(12)),
                  child: Row(
                    children: <Widget>[
                      Transform.rotate(
                        angle: pi / 1.2,
                        child: Text(
                          "#",
                          style: textTheme.headlineMedium!.copyWith(
                            color: Colors.white,
                          ),
                        ),
                      ),
                      SizedBox(
                        width: 16,
                      ),
                      Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: <Widget>[
                          Text(
                            "Engage with clients",
                            style: textTheme.titleMedium!.copyWith(
                              color: Colors.white,
                            ),
                          ),
                          SizedBox(
                            height: 4,
                          ),
                          Text(
                            "Juan slack channel",
                            style: textTheme.titleSmall!.copyWith(
                              color: Colors.white54,
                            ),
                          ),
                        ],
                      ),
                      Spacer(),
                      Container(
                        decoration: BoxDecoration(
                          color: Color(0xFF385be9),
                          borderRadius: BorderRadius.circular(6),
                        ),
                        padding: const EdgeInsets.all(8),
                        child: Text("Join now",
                            style: TextStyle(
                              color: Colors.white,
                            )),
                      )
                    ],
                  )),
            ],
          ),
        ),
      ),
    );
  }
}

class ProjectDescription extends StatelessWidget {
  const ProjectDescription({
    Key? key,
    @required this.textTheme,
  }) : super(key: key);

  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.all(8.0),
      child: Text(
        "Build the next Tiktok",
        style: textTheme!.titleSmall!.copyWith(
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }
}

class ProjectClientName extends StatelessWidget {
  const ProjectClientName({
    Key? key,
    @required this.textTheme,
  }) : super(key: key);

  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        CircleAvatar(
          child: Icon(
            Icons.person,
            color: Colors.white,
          ),
          backgroundColor: Color(0xFF3E53D2),
        ),
        SizedBox(
          width: 8,
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Text("Juan Dela Cruz", style: textTheme!.bodySmall),
            SizedBox(height: 4),
            Text("Posted yesterday",
                style: textTheme!.titleSmall!.copyWith(
                  color: Colors.black54,
                )),
          ],
        ),
        Spacer(),
        Container(
          decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              color: Color(0xFF15c7c4)),
          padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
          child: Text(
            "mobile",
            style: textTheme!.titleSmall!.copyWith(
              color: Colors.white,
            ),
          ),
        ),
      ],
    );
  }
}

class ProjectBudget extends StatelessWidget {
  const ProjectBudget({
    Key? key,
    @required this.textTheme,
  }) : super(key: key);

  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      margin: const EdgeInsets.all(8),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
          color: Color(0xFFE7EAF5).withOpacity(0.6),
          borderRadius: BorderRadius.circular(8)),
      child: Row(
        children: <Widget>[
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "PHP ",
                  style: textTheme!.headlineSmall!.copyWith(color: Colors.black54),
                ),
                TextSpan(
                  text: "80,000",
                  style: textTheme!.headlineSmall,
                ),
                TextSpan(
                  text: " /month",
                  style: textTheme!.titleSmall!.copyWith(color: Colors.black45),
                ),
              ],
            ),
          ),
          Spacer(),
          Container(
            padding: const EdgeInsets.symmetric(vertical: 4, horizontal: 12),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(24),
              border: Border.all(
                color: Color(0xFFb1c3e1),
              ),
            ),
            child: Text(
              "Contract",
              style: TextStyle(
                color: Colors.blue,
              ),
            ),
          ),
        ],
      ),
    );
  }
}

class ProgressTracker extends StatelessWidget {
  const ProgressTracker({
    Key? key,
    @required this.textTheme,
  }) : super(key: key);

  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceAround,
      children: <Widget>[
        EarningWidget(textTheme: textTheme!),
        Column(
          children: <Widget>[
            Container(
              height: MediaQuery.of(context).size.height / 10,
              width: MediaQuery.of(context).size.width / 2.3,
              padding: const EdgeInsets.only(left: 8),
              decoration: BoxDecoration(
                  color: Color(0xFFE7EAF5).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12)),
              child: Row(
                children: <Widget>[
                  Container(
                    padding: const EdgeInsets.all(12),
                    child: Text(
                      "98",
                      style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                            color: Colors.white,
                          ),
                    ),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(12),
                      color: Color(0xFF1E35F5).withOpacity(0.6),
                    ),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: <Widget>[
                      Padding(
                        padding: const EdgeInsets.only(
                            left: 8.0, top: 16, bottom: 8),
                        child: Text("Rank", style: textTheme!.bodySmall),
                      ),
                      Padding(
                        padding: const EdgeInsets.only(
                          left: 8,
                        ),
                        child: RichText(
                          text: TextSpan(
                            children: [
                              TextSpan(
                                text: "In top ",
                                style: textTheme!.titleSmall!.copyWith(
                                  fontWeight: FontWeight.w600,
                                ),
                              ),
                              TextSpan(
                                text: "30%",
                                style: textTheme!.titleSmall!.copyWith(
                                    fontWeight: FontWeight.w600, fontSize: 16),
                              ),
                            ],
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
            SizedBox(height: 8),
            Container(
              height: MediaQuery.of(context).size.height / 7,
              width: MediaQuery.of(context).size.width / 2.3,
              padding: const EdgeInsets.only(
                left: 8,
              ),
              decoration: BoxDecoration(
                  color: Color(0xFFE7EAF5).withOpacity(0.6),
                  borderRadius: BorderRadius.circular(12)),
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                mainAxisSize: MainAxisSize.min,
                children: <Widget>[
                  CompletedProjects(textTheme: textTheme!),
                  SizedBox(
                    height: 6,
                  ),
                  Row(
                    children: <Widget>[
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              24,
                            ),
                            color: Color(0xFFe4eaf8)),
                        child: Text(
                          "mobile app",
                          style: textTheme!.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      ),
                      SizedBox(width: 8),
                      Container(
                        padding: EdgeInsets.all(8),
                        decoration: BoxDecoration(
                            borderRadius: BorderRadius.circular(
                              24,
                            ),
                            color: Color(0xFFe4eaf8)),
                        child: Text(
                          "branding",
                          style: textTheme!.titleSmall!.copyWith(
                            fontWeight: FontWeight.w600,
                            fontSize: 10,
                          ),
                        ),
                      )
                    ],
                  )
                ],
              ),
            ),
          ],
        )
      ],
    );
  }
}

class CompletedProjects extends StatelessWidget {
  const CompletedProjects({
    Key? key,
    @required this.textTheme,
  }) : super(key: key);

  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    return Row(
      children: <Widget>[
        Container(
          padding: const EdgeInsets.all(12),
          child: Text(
            "32",
            style: Theme.of(context).textTheme.headlineSmall!.copyWith(
                  color: Colors.white,
                ),
          ),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(12),
            color: Color(0xFF1E35F5).withOpacity(0.6),
          ),
        ),
        Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            Padding(
              padding: const EdgeInsets.only(left: 8.0, top: 16, bottom: 8),
              child: Text("Projects", style: textTheme!.bodySmall),
            ),
            Padding(
              padding: const EdgeInsets.only(
                left: 8,
              ),
              child: RichText(
                text: TextSpan(
                  children: [
                    TextSpan(
                      text: "8 ",
                      style: textTheme!.titleSmall!
                          .copyWith(fontWeight: FontWeight.w600, fontSize: 16),
                    ),
                    TextSpan(
                      text: "this month",
                      style: textTheme!.titleSmall!.copyWith(
                        fontWeight: FontWeight.w600,
                      ),
                    )
                  ],
                ),
              ),
            ),
          ],
        )
      ],
    );
  }
}

class EarningWidget extends StatelessWidget {
  const EarningWidget({
    Key? key,
    @required this.textTheme,
  }) : super(key: key);

  final TextTheme? textTheme;

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.only(left: 16, top: 12),
      decoration: BoxDecoration(
        color: Color(0xFF1E35F5).withOpacity(0.6),
        borderRadius: BorderRadius.circular(12),
      ),
      height: MediaQuery.of(context).size.height / 4.2,
      width: MediaQuery.of(context).size.width / 2.5,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: <Widget>[
          Icon(
            Icons.show_chart,
            color: Colors.white,
            size: 32,
          ),
          Text(
            "Earnings",
            style: TextStyle(
              color: Colors.white,
              fontWeight: FontWeight.w500,
            ),
          ),
          SizedBox(
            height: 16,
          ),
          RichText(
            text: TextSpan(
              children: [
                TextSpan(
                  text: "₱ ",
                  style: textTheme!.titleSmall!.copyWith(
                      fontWeight: FontWeight.w300, color: Colors.white),
                ),
                TextSpan(
                    text: "7,000",
                    style: textTheme!.titleSmall!.copyWith(
                      color: Colors.white,
                    ))
              ],
            ),
          ),
          SizedBox(height: 12),
          Container(
            decoration: BoxDecoration(
                color: Color(0xFF1E35F5).withOpacity(0.6),
                borderRadius: BorderRadius.circular(24)),
            padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
            child: Text(
              "+ 10% since last month",
              style: TextStyle(
                fontSize: 10,
                color: Colors.white,
              ),
            ),
          )
        ],
      ),
    );
  }
}
