import 'code_template.dart';

class TemplateRegistry {
  static final Map<String, List<CodeTemplate>> _templates = {
    'nodejs': _getNodeJSTemplates(),
    'deno': _getDenoTemplates(),
    'laravel': _getLaravelTemplates(),
    'flutter': _getFlutterTemplates(),
    'react': _getReactTemplates(),
  };
  static List<CodeTemplate> getTemplates(String framework) {
    return _templates[framework] ?? [];
  }

  static List<CodeTemplate> _getNodeJSTemplates() {
    return [
      CodeTemplate(
        id: 'nodejs_entity',
        name: 'Prisma Entity',
        framework: 'Node.js/TypeScript',
        language: 'typescript',
        category: 'entity',
        filePath: 'prisma/schema.prisma',
        template: '''
model {{className}} {
  id        String   @id @default(uuid())
{{#fields}}
  {{name}}  {{#isRequired}}{{type}}{{/isRequired}}{{^isRequired}}{{type}}?{{/isRequired}}{{#isUnique}} @unique{{/isUnique}}
{{/fields}}
  createdAt DateTime @default(now())
  updatedAt DateTime @updatedAt
  published Boolean  @default(false)
{{#relationships}}
  {{name}}  {{targetModel}}{{#isArray}}[]{{/isArray}}{{^isRequired}}?{{/isRequired}}
{{/relationships}}

  @@index([createdAt])
{{#indexedFields}}
  @@index([{{name}}])
{{/indexedFields}}
}
''',
        dependencies: {'@prisma/client': '^5.0.0', 'prisma': '^5.0.0'},
      ),
      CodeTemplate(
        id: 'nodejs_controller',
        name: 'Express Controller',
        framework: 'Node.js/TypeScript',
        language: 'typescript',
        category: 'resource',
        filePath: 'src/controllers/{{fileName}}.controller.ts',
        template: '''
import { Request, Response } from 'express';
import { PrismaClient } from '@prisma/client';

const prisma = new PrismaClient();

export class {{className}}Controller {
  
  // GET /{{tableName}}
  async list(req: Request, res: Response) {
    const { page = 0, size = 20 } = req.query;
    
    const items = await prisma.{{camelCaseName}}.findMany({
      skip: Number(page) * Number(size),
      take: Number(size),
      orderBy: { createdAt: 'desc' }
    });
    
    const total = await prisma.{{camelCaseName}}.count();
    
    res.json({
      items,
      total,
      page: Number(page),
      size: Number(size)
    });
  }
  
  // GET /{{tableName}}/:id
  async get(req: Request, res: Response) {
    const { id } = req.params;
    
    const item = await prisma.{{camelCaseName}}.findUnique({
      where: { id }
    });
    
    if (!item) {
      return res.status(404).json({ error: 'Not found' });
    }
    
    res.json(item);
  }
  
  // POST /{{tableName}}
  async create(req: Request, res: Response) {
    const data = req.body;
    
    const item = await prisma.{{camelCaseName}}.create({
      data: {
        ...data,
        createdAt: new Date(),
        updatedAt: new Date()
      }
    });
    
    res.status(201).json(item);
  }
  
  // PUT /{{tableName}}/:id
  async update(req: Request, res: Response) {
    const { id } = req.params;
    const data = req.body;
    
    const item = await prisma.{{camelCaseName}}.update({
      where: { id },
      data: {
        ...data,
        updatedAt: new Date()
      }
    });
    
    res.json(item);
  }
  
  // DELETE /{{tableName}}/:id
  async delete(req: Request, res: Response) {
    const { id } = req.params;
    
    await prisma.{{camelCaseName}}.delete({
      where: { id }
    });
    
    res.status(204).send();
  }
}
''',
        dependencies: {'express': '^4.18.0', '@types/express': '^4.17.0'},
      ),
      CodeTemplate(
        id: 'nodejs_routes',
        name: 'Express Routes',
        framework: 'Node.js/TypeScript',
        language: 'typescript',
        category: 'resource',
        filePath: 'src/routes/{{fileName}}.routes.ts',
        template: '''
import { Router } from 'express';
import { {{className}}Controller } from '../controllers/{{fileName}}.controller';

const router = Router();
const controller = new {{className}}Controller();

router.get('/{{tableName}}', controller.list.bind(controller));
router.get('/{{tableName}}/:id', controller.get.bind(controller));
router.post('/{{tableName}}', controller.create.bind(controller));
router.put('/{{tableName}}/:id', controller.update.bind(controller));
router.delete('/{{tableName}}/:id', controller.delete.bind(controller));

export default router;
''',
      ),
      CodeTemplate(
        id: 'nodejs_package',
        name: 'package.json',
        framework: 'Node.js/TypeScript',
        language: 'json',
        category: 'config',
        filePath: 'package.json',
        template: '''
{
  "name": "{{projectName}}",
  "version": "1.0.0",
  "description": "Auto-generated API from CMS schemas",
  "main": "dist/index.js",
  "scripts": {
    "dev": "tsx watch src/index.ts",
    "build": "tsc",
    "start": "node dist/index.js",
    "prisma:generate": "prisma generate",
    "prisma:migrate": "prisma migrate dev"
  },
  "dependencies": {
    "express": "^4.18.0",
    "@prisma/client": "^5.0.0",
    "cors": "^2.8.5",
    "dotenv": "^16.0.0"
  },
  "devDependencies": {
    "@types/express": "^4.17.0",
    "@types/node": "^20.0.0",
    "prisma": "^5.0.0",
    "tsx": "^4.0.0",
    "typescript": "^5.0.0"
  }
}
''',
      ),
    ];
  }

