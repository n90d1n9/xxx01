/* import 'package:flutter/material.dart';
import 'package:flutter_gen/gen_l10n/app_localizations.dart'; */
import 'package:kayys_components/kayys_components.dart';
import 'package:syirkah/modules/shop/shop_module.dart';

import '../../modules/finance/accounting/accounting_module.dart';

var header = {"title": "", "logo": "assets/images/logo.png"};

var gridMenuItems = [
  GridItem(
      id: 1, title: 'Toko', path: ShopModule.shophome, imagePath: 'assets/icons/toko.png'),
  GridItem(
      id: 2, title: 'Kasir', path: '/pos', imagePath: 'assets/icons/kasir.png'),
  GridItem(
      id: 3,
      title: 'Akuntasi',
      path: AccountingModule.accounting,
      imagePath: 'assets/icons/akuntansi.png'),
  GridItem(
      id: 5,
      title: 'Anggaran Belanja',
      path: '/expenditure',
      imagePath: 'assets/icons/belanja.png'),
  GridItem(
      id: 6,
      title: 'Lowongan',
      path: '/lowongan',
      imagePath: 'assets/icons/lowongan.png'),
  GridItem(
      id: 4,
      title: 'Bingkai',
      path: '/imageEditor2',
      imagePath: 'assets/icons/bingkai.png'),
  /* GridItem(
      id: 7,
      title: 'Image Editor',
      path: '/imageEditor2',
      icon: Icons.abc_rounded),
  GridItem(
      id: 8,
      title: 'Invoice',
      path: AccountingModule.invoiceList,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'valas',
      path: AccountingModule.valasSetup,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'backup',
      path: AccountingModule.backupdata,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'restore',
      path: AccountingModule.restoredata,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'Profile Form',
      path: AccountingModule.profile,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'Account form',
      path: AccountingModule.accountForm,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'Currency',
      path: AccountingModule.currency,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'currency chart',
      path: AccountingModule.currencyChart,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'proyek',
      path: AccountingModule.proyek,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9,
      title: 'Invoice',
      path: AccountingModule.invoice,
      icon: Icons.abc_rounded),
  GridItem(
      id: 9, title: 'Invoice6', path: '/invoiceList', icon: Icons.abc_rounded),
  GridItem(
      id: 9, title: 'Invoice6', path: '/invoiceList', icon: Icons.abc_rounded), */
];

/* 
List<Menu> menu(BuildContext context) => [
      Menu(
        title: AppLocalizations.of(context)!.dashboard,
        icon: "list",
        path: "/dashboard",
      ),
      Menu(
          title: AppLocalizations.of(context)!.users,
          icon: "home",
          path: "/users",
          items: const [
            Menu(title: "Users", icon: "home", path: "/users"),
            Menu(title: "Users Detail", icon: "home", path: "/users/3")
          ]),
      Menu(
          title: AppLocalizations.of(context)!.settings,
          icon: "home",
          path: "/settings",
          items: const [
            Menu(title: "Events", icon: "home", path: "/dashboard"),
            Menu(title: "Assets", icon: "home", path: "/dashboard")
          ]),
      Menu(
        title: AppLocalizations.of(context)!.about,
        icon: "home",
        path: "/about",
      ),
    ]; */

