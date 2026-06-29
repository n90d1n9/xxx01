
import 'package:flutter/material.dart' as m;

import '../models/component_category.dart';
import '../models/schema/component.dart';
import '../models/schema/layout/layout.dart';
import '../models/schema/layout/section.dart';
import '../models/schema/styles/background.dart';
import '../models/schema/styles/border.dart';
import '../models/schema/styles/border_radius.dart';
import '../models/schema/styles/dimensions.dart';
import '../models/schema/styles/spacing.dart';
import '../models/schema/styles/styles.dart';
import '../models/schema/styles/typography.dart';

class ModernComponentsLibrary {
  static final Map<String, ComponentCategory> categories = {
    'hero': ComponentCategory(
      name: 'Hero Sections',
      icon: m.Icons.panorama,
      components: [
        _createHeroWithSplit(),
        _createHeroWithVideo(),
        _createHeroAnimated(),
        _createHeroMinimal(),
      ],
    ),
    'features': ComponentCategory(
      name: 'Features',
      icon: m.Icons.widgets,
      components: [
        _createFeaturesGrid(),
        _createFeaturesCards(),
        _createFeaturesTimeline(),
        _createFeaturesComparison(),
      ],
    ),
    'testimonials': ComponentCategory(
      name: 'Testimonials',
      icon: m.Icons.format_quote,
      components: [
        _createTestimonialsCarousel(),
        _createTestimonialsGrid(),
        _createTestimonialsWall(),
      ],
    ),
    'pricing': ComponentCategory(
      name: 'Pricing',
      icon: m.Icons.attach_money,
      components: [
        _createPricingCards(),
        _createPricingTable(),
        _createPricingToggle(),
      ],
    ),
    'cta': ComponentCategory(
      name: 'Call to Action',
      icon: m.Icons.call_to_action,
      components: [
        _createCTABanner(),
        _createCTASplit(),
        _createCTAModal(),
      ],
    ),
    'navigation': ComponentCategory(
      name: 'Navigation',
      icon: m.Icons.menu,
      components: [
        _createNavbarModern(),
        _createNavbarTransparent(),
        _createNavbarSidebar(),
      ],
    ),
    'stats': ComponentCategory(
      name: 'Statistics',
      icon: m.Icons.bar_chart,
      components: [
        _createStatsRow(),
        _createStatsCards(),
        _createStatsCounters(),
      ],
    ),
    'team': ComponentCategory(
      name: 'Team',
      icon: m.Icons.people,
      components: [
        _createTeamGrid(),
        _createTeamCards(),
        _createTeamCarousel(),
      ],
    ),
    'blog': ComponentCategory(
      name: 'Blog',
      icon: m.Icons.article,
      components: [
        _createBlogGrid(),
        _createBlogList(),
        _createBlogFeatured(),
      ],
    ),
    'forms': ComponentCategory(
      name: 'Forms',
      icon: m.Icons.input,
      components: [
        _createContactForm(),
        _createNewsletterForm(),
        _createMultiStepForm(),
      ],
    ),
    'gallery': ComponentCategory(
      name: 'Gallery',
      icon: m.Icons.photo_library,
      components: [
        _createGalleryMasonry(),
        _createGalleryGrid(),
        _createGalleryLightbox(),
      ],
    ),
    'interactive': ComponentCategory(
      name: 'Interactive',
      icon: m.Icons.touch_app,
      components: [
        _createAccordion(),
        _createTabs(),
        _createModal(),
        _createTooltip(),
      ],
    ),
  };