  static List<CodeTemplate> _getDenoTemplates() {
    return [
      CodeTemplate(
        id: 'deno_handler',
        name: 'Fresh Handler',
        framework: 'Deno',
        language: 'typescript',
        category: 'resource',
        filePath: 'routes/{{tableName}}/index.ts',
        template: '''
import { Handlers } from "\$fresh/server.ts";

interface {{className}} {
  id: string;
{{#fields}}
  {{name}}{{^isRequired}}?{{/isRequired}}: {{tsType}};
{{/fields}}
  createdAt: Date;
  updatedAt: Date;
  published: boolean;
}

const kv = await Deno.openKv();

export const handler: Handlers<{{className}}[]> = {
  async GET(_req) {
    const entries = [];
    const iter = kv.list<{{className}}>({ prefix: ["{{tableName}}"] });
    
    for await (const entry of iter) {
      entries.push(entry.value);
    }
    
    return new Response(JSON.stringify(entries), {
      headers: { "Content-Type": "application/json" },
    });
  },
  
  async POST(req) {
    const data = await req.json();
    const id = crypto.randomUUID();
    
    const item: {{className}} = {
      id,
      ...data,
      createdAt: new Date(),
      updatedAt: new Date(),
      published: false
    };
    
    await kv.set(["{{tableName}}", id], item);
    
    return new Response(JSON.stringify(item), {
      status: 201,
      headers: { "Content-Type": "application/json" },
    });
  }
};
''',
      ),
      CodeTemplate(
        id: 'deno_detail_handler',
        name: 'Fresh Detail Handler',
        framework: 'Deno',
        language: 'typescript',
        category: 'resource',
        filePath: 'routes/{{tableName}}/[id].ts',
        template: '''
import { Handlers } from "\$fresh/server.ts";

const kv = await Deno.openKv();

export const handler: Handlers = {
  async GET(_req, ctx) {
    const id = ctx.params.id;
    const result = await kv.get(["{{tableName}}", id]);
    
    if (!result.value) {
      return new Response("Not found", { status: 404 });
    }
    
    return new Response(JSON.stringify(result.value), {
      headers: { "Content-Type": "application/json" },
    });
  },
  
  async PUT(req, ctx) {
    const id = ctx.params.id;
    const data = await req.json();
    
    const existing = await kv.get(["{{tableName}}", id]);
    if (!existing.value) {
      return new Response("Not found", { status: 404 });
    }
    
    const updated = {
      ...(existing.value as Record<string, unknown>),
      ...data,
      updatedAt: new Date()
    };
    
    await kv.set(["{{tableName}}", id], updated);
    
    return new Response(JSON.stringify(updated), {
      headers: { "Content-Type": "application/json" },
    });
  },
  
  async DELETE(_req, ctx) {
    const id = ctx.params.id;
    await kv.delete(["{{tableName}}", id]);
    
    return new Response(null, { status: 204 });
  }
};
''',
      ),
      CodeTemplate(
        id: 'deno_config',
        name: 'deno.json',
        framework: 'Deno',
        language: 'json',
        category: 'config',
        filePath: 'deno.json',
        template: '''
{
  "tasks": {
    "dev": "deno run --allow-net --allow-read --allow-env --watch main.ts",
    "start": "deno run --allow-net --allow-read --allow-env main.ts"
  },
  "imports": {
    "\$fresh/": "https://deno.land/x/fresh@1.6.0/"
  }
}
''',
      ),
    ];
  }

