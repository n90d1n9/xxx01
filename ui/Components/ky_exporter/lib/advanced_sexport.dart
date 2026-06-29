class AdvancedExport {
  Future<String> exportToSPSS(List<Map<String, dynamic>> data) async {
    StringBuffer buffer = StringBuffer();
    
    // Write variable definitions
    buffer.writeln('DATA LIST FREE/');
    data.first.keys.forEach((key) {
      buffer.writeln('  $key (A8)');
    });
    
    buffer.writeln('BEGIN DATA');
    // Write data
    for (var row in data) {
      buffer.writeln(row.values.join(' '));
    }
    buffer.writeln('END DATA.');
    
    return buffer.toString();
  }
  
  Future<String> exportToStata(List<Map<String, dynamic>> data) async {
    StringBuffer buffer = StringBuffer();
    
    // Write dataset
    buffer.writeln('clear');
    buffer.writeln('set more off');
    
    // Define variables
    data.first.keys.forEach((key) {
      buffer.writeln('generate $key = ""');
    });
    
    // Write data
    for (int i = 0; i < data.length; i++) {
      data[i].forEach((key, value) {
        buffer.writeln('replace $key = "$value" in ${i + 1}');
      });
    }
    
    return buffer.toString();
  }
}

class AdvancedExport {
  // Previous export methods remain...

  Future<String> exportToMplus(List<Map<String, dynamic>> data) async {
    StringBuffer buffer = StringBuffer();
    
    // Write title and data definition
    buffer.writeln('TITLE: Survey Data Analysis;');
    buffer.writeln('DATA:');
    buffer.writeln('  FILE = "survey_data.dat";');
    
    // Write variable names
    buffer.writeln('VARIABLE:');
    buffer.writeln('  NAMES ARE');
    buffer.writeln('    ${data.first.keys.join('\n    ')};');
    
    // Write analysis specifications
    buffer.writeln('ANALYSIS:');
    buffer.writeln('  TYPE = GENERAL;');
    buffer.writeln('  ESTIMATOR = MLR;');
    
    // Write model specifications
    buffer.writeln('MODEL:');
    // Add model specifications based on data structure
    
    return buffer.toString();
  }

  Future<String> exportToJMP(List<Map<String, dynamic>> data) async {
    StringBuffer buffer = StringBuffer();
    
    // Write JMP script header
    buffer.writeln('Clear Log;');
    buffer.writeln('Clear Results;');
    
    // Create data table
    buffer.writeln('New Table("Survey Data");');
    
    // Add columns
    for (var key in data.first.keys) {
      String dataType = inferJMPDataType(data.map((row) => row[key]).toList());
      buffer.writeln('Add Column("$key", $dataType);');
    }
    
    // Add data rows
    for (var row in data) {
      buffer.writeln('Add Row(${row.values.map((v) => '"$v"').join(', ')});');
    }
    
    return buffer.toString();
  }
}
