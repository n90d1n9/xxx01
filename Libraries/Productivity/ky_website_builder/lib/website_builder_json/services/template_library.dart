import 'package:flutter/material.dart' as m;

import '../models/schema/component.dart';
import '../models/schema/layout/layout.dart';
import '../models/schema/layout/section.dart';
import '../models/schema/styles/background.dart';
import '../models/schema/styles/border.dart';
import '../models/schema/styles/border_radius.dart';
import '../models/schema/styles/gradient.dart';
import '../models/schema/styles/gradient_stop.dart';
import '../models/schema/styles/shadow.dart';
import '../models/schema/styles/shadow_layer.dart';
import '../models/schema/styles/spacing.dart';
import '../models/schema/styles/styles.dart';
import '../models/schema/styles/typography.dart';
import '../models/template.dart';

class TemplateLibrary {
  static List<Template> get templates => [
    Template(
      id: 'landing-1',
      name: 'Modern Landing Page',
      description: 'Clean and modern landing page with hero section',
      category: 'Landing Pages',
      thumbnail: 'assets/templates/landing-1.png',
      sections: [_heroSection(), _featuresSection(), _ctaSection()],
    ),
    Template(
      id: 'portfolio-1',
      name: 'Portfolio',
      description: 'Showcase your work with style',
      category: 'Portfolio',
      thumbnail: 'assets/templates/portfolio-1.png',
      sections: [_portfolioHero(), _portfolioGrid(), _contactSection()],
    ),
    Template(
      id: 'business-1',
      name: 'Business Website',
      description: 'Professional business website template',
      category: 'Business',
      thumbnail: 'assets/templates/business-1.png',
      sections: [_businessHero(), _servicesSection(), _testimonialSection()],
    ),
  ];

