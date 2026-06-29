// pubspec.yaml dependencies:
/*
dependencies:
  flutter:
    sdk: flutter
  flutter_riverpod: ^2.4.9
  code_text_field: ^1.1.0
  flutter_highlight: ^0.7.0
  flutter_html: ^3.0.0-beta.2
  file_picker: ^6.1.1
  path_provider: ^2.1.1
  http: ^1.1.0
*/

import 'package:flutter/material.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:code_text_field/code_text_field.dart';
import 'package:flutter_highlight/themes/github.dart';
import 'package:flutter_highlight/themes/vs2015.dart';
import 'package:flutter_riverpod/legacy.dart';
import 'package:highlight/languages/xml.dart';
import 'package:highlight/languages/css.dart';
import 'package:highlight/languages/javascript.dart';
import 'package:flutter_html/flutter_html.dart';
import 'dart:convert';
import 'dart:io';
import 'package:http/http.dart' as http;

// Models
class EditorState {
  final String htmlCode;
  final String cssCode;
  final String jsCode;
  final int activeTabIndex;
  final bool isDarkMode;
  final bool isPreviewVisible;
  final String projectName;

  const EditorState({
    this.htmlCode =
        '<!DOCTYPE html>\n<html>\n<head>\n    <title>My Project</title>\n</head>\n<body>\n    <h1>Hello World!</h1>\n</body>\n</html>',
    this.cssCode =
        '/* Add your CSS here */\nbody {\n    font-family: Arial, sans-serif;\n    margin: 0;\n    padding: 20px;\n// Main App\n\nh1 {\n    color: #333;\n}',
    this.jsCode = '// Add your JavaScript here\nconsole.log("Hello World!");',
    this.activeTabIndex = 0,
    this.isDarkMode = false,
    this.isPreviewVisible = true,
    this.projectName = 'Untitled Project',
  });

  EditorState copyWith({
    String? htmlCode,
    String? cssCode,
    String? jsCode,
    int? activeTabIndex,
    bool? isDarkMode,
    bool? isPreviewVisible,
    String? projectName,
  }) {
    return EditorState(
      htmlCode: htmlCode ?? this.htmlCode,
      cssCode: cssCode ?? this.cssCode,
      jsCode: jsCode ?? this.jsCode,
      activeTabIndex: activeTabIndex ?? this.activeTabIndex,
      isDarkMode: isDarkMode ?? this.isDarkMode,
      isPreviewVisible: isPreviewVisible ?? this.isPreviewVisible,
      projectName: projectName ?? this.projectName,
    );
  }

  String get combinedHtml {
    return '''
<!DOCTYPE html>
<html>
<head>
    <meta charset="UTF-8">
    <meta name="viewport" content="width=device-width, initial-scale=1.0">
    <title>$projectName</title>
    <style>
$cssCode
    </style>
</head>
<body>
${htmlCode.replaceAll(RegExp(r'<!DOCTYPE html>.*?<body[^>]*>', dotAll: true), '').replaceAll('</body></html>', '')}
    <script>
$jsCode
    </script>
</body>
</html>
    ''';
  }
}

// Providers
class EditorNotifier extends StateNotifier<EditorState> {
  EditorNotifier() : super(const EditorState());

  void updateHtmlCode(String code) {
    state = state.copyWith(htmlCode: code);
  }

  void updateCssCode(String code) {
    state = state.copyWith(cssCode: code);
  }

  void updateJsCode(String code) {
    state = state.copyWith(jsCode: code);
  }

  void setActiveTab(int index) {
    state = state.copyWith(activeTabIndex: index);
  }

  void toggleDarkMode() {
    state = state.copyWith(isDarkMode: !state.isDarkMode);
  }

  void togglePreview() {
    state = state.copyWith(isPreviewVisible: !state.isPreviewVisible);
  }

  void updateProjectName(String name) {
    state = state.copyWith(projectName: name);
  }

  void resetToDefault() {
    state = const EditorState();
  }

