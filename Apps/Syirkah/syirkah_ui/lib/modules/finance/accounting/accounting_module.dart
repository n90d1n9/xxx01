import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';

import 'package:kayys_components/kayys_components.dart';
import 'package:syirkah/core/modules/module_model.dart';
import 'package:syirkah/core/routes/routes.dart';
import 'package:syirkah/modules/finance/accounting/pages/adjusting_journal/adjusting_journal.dart';
import 'package:syirkah/modules/finance/accounting/pages/balance_sheet/bs_page.dart';
import 'package:syirkah/modules/finance/accounting/pages/general_journal/pages/general_journal_page.dart';
import 'package:syirkah/modules/finance/accounting/pages/general_ledger/gl_page.dart';
import 'package:syirkah/modules/finance/accounting/pages/report_income_statement/is_page.dart';
import 'package:syirkah/modules/finance/accounting/pages/report_profit_and_loss/pnl_page.dart';
import 'package:syirkah/modules/finance/accounting/pages/worksheet/ws_page.dart';
import 'package:syirkah/modules/finance/cashflow/cash_flow_page.dart';

class AccountingModule implements Module {
  @override
  String? name = 'Apps';
  static String accounting = '/accounting';
  static String cashFlow = '/cashFlow';
  static String generalJournal = '/generalJournal';
  static String generalLedger = '/generalLedger';
  static String balanceSheet = '/balanceSheet';
  static String adjustingJournal = '/adjustingJournal';
  static String worksheet = '/worksheet';
  static String incomeStatement = '/incomeStatement';
  static String profitAndLoss = '/profitAndLoss';

  static String currency = '/currency';
/*   static String currencyChart = '/currencychart';
  static String proyek = '/proyek';
  static String valasSetup9 = '/valasSetup';
  static String valasSetup10 = '/valasSetup';
  static String valasSetup11 = '/valasSetup';
  static String penerimaanBarang = '/penerimaanBarang';
  static String uangMukaPelanggan = '/uangMukaPelanggan';
  static String daftarJurnal = '/daftarJurnal';
  static String faktur = '/faktur'; */

  @override
  pages(BuildContext context) => [
        Menu(
            title: 'Accounting',
            items: [
              Menu(title: 'Cash Flow', path: cashFlow, showInDrawer: false),
              Menu(
                  title: 'General Journal',
                  path: generalJournal,
                  showInDrawer: false),
              Menu(
                  title: 'General Ledger',
                  path: generalLedger,
                  showInDrawer: false),
              Menu(
                  title: 'Balance Sheet',
                  path: balanceSheet,
                  showInDrawer: false),
              Menu(
                  title: 'Adjusting Journal',
                  path: adjustingJournal,
                  showInDrawer: false),
              Menu(
                  title: 'Worksheet',
                  path: worksheet,
                  iconWidget: const Icon(Icons.dashboard)),
              Menu(
                  title: 'Income Statement',
                  path: incomeStatement,
                  showInDrawer: false),
              Menu(
                  title: 'Profit and Loss',
                  path: profitAndLoss,
                  showInDrawer: false),
            ],
            showInDrawer: false),
      ];

  @override
  services() {}

  @override
  goroutes() => [
        /*  GoRoute(
          path: uangMukaPelanggan,
          builder: (BuildContext context, GoRouterState state) =>
              const UangMukaPelanggan(),
        ), */
        /* GoRoute(
          path: invoiceSale,
          builder: (BuildContext context, GoRouterState state) =>
              const PenerimaanBarang(),
        ), */
        /* GoRoute(
          path: invoiceSale,
          builder: (BuildContext context, GoRouterState state) =>
              const DesktopUI(),
        ), */
      ];

  @override
  List<StatefulShellBranch> branches() => [
        Routes.shellBranch(cashFlow, cashFlow, const CashFlowPage(), []),
        Routes.shellBranch(
            generalJournal, generalJournal, const GeneralJournalPage(), []),
        Routes.shellBranch(
            generalLedger, generalLedger, const GeneralLedger(), []),
        Routes.shellBranch(
            balanceSheet, balanceSheet, const BalanceSheet(), []),
        Routes.shellBranch(
            adjustingJournal, adjustingJournal, const AdjustingJournal(), []),
        Routes.shellBranch(worksheet, worksheet, const Worksheet(), []),
        Routes.shellBranch(
            incomeStatement, incomeStatement, const IncomeStatement(), []),
        Routes.shellBranch(
            profitAndLoss, profitAndLoss, const ProfitAndLoss(), []),
      ];
}