  static List<CodeTemplate> _getLaravelTemplates() {
    return [
      CodeTemplate(
        id: 'laravel_model',
        name: 'Eloquent Model',
        framework: 'Laravel',
        language: 'php',
        category: 'entity',
        filePath: 'app/Models/{{className}}.php',
        template: '''
<?php

namespace App\\Models;

use Illuminate\\Database\\Eloquent\\Model;
use Illuminate\\Database\\Eloquent\\Factories\\HasFactory;

class {{className}} extends Model
{
    use HasFactory;

    protected \$table = '{{tableName}}';

    protected \$fillable = [
{{#fields}}
        '{{name}}',
{{/fields}}
    ];

    protected \$casts = [
{{#fields}}
{{#isCastable}}
        '{{name}}' => '{{castType}}',
{{/isCastable}}
{{/fields}}
        'published' => 'boolean',
        'created_at' => 'datetime',
        'updated_at' => 'datetime',
    ];

{{#relationships}}
    public function {{name}}()
    {
        return \$this->{{relationType}}({{targetModel}}::class);
    }

{{/relationships}}
}
''',
      ),
      CodeTemplate(
        id: 'laravel_controller',
        name: 'API Controller',
        framework: 'Laravel',
        language: 'php',
        category: 'resource',
        filePath: 'app/Http/Controllers/{{className}}Controller.php',
        template: '''
<?php

namespace App\\Http\\Controllers;

use App\\Models\\{{className}};
use Illuminate\\Http\\Request;

class {{className}}Controller extends Controller
{
    public function index(Request \$request)
    {
        \$query = {{className}}::query();
        
        if (\$request->has('published')) {
            \$query->where('published', \$request->boolean('published'));
        }
        
        \$items = \$query->paginate(\$request->input('per_page', 20));
        
        return response()->json(\$items);
    }

    public function show(\$id)
    {
        \$item = {{className}}::findOrFail(\$id);
        return response()->json(\$item);
    }

    public function store(Request \$request)
    {
        \$validated = \$request->validate([
{{#fields}}
{{#isRequired}}
            '{{name}}' => 'required{{#validationRules}}|{{validationRules}}{{/validationRules}}',
{{/isRequired}}
{{^isRequired}}
            '{{name}}' => 'nullable{{#validationRules}}|{{validationRules}}{{/validationRules}}',
{{/isRequired}}
{{/fields}}
        ]);

        \$item = {{className}}::create(\$validated);
        
        return response()->json(\$item, 201);
    }

    public function update(Request \$request, \$id)
    {
        \$item = {{className}}::findOrFail(\$id);
        
        \$validated = \$request->validate([
{{#fields}}
            '{{name}}' => 'nullable{{#validationRules}}|{{validationRules}}{{/validationRules}}',
{{/fields}}
        ]);

        \$item->update(\$validated);
        
        return response()->json(\$item);
    }

    public function destroy(\$id)
    {
        \$item = {{className}}::findOrFail(\$id);
        \$item->delete();
        
        return response()->json(null, 204);
    }
}
''',
      ),
      CodeTemplate(
        id: 'laravel_migration',
        name: 'Database Migration',
        framework: 'Laravel',
        language: 'php',
        category: 'migration',
        filePath:
            'database/migrations/{{timestamp}}_create_{{tableName}}_table.php',
        template: '''
<?php

use Illuminate\\Database\\Migrations\\Migration;
use Illuminate\\Database\\Schema\\Blueprint;
use Illuminate\\Support\\Facades\\Schema;

return new class extends Migration
{
    public function up(): void
    {
        Schema::create('{{tableName}}', function (Blueprint \$table) {
            \$table->uuid('id')->primary();
{{#fields}}
            \$table->{{laravelType}}('{{name}}'){{^isRequired}}->nullable(){{/isRequired}}{{#isUnique}}->unique(){{/isUnique}};
{{/fields}}
            \$table->timestamps();
            \$table->boolean('published')->default(false);
            \$table->timestamp('published_at')->nullable();

{{#indexedFields}}
            \$table->index('{{name}}');
{{/indexedFields}}
        });
    }

    public function down(): void
    {
        Schema::dropIfExists('{{tableName}}');
    }
};
''',
      ),
    ];
  }

