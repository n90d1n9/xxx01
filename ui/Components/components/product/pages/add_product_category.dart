import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:image_picker/image_picker.dart';

class AddProductCategoryScreen extends ConsumerWidget {
  const AddProductCategoryScreen({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Product Category'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            // Image
            const Center(
              child: SizedBox(
                height: 100,
                width: 100,
                child: /* ref.watch(imageProvider).when(
                  data: (image) => image != null
                      ? Image.file(image)
                      :  */Text('NO IMAGE AVAILABLE')
                 /*  error: (error, stackTrace) => Text(error.toString()),
                  loading: () => const CircularProgressIndicator(), */
               // ),
              ),
            ),
            const SizedBox(height: 16.0),
            // File Size and Format
            const Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text('Maximum File Size'),
                SizedBox(height: 4.0),
                Text('500 KB'),
                SizedBox(height: 8.0),
                Text('Format File:'),
                SizedBox(height: 4.0),
                Text('.jpg .jpeg .png'),
              ],
            ),
            const SizedBox(height: 16.0),
            // Delete Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                 // ref.read(imageProvider.notifier).clearImage();
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Delete'),
              ),
            ),
            const SizedBox(height: 32.0),
            // Category Name
            TextField(
              decoration: const InputDecoration(
                labelText: 'Category Name',
                prefixIcon: Icon(Icons.category),
              ),
              onChanged: (value) {
                ref.read(categoryNameProvider.notifier).state = value;
              },
            ),
            const SizedBox(height: 16.0),
            // Sequence No
            TextField(
              decoration: const InputDecoration(
                labelText: 'Sequence No',
                prefixIcon: Icon(Icons.sort),
              ),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                ref.read(sequenceNoProvider.notifier).state = int.tryParse(value) ?? 0;
              },
            ),
            const SizedBox(height: 16.0),
            // Flag Online
            Row(
              children: [
                const Text('Flag Online'),
                const Spacer(),
                Switch(
                  value: ref.watch(flagOnlineProvider),
                  onChanged: (value) {
                    ref.read(flagOnlineProvider.notifier).state = value;
                  },
                ),
              ],
            ),
            const SizedBox(height: 8.0),
            const Text('Activate to show this category in'),
            const Text('\'All\' category and in Self Order'),
            const SizedBox(height: 32.0),
            // Save Button
            Center(
              child: ElevatedButton(
                onPressed: () {
                  // Save the category data
                  // ...
                },
                style: ElevatedButton.styleFrom(
                  backgroundColor: Colors.red,
                  foregroundColor: Colors.white,
                ),
                child: const Text('Save'),
              ),
            ),
          ],
        ),
      ),
    );
  }
}

// Riverpod providers
final imageProvider = StateProvider<XFile?>((ref) => null);
final categoryNameProvider = StateProvider<String>((ref) => '');
final sequenceNoProvider = StateProvider<int>((ref) => 0);
final flagOnlineProvider = StateProvider<bool>((ref) => false);

// Function to pick an image
Future<void> pickImage(WidgetRef ref) async {
  final ImagePicker picker = ImagePicker();
  final XFile? image = await picker.pickImage(source: ImageSource.gallery);
  ref.read(imageProvider.notifier).state = image;
}
