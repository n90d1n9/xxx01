import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/presentation_provider.dart';

class SlidePanel extends ConsumerWidget {
  const SlidePanel({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final presentation = ref.watch(presentationProvider);

    return Column(
      children: [
        Padding(
          padding: const EdgeInsets.all(12.0),
          child: Container(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  presentation.theme.primaryColor,
                  presentation.theme.secondaryColor,
                ],
              ),
              borderRadius: BorderRadius.circular(12),
              boxShadow: [
                BoxShadow(
                  color: presentation.theme.primaryColor.withOpacity(0.3),
                  blurRadius: 10,
                ),
              ],
            ),
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => ref.read(presentationProvider.notifier).addSlide(),
                borderRadius: BorderRadius.circular(12),
                child: const Padding(
                  padding: EdgeInsets.symmetric(vertical: 14),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(Icons.add, color: Colors.white),
                      SizedBox(width: 8),
                      Text(
                        'New Slide',
                        style: TextStyle(
                          color: Colors.white,
                          fontWeight: FontWeight.w600,
                        ),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ),
        const Divider(height: 1, color: Color(0xFF334155)),
        Expanded(
          child: ReorderableListView.builder(
            itemCount: presentation.slides.length,
            onReorder: (oldIndex, newIndex) {
              ref
                  .read(presentationProvider.notifier)
                  .reorderSlides(oldIndex, newIndex);
            },
            itemBuilder: (context, index) {
              final slide = presentation.slides[index];
              final isSelected = index == presentation.currentSlideIndex;

              return Card(
                key: ValueKey(slide.id),
                color:
                    isSelected
                        ? const Color(0xFF334155)
                        : const Color(0xFF1E293B),
                margin: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                elevation: isSelected ? 8 : 2,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(12),
                  side:
                      isSelected
                          ? BorderSide(
                            color: presentation.theme.primaryColor,
                            width: 2,
                          )
                          : BorderSide.none,
                ),
                child: InkWell(
                  onTap:
                      () => ref
                          .read(presentationProvider.notifier)
                          .setCurrentSlide(index),
                  borderRadius: BorderRadius.circular(12),
                  child: Padding(
                    padding: const EdgeInsets.all(12),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 10,
                                vertical: 6,
                              ),
                              decoration: BoxDecoration(
                                gradient:
                                    isSelected
                                        ? LinearGradient(
                                          colors: [
                                            presentation.theme.primaryColor,
                                            presentation.theme.secondaryColor,
                                          ],
                                        )
                                        : null,
                                color:
                                    isSelected ? null : const Color(0xFF475569),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${index + 1}',
                                style: const TextStyle(
                                  fontSize: 12,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.white,
                                ),
                              ),
                            ),
                            const SizedBox(width: 10),
                            Expanded(
                              child: Text(
                                slide.title ?? 'Slide ${index + 1}',
                                style: const TextStyle(
                                  fontSize: 13,
                                  fontWeight: FontWeight.w600,
                                  color: Colors.white,
                                ),
                                maxLines: 1,
                                overflow: TextOverflow.ellipsis,
                              ),
                            ),
                            PopupMenuButton(
                              icon: const Icon(
                                Icons.more_vert,
                                size: 18,
                                color: Colors.white70,
                              ),
                              color: const Color(0xFF1E293B),
                              itemBuilder:
                                  (context) => [
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.content_copy,
                                            size: 18,
                                            color: Colors.white70,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Duplicate',
                                            style: TextStyle(
                                              color: Colors.white,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap:
                                          () => Future.delayed(
                                            Duration.zero,
                                            () => ref
                                                .read(
                                                  presentationProvider.notifier,
                                                )
                                                .duplicateSlide(index),
                                          ),
                                    ),
                                    PopupMenuItem(
                                      child: const Row(
                                        children: [
                                          Icon(
                                            Icons.delete,
                                            size: 18,
                                            color: Colors.redAccent,
                                          ),
                                          SizedBox(width: 8),
                                          Text(
                                            'Delete',
                                            style: TextStyle(
                                              color: Colors.redAccent,
                                            ),
                                          ),
                                        ],
                                      ),
                                      onTap:
                                          () => Future.delayed(
                                            Duration.zero,
                                            () => ref
                                                .read(
                                                  presentationProvider.notifier,
                                                )
                                                .deleteSlide(index),
                                          ),
                                    ),
                                  ],
                            ),
                          ],
                        ),
                        const SizedBox(height: 10),
                        Container(
                          height: 80,
                          decoration: BoxDecoration(
                            color:
                                slide.backgroundColor ??
                                presentation.theme.backgroundColor,
                            borderRadius: BorderRadius.circular(8),
                            border: Border.all(color: const Color(0xFF475569)),
                            image:
                                slide.backgroundImage != null
                                    ? DecorationImage(
                                      image: MemoryImage(
                                        slide.backgroundImage!,
                                      ),
                                      fit: BoxFit.cover,
                                    )
                                    : null,
                            gradient:
                                slide.backgroundGradient != null
                                    ? LinearGradient(
                                      colors: slide.backgroundGradient!.colors,
                                      begin: slide.backgroundGradient!.begin,
                                      end: slide.backgroundGradient!.end,
                                    )
                                    : null,
                          ),
                          child: Center(
                            child: Container(
                              padding: const EdgeInsets.symmetric(
                                horizontal: 8,
                                vertical: 4,
                              ),
                              decoration: BoxDecoration(
                                color: Colors.black.withOpacity(0.6),
                                borderRadius: BorderRadius.circular(6),
                              ),
                              child: Text(
                                '${slide.components.length} items',
                                style: const TextStyle(
                                  fontSize: 10,
                                  color: Colors.white,
                                  fontWeight: FontWeight.w500,
                                ),
                              ),
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              );
            },
          ),
        ),
      ],
    );
  }
}
