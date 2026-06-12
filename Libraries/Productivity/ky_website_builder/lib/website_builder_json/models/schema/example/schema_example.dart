/// Example usage and sample JSON structure
class SchemaExamples {
  static Map<String, dynamic> get minimalWebsite => {
    'id': 'website-001',
    'version': '1.0.0',
    'metadata': {
      'name': 'My Website',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
    },
    'pages': [
      {
        'id': 'page-001',
        'name': 'Home',
        'path': '/',
        'sections': [
          {
            'id': 'section-001',
            'type': 'hero',
            'layout': {
              'type': 'flex',
              'direction': 'column',
              'alignment': 'center',
            },
            'components': [
              {
                'id': 'comp-001',
                'type': 'text',
                'props': {'content': 'Welcome to My Website', 'tag': 'h1'},
              },
            ],
          },
        ],
      },
    ],
  };

  static Map<String, dynamic> get fullFeaturedWebsite => {
    'id': 'website-002',
    'version': '1.0.0',
    'metadata': {
      'name': 'E-Commerce Store',
      'description': 'Modern e-commerce website',
      'author': 'Designer Name',
      'createdAt': DateTime.now().toIso8601String(),
      'updatedAt': DateTime.now().toIso8601String(),
      'seo': {
        'defaultTitle': 'My Store - Shop Online',
        'defaultDescription': 'Best products at great prices',
      },
    },
    'globalStyles': {
      'colorPalette': {
        'primary': '#4F46E5',
        'secondary': '#10B981',
        'background': '#FFFFFF',
        'text': '#1F2937',
      },
      'typography': {'h1': '3rem', 'h2': '2.25rem', 'body': '1rem'},
      'spacing': {
        'xs': '0.25rem',
        'sm': '0.5rem',
        'md': '1rem',
        'lg': '2rem',
        'xl': '4rem',
      },
    },
    'pages': [
      {
        'id': 'page-home',
        'name': 'Home',
        'path': '/',
        'metadata': {
          'title': 'Home - My Store',
          'description': 'Welcome to our online store',
        },
        'sections': [
          {
            'id': 'section-header',
            'type': 'header',
            'layout': {
              'type': 'flex',
              'direction': 'row',
              'justifyContent': 'space-between',
              'padding': {'all': '1rem'},
            },
            'components': [
              {
                'id': 'logo',
                'type': 'image',
                'props': {'src': '/assets/logo.png', 'alt': 'Store Logo'},
                'styles': {
                  'dimensions': {'height': '48px'},
                },
              },
              {
                'id': 'nav',
                'type': 'navigation',
                'props': {
                  'items': [
                    {'label': 'Home', 'link': '/'},
                    {'label': 'Products', 'link': '/products'},
                    {'label': 'About', 'link': '/about'},
                  ],
                },
              },
            ],
            'styles': {
              'background': {'color': '#FFFFFF'},
              'shadow': {
                'boxShadow': [
                  {
                    'offsetX': '0',
                    'offsetY': '2px',
                    'blur': '4px',
                    'color': 'rgba(0,0,0,0.1)',
                  },
                ],
              },
            },
          },
        ],
      },
    ],
  };
}
