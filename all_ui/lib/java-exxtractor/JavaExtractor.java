import java.io.*;
import java.nio.file.*;
import java.util.*;
import java.util.regex.*;
import java.util.stream.Collectors;

public class JavaExtractor {
    public static void main(String[] args) {
        if (args.length == 0) {
            System.err.println("Usage: java JavaExtractor path/to/input.java [output_dir]");
            System.err.println("  path/to/input.java - Java file to extract classes from");
            System.err.println("  output_dir         - Output directory (default: ./extracted)");
            System.exit(1);
        }

        try {
            String inputPath = args[0];
            String outputDir = args.length > 1 ? args[1] : "./extracted";
            
            extractClassesToSeparateFiles(inputPath, outputDir);
            
        } catch (Exception e) {
            System.err.println("Error: " + e.getMessage());
            e.printStackTrace();
            System.exit(2);
        }
    }

    public static void extractClassesToSeparateFiles(String inputFilePath, String outputDir) throws IOException {
        Path inputFile = Paths.get(inputFilePath);
        
        if (!Files.exists(inputFile)) {
            throw new FileNotFoundException("File not found: " + inputFilePath);
        }

        String content = Files.readString(inputFile);
        
        // Create output directory
        Path outputDirectory = Paths.get(outputDir);
        if (!Files.exists(outputDirectory)) {
            Files.createDirectories(outputDirectory);
            System.out.println("📁 Created directory: " + outputDir);
        }

        // Extract package declaration and imports
        List<String> lines = Files.readAllLines(inputFile);
        String packageDecl = extractPackageDeclaration(lines);
        List<String> imports = extractImports(lines);
        List<String> originalImports = new ArrayList<>(imports);

        // Collect all class/enum/interface names
        Set<String> allTypeNames = new HashSet<>();
        List<ClassInfo> allDeclarations = new ArrayList<>();

        // Pattern to match class/enum/interface declarations
        Pattern classPattern = Pattern.compile(
            "^(public\\s+|protected\\s+|private\\s+|abstract\\s+|final\\s+|static\\s+)*" +
            "(class|enum|interface|@interface)\\s+(\\w+)"
        );

        Pattern innerClassPattern = Pattern.compile(
            "^(public\\s+|protected\\s+|private\\s+|static\\s+)*" +
            "(class|enum|interface)\\s+(\\w+)"
        );

        StringBuilder currentClass = new StringBuilder();
        String currentClassName = null;
        int braceCount = 0;
        boolean inClass = false;

        for (String line : lines) {
            // Skip package and import lines when building class content
            if (line.trim().startsWith("package ") || line.trim().startsWith("import ")) {
                if (inClass) {
                    currentClass.append(line).append("\n");
                }
                continue;
            }

            Matcher classMatcher = classPattern.matcher(line.trim());
            Matcher innerClassMatcher = innerClassPattern.matcher(line.trim());

            if (!inClass && classMatcher.find()) {
                // Start of top-level class
                inClass = true;
                currentClassName = classMatcher.group(3);
                allTypeNames.add(currentClassName);
                currentClass.append(line).append("\n");
                braceCount = countBraces(line);
            } else if (inClass && innerClassMatcher.find()) {
                // Inner class - we'll handle this as part of the outer class
                currentClass.append(line).append("\n");
                braceCount += countBraces(line);
            } else if (inClass) {
                currentClass.append(line).append("\n");
                braceCount += countBraces(line);
                
                if (braceCount == 0 && inClass) {
                    // End of class
                    allDeclarations.add(new ClassInfo(
                        currentClassName,
                        currentClass.toString(),
                        getClassType(currentClass.toString())
                    ));
                    
                    currentClass = new StringBuilder();
                    inClass = false;
                    currentClassName = null;
                }
            }
        }

        // Find dependencies for each class
        for (ClassInfo classInfo : allDeclarations) {
            Set<String> dependencies = findDependencies(classInfo.content, allTypeNames);
            classInfo.dependencies.addAll(dependencies);
        }

        // Create files
        int createdCount = 0;
        for (ClassInfo classInfo : allDeclarations) {
            createClassFile(classInfo, packageDecl, originalImports, outputDir);
            createdCount++;
        }

        // Create main file if there are multiple classes
        if (allDeclarations.size() > 1) {
            createMainFile(allDeclarations, packageDecl, outputDir);
        }

        // Format files (using Google Java Format if available)
        formatJavaFiles(outputDir);

        System.out.println("\n✅ Extraction Complete!");
        System.out.println("📊 Summary:");
        System.out.println("   Files created: " + createdCount);
        System.out.println("   Output directory: " + outputDirectory.toAbsolutePath());
    }

    private static String extractPackageDeclaration(List<String> lines) {
        for (String line : lines) {
            if (line.trim().startsWith("package ")) {
                return line.trim();
            }
        }
        return "";
    }

    private static List<String> extractImports(List<String> lines) {
        return lines.stream()
            .filter(line -> line.trim().startsWith("import "))
            .collect(Collectors.toList());
    }

    private static int countBraces(String line) {
        int count = 0;
        for (char c : line.toCharArray()) {
            if (c == '{') count++;
            if (c == '}') count--;
        }
        return count;
    }