  void loadTemplate(String template) {
    switch (template) {
      case 'blank':
        state = const EditorState();
        break;
      case 'landing':
        state = state.copyWith(
          htmlCode: '''<!DOCTYPE html>
<html>
<head>
    <title>Landing Page</title>
</head>
<body>
    <header>
        <nav>
            <div class="logo">Brand</div>
            <ul>
                <li><a href="#home">Home</a></li>
                <li><a href="#about">About</a></li>
                <li><a href="#contact">Contact</a></li>
            </ul>
        </nav>
    </header>
    <main>
        <section class="hero">
            <h1>Welcome to Our Website</h1>
            <p>Build amazing things with HTML, CSS, and JavaScript</p>
            <button class="cta-button">Get Started</button>
        </section>
    </main>
</body>
</html>''',
          cssCode: '''* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: 'Helvetica', Arial, sans-serif;
    line-height: 1.6;
}

header {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    padding: 1rem 0;
}

nav {
    display: flex;
    justify-content: space-between;
    align-items: center;
    max-width: 1200px;
    margin: 0 auto;
    padding: 0 2rem;
}

.logo {
    font-size: 1.5rem;
    font-weight: bold;
}

nav ul {
    display: flex;
    list-style: none;
    gap: 2rem;
}

nav a {
    color: white;
    text-decoration: none;
    transition: opacity 0.3s;
}

nav a:hover {
    opacity: 0.8;
}

.hero {
    text-align: center;
    padding: 5rem 2rem;
    background: linear-gradient(135deg, #f5f7fa 0%, #c3cfe2 100%);
}

.hero h1 {
    font-size: 3rem;
    margin-bottom: 1rem;
    color: #333;
}

.hero p {
    font-size: 1.2rem;
    margin-bottom: 2rem;
    color: #666;
}

.cta-button {
    background: linear-gradient(135deg, #667eea 0%, #764ba2 100%);
    color: white;
    border: none;
    padding: 1rem 2rem;
    font-size: 1.1rem;
    border-radius: 50px;
    cursor: pointer;
    transition: transform 0.3s;
}

.cta-button:hover {
    transform: translateY(-2px);
}''',
          jsCode: '''document.addEventListener('DOMContentLoaded', function() {
    const ctaButton = document.querySelector('.cta-button');
    
    ctaButton.addEventListener('click', function() {
        alert('Welcome! Let\\'s build something amazing together!');
    });
    
    // Smooth scrolling for navigation links
    document.querySelectorAll('nav a[href^="#"]').forEach(anchor => {
        anchor.addEventListener('click', function (e) {
            e.preventDefault();
            const target = document.querySelector(this.getAttribute('href'));
            if (target) {
                target.scrollIntoView({
                    behavior: 'smooth'
                });
            }
        });
    });
});''',
          projectName: 'Landing Page',
        );
        break;
      case 'dashboard':
        state = state.copyWith(
          htmlCode: '''<!DOCTYPE html>
<html>
<head>
    <title>Dashboard</title>
</head>
<body>
    <div class="container">
        <aside class="sidebar">
            <h2>Dashboard</h2>
            <nav>
                <a href="#" class="nav-item active">Overview</a>
                <a href="#" class="nav-item">Analytics</a>
                <a href="#" class="nav-item">Users</a>
                <a href="#" class="nav-item">Settings</a>
            </nav>
        </aside>
        <main class="main-content">
            <header class="header">
                <h1>Welcome back, User!</h1>
                <button class="btn-primary">New Project</button>
            </header>
            <div class="stats-grid">
                <div class="stat-card">
                    <h3>Total Users</h3>
                    <p class="stat-number">1,234</p>
                </div>
                <div class="stat-card">
                    <h3>Revenue</h3>
                    <p class="stat-number">\$12,345</p>
                </div>
                <div class="stat-card">
                    <h3>Orders</h3>
                    <p class="stat-number">567</p>
                </div>
            </div>
        </main>
    </div>
</body>
</html>''',
          cssCode: '''* {
    margin: 0;
    padding: 0;
    box-sizing: border-box;
}

body {
    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
    background-color: #f8fafc;
}

.container {
    display: flex;
    min-height: 100vh;
}

.sidebar {
    width: 250px;
    background: white;
    border-right: 1px solid #e2e8f0;
    padding: 2rem;
}

.sidebar h2 {
    color: #1a202c;
    margin-bottom: 2rem;
}

.nav-item {
    display: block;
    padding: 0.75rem 1rem;
    color: #64748b;
    text-decoration: none;
    border-radius: 0.5rem;
    margin-bottom: 0.5rem;
    transition: all 0.2s;
}

.nav-item:hover,
.nav-item.active {
    background-color: #3b82f6;
    color: white;
}

.main-content {
    flex: 1;
    padding: 2rem;
}

.header {
    display: flex;
    justify-content: space-between;
    align-items: center;
    margin-bottom: 2rem;
}

.header h1 {
    color: #1a202c;
}

.btn-primary {
    background-color: #3b82f6;
    color: white;
    border: none;
    padding: 0.75rem 1.5rem;
    border-radius: 0.5rem;
    cursor: pointer;
    font-weight: 500;
    transition: background-color 0.2s;
}

.btn-primary:hover {
    background-color: #2563eb;
}

.stats-grid {
    display: grid;
    grid-template-columns: repeat(auto-fit, minmax(250px, 1fr));
    gap: 1.5rem;
}

.stat-card {
    background: white;
    padding: 1.5rem;
    border-radius: 0.75rem;
    border: 1px solid #e2e8f0;
    box-shadow: 0 1px 3px rgba(0, 0, 0, 0.1);
}

.stat-card h3 {
    color: #64748b;
    font-size: 0.875rem;
    font-weight: 500;
    margin-bottom: 0.5rem;
}

.stat-number {
    font-size: 2rem;
    font-weight: bold;
    color: #1a202c;
}''',
          jsCode: '''document.addEventListener('DOMContentLoaded', function() {
    const navItems = document.querySelectorAll('.nav-item');
    const newProjectBtn = document.querySelector('.btn-primary');
    
    // Navigation handling
    navItems.forEach(item => {
        item.addEventListener('click', function(e) {
            e.preventDefault();
            
            // Remove active class from all items
            navItems.forEach(nav => nav.classList.remove('active'));
            
            // Add active class to clicked item
            this.classList.add('active');
            
            console.log('Navigated to:', this.textContent);
        });
    });
    
    // New project button
    newProjectBtn.addEventListener('click', function() {
        alert('Creating new project...');
    });
    
    // Animate stat numbers on load
    const statNumbers = document.querySelectorAll('.stat-number');
    statNumbers.forEach(stat => {
        const originalText = stat.textContent;
        const isNumber = /^\d+\$/.test(originalText.replace(/[,\$]/g, ''));
        
        if (isNumber) {
            const targetNumber = parseInt(originalText.replace(/[,\$]/g, ''));
            animateNumber(stat, 0, targetNumber, 1000);
        }
    });
});

function animateNumber(element, start, end, duration) {
    const range = end - start;
    const increment = range / (duration / 16);
    let current = start;
    
    const timer = setInterval(() => {
        current += increment;
        if (current >= end) {
            current = end;
            clearInterval(timer);
        }
        
        element.textContent = Math.floor(current).toLocaleString();
    }, 16);
}''',
          projectName: 'Dashboard',
        );
        break;
    }
  }
}

