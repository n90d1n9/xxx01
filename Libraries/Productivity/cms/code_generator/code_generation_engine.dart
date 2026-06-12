import '../content/model/content_type_schema.dart';

class CodeGenerationEngine {
  /// Generate Quarkus project structure
  Map<String, String> generateQuarkusProject(List<ContentTypeSchema> schemas) {
    final files = <String, String>{};

    // Generate application.properties
    files['src/main/resources/application.properties'] =
        _generateApplicationProperties();

    // Generate pom.xml
    files['pom.xml'] = _generatePomXml();

    // Generate entities and resources for each schema
    for (var schema in schemas) {
      final className = _toPascalCase(schema.tableName);
      files['src/main/java/com/example/entity/$className.java'] =
          schema.toQuarkusEntity();
      files['src/main/java/com/example/resource/${className}Resource.java'] =
          schema.toQuarkusResource();
    }

    // Generate database migration
    files['src/main/resources/db/migration/V1__init.sql'] =
        _generateMigrationSQL(schemas);

    return files;
  }

  String _generateApplicationProperties() {
    return '''
# Database Configuration
quarkus.datasource.db-kind=postgresql
quarkus.datasource.username=cms_user
quarkus.datasource.password=cms_password
quarkus.datasource.jdbc.url=jdbc:postgresql://localhost:5432/cms_db

# Hibernate Configuration
quarkus.hibernate-orm.database.generation=none
quarkus.hibernate-orm.log.sql=true

# Flyway Migration
quarkus.flyway.migrate-at-start=true

# HTTP Configuration
quarkus.http.port=8080
quarkus.http.cors=true

# Dev Mode
%dev.quarkus.http.port=8080
%dev.quarkus.datasource.db-kind=h2
%dev.quarkus.datasource.jdbc.url=jdbc:h2:mem:cms_db
''';
  }

  String _generatePomXml() {
    return '''
<?xml version="1.0"?>
<project xsi:schemaLocation="http://maven.apache.org/POM/4.0.0 https://maven.apache.org/xsd/maven-4.0.0.xsd"
         xmlns="http://maven.apache.org/POM/4.0.0"
         xmlns:xsi="http://www.w3.org/2001/XMLSchema-instance">
    <modelVersion>4.0.0</modelVersion>
    <groupId>com.example</groupId>
    <artifactId>cms-runtime</artifactId>
    <version>1.0.0</version>
    
    <properties>
        <quarkus.version>3.6.0</quarkus.version>
        <maven.compiler.source>17</maven.compiler.source>
        <maven.compiler.target>17</maven.compiler.target>
    </properties>
    
    <dependencyManagement>
        <dependencies>
            <dependency>
                <groupId>io.quarkus</groupId>
                <artifactId>quarkus-bom</artifactId>
                <version>\${quarkus.version}</version>
                <type>pom</type>
                <scope>import</scope>
            </dependency>
        </dependencies>
    </dependencyManagement>
    
    <dependencies>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-hibernate-orm-panache</artifactId>
        </dependency>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-jdbc-postgresql</artifactId>
        </dependency>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-resteasy-reactive-jackson</artifactId>
        </dependency>
        <dependency>
            <groupId>io.quarkus</groupId>
            <artifactId>quarkus-flyway</artifactId>
        </dependency>
    </dependencies>
    
    <build>
        <plugins>
            <plugin>
                <groupId>io.quarkus</groupId>
                <artifactId>quarkus-maven-plugin</artifactId>
                <version>\${quarkus.version}</version>
            </plugin>
        </plugins>
    </build>
</project>
''';
  }

  String _generateMigrationSQL(List<ContentTypeSchema> schemas) {
    final buffer = StringBuffer();
    buffer.writeln('-- Generated CMS Database Schema');
    buffer.writeln('-- Generated at: ${DateTime.now()}');
    buffer.writeln();

    for (var schema in schemas) {
      buffer.writeln('-- Table: ${schema.tableName}');
      buffer.writeln(schema.toCreateTableSQL());
      buffer.writeln();
    }

    return buffer.toString();
  }

  String _toPascalCase(String str) {
    return str
        .split('_')
        .map(
          (word) =>
              word.isEmpty ? '' : word[0].toUpperCase() + word.substring(1),
        )
        .join('');
  }
}
