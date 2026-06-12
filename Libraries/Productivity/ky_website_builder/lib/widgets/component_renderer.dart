import 'package:flutter/material.dart';

import '../models/component_type.dart';
import '../models/design_component.dart';

class ComponentRenderer extends StatelessWidget {
  final DesignComponent component;

  const ComponentRenderer({super.key, required this.component});

  @override
  Widget build(BuildContext context) {
    return AnimatedContainer(
      duration: Duration(
        milliseconds: (component.animation.duration * 1000).toInt(),
      ),
      curve: component.animation.curve,
      child: _buildComponent(),
    );
  }

  Widget _buildComponent() {
    switch (component.type) {
      case ComponentType.hero:
        return _buildHero();
      case ComponentType.glassmorphism:
        return _buildGlassmorphism();
      case ComponentType.neumorphism:
        return _buildNeumorphism();
      case ComponentType.card:
        return _buildCard();
      case ComponentType.productCard:
        return _buildProductCard();
      case ComponentType.button:
        return _buildButton();
      case ComponentType.text:
        return _buildText();
      case ComponentType.input:
        return _buildInput();
      case ComponentType.image:
        return _buildImage();
      case ComponentType.imageCarousel:
        return _buildCarousel();
      case ComponentType.chart:
        return _buildChart();
      case ComponentType.progressBar:
        return _buildProgressBar();
      case ComponentType.rating:
        return _buildRating();
      case ComponentType.shimmer:
        return _buildShimmer();
      case ComponentType.chip:
        return _buildChip();
      case ComponentType.badge:
        return _buildBadge();
      case ComponentType.icon:
        return _buildIcon();
      case ComponentType.checkbox:
        return _buildCheckbox();
      case ComponentType.slider:
        return _buildSlider();
      default:
        return _buildPlaceholder();
    }
  }

