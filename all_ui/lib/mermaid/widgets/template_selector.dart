import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

import '../states/mermaid_provider.dart';

class TemplateSelector extends ConsumerWidget {
  const TemplateSelector({super.key});

  static const templates = {
    'Flowchart': {
      'Basic Flow': '''graph TD
    A[Start] --> B{Decision}
    B -->|Yes| C[Action 1]
    B -->|No| D[Action 2]
    C --> E[End]
    D --> E''',
      'All Shapes': '''graph TD
    A[Rectangle] --> B(Rounded)
    B --> C([Stadium])
    C --> D[[Subroutine]]
    D --> E[(Database)]
    E --> F((Circle))
    F --> G{Diamond}
    G --> H{{Hexagon}}''',
      'Complex': '''graph TD
    Start[Start] --> Init[Initialize]
    Init --> Check{Check Status}
    Check -->|Ready| Process[Process Data]
    Check -->|Not Ready| Wait[Wait]
    Wait --> Check
    Process --> Validate{Valid?}
    Validate -->|Yes| Save[(Save to DB)]
    Validate -->|No| Error[Handle Error]
    Error --> Process
    Save --> End[End]''',
    },
    'Sequence': {
      'Basic': '''sequenceDiagram
    participant A as Alice
    participant B as Bob
    A->>B: Hello Bob!
    B->>A: Hi Alice!
    A->>B: How are you?
    B->>A: I'm good!''',
      'API Call': '''sequenceDiagram
    participant C as Client
    participant S as Server
    participant D as Database
    C->>S: Request Data
    S->>D: Query
    D-->>S: Results
    S-->>C: Response''',
    },
    'Class Diagram': {
      'Basic': '''classDiagram
    class Animal {
        +String name
        +int age
        +makeSound()
    }
    class Dog {
        +String breed
        +bark()
    }
    Animal <|-- Dog''',
      'Full Example': '''classDiagram
    class User {
        +String username
        +String email
        +login()
        +logout()
    }
    class Admin {
        +String role
        +manageUsers()
    }
    User <|-- Admin''',
    },
    'State Diagram': {
      'Simple': '''stateDiagram-v2
    [*] --> Idle
    Idle --> Processing
    Processing --> Success
    Processing --> Error
    Success --> [*]
    Error --> Idle''',
      'Complex': '''stateDiagram-v2
    [*] --> Idle
    Idle --> Processing : Start
    Processing --> Success : Complete
    Processing --> Error : Fail
    Success --> [*]
    Error --> Retry : Retry
    Retry --> Processing''',
    },
    'ER Diagram': {
      'Basic': '''erDiagram
    CUSTOMER ||--o{ ORDER : places
    ORDER ||--|{ LINE-ITEM : contains
    CUSTOMER {
        string name
        string email
    }
    ORDER {
        int orderNumber
        date orderDate
    }''',
    },
    'Gantt': {
      'Project': '''gantt
    title Project Schedule
    dateFormat YYYY-MM-DD
    section Planning
    Requirements : 2024-01-01, 7d
    Design : 2024-01-08, 5d
    section Development
    Backend : 2024-01-13, 10d
    Frontend : 2024-01-18, 12d
    section Testing
    QA Testing : 2024-01-25, 5d''',
    },
    'Pie Chart': {
      'Distribution': '''pie title Sales Distribution
    "Q1" : 35
    "Q2" : 28
    "Q3" : 22
    "Q4" : 15''',
    },
    'Timeline': {
      'History': '''timeline
    title History of Company
    2020 : Founded : First Product Launch
    2021 : Series A Funding : Expanded Team
    2022 : International Expansion : 10M Users
    2023 : IPO : Market Leader''',
    },
    'Journey': {
      'User Experience': '''journey
    title User Shopping Experience
    section Browse
    View Products: 5: User
    Add to Cart: 4: User
    section Checkout
    Enter Details: 3: User
    Payment: 4: User, System
    section Delivery
    Track Order: 5: User
    Receive: 5: User''',
    },
    'Mindmap': {
      'Project Planning': '''mindmap
  root((Project))
    Planning
      Requirements
      Timeline
      Budget
    Development
      Backend
      Frontend
      Testing
    Launch
      Marketing
      Support''',
    },
    'Git Graph': {
      'Branches': '''gitGraph
    commit id: "Initial"
    commit id: "Feature 1"
    branch develop
    checkout develop
    commit id: "Dev Work"
    checkout main
    merge develop
    commit id: "Release"''',
    },
  };

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    return Container(
      height: MediaQuery.of(context).size.height * 0.8,
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              const Text(
                'Templates',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              IconButton(
                icon: const Icon(Icons.close),
                onPressed: () => Navigator.pop(context),
              ),
            ],
          ),
          const SizedBox(height: 16),
          Expanded(
            child: ListView.builder(
              itemCount: templates.length,
              itemBuilder: (context, index) {
                final category = templates.keys.elementAt(index);
                final categoryTemplates = templates[category]!;

                return ExpansionTile(
                  title: Text(
                    category,
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  children:
                      categoryTemplates.entries.map((entry) {
                        return ListTile(
                          leading: const Icon(Icons.insert_drive_file),
                          title: Text(entry.key),
                          onTap: () {
                            ref
                                .read(mermaidProvider.notifier)
                                .loadTemplate(entry.value);
                            Navigator.pop(context);
                          },
                        );
                      }).toList(),
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