  static List<CodeTemplate> _getFlutterTemplates() {
    return [
      CodeTemplate(
        id: 'flutter_model',
        name: 'Data Model',
        framework: 'Flutter',
        language: 'dart',
        category: 'entity',
        filePath: 'lib/models/{{fileName}}.dart',
        template: '''
class {{className}} {
  final String id;
{{#fields}}
  final {{dartType}}{{^isRequired}}?{{/isRequired}} {{name}};
{{/fields}}
  final DateTime createdAt;
  final DateTime updatedAt;
  final bool published;

  const {{className}}({
    required this.id,
{{#fields}}
    {{#isRequired}}required {{/isRequired}}this.{{name}},
{{/fields}}
    required this.createdAt,
    required this.updatedAt,
    required this.published,
  });

  factory {{className}}.fromJson(Map<String, dynamic> json) {
    return {{className}}(
      id: json['id'] as String,
{{#fields}}
      {{name}}: {{#jsonDecoder}}{{jsonDecoder}}{{/jsonDecoder}}{{^jsonDecoder}}json['{{name}}']{{/jsonDecoder}},
{{/fields}}
      createdAt: DateTime.parse(json['createdAt'] as String),
      updatedAt: DateTime.parse(json['updatedAt'] as String),
      published: json['published'] as bool,
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'id': id,
{{#fields}}
      '{{name}}': {{#jsonEncoder}}{{jsonEncoder}}{{/jsonEncoder}}{{^jsonEncoder}}{{name}}{{/jsonEncoder}},
{{/fields}}
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'published': published,
    };
  }
}
''',
      ),
      CodeTemplate(
        id: 'flutter_api_client',
        name: 'API Client',
        framework: 'Flutter',
        language: 'dart',
        category: 'resource',
        filePath: 'lib/services/{{fileName}}_service.dart',
        template: '''
import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/{{fileName}}.dart';

class {{className}}Service {
  final String baseUrl;

  {{className}}Service({required this.baseUrl});

  Future<List<{{className}}>> list() async {
    final response = await http.get(
      Uri.parse('\$baseUrl/{{tableName}}'),
    );

    if (response.statusCode == 200) {
      final List<dynamic> json = jsonDecode(response.body);
      return json.map((item) => {{className}}.fromJson(item)).toList();
    } else {
      throw Exception('Failed to load {{tableName}}');
    }
  }

  Future<{{className}}> get(String id) async {
    final response = await http.get(
      Uri.parse('\$baseUrl/{{tableName}}/\$id'),
    );

    if (response.statusCode == 200) {
      return {{className}}.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to load {{className}}');
    }
  }

  Future<{{className}}> create({{className}} item) async {
    final response = await http.post(
      Uri.parse('\$baseUrl/{{tableName}}'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 201) {
      return {{className}}.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to create {{className}}');
    }
  }

  Future<{{className}}> update(String id, {{className}} item) async {
    final response = await http.put(
      Uri.parse('\$baseUrl/{{tableName}}/\$id'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode(item.toJson()),
    );

    if (response.statusCode == 200) {
      return {{className}}.fromJson(jsonDecode(response.body));
    } else {
      throw Exception('Failed to update {{className}}');
    }
  }

  Future<void> delete(String id) async {
    final response = await http.delete(
      Uri.parse('\$baseUrl/{{tableName}}/\$id'),
    );

    if (response.statusCode != 204) {
      throw Exception('Failed to delete {{className}}');
    }
  }
}
''',
      ),
    ];
  }

