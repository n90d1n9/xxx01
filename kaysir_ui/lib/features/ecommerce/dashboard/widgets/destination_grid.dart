import 'package:flutter/material.dart';

import '../models/destination.dart';
import 'destination_card.dart';
import 'responsive_wrap_grid.dart';

class DestinationGrid extends StatelessWidget {
  final List<Destination> destinations;
  final ValueChanged<String> onDestinationSelected;

  const DestinationGrid({
    super.key,
    required this.destinations,
    required this.onDestinationSelected,
  });

  @override
  Widget build(BuildContext context) {
    if (destinations.isEmpty) return const SizedBox.shrink();

    return ResponsiveWrapGrid(
      itemCount: destinations.length,
      columnsForWidth: _columnsForWidth,
      itemBuilder: (context, index, width) {
        final destination = destinations[index];

        return DestinationCard(
          width: width,
          destination: destination,
          onPressed: () => onDestinationSelected(destination.routePath),
        );
      },
    );
  }
}

int _columnsForWidth(double width) {
  if (width >= 1080) return 3;
  if (width >= 720) return 2;
  return 1;
}
