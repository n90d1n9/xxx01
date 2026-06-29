import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kayys_components/models/menu.dart';
import 'package:syirkah/modules/pos/pages/fnb_layout/pos_fnb_large.dart';
import 'package:syirkah/modules/pos/pages/grocery_layout/pos_grocery.dart';
import 'package:syirkah/modules/pos/pages/touchscreen_layout/touch03.dart';

import '../../core/modules/module_model.dart';

class PosModule implements Module {
  @override
  String? name = 'Dashboard';
  static String pos = '/pos';
  static String posGrocery = '/pos/grocery';
  static String posFnb = '/pos/fnb';
  static String posTouchscreen = '/pos/touchscreen';
  static String order = '/order';

  @override
  pages(BuildContext context) => [
        Menu(title: 'Pos', items: [
          Menu(title: 'Pos Grocery', path: posGrocery),
          Menu(title: 'Pos Food and Beverage', path: posFnb),
          Menu(title: 'Pos Touch Screen', path: posTouchscreen),
        ]),
      ];

  @override
  services() {}

  @override
  goroutes() => [
        GoRoute(
          path: posGrocery,
          builder: (BuildContext context, GoRouterState state) =>
              const PosGroceryPage(),
          //const CartScreen(),
          // const MenuScreen()
        ),
        GoRoute(
          path: posFnb,
          builder: (BuildContext context, GoRouterState state) =>
              const PosFnBLargePage(),
        ),
        GoRoute(
          path: posTouchscreen,
          builder: (BuildContext context, GoRouterState state) =>
             // const PosTouchLargePage(),
            // const Mpos()
            //const DesktopUI()
            const DesktopCheckoutScreen()
        ),
      ];

  @override
  List<StatefulShellBranch> branches() => [
        //Routes.shellBranch('pos', pos, const PosGroceryPage(), []),
        //Routes.shellBranch('pos', pos, const ProductDetail(), []),
        //Routes.shellBranch('pos', pos, const DineInScreen(), []),
        //Routes.shellBranch('pos', pos, const OutletOrderWidget(), []),
        //Routes.shellBranch('pos', pos, const SelfOrderScreen(), []),
        //Routes.shellBranch('pos', pos, const OrderSuccessScreen(), []),
        //Routes.shellBranch('pos', pos, const OrderConfirmationScreen(), []),
        //Routes.shellBranch('pos', pos, const InitialBalanceScreen(), []),
        //Routes.shellBranch('pos', pos, const IncomeExpenseWidget(), []),
        //Routes.shellBranch('pos', pos, const AddExpenseWidget(), []),
        //Routes.shellBranch('pos', pos, const AddExpenseScreen(), []),
        //Routes.shellBranch('pos', pos, const ChooseDateWidget(), []),
        //Routes.shellBranch('pos', pos, const PrintBillScreen(), []),
        // Routes.shellBranch('pos', pos, const PaymentScreen(), []),
        //Routes.shellBranch('pos', pos,  SplitBillScreen(), []),
        //Routes.shellBranch('pos', pos, const ConfirmSplitBill(), []),
        //Routes.shellBranch('pos', pos, const PaymentMethodScreen(), []),
        //Routes.shellBranch('pos', pos, const ScanQR(), []),
        //Routes.shellBranch('pos', pos, const DashboardPos(), []),
        //Routes.shellBranch('pos', pos, const ReportScreen(), []),
        //Routes.shellBranch('pos', pos, const AccountScreen(), []),
        //Routes.shellBranch('pos', pos, const AddDiscountScreen(), []),
        //Routes.shellBranch('pos', pos, const ItemRelationScreen(), []),
        //Routes.shellBranch('pos', pos, const AddNewsWidget(), []),
        //Routes.shellBranch('pos', pos, const CustomLevelScreen(), []),
        //Routes.shellBranch('pos', pos, const ReceiptSettingPage(), []),
        //Routes.shellBranch('pos', pos, const InventoryAdjustmentScreen(), []),
        //Routes.shellBranch('pos', pos, const AddInventoryScreen(), []),
        //Routes.shellBranch('pos', pos, const InventoryPeriodePage(), []),
        //Routes.shellBranch('pos', pos, const AddBranchScreen(), []),
        //Routes.shellBranch('pos', pos, const PrinterSettingScreen(), []),
        //Routes.shellBranch('pos', pos, const PrintKitchenSetting(), []),
        //Routes.shellBranch('pos', pos, const PrintSelfOrderQrCode(), []),
        //Routes.shellBranch('pos', pos, const ProductCategoryScreen(), []),
        //Routes.shellBranch('pos', pos, const AddProductCategoryScreen(), []),
        // Routes.shellBranch('pos', pos, const TableLayout(), []),
        //Routes.shellBranch('order', pos, const DineInScreen(), []),
        /*Routes.shellBranch('pos', pos, const ProductDetail(), []),
        Routes.shellBranch('pos', pos, const ProductDetail(), []),
        Routes.shellBranch('pos', pos, const ProductDetail(), []),
        
         */
      ];
}