  Widget _buildHero() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
          colors: [
            component.style.backgroundColor ?? Colors.blue,
            (component.style.backgroundColor ?? Colors.blue).withOpacity(0.7),
          ],
        ),
        borderRadius: BorderRadius.circular(component.style.borderRadius ?? 0),
      ),
      padding: const EdgeInsets.all(32),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(
            component.properties['title'] ?? 'Hero Title',
            style: TextStyle(
              fontSize: component.style.fontSize ?? 48,
              fontWeight: component.style.fontWeight ?? FontWeight.bold,
              color: component.style.foregroundColor ?? Colors.white,
            ),
          ),
          const SizedBox(height: 16),
          Text(
            component.properties['subtitle'] ?? 'Subtitle',
            style: TextStyle(
              fontSize: (component.style.fontSize ?? 48) / 2,
              color: (component.style.foregroundColor ?? Colors.white)
                  .withOpacity(0.9),
            ),
          ),
          const SizedBox(height: 24),
          ElevatedButton(
            onPressed: () {},
            style: ElevatedButton.styleFrom(
              backgroundColor: Colors.white,
              foregroundColor: component.style.backgroundColor,
              padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
            ),
            child: Text(component.properties['ctaText'] ?? 'Get Started'),
          ),
        ],
      ),
    );
  }

  Widget _buildGlassmorphism() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.1),
        borderRadius: BorderRadius.circular(component.style.borderRadius ?? 16),
        border: Border.all(color: Colors.white.withOpacity(0.2), width: 1.5),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.1),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: const Center(
        child: Text(
          'Glassmorphism',
          style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
        ),
      ),
    );
  }

  Widget _buildNeumorphism() {
    final bgColor = component.style.backgroundColor ?? const Color(0xFFE0E0E0);
    return Container(
      decoration: BoxDecoration(
        color: bgColor,
        borderRadius: BorderRadius.circular(component.style.borderRadius ?? 20),
        boxShadow: [
          BoxShadow(
            color: Colors.white,
            offset: const Offset(-5, -5),
            blurRadius: 10,
          ),
          BoxShadow(
            color: Colors.black.withOpacity(0.2),
            offset: const Offset(5, 5),
            blurRadius: 10,
          ),
        ],
      ),
      child: const Center(
        child: Icon(Icons.favorite, size: 48, color: Colors.grey),
      ),
    );
  }

  Widget _buildCard() {
    return Card(
      elevation: 4,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(component.style.borderRadius ?? 12),
      ),
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              height: 100,
              decoration: BoxDecoration(
                color: Colors.grey.shade300,
                borderRadius: BorderRadius.circular(8),
              ),
              child: const Center(child: Icon(Icons.image, size: 40)),
            ),
            const SizedBox(height: 12),
            const Text(
              'Card Title',
              style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 8),
            const Text(
              'Card description',
              style: TextStyle(fontSize: 12, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildProductCard() {
    return Card(
      elevation: 8,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Expanded(
            flex: 3,
            child: Container(
              decoration: BoxDecoration(
                color: Colors.grey.shade200,
                borderRadius: const BorderRadius.vertical(
                  top: Radius.circular(16),
                ),
              ),
              child: Stack(
                children: [
                  const Center(
                    child: Icon(
                      Icons.shopping_bag,
                      size: 64,
                      color: Colors.grey,
                    ),
                  ),
                  Positioned(
                    top: 8,
                    right: 8,
                    child: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: const BoxDecoration(
                        color: Colors.red,
                        shape: BoxShape.circle,
                      ),
                      child: const Icon(
                        Icons.favorite,
                        size: 16,
                        color: Colors.white,
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
          Expanded(
            flex: 2,
            child: Padding(
              padding: const EdgeInsets.all(12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    component.properties['title'] ?? 'Product',
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  const Spacer(),
                  Row(
                    children: [
                      Text(
                        component.properties['price'] ?? '\$99',
                        style: const TextStyle(
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                          color: Colors.blue,
                        ),
                      ),
                      const Spacer(),
                      Container(
                        padding: const EdgeInsets.all(6),
                        decoration: BoxDecoration(
                          color: Colors.blue,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Icon(
                          Icons.add_shopping_cart,
                          size: 16,
                          color: Colors.white,
                        ),
                      ),
                    ],
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildButton() {
    return ElevatedButton(
      style: ElevatedButton.styleFrom(
        backgroundColor: component.style.backgroundColor ?? Colors.blue,
        foregroundColor: component.style.foregroundColor ?? Colors.white,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(
            component.style.borderRadius ?? 8,
          ),
        ),
        padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 12),
      ),
      onPressed: () {},
      child: Text(component.properties['text'] ?? 'Button'),
    );
  }

  Widget _buildText() {
    return Text(
      component.properties['text'] ?? 'Text',
      style: TextStyle(
        fontSize: component.style.fontSize ?? 16,
        color: component.style.foregroundColor ?? Colors.black,
        fontWeight: component.style.fontWeight ?? FontWeight.normal,
      ),
    );
  }

  Widget _buildInput() {
    return TextField(
      decoration: InputDecoration(
        hintText: component.properties['placeholder'] ?? 'Enter text',
        filled: true,
        fillColor: component.style.backgroundColor ?? Colors.white,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(
            component.style.borderRadius ?? 8,
          ),
        ),
      ),
    );
  }

  Widget _buildImage() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade300,
        borderRadius: BorderRadius.circular(component.style.borderRadius ?? 0),
      ),
      child: const Center(
        child: Icon(Icons.image, size: 64, color: Colors.grey),
      ),
    );
  }

  Widget _buildCarousel() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade900,
        borderRadius: BorderRadius.circular(12),
      ),
      child: Stack(
        children: [
          const Center(
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Icon(Icons.view_carousel, size: 64, color: Colors.white54),
                SizedBox(height: 8),
                Text('Carousel', style: TextStyle(color: Colors.white54)),
              ],
            ),
          ),
          Positioned(
            bottom: 16,
            left: 0,
            right: 0,
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: List.generate(
                3,
                (i) => Container(
                  margin: const EdgeInsets.symmetric(horizontal: 4),
                  width: 8,
                  height: 8,
                  decoration: BoxDecoration(
                    color: i == 0 ? Colors.white : Colors.white38,
                    shape: BoxShape.circle,
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildChart() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.grey.shade300),
      ),
      padding: const EdgeInsets.all(16),
      child: Column(
        children: [
          const Text('Chart', style: TextStyle(fontWeight: FontWeight.bold)),
          const Spacer(),
          Row(
            crossAxisAlignment: CrossAxisAlignment.end,
            mainAxisAlignment: MainAxisAlignment.spaceEvenly,
            children: List.generate(
              5,
              (i) => Container(
                width: 40,
                height: 50.0 + (i * 20),
                decoration: BoxDecoration(
                  color: Colors.blue.shade300,
                  borderRadius: const BorderRadius.vertical(
                    top: Radius.circular(4),
                  ),
                ),
              ),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildProgressBar() {
    final value = component.properties['value'] ?? 0.7;
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(component.style.borderRadius ?? 4),
      ),
      child: FractionallySizedBox(
        widthFactor: value,
        alignment: Alignment.centerLeft,
        child: Container(
          decoration: BoxDecoration(
            color: Colors.blue,
            borderRadius: BorderRadius.circular(
              component.style.borderRadius ?? 4,
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildRating() {
    final value = component.properties['value'] ?? 4.5;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: List.generate(
        5,
        (i) => Icon(
          i < value.floor()
              ? Icons.star
              : (i < value ? Icons.star_half : Icons.star_border),
          color: Colors.amber,
          size: 24,
        ),
      ),
    );
  }

  Widget _buildShimmer() {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [
            Colors.grey.shade300,
            Colors.grey.shade100,
            Colors.grey.shade300,
          ],
          stops: const [0.0, 0.5, 1.0],
        ),
        borderRadius: BorderRadius.circular(8),
      ),
      child: const Center(
        child: Text('Shimmer', style: TextStyle(color: Colors.grey)),
      ),
    );
  }

  Widget _buildChip() {
    return Chip(
      label: const Text('Chip'),
      avatar: const CircleAvatar(child: Icon(Icons.person, size: 16)),
      backgroundColor: component.style.backgroundColor ?? Colors.blue.shade50,
    );
  }

  Widget _buildBadge() {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
      decoration: BoxDecoration(
        color: component.style.backgroundColor ?? Colors.red,
        borderRadius: BorderRadius.circular(12),
      ),
      child: const Text(
        '9+',
        style: TextStyle(
          color: Colors.white,
          fontSize: 12,
          fontWeight: FontWeight.bold,
        ),
      ),
    );
  }

  Widget _buildIcon() {
    return Icon(
      Icons.star,
      size: component.properties['size'] ?? 24,
      color: component.style.foregroundColor ?? Colors.blue,
    );
  }

  Widget _buildCheckbox() {
    return Checkbox(
      value: component.properties['checked'] ?? false,
      onChanged: (v) {},
      activeColor: component.style.backgroundColor ?? Colors.blue,
    );
  }

  Widget _buildSlider() {
    return Slider(
      value: component.properties['value'] ?? 0.5,
      onChanged: (v) {},
      activeColor: component.style.backgroundColor ?? Colors.blue,
    );
  }

  Widget _buildPlaceholder() {
    return Container(
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(
          color: Colors.grey.shade400,
          style: BorderStyle.solid,
        ),
      ),
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(_getIconForType(), size: 32, color: Colors.grey),
            const SizedBox(height: 8),
            Text(
              component.type.name,
              style: const TextStyle(fontSize: 11, color: Colors.grey),
            ),
          ],
        ),
      ),
    );
  }

  IconData _getIconForType() {
    switch (component.type) {
      case ComponentType.container:
        return Icons.crop_square;
      case ComponentType.column:
        return Icons.view_column;
      case ComponentType.row:
        return Icons.view_week;
      default:
        return Icons.widgets;
    }
  }
}
