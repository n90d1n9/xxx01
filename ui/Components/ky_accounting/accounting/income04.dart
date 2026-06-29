
import 'package:flutter/material.dart';

class BalanceSheetTable extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DataTable(
      columns: const [
        DataColumn(label: Text('')),
        DataColumn(label: Text('2016')),
        DataColumn(label: Text('2017')),
      ],
      rows: const [
        DataRow(
          cells: [
            DataCell(Text('Current assets:')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Cash and cash equivalents')),
            DataCell(Text('\$ 19,334')),
            DataCell(Text('\$ 20,522')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Marketable securities')),
            DataCell(Text('\$ 6,647')),
            DataCell(Text('\$ 10,464')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Inventories')),
            DataCell(Text('\$ 11,461')),
            DataCell(Text('\$ 16,047')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Accounts receivable, net and other')),
            DataCell(Text('\$ 8,339')),
            DataCell(Text('\$ 13,164')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Total current assets')),
            DataCell(Text('\$ 45,781')),
            DataCell(Text('\$ 60,197')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Property and equipment, net')),
            DataCell(Text('\$ 29,114')),
            DataCell(Text('\$ 48,866')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Goodwill')),
            DataCell(Text('\$ 3,784')),
            DataCell(Text('\$ 13,350')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Other assets')),
            DataCell(Text('\$ 4,723')),
            DataCell(Text('\$ 8,897')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Total assets')),
            DataCell(Text('\$ 83,402')),
            DataCell(Text('\$ 131,310')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('LIABILITIES AND STOCKHOLDERS\' EQUITY')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Current liabilities:')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Accounts payable')),
            DataCell(Text('\$ 25,309')),
            DataCell(Text('\$ 34,616')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Accrued expenses and other')),
            DataCell(Text('\$ 13,739')),
            DataCell(Text('\$ 18,170')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Unearned revenue')),
            DataCell(Text('\$ 4,768')),
            DataCell(Text('\$ 5,097')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Total current liabilities')),
            DataCell(Text('\$ 43,816')),
            DataCell(Text('\$ 57,883')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Long-term debt')),
            DataCell(Text('\$ 7,694')),
            DataCell(Text('\$ 24,743')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Other long-term liabilities')),
            DataCell(Text('\$ 12,607')),
            DataCell(Text('\$ 20,975')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Commitments and contingencies (Note 7)')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Stockholders\' equity:')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Preferred stock, \$0.01 par value:')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Authorized shares - 500')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Issued and outstanding shares - none')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Common stock, \$0.01 par value:')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Authorized shares - 5,000')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Issued shares - 500 and 507')),
            DataCell(Text('')),
            DataCell(Text('')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Outstanding shares - 477 and 484')),
            DataCell(Text('\$ (1,837)')),
            DataCell(Text('\$ 5')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Treasury stock, at cost')),
            DataCell(Text('\$ 17,186')),
            DataCell(Text('\$ 21,389')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Additional paid-in capital')),
            DataCell(Text('\$ (985)')),
            DataCell(Text('\$ (484)')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Accumulated other comprehensive loss')),
            DataCell(Text('\$ 19,916')),
            DataCell(Text('\$ 8,636')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Retained earnings')),
            DataCell(Text('\$ 4,285')),
            DataCell(Text('\$ 27,709')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Total stockholders\' equity')),
            DataCell(Text('\$ 19,285')),
            DataCell(Text('\$ 27,906')),
          ],
        ),
        DataRow(
          cells: [
            DataCell(Text('Total liabilities and stockholders\' equity')),
            DataCell(Text('\$ 83,402')),
            DataCell(Text('\$ 131,310')),
          ],
        ),
      ],
    );
  }
}