// Preview Widget for HTML rendering
class HtmlPreviewWidget extends StatefulWidget {
  final String htmlContent;
  final String cssContent;
  final String jsContent;

  const HtmlPreviewWidget({
    super.key,
    required this.htmlContent,
    required this.cssContent,
    required this.jsContent,
  });

  @override
  State<HtmlPreviewWidget> createState() => _HtmlPreviewWidgetState();
}

class _HtmlPreviewWidgetState extends State<HtmlPreviewWidget> {
  String _processedHtml = '';
  bool _isLoading = false;

  @override
  void initState() {
    super.initState();
    _processHtml();
  }

  @override
  void didUpdateWidget(HtmlPreviewWidget oldWidget) {
    super.didUpdateWidget(oldWidget);
    if (oldWidget.htmlContent != widget.htmlContent ||
        oldWidget.cssContent != widget.cssContent ||
        oldWidget.jsContent != widget.jsContent) {
      _processHtml();
    }
  }

  void _processHtml() {
    setState(() {
      _isLoading = true;
    });

    try {
      // Extract body content from HTML
      String bodyContent = widget.htmlContent;
      final bodyMatch = RegExp(
        r'<body[^>]*>(.*?)</body>',
        dotAll: true,
      ).firstMatch(bodyContent);
      if (bodyMatch != null) {
        bodyContent = bodyMatch.group(1) ?? '';
      } else {
        // Remove DOCTYPE, html, head, body tags for cleaner rendering
        bodyContent = bodyContent
            .replaceAll(RegExp(r'<!DOCTYPE[^>]*>', caseSensitive: false), '')
            .replaceAll(RegExp(r'</?html[^>]*>', caseSensitive: false), '')
            .replaceAll(
              RegExp(r'<head>.*?</head>', dotAll: true, caseSensitive: false),
              '',
            )
            .replaceAll(RegExp(r'</?body[^>]*>', caseSensitive: false), '');
      }

      _processedHtml = bodyContent.trim();

      setState(() {
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _processedHtml =
            '<div style="color: red; padding: 20px;">Error processing HTML: $e</div>';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return const Center(child: CircularProgressIndicator());
    }

    return SingleChildScrollView(
      padding: const EdgeInsets.all(16.0),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // CSS Styles Info
          if (widget.cssContent.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.blue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.blue.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.style, color: Colors.blue, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'CSS Styles Applied',
                    style: TextStyle(
                      color: Colors.blue.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // JavaScript Info
          if (widget.jsContent.trim().isNotEmpty)
            Container(
              margin: const EdgeInsets.only(bottom: 16),
              padding: const EdgeInsets.all(12),
              decoration: BoxDecoration(
                color: Colors.orange.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
                border: Border.all(color: Colors.orange.withOpacity(0.3)),
              ),
              child: Row(
                children: [
                  Icon(Icons.code, color: Colors.orange, size: 16),
                  const SizedBox(width: 8),
                  Text(
                    'JavaScript Code Ready',
                    style: TextStyle(
                      color: Colors.orange.shade700,
                      fontWeight: FontWeight.w500,
                    ),
                  ),
                ],
              ),
            ),

          // HTML Content
          Html(
            data:
                _processedHtml.isEmpty
                    ? '<p>Start typing HTML to see preview...</p>'
                    : _processedHtml,
            style: {
              "body": Style(margin: Margins.zero, padding: HtmlPaddings.zero),
              "*": Style(fontSize: FontSize(14)),
              "h1": Style(
                fontSize: FontSize(24),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 16),
              ),
              "h2": Style(
                fontSize: FontSize(20),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 12),
              ),
              "h3": Style(
                fontSize: FontSize(18),
                fontWeight: FontWeight.bold,
                margin: Margins.only(bottom: 10),
              ),
              "p": Style(
                margin: Margins.only(bottom: 12),
                lineHeight: LineHeight(1.5),
              ),
              "button": Style(
                backgroundColor: Colors.blue,
                color: Colors.white,
                padding: HtmlPaddings.all(12),
                margin: Margins.only(right: 8, bottom: 8),
                border: Border.all(width: 0),
              ),
              "input": Style(
                border: Border.all(color: Colors.grey),
                padding: HtmlPaddings.all(8),
                margin: Margins.only(bottom: 8),
              ),
              "nav": Style(
                backgroundColor: Colors.grey.shade100,
                padding: HtmlPaddings.all(12),
                margin: Margins.only(bottom: 16),
              ),
              "header": Style(
                backgroundColor: Colors.blue.shade50,
                padding: HtmlPaddings.all(16),
                margin: Margins.only(bottom: 16),
              ),
              "footer": Style(
                backgroundColor: Colors.grey.shade100,
                padding: HtmlPaddings.all(16),
                margin: Margins.only(top: 16),
              ),
              "section": Style(margin: Margins.only(bottom: 16)),
              "div": Style(margin: Margins.only(bottom: 8)),
              "ul": Style(
                margin: Margins.only(bottom: 12),
                //paddingLeft: 20,
              ),
              "li": Style(margin: Margins.only(bottom: 4)),
              "a": Style(
                color: Colors.blue,
                textDecoration: TextDecoration.underline,
              ),
            },
            onLinkTap: (url, attributes, element) {
              ScaffoldMessenger.of(
                context,
              ).showSnackBar(SnackBar(content: Text('Link clicked: $url')));
            },
            /* onImageError: (exception, stackTrace) {
              print('Image loading error: $exception');
            }, */
          ),
        ],
      ),
    );
  }
}

final editorProvider = StateNotifierProvider<EditorNotifier, EditorState>((
  ref,
) {
  return EditorNotifier();
});
void main() {
  runApp(const ProviderScope(child: WebEditorApp()));
}

class WebEditorApp extends ConsumerWidget {
  const WebEditorApp({super.key});

  @override
  Widget build(BuildContext context, WidgetRef ref) {
    final editorState = ref.watch(editorProvider);

    return MaterialApp(
      title: 'Web Code Editor',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: Colors.blue,
          brightness:
              editorState.isDarkMode ? Brightness.dark : Brightness.light,
        ),
      ),
      home: const EditorScreen(),
    );
  }
}

// Main Editor Screen
class EditorScreen extends ConsumerStatefulWidget {
  const EditorScreen({super.key});

  @override
  ConsumerState<EditorScreen> createState() => _EditorScreenState();
}

class _EditorScreenState extends ConsumerState<EditorScreen>
    with TickerProviderStateMixin {
  late CodeController _htmlController;
  late CodeController _cssController;
  late CodeController _jsController;
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _initializeControllers();
    _initializeTabController();
  }

  void _initializeTabController() {
    final editorState = ref.read(editorProvider);
    _tabController = TabController(
      length: 3,
      vsync: this,
      initialIndex: editorState.activeTabIndex,
    );

    _tabController.addListener(() {
      if (!_tabController.indexIsChanging) {
        ref.read(editorProvider.notifier).setActiveTab(_tabController.index);
      }
    });
  }

  void _initializeControllers() {
    final editorState = ref.read(editorProvider);

    _htmlController = CodeController(text: editorState.htmlCode, language: xml);

    _cssController = CodeController(text: editorState.cssCode, language: css);

    _jsController = CodeController(
      text: editorState.jsCode,
      language: javascript,
    );

    // Add listeners for code changes
    _htmlController.addListener(() {
      ref.read(editorProvider.notifier).updateHtmlCode(_htmlController.text);
    });

    _cssController.addListener(() {
      ref.read(editorProvider.notifier).updateCssCode(_cssController.text);
    });

    _jsController.addListener(() {
      ref.read(editorProvider.notifier).updateJsCode(_jsController.text);
    });
  }

  @override
  Widget build(BuildContext context) {
    final editorState = ref.watch(editorProvider);

    return Scaffold(
      appBar: AppBar(
        title: Text(editorState.projectName),
        backgroundColor: Theme.of(context).colorScheme.inversePrimary,
        actions: [
          IconButton(
            icon: Icon(
              editorState.isDarkMode ? Icons.light_mode : Icons.dark_mode,
            ),
            onPressed: () => ref.read(editorProvider.notifier).toggleDarkMode(),
            tooltip: 'Toggle Theme',
          ),
          IconButton(
            icon: Icon(
              editorState.isPreviewVisible
                  ? Icons.visibility_off
                  : Icons.visibility,
            ),
            onPressed: () => ref.read(editorProvider.notifier).togglePreview(),
            tooltip: 'Toggle Preview',
          ),
          PopupMenuButton<String>(
            icon: const Icon(Icons.insert_drive_file),
            tooltip: 'Templates',
            onSelected: (template) {
              ref.read(editorProvider.notifier).loadTemplate(template);
              _updateControllers();
            },
            itemBuilder:
                (context) => [
                  const PopupMenuItem(
                    value: 'blank',
                    child: Text('Blank Template'),
                  ),
                  const PopupMenuItem(
                    value: 'landing',
                    child: Text('Landing Page'),
                  ),
                  const PopupMenuItem(
                    value: 'dashboard',
                    child: Text('Dashboard'),
                  ),
                ],
          ),
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: () {
              setState(() {}); // Refresh preview
            },
            tooltip: 'Refresh Preview',
          ),
        ],
      ),
      body: Row(
        children: [
          // Code Editor Section
          Expanded(
            flex: editorState.isPreviewVisible ? 1 : 2,
            child: Column(
              children: [
                // Tab Bar
                Container(
                  decoration: BoxDecoration(
                    color: Theme.of(context).colorScheme.surface,
                    border: Border(
                      bottom: BorderSide(color: Theme.of(context).dividerColor),
                    ),
                  ),
                  child: TabBar(
                    controller: _tabController,
                    tabs: const [
                      Tab(text: 'HTML', icon: Icon(Icons.code)),
                      Tab(text: 'CSS', icon: Icon(Icons.style)),
                      Tab(text: 'JavaScript', icon: Icon(Icons.javascript)),
                    ],
                  ),
                ),
                // Code Editor
                Expanded(
                  child: TabBarView(
                    controller: _tabController,
                    children: [
                      _buildCodeEditor(_htmlController, 'HTML'),
                      _buildCodeEditor(_cssController, 'CSS'),
                      _buildCodeEditor(_jsController, 'JavaScript'),
                    ],
                  ),
                ),
              ],
            ),
          ),
          // Preview Section
          if (editorState.isPreviewVisible)
            Expanded(
              flex: 1,
              child: Container(
                decoration: BoxDecoration(
                  border: Border(
                    left: BorderSide(color: Theme.of(context).dividerColor),
                  ),
                ),
                child: Column(
                  children: [
                    Container(
                      padding: const EdgeInsets.all(8),
                      decoration: BoxDecoration(
                        color: Theme.of(context).colorScheme.surface,
                        border: Border(
                          bottom: BorderSide(
                            color: Theme.of(context).dividerColor,
                          ),
                        ),
                      ),
                      child: Row(
                        children: [
                          const Icon(Icons.preview, size: 16),
                          const SizedBox(width: 8),
                          const Text('Preview'),
                          const Spacer(),
                          IconButton(
                            icon: const Icon(Icons.refresh, size: 16),
                            onPressed: () {
                              setState(() {}); // Refresh preview
                            },
                            tooltip: 'Refresh Preview',
                          ),
                        ],
                      ),
                    ),
                    Expanded(
                      child: HtmlPreviewWidget(
                        htmlContent: editorState.htmlCode,
                        cssContent: editorState.cssCode,
                        jsContent: editorState.jsCode,
                      ),
                    ),
                  ],
                ),
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCodeEditor(CodeController controller, String language) {
    final editorState = ref.watch(editorProvider);

    return Container(
      padding: const EdgeInsets.all(8),
      child: CodeTheme(
        data: CodeThemeData(
          styles: editorState.isDarkMode ? vs2015Theme : githubTheme,
        ),
        child: CodeField(
          controller: controller,
          textStyle: const TextStyle(fontFamily: 'Fira Code', fontSize: 14),
          lineNumberStyle: LineNumberStyle(
            textStyle: TextStyle(
              color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
              fontSize: 12,
            ),
          ),
        ),
      ),
    );
  }

  void _updateControllers() {
    final editorState = ref.read(editorProvider);
    _htmlController.text = editorState.htmlCode;
    _cssController.text = editorState.cssCode;
    _jsController.text = editorState.jsCode;
  }

  @override
  void dispose() {
    _htmlController.dispose();
    _cssController.dispose();
    _jsController.dispose();
    super.dispose();
  }
}

// Extensions for better code organization
extension EditorStateExtensions on EditorState {
  bool get hasUnsavedChanges {
    return htmlCode.isNotEmpty || cssCode.isNotEmpty || jsCode.isNotEmpty;
  }

  Map<String, dynamic> toJson() {
    return {
      'htmlCode': htmlCode,
      'cssCode': cssCode,
      'jsCode': jsCode,
      'projectName': projectName,
      'isDarkMode': isDarkMode,
    };
  }
}