  // Hero Sections
  static Section _createHeroWithSplit() {
    return Section(
      id: 'hero-split-${DateTime.now().millisecondsSinceEpoch}',
      type: 'hero',
      name: 'Split Hero',
      layout: Layout(
        type: 'grid',
        columns: 2,
        gap: '48px',
        padding: Spacing(all: '80px'),
        alignment: 'center',
      ),
      components: [
        Component(
          id: 'hero-content',
          type: 'container',
          children: [
            Component(
              id: 'member-name-$i',
              type: 'text',
              props: {'content': 'Team Member', 'tag': 'h4'},
              styles: Styles(
                typography: Typography(
                  fontSize: '18px',
                  fontWeight: 'bold',
                ),
                margin: Spacing(bottom: '4px'),
              ),
            ),
            Component(
              id: 'member-role-$i',
              type: 'text',
              props: {'content': 'Position', 'tag': 'p'},
              styles: Styles(
                typography: Typography(color: '#6B7280'),
              ),
            ),
          ],
          styles: Styles(
            textAlign: 'center',
          ),
        );
      }),
    );
  }

  static Section _createTeamCards() {
    return Section(
      id: 'team-cards-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Team Cards',
      layout: Layout(type: 'grid', columns: 3),
      components: [],
    );
  }

  static Section _createTeamCarousel() {
    return Section(
      id: 'team-carousel-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Team Carousel',
      layout: Layout(type: 'flex'),
      components: [],
    );
  }

  // Blog
  static Section _createBlogGrid() {
    return Section(
      id: 'blog-grid-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Blog Grid',
      layout: Layout(
        type: 'grid',
        columns: 3,
        gap: '32px',
        padding: Spacing(all: '80px'),
      ),
      components: List.generate(3, (i) {
        return Component(
          id: 'blog-post-$i',
          type: 'container',
          children: [
            Component(
              id: 'post-image-$i',
              type: 'image',
              props: {
                'src': 'https://via.placeholder.com/400x250',
                'alt': 'Blog Post',
              },
              styles: Styles(
                border: Border(radius: BorderRadius(all: '12px')),
                margin: Spacing(bottom: '16px'),
              ),
            ),
            Component(
              id: 'post-category-$i',
              type: 'text',
              props: {'content': 'Technology', 'tag': 'span'},
              styles: Styles(
                typography: Typography(
                  fontSize: '12px',
                  color: '#4F46E5',
                  fontWeight: '600',
                ),
                margin: Spacing(bottom: '8px'),
              ),
            ),
            Component(
              id: 'post-title-$i',
              type: 'text',
              props: {'content': 'How to Build Modern Websites', 'tag': 'h3'},
              styles: Styles(
                typography: Typography(
                  fontSize: '20px',
                  fontWeight: 'bold',
                ),
                margin: Spacing(bottom: '8px'),
              ),
            ),
            Component(
              id: 'post-excerpt-$i',
              type: 'text',
              props: {'content': 'Learn the best practices for modern web development...', 'tag': 'p'},
              styles: Styles(
                typography: Typography(color: '#6B7280'),
                margin: Spacing(bottom: '16px'),
              ),
            ),
            Component(
              id: 'post-link-$i',
              type: 'link',
              props: {'text': 'Read More →', 'url': '#'},
              styles: Styles(
                typography: Typography(
                  color: '#4F46E5',
                  fontWeight: '600',
                ),
              ),
            ),
          ],
          styles: Styles(
            background: Background(color: '#FFFFFF'),
            border: Border(
              width: '1px',
              color: '#E5E7EB',
              radius: BorderRadius(all: '16px'),
            ),
            padding: Spacing(all: '24px'),
          ),
        );
      }),
    );
  }

  static Section _createBlogList() {
    return Section(
      id: 'blog-list-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Blog List',
      layout: Layout(type: 'flex', direction: 'column'),
      components: [],
    );
  }

  static Section _createBlogFeatured() {
    return Section(
      id: 'blog-featured-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Featured Blog Post',
      layout: Layout(type: 'flex'),
      components: [],
    );
  }

  // Forms
  static Section _createContactForm() {
    return Section(
      id: 'contact-form-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Contact Form',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        padding: Spacing(all: '80px'),
      ),
      components: [
        Component(
          id: 'form-title',
          type: 'text',
          props: {'content': 'Get In Touch', 'tag': 'h2'},
          styles: Styles(
            typography: Typography(fontSize: '36px', fontWeight: 'bold'),
            margin: Spacing(bottom: '32px'),
          ),
        ),
        Component(
          id: 'form-container',
          type: 'container',
          children: [
            Component(
              id: 'input-name',
              type: 'input',
              props: {'placeholder': 'Your Name', 'type': 'text'},
              styles: Styles(
                margin: Spacing(bottom: '16px'),
              ),
            ),
            Component(
              id: 'input-email',
              type: 'input',
              props: {'placeholder': 'Your Email', 'type': 'email'},
              styles: Styles(
                margin: Spacing(bottom: '16px'),
              ),
            ),
            Component(
              id: 'input-message',
              type: 'input',
              props: {'placeholder': 'Your Message', 'type': 'textarea'},
              styles: Styles(
                margin: Spacing(bottom: '24px'),
              ),
            ),
            Component(
              id: 'form-submit',
              type: 'button',
              props: {'text': 'Send Message', 'variant': 'contained'},
              styles: Styles(
                background: Background(color: '#4F46E5'),
                padding: Spacing(all: '14px 32px'),
                border: Border(radius: BorderRadius(all: '8px')),
              ),
            ),
          ],
          styles: Styles(
            dimensions: Dimensions(maxWidth: '600px'),
          ),
        ),
      ],
    );
  }

  static Section _createNewsletterForm() {
    return Section(
      id: 'newsletter-form-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Newsletter Form',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        alignment: 'center',
        padding: Spacing(all: '80px'),
      ),
      components: [
        Component(
          id: 'newsletter-title',
          type: 'text',
          props: {'content': 'Subscribe to Our Newsletter', 'tag': 'h3'},
          styles: Styles(
            typography: Typography(fontSize: '28px', fontWeight: 'bold'),
            margin: Spacing(bottom: '16px'),
          ),
        ),
        Component(
          id: 'newsletter-form',
          type: 'container',
          children: [
            Component(
              id: 'newsletter-input',
              type: 'input',
              props: {'placeholder': 'Enter your email', 'type': 'email'},
              styles: Styles(
                margin: Spacing(right: '8px'),
              ),
            ),
            Component(
              id: 'newsletter-button',
              type: 'button',
              props: {'text': 'Subscribe', 'variant': 'contained'},
            ),
          ],
        ),
      ],
      styles: Styles(
        background: Background(color: '#F9FAFB'),
      ),
    );
  }

  static Section _createMultiStepForm() {
    return Section(
      id: 'multistep-form-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Multi-Step Form',
      layout: Layout(type: 'flex'),
      components: [],
    );
  }

  // Gallery
  static Section _createGalleryMasonry() {
    return Section(
      id: 'gallery-masonry-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Masonry Gallery',
      layout: Layout(type: 'grid', columns: 3, gap: '16px'),
      components: [],
    );
  }

  static Section _createGalleryGrid() {
    return Section(
      id: 'gallery-grid-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Grid Gallery',
      layout: Layout(type: 'grid', columns: 4, gap: '16px'),
      components: [],
    );
  }

  static Section _createGalleryLightbox() {
    return Section(
      id: 'gallery-lightbox-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Lightbox Gallery',
      layout: Layout(type: 'grid', columns: 3),
      components: [],
    );
  }

  // Interactive
  static Section _createAccordion() {
    return Section(
      id: 'accordion-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Accordion',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        padding: Spacing(all: '80px'),
      ),
      components: List.generate(4, (i) {
        return Component(
          id: 'accordion-item-$i',
          type: 'container',
          props: {'expandable': true},
          children: [
            Component(
              id: 'accordion-header-$i',
              type: 'text',
              props: {'content': 'Question ${i + 1}', 'tag': 'h4'},
              styles: Styles(
                typography: Typography(fontWeight: 'bold'),
              ),
            ),
            Component(
              id: 'accordion-content-$i',
              type: 'text',
              props: {'content': 'Answer to question ${i + 1}', 'tag': 'p'},
              styles: Styles(
                typography: Typography(color: '#6B7280'),
              ),
            ),
          ],
          styles: Styles(
            padding: Spacing(all: '24px'),
            border: Border(
              width: '1px',
              color: '#E5E7EB',
              radius: BorderRadius(all: '8px'),
            ),
            margin: Spacing(bottom: '8px'),
          ),
        );
      }),
    );
  }

  static Section _createTabs() {
    return Section(
      id: 'tabs-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Tabs',
      layout: Layout(type: 'flex'),
      components: [],
    );
  }

  static Section _createModal() {
    return Section(
      id: 'modal-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Modal',
      layout: Layout(type: 'flex'),
      components: [],
    );
  }

  static Section _createTooltip() {
    return Section(
      id: 'tooltip-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      name: 'Tooltip',
      layout: Layout(type: 'flex'),
      components: [],
    );
  }
}
