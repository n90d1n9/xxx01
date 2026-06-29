import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import 'package:kasir/modules/order/pages/new_order.dart';
import 'package:kasir/modules/table/pages/table_layout.dart';

import '../../core/modules/module_model.dart';
import '../../core/routes/routes.dart';

class PosModule implements Module {
  @override
  String? name = 'Dashboard';
  static String pos = '/pos';
  static String order = '/order'; 

  @override
  pages(BuildContext context) => [
        //  Menu(title: 'Dashboard', path: DashboardRoutes.dashboard),
      ];

  @override
  services() {}

  @override
  goroutes() => [];

  @override
  List<StatefulShellBranch> branches() => [
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
        Routes.shellBranch('pos', pos, const TableLayout(), []),
        Routes.shellBranch('order', pos, const DineInScreen(), []),
        /*Routes.shellBranch('pos', pos, const ProductDetail(), []),
        Routes.shellBranch('pos', pos, const ProductDetail(), []),
        Routes.shellBranch('pos', pos, const ProductDetail(), []),
        
         */
      ];
}