  static Section _heroSection() {
    return Section(
      id: 'hero-${DateTime.now().millisecondsSinceEpoch}',
      type: 'hero',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        alignment: 'center',
        padding: Spacing(all: '64px'),
      ),
      components: [
        Component(
          id: 'hero-title',
          type: 'text',
          props: {'content': 'Welcome to Your Website', 'tag': 'h1'},
          styles: Styles(
            typography: Typography(
              fontSize: '48px',
              fontWeight: 'bold',
              textAlign: 'center',
              color: '#1F2937',
            ),
            margin: Spacing(bottom: '16px'),
          ),
        ),
        Component(
          id: 'hero-subtitle',
          type: 'text',
          props: {'content': 'Create something amazing today', 'tag': 'p'},
          styles: Styles(
            typography: Typography(
              fontSize: '20px',
              textAlign: 'center',
              color: '#6B7280',
            ),
            margin: Spacing(bottom: '32px'),
          ),
        ),
        Component(
          id: 'hero-button',
          type: 'button',
          props: {'text': 'Get Started', 'variant': 'contained'},
          styles: Styles(
            background: Background(color: '#4F46E5'),
            padding: Spacing(all: '16px 32px'),
            border: Border(radius: BorderRadius(all: '8px')),
          ),
        ),
      ],
      styles: Styles(
        background: Background(
          gradient: Gradient(
            type: 'linear',
            stops: [
              GradientStop(color: '#EEF2FF', position: '0%'),
              GradientStop(color: '#FFFFFF', position: '100%'),
            ],
          ),
        ),
      ),
    );
  }

  static Section _featuresSection() {
    return Section(
      id: 'features-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      layout: Layout(
        type: 'grid',
        columns: 3,
        gap: '24px',
        padding: Spacing(all: '64px'),
      ),
      components: [
        _featureCard('Fast', m.Icons.speed, 'Lightning fast performance'),
        _featureCard('Secure', m.Icons.security, 'Bank-level security'),
        _featureCard('Reliable', m.Icons.verified, '99.9% uptime guarantee'),
      ],
    );
  }

  static Component _featureCard(
    String title,
    m.IconData icon,
    String description,
  ) {
    return Component(
      id: 'feature-${DateTime.now().millisecondsSinceEpoch}',
      type: 'container',
      children: [
        Component(
          id: 'feature-icon',
          type: 'icon',
          props: {'name': icon.toString(), 'size': 48},
          styles: Styles(margin: Spacing(bottom: '16px')),
        ),
        Component(
          id: 'feature-title',
          type: 'text',
          props: {'content': title, 'tag': 'h3'},
          styles: Styles(
            typography: Typography(fontSize: '20px', fontWeight: 'bold'),
            margin: Spacing(bottom: '8px'),
          ),
        ),
        Component(
          id: 'feature-desc',
          type: 'text',
          props: {'content': description, 'tag': 'p'},
          styles: Styles(typography: Typography(color: '#6B7280')),
        ),
      ],
      styles: Styles(
        padding: Spacing(all: '24px'),
        background: Background(color: '#FFFFFF'),
        border: Border(
          width: '1px',
          color: '#E5E7EB',
          radius: BorderRadius(all: '12px'),
        ),
        shadow: Shadow(
          boxShadow: [
            ShadowLayer(
              offsetX: '0',
              offsetY: '4px',
              blur: '12px',
              color: 'rgba(0,0,0,0.05)',
            ),
          ],
        ),
      ),
    );
  }

  static Section _ctaSection() {
    return Section(
      id: 'cta-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        alignment: 'center',
        padding: Spacing(all: '64px'),
      ),
      components: [
        Component(
          id: 'cta-title',
          type: 'text',
          props: {'content': 'Ready to get started?', 'tag': 'h2'},
          styles: Styles(
            typography: Typography(
              fontSize: '36px',
              fontWeight: 'bold',
              textAlign: 'center',
              color: '#FFFFFF',
            ),
            margin: Spacing(bottom: '24px'),
          ),
        ),
        Component(
          id: 'cta-button',
          type: 'button',
          props: {'text': 'Sign Up Now', 'variant': 'contained'},
          styles: Styles(
            background: Background(color: '#FFFFFF'),
            padding: Spacing(all: '16px 32px'),
            border: Border(radius: BorderRadius(all: '8px')),
          ),
        ),
      ],
      styles: Styles(
        background: Background(
          gradient: Gradient(
            type: 'linear',
            stops: [
              GradientStop(color: '#667eea', position: '0%'),
              GradientStop(color: '#764ba2', position: '100%'),
            ],
          ),
        ),
      ),
    );
  }

  static Section _portfolioHero() {
    return Section(
      id: 'portfolio-hero-${DateTime.now().millisecondsSinceEpoch}',
      type: 'hero',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        alignment: 'center',
        padding: Spacing(all: '96px'),
      ),
      components: [
        Component(
          id: 'portfolio-name',
          type: 'text',
          props: {'content': 'John Doe', 'tag': 'h1'},
          styles: Styles(
            typography: Typography(fontSize: '56px', fontWeight: 'bold'),
          ),
        ),
        Component(
          id: 'portfolio-role',
          type: 'text',
          props: {'content': 'Creative Designer', 'tag': 'p'},
          styles: Styles(
            typography: Typography(fontSize: '24px', color: '#6B7280'),
          ),
        ),
      ],
    );
  }

  static Section _portfolioGrid() {
    return Section(
      id: 'portfolio-grid-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      layout: Layout(
        type: 'grid',
        columns: 2,
        gap: '32px',
        padding: Spacing(all: '64px'),
      ),
      components: [
        _portfolioItem('Project 1'),
        _portfolioItem('Project 2'),
        _portfolioItem('Project 3'),
        _portfolioItem('Project 4'),
      ],
    );
  }

  static Component _portfolioItem(String title) {
    return Component(
      id: 'portfolio-item-${DateTime.now().millisecondsSinceEpoch}',
      type: 'container',
      children: [
        Component(
          id: 'portfolio-image',
          type: 'image',
          props: {'src': 'https://via.placeholder.com/600x400', 'alt': title},
        ),
        Component(
          id: 'portfolio-title',
          type: 'text',
          props: {'content': title, 'tag': 'h3'},
          styles: Styles(
            typography: Typography(fontSize: '24px', fontWeight: 'bold'),
            margin: Spacing(top: '16px'),
          ),
        ),
      ],
      styles: Styles(
        border: Border(radius: BorderRadius(all: '12px')),
        overflow: 'hidden',
      ),
    );
  }

  static Section _businessHero() {
    return Section(
      id: 'business-hero-${DateTime.now().millisecondsSinceEpoch}',
      type: 'hero',
      layout: Layout(
        type: 'flex',
        direction: 'row',
        alignment: 'center',
        padding: Spacing(all: '64px'),
      ),
      components: [
        Component(
          id: 'business-content',
          type: 'container',
          children: [
            Component(
              id: 'business-title',
              type: 'text',
              props: {'content': 'Grow Your Business', 'tag': 'h1'},
              styles: Styles(
                typography: Typography(fontSize: '48px', fontWeight: 'bold'),
              ),
            ),
            Component(
              id: 'business-desc',
              type: 'text',
              props: {
                'content': 'We help businesses succeed in the digital age',
                'tag': 'p',
              },
              styles: Styles(
                typography: Typography(fontSize: '18px', color: '#6B7280'),
                margin: Spacing(top: '16px', bottom: '32px'),
              ),
            ),
            Component(
              id: 'business-button',
              type: 'button',
              props: {'text': 'Learn More', 'variant': 'contained'},
            ),
          ],
        ),
      ],
    );
  }

  static Section _servicesSection() {
    return Section(
      id: 'services-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      layout: Layout(
        type: 'grid',
        columns: 3,
        gap: '24px',
        padding: Spacing(all: '64px'),
      ),
      components: [
        _serviceCard('Consulting', 'Expert business consulting'),
        _serviceCard('Development', 'Custom software development'),
        _serviceCard('Marketing', 'Digital marketing services'),
      ],
    );
  }

  static Component _serviceCard(String title, String description) {
    return Component(
      id: 'service-${DateTime.now().millisecondsSinceEpoch}',
      type: 'container',
      children: [
        Component(
          id: 'service-title',
          type: 'text',
          props: {'content': title, 'tag': 'h3'},
          styles: Styles(
            typography: Typography(fontSize: '24px', fontWeight: 'bold'),
            margin: Spacing(bottom: '12px'),
          ),
        ),
        Component(
          id: 'service-desc',
          type: 'text',
          props: {'content': description, 'tag': 'p'},
          styles: Styles(typography: Typography(color: '#6B7280')),
        ),
      ],
      styles: Styles(
        padding: Spacing(all: '32px'),
        background: Background(color: '#F9FAFB'),
        border: Border(radius: BorderRadius(all: '12px')),
      ),
    );
  }

  static Section _testimonialSection() {
    return Section(
      id: 'testimonial-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        alignment: 'center',
        padding: Spacing(all: '64px'),
      ),
      components: [
        Component(
          id: 'testimonial-text',
          type: 'text',
          props: {
            'content': '"This service transformed our business!"',
            'tag': 'blockquote',
          },
          styles: Styles(
            typography: Typography(
              fontSize: '24px',
              fontStyle: 'italic',
              textAlign: 'center',
            ),
            margin: Spacing(bottom: '16px'),
          ),
        ),
        Component(
          id: 'testimonial-author',
          type: 'text',
          props: {'content': '- Happy Customer', 'tag': 'p'},
          styles: Styles(
            typography: Typography(color: '#6B7280', textAlign: 'center'),
          ),
        ),
      ],
      styles: Styles(background: Background(color: '#F9FAFB')),
    );
  }

  static Section _contactSection() {
    return Section(
      id: 'contact-${DateTime.now().millisecondsSinceEpoch}',
      type: 'content',
      layout: Layout(
        type: 'flex',
        direction: 'column',
        alignment: 'center',
        padding: Spacing(all: '64px'),
      ),
      components: [
        Component(
          id: 'contact-title',
          type: 'text',
          props: {'content': 'Get In Touch', 'tag': 'h2'},
          styles: Styles(
            typography: Typography(
              fontSize: '36px',
              fontWeight: 'bold',
              textAlign: 'center',
            ),
            margin: Spacing(bottom: '32px'),
          ),
        ),
        Component(
          id: 'contact-email',
          type: 'link',
          props: {
            'text': 'contact@example.com',
            'url': 'mailto:contact@example.com',
          },
          styles: Styles(
            typography: Typography(fontSize: '20px', color: '#4F46E5'),
          ),
        ),
      ],
    );
  }
}