    private static String getClassType(String classContent) {
        if (classContent.contains(" enum ")) return "enum";
        if (classContent.contains(" interface ")) return "interface";
        if (classContent.contains(" @interface ")) return "annotation";
        return "class";
    }

    private static Set<String> findDependencies(String content, Set<String> availableTypes) {
        Set<String> dependencies = new HashSet<>();
        
        for (String typeName : availableTypes) {
            // Look for type usage in the content (basic pattern matching)
            Pattern pattern = Pattern.compile("\\b" + typeName + "\\b");
            Matcher matcher = pattern.matcher(content);
            
            if (matcher.find() && isLikelyDependency(content, typeName)) {
                dependencies.add(typeName);
            }
        }
        
        return dependencies;
    }

    private static boolean isLikelyDependency(String content, String typeName) {
        // Avoid matching the class declaration itself
        Pattern declarationPattern = Pattern.compile(
            "(class|enum|interface)\\s+" + typeName + "\\b"
        );
        if (declarationPattern.matcher(content).find()) {
            return false;
        }

        // Look for usage patterns
        String[] usagePatterns = {
            "\\b" + typeName + "\\s+\\w+",                    // Type variableName
            "\\b" + typeName + "\\s*\\[\\s*\\]",              // Type[]
            "\\b" + typeName + "\\s*\\([^)]*\\)",             // Type(...)
            "\\b" + typeName + "\\s*<[^>]*>",                 // Type<...>
            "List\\s*<\\s*" + typeName + "\\s*>",             // List<Type>
            "Map\\s*<[^,]*,\\s*" + typeName + "\\s*>",        // Map<..., Type>
            "Set\\s*<\\s*" + typeName + "\\s*>",              // Set<Type>
            "Optional\\s*<\\s*" + typeName + "\\s*>",         // Optional<Type>
        };

        for (String pattern : usagePatterns) {
            if (Pattern.compile(pattern).matcher(content).find()) {
                return true;
            }
        }

        return false;
    }

    private static void createClassFile(ClassInfo classInfo, String packageDecl, 
                                      List<String> imports, String outputDir) throws IOException {
        // Use the exact class name for the file name (Java convention)
        String fileName = classInfo.name + ".java";
        Path filePath = Paths.get(outputDir, fileName);

        StringBuilder content = new StringBuilder();
        
        // Add package declaration
        if (!packageDecl.isEmpty()) {
            content.append(packageDecl).append("\n\n");
        }
        
        // Add imports (filter out redundant ones)
        Set<String> allImports = new LinkedHashSet<>(imports);
        
        // Add imports for dependencies
        for (String dependency : classInfo.dependencies) {
            // For now, assume all dependencies are in the same package
            // In a real implementation, you might need more sophisticated import resolution
        }
        
        for (String importLine : allImports) {
            content.append(importLine).append("\n");
        }
        
        if (!allImports.isEmpty()) {
            content.append("\n");
        }
        
        // Add class content
        content.append(classInfo.content);

        Files.writeString(filePath, content.toString());
        
        String dependencyInfo = classInfo.dependencies.isEmpty() 
            ? "" 
            : " (depends on: " + String.join(", ", classInfo.dependencies) + ")";
        System.out.println("✓ Created: " + fileName + dependencyInfo);
    }

    private static void createMainFile(List<ClassInfo> allDeclarations, String packageDecl, String outputDir) throws IOException {
        Path mainFile = Paths.get(outputDir, "Main.java");
        
        StringBuilder content = new StringBuilder();
        if (!packageDecl.isEmpty()) {
            content.append(packageDecl).append("\n\n");
        }
        
        content.append("// Main class demonstrating usage of all extracted classes\n");
        content.append("public class Main {\n");
        content.append("    public static void main(String[] args) {\n");
        content.append("        System.out.println(\"All classes extracted successfully!\");\n");
        content.append("    }\n");
        content.append("}\n");
        
        Files.writeString(mainFile, content.toString());
        System.out.println("✓ Created: Main.java");
    }

    private static void formatJavaFiles(String outputDir) {
        System.out.println("\n🎨 Formatting Java files...");
        
        try {
            // Try to use google-java-format if available
            ProcessBuilder pb = new ProcessBuilder("java", "-jar", "google-java-format.jar", "-r", outputDir);
            Process process = pb.start();
            int exitCode = process.waitFor();
            
            if (exitCode == 0) {
                System.out.println("✓ Successfully formatted files with google-java-format");
            } else {
                System.out.println("⚠ Could not format with google-java-format, using basic formatting");
            }
        } catch (Exception e) {
            System.out.println("⚠ Could not run google-java-format: " + e.getMessage());
            System.out.println("💡 Install from: https://github.com/google/google-java-format");
        }
    }

    // Remove the toSnakeCase method since we don't need it for Java

    static class ClassInfo {
        String name;
        String content;
        String type;
        Set<String> dependencies;

        ClassInfo(String name, String content, String type) {
            this.name = name;
            this.content = content;
            this.type = type;
            this.dependencies = new HashSet<>();
        }
    }
}