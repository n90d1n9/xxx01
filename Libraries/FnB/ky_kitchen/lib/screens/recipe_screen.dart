import 'package:flutter/material.dart';
import 'package:flutter_riverpod/legacy.dart';

import '../models/inventory_item.dart';
import '../models/recipe.dart';
import '../models/recipe_ingredient.dart';
import '../states/inventory_provider.dart';
import '../states/recipe_provider.dart';

class RecipeScreen extends ConsumerWidget {
  const RecipeScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final recipes = ref.watch(recipeProvider);

    return Scaffold(
      appBar: AppBar(title: const Text('Recipe Management')),
      body: recipes.isEmpty
          ? const Center(child: Text('No recipes yet'))
          : ListView.builder(
              itemCount: recipes.length,
              itemBuilder: (context, index) {
                final recipe = recipes[index];
                return Card(
                  margin: const EdgeInsets.symmetric(
                    horizontal: 16,
                    vertical: 8,
                  ),
                  child: ExpansionTile(
                    title: Text(
                      recipe.name,
                      style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    subtitle: Text(
                      '${recipe.category} • ${recipe.preparationTime + recipe.cookingTime} mins • \$${recipe.cost.toStringAsFixed(2)}',
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16.0),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            const Text(
                              'Description:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(recipe.description),
                            const SizedBox(height: 12),
                            const Text(
                              'Ingredients:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            const SizedBox(height: 4),
                            ListView.builder(
                              shrinkWrap: true,
                              physics: const NeverScrollableScrollPhysics(),
                              itemCount: recipe.ingredients.length,
                              itemBuilder: (context, i) {
                                final ingredient = recipe.ingredients[i];
                                return Padding(
                                  padding: const EdgeInsets.only(bottom: 4.0),
                                  child: Text(
                                    '• ${ingredient.name}: ${ingredient.quantity} ${ingredient.unit}',
                                  ),
                                );
                              },
                            ),
                            const SizedBox(height: 12),
                            const Text(
                              'Instructions:',
                              style: TextStyle(fontWeight: FontWeight.bold),
                            ),
                            Text(recipe.instructions),
                            const SizedBox(height: 12),
                            Row(
                              mainAxisAlignment: MainAxisAlignment.end,
                              children: [
                                TextButton(
                                  onPressed: () {
                                    // Edit recipe
                                  },
                                  child: const Text('Edit'),
                                ),
                                TextButton(
                                  onPressed: () {
                                    _confirmDelete(context, ref, recipe.id);
                                  },
                                  child: const Text(
                                    'Delete',
                                    style: TextStyle(color: Colors.red),
                                  ),
                                ),
                              ],
                            ),
                          ],
                        ),
                      ),
                    ],
                  ),
                );
              },
            ),
      floatingActionButton: FloatingActionButton(
        onPressed: () {
          _showAddRecipeDialog(context, ref);
        },
        child: const Icon(Icons.add),
      ),
    );
  }

  void _showAddRecipeDialog(BuildContext context, WidgetRef ref) {
    final nameController = TextEditingController();
    final descriptionController = TextEditingController();
    final prepTimeController = TextEditingController();
    final cookTimeController = TextEditingController();
    final categoryController = TextEditingController();
    final costController = TextEditingController();
    final instructionsController = TextEditingController();

    final List<RecipeIngredient> ingredients = [];
    final inventory = ref.read(inventoryProvider);

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Recipe'),
              content: SingleChildScrollView(
                child: Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    TextField(
                      controller: nameController,
                      decoration: const InputDecoration(
                        labelText: 'Recipe Name',
                      ),
                    ),
                    TextField(
                      controller: descriptionController,
                      decoration: const InputDecoration(
                        labelText: 'Description',
                      ),
                      maxLines: 2,
                    ),
                    Row(
                      children: [
                        Expanded(
                          child: TextField(
                            controller: prepTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Prep Time (mins)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: TextField(
                            controller: cookTimeController,
                            decoration: const InputDecoration(
                              labelText: 'Cook Time (mins)',
                            ),
                            keyboardType: TextInputType.number,
                          ),
                        ),
                      ],
                    ),
                    TextField(
                      controller: categoryController,
                      decoration: const InputDecoration(labelText: 'Category'),
                    ),
                    TextField(
                      controller: costController,
                      decoration: const InputDecoration(labelText: 'Cost'),
                      keyboardType: TextInputType.number,
                    ),
                    const SizedBox(height: 12),
                    const Text(
                      'Ingredients:',
                      style: TextStyle(fontWeight: FontWeight.bold),
                    ),
                    const SizedBox(height: 8),
                    ListView.builder(
                      shrinkWrap: true,
                      physics: const NeverScrollableScrollPhysics(),
                      itemCount: ingredients.length,
                      itemBuilder: (context, index) {
                        final ingredient = ingredients[index];
                        return Padding(
                          padding: const EdgeInsets.only(bottom: 8.0),
                          child: Row(
                            children: [
                              Expanded(
                                child: Text(
                                  '${ingredient.name}: ${ingredient.quantity} ${ingredient.unit}',
                                ),
                              ),
                              IconButton(
                                icon: const Icon(
                                  Icons.delete,
                                  color: Colors.red,
                                ),
                                onPressed: () {
                                  setState(() {
                                    ingredients.removeAt(index);
                                  });
                                },
                              ),
                            ],
                          ),
                        );
                      },
                    ),
                    ElevatedButton(
                      onPressed: () {
                        _showAddIngredientDialog(context, inventory, (
                          ingredient,
                        ) {
                          setState(() {
                            ingredients.add(ingredient);
                          });
                        });
                      },
                      child: const Text('Add Ingredient'),
                    ),
                    const SizedBox(height: 12),
                    TextField(
                      controller: instructionsController,
                      decoration: const InputDecoration(
                        labelText: 'Instructions',
                      ),
                      maxLines: 4,
                    ),
                  ],
                ),
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (nameController.text.isNotEmpty &&
                        prepTimeController.text.isNotEmpty &&
                        cookTimeController.text.isNotEmpty &&
                        categoryController.text.isNotEmpty &&
                        costController.text.isNotEmpty &&
                        instructionsController.text.isNotEmpty &&
                        ingredients.isNotEmpty) {
                      final newRecipe = Recipe(
                        id: DateTime.now().millisecondsSinceEpoch.toString(),
                        name: nameController.text,
                        description: descriptionController.text,
                        ingredients: ingredients,
                        instructions: instructionsController.text,
                        preparationTime: int.parse(prepTimeController.text),
                        cookingTime: int.parse(cookTimeController.text),
                        category: categoryController.text,
                        cost: double.parse(costController.text),
                      );
                      ref.read(recipeProvider.notifier).addRecipe(newRecipe);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _showAddIngredientDialog(
    BuildContext context,
    List<InventoryItem> inventory,
    Function(RecipeIngredient) onAdd,
  ) {
    InventoryItem? selectedItem;
    final quantityController = TextEditingController();

    showDialog(
      context: context,
      builder: (context) {
        return StatefulBuilder(
          builder: (context, setState) {
            return AlertDialog(
              title: const Text('Add Ingredient'),
              content: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  DropdownButtonFormField<InventoryItem>(
                    hint: const Text('Select Ingredient'),
                    items: inventory.map((item) {
                      return DropdownMenuItem<InventoryItem>(
                        value: item,
                        child: Text(item.name),
                      );
                    }).toList(),
                    onChanged: (value) {
                      setState(() {
                        selectedItem = value;
                      });
                    },
                  ),
                  const SizedBox(height: 12),
                  if (selectedItem != null)
                    TextField(
                      controller: quantityController,
                      decoration: InputDecoration(
                        labelText: 'Quantity (${selectedItem!.unit})',
                      ),
                      keyboardType: TextInputType.number,
                    ),
                ],
              ),
              actions: [
                TextButton(
                  onPressed: () {
                    Navigator.of(context).pop();
                  },
                  child: const Text('Cancel'),
                ),
                TextButton(
                  onPressed: () {
                    if (selectedItem != null &&
                        quantityController.text.isNotEmpty) {
                      final ingredient = RecipeIngredient(
                        inventoryItemId: selectedItem!.id,
                        name: selectedItem!.name,
                        quantity: double.parse(quantityController.text),
                        unit: selectedItem!.unit,
                      );
                      onAdd(ingredient);
                      Navigator.of(context).pop();
                    }
                  },
                  child: const Text('Add'),
                ),
              ],
            );
          },
        );
      },
    );
  }

  void _confirmDelete(BuildContext context, WidgetRef ref, String id) {
    showDialog(
      context: context,
      builder: (context) {
        return AlertDialog(
          title: const Text('Confirm Delete'),
          content: const Text('Are you sure you want to delete this recipe?'),
          actions: [
            TextButton(
              onPressed: () {
                Navigator.of(context).pop();
              },
              child: const Text('Cancel'),
            ),
            TextButton(
              onPressed: () {
                ref.read(recipeProvider.notifier).deleteRecipe(id);
                Navigator.of(context).pop();
              },
              child: const Text('Delete', style: TextStyle(color: Colors.red)),
            ),
          ],
        );
      },
    );
  }
}
