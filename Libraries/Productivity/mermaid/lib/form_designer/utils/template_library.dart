import '../model/field_config.dart';
import '../model/form_template.dart';

class TemplateLibrary {
  static final List<FormTemplate> predefined = [
    FormTemplate(
      id: 'contact_form',
      name: 'Contact Form',
      description: 'Simple contact form with name, email, and message',
      category: 'Contact',
      tags: ['contact', 'email', 'basic'],
      thumbnail: '📧',
      fields: [
        FieldConfig(
          id: 'name',
          type: 'text',
          name: 'name',
          label: 'Full Name',
          required: true,
        ),
        FieldConfig(
          id: 'email',
          type: 'email',
          name: 'email',
          label: 'Email Address',
          required: true,
        ),
        FieldConfig(
          id: 'message',
          type: 'textarea',
          name: 'message',
          label: 'Message',
          required: true,
        ),
      ],
      metadata: {},
      createdAt: DateTime.now(),
      usageCount: 150,
      rating: 4.5,
    ),
    FormTemplate(
      id: 'registration',
      name: 'User Registration',
      description: 'Complete user registration with validation',
      category: 'Authentication',
      tags: ['registration', 'auth', 'user'],
      thumbnail: '👤',
      fields: [
        FieldConfig(
          id: 'username',
          type: 'text',
          name: 'username',
          label: 'Username',
          required: true,
        ),
        FieldConfig(
          id: 'email',
          type: 'email',
          name: 'email',
          label: 'Email',
          required: true,
        ),
        FieldConfig(
          id: 'password',
          type: 'password',
          name: 'password',
          label: 'Password',
          required: true,
        ),
        FieldConfig(
          id: 'confirm_password',
          type: 'password',
          name: 'confirm_password',
          label: 'Confirm Password',
          required: true,
        ),
      ],
      metadata: {},
      createdAt: DateTime.now(),
      usageCount: 200,
      rating: 4.8,
    ),
  ];
}
