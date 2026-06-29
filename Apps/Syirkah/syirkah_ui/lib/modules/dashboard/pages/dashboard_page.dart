import 'package:flutter/material.dart';

import 'package:syirkah/modules/dashboard/widgets/filter_widget.dart';
import 'package:syirkah/modules/dashboard/widgets/gchart/cardboxdata.dart';
import 'package:syirkah/modules/dashboard/widgets/gchart/gbox.dart';
import 'package:syirkah/modules/dashboard/widgets/gchart/gchart.dart';

class DashboardPage extends StatefulWidget {
  const DashboardPage({super.key});

  @override
  State<DashboardPage> createState() => _DashboardPageState();
}

class _DashboardPageState extends State<DashboardPage> {

  @override
  Widget build(BuildContext context) {
    return SingleChildScrollView(
        child: Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        const FilterWidget(),
        Padding(
            padding: const EdgeInsets.fromLTRB(10, 10, 10, 10),
            child: Row(children: [
              CardBoxData(
                color: Colors.green[50],
              ),
              CardBoxData(
                color: Colors.red[50],
              ),
              CardBoxData(
                color: Colors.blue[50],
              ),
              CardBoxData(
                color: Colors.yellow[50],
              ),
            ])),
        Row(mainAxisAlignment: MainAxisAlignment.spaceBetween, children: [
          Expanded(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  width: 200,
                  /*child: GChart(
                    config: config2,
                    width: 300,
                    height: 300,
                    type: GChartType.line,
                  )*/
              )),
          Expanded(
              child: Container(
                  margin: const EdgeInsets.fromLTRB(10, 10, 10, 10),
                  decoration: const BoxDecoration(
                    color: Colors.white,
                  ),
                  width: 200,
                  /*child: GChart(
                      config: config1,
                      width: 300,
                      height: 300,
                      type: GChartType.bar)*/
              )),
        ]),
        /* Row(
          children: [
            GChart(
              config: config1,
              type: GChartType.pie,
            ),
            GChart(
              config: config1,
              type: GChartType.pie,
            ),
          ],
        ), */
        
        //const SalesEvolutionChart2(),
       // const SalesEvolutionChart(),
        const Row(children: [
          Expanded(
            child: Card(
              color: Colors.white,
              child: Padding(
                padding: EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      'Last Month',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      '\$4,758,565',
                      style: TextStyle(
                        fontSize: 24.0,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Text(
                      'Sales',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    SizedBox(height: 8.0),
                    Row(
                      children: [
                        Text('Y-1'),
                        SizedBox(width: 8.0),
                        Text('\$4,053,682'),
                        SizedBox(width: 16.0),
                        Icon(Icons.arrow_upward, color: Colors.green),
                        SizedBox(width: 8.0),
                        Text('17.39%'),
                      ],
                    ),
                  ],
                ),
              ),
            ),
          ),
        ])
      ],
    ));
  }

  List<Widget> boxesWidget(data) {
    List<ChartData> bd = ChartData.fromMapList(data);

    List<Widget> bl = [];
    for (var i = 0; i < bd.length; i++) {
      bl.add(Expanded(
          child: GBox(
        backgroundColor: Colors.white,
        height: 100,
        width: 150,
        label: bd[i].name,
        value: double.parse('${bd[i].value}'),
        valueStyle: const TextStyle(fontSize: 20),
      )));
    }
    return bl;
  }
}