  static List<CodeTemplate> _getReactTemplates() {
    return [
      CodeTemplate(
        id: 'react_types',
        name: 'TypeScript Types',
        framework: 'React',
        language: 'typescript',
        category: 'entity',
        filePath: 'src/types/{{fileName}}.ts',
        template: '''
export interface {{className}} {
  id: string;
{{#fields}}
  {{name}}{{^isRequired}}?{{/isRequired}}: {{tsType}};
{{/fields}}
  createdAt: string;
  updatedAt: string;
  published: boolean;
}

export interface {{className}}CreateInput {
{{#fields}}
  {{name}}{{^isRequired}}?{{/isRequired}}: {{tsType}};
{{/fields}}
}

export interface {{className}}UpdateInput {
{{#fields}}
  {{name}}?: {{tsType}};
{{/fields}}
}
''',
      ),
      CodeTemplate(
        id: 'react_hook',
        name: 'Custom Hook',
        framework: 'React',
        language: 'typescript',
        category: 'resource',
        filePath: 'src/hooks/use{{className}}.ts',
        template: '''
import { useState, useEffect } from 'react';
import { {{className}}, {{className}}CreateInput, {{className}}UpdateInput } from '../types/{{fileName}}';

const API_URL = process.env.REACT_APP_API_URL || 'http://localhost:8080';

export function use{{className}}() {
  const [items, setItems] = useState<{{className}}[]>([]);
  const [loading, setLoading] = useState(false);
  const [error, setError] = useState<Error | null>(null);

  const fetchAll = async () => {
    setLoading(true);
    try {
      const response = await fetch(`\${API_URL}/{{tableName}}`);
      if (!response.ok) throw new Error('Failed to fetch');
      const data = await response.json();
      setItems(data);
    } catch (err) {
      setError(err as Error);
    } finally {
      setLoading(false);
    }
  };

  const fetchOne = async (id: string): Promise<{{className}} | null> => {
    try {
      const response = await fetch(`\${API_URL}/{{tableName}}/\${id}`);
      if (!response.ok) return null;
      return await response.json();
    } catch (err) {
      setError(err as Error);
      return null;
    }
  };

  const create = async (data: {{className}}CreateInput): Promise<{{className}} | null> => {
    try {
      const response = await fetch(`\${API_URL}/{{tableName}}`, {
        method: 'POST',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!response.ok) throw new Error('Failed to create');
      const created = await response.json();
      setItems(prev => [...prev, created]);
      return created;
    } catch (err) {
      setError(err as Error);
      return null;
    }
  };

  const update = async (id: string, data: {{className}}UpdateInput): Promise<{{className}} | null> => {
    try {
      const response = await fetch(`\${API_URL}/{{tableName}}/\${id}`, {
        method: 'PUT',
        headers: { 'Content-Type': 'application/json' },
        body: JSON.stringify(data),
      });
      if (!response.ok) throw new Error('Failed to update');
      const updated = await response.json();
      setItems(prev => prev.map(item => item.id === id ? updated : item));
      return updated;
    } catch (err) {
      setError(err as Error);
      return null;
    }
  };

  const remove = async (id: string): Promise<boolean> => {
    try {
      const response = await fetch(`\${API_URL}/{{tableName}}/\${id}`, {
        method: 'DELETE',
      });
      if (!response.ok) throw new Error('Failed to delete');
      setItems(prev => prev.filter(item => item.id !== id));
      return true;
    } catch (err) {
      setError(err as Error);
      return false;
    }
  };

  useEffect(() => {
    fetchAll();
  }, []);

  return {
    items,
    loading,
    error,
    fetchAll,
    fetchOne,
    create,
    update,
    remove,
  };
}
''',
      ),
    ];
  }
}
