import 'package:flutter/material.dart';

import 'package:kays_recipe/kays_recipe.dart';

class RecipesScreen  extends StatelessWidget {
  const RecipesScreen ({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Container(
      child: RecipePage(),
    );
  }
}