import 'dart:io';

import 'package:flutter/material.dart';
import 'package:syncfusion_flutter_xlsio/xlsio.dart' as xlsio;
import 'package:syncfusion_flutter_xlsio/xlsio.dart';

class ExcelServices {

  static Future<void> export(List<Map<String, dynamic>> data, String filename) async {
    /// Create a new Workbook.
    final xlsio.Workbook workbook = xlsio.Workbook();
    /// Get the first worksheet.
    final xlsio.Worksheet sheet = workbook.worksheets[0];
    /// Add data to the sheet.
    for (int i = 0; i < data.length; i++) {
      for (int j = 0; j < data[i].keys.length; j++) {
        sheet.getRangeByName('A${i + 1}').setValue(data[i].keys.elementAt(j));
        sheet.getRangeByName('B${i + 1}').setValue(data[i].values.elementAt(j));
      }
    }
    /// Save workbook as stream
    List<int> bytes = workbook.saveAsStream();

    /// Choose directory to store the file
   /*  String? filePath = await FilePicker.platform.getDirectoryPath();

    String excelFilePath = '$filePath/$filename.xlsx';

    /// Save stream to file
    File(excelFilePath).writeAsBytes(bytes); */

    /// Dispose workbook
    workbook.dispose();
  }

  getExtStorage() async {
    //final Directory? directory = await getExternalStorageDirectory();
  }


importExcel(){
  
}

formula(){
  // Create a new Excel document.
final xlsio.Workbook workbook = xlsio.Workbook();
//Accessing worksheet via index.
final xlsio.Worksheet sheet = workbook.worksheets[0];
//Setting value in the cell
sheet.getRangeByName('A1').setNumber(22);
sheet.getRangeByName('A2').setNumber(44);

//Formula calculation is enabled for the sheet
sheet.enableSheetCalculations();

//Setting formula in the cell
sheet.getRangeByName('A3').setFormula('=A1+A2');

// Save the document.
final List<int> bytes = workbook.saveAsStream();
File('AddingFormula.xlsx').writeAsBytes(bytes);
//Dispose the workbook.
workbook.dispose();
}

styling(){
  // Create a new Excel document.
final xlsio.Workbook workbook =  xlsio.Workbook();

//Accessing worksheet via index.
final xlsio.Worksheet sheet = workbook.worksheets[0];

//Defining a global style with all properties.
Style globalStyle = workbook.styles.add('style');
//set back color by hexa decimal.
globalStyle.backColor = '#37D8E9';
//set font name.
globalStyle.fontName = 'Times New Roman';
//set font size.
globalStyle.fontSize = 20;
//set font color by hexa decimal.
globalStyle.fontColor = '#C67878';
//set font italic.
globalStyle.italic = true;
//set font bold.
globalStyle.bold = true;
//set font underline.
globalStyle.underline = true;
//set wraper text.
globalStyle.wrapText = true;
//set indent value.
globalStyle.indent = 1;
//set horizontal alignment type.
globalStyle.hAlign = HAlignType.left;
//set vertical alignment type.
globalStyle.vAlign = VAlignType.bottom;
//set text rotation.
globalStyle.rotation = 90;
//set all border line style.
globalStyle.borders.all.lineStyle = LineStyle.thick;
//set border color by hexa decimal.
globalStyle.borders.all.color = '#9954CC';
//set number format.
globalStyle.numberFormat = '_(\$* #,##0_)';

//Apply GlobalStyle to 'A1'.
sheet.getRangeByName('A1').cellStyle = globalStyle;

//Defining Gloabl style.
globalStyle = workbook.styles.add('style1');
//set back color by RGB value.
globalStyle.backColorRgb = const Color.fromARGB(245, 22, 44, 144);
//set font color by RGB value.
globalStyle.fontColorRgb = const Color.fromARGB(255, 244, 22, 44);
//set border line style.
globalStyle.borders.all.lineStyle = LineStyle.double;
//set border color by RGB value.
globalStyle.borders.all.colorRgb = const Color.fromARGB(255, 44, 200, 44);

//Apply GlobalStyle to 'A4';
sheet.getRangeByName('A4').cellStyle = globalStyle;

// Save the document.
final List<int> bytes = workbook.saveAsStream();
File('ApplyGlobalStyle.xlsx').writeAsBytes(bytes);
//Dispose the workbook.
workbook.dispose();
}

/* Apply Build-in Formatting

Use the following code to apply build-in style to to the Excel worksheet cells.

// Create a new Excel document.
final Workbook workbook = new Workbook();
//Accessing worksheet via index.
final Worksheet sheet = workbook.worksheets[0];

//Applying Number format.
sheet.getRangeByName('A1').builtInStyle = BuiltInStyles.linkedCell;

// Save the document.
final List<int> bytes = workbook.saveAsStream();
File('ApplyBuildInStyle.xlsx').writeAsBytes(bytes);
//Dispose the workbook.
workbook.dispose(); 


Apply NumberFormat

Use the following code to apply number format to to the Excel worksheet cells.

// Create a new Excel document.
final Workbook workbook = new Workbook();
//Accessing worksheet via index.
final Worksheet sheet = workbook.worksheets[0];

//Applying Number format.
final Range range = sheet.getRangeByName('A1');
range.setNumber(100);
range.numberFormat = '\S#,##0.00';

// Save the document.
final List<int> bytes = workbook.saveAsStream();
File('ApplyNumberFormat.xlsx').writeAsBytes(bytes);
//Dispose the workbook.
workbook.dispose();



Add images 

Syncfusion Flutter XlsIO supports only PNG and JPEG images. Refer to the following code to add images to Excel worksheet.

// Create a new Excel document.
final Workbook workbook = new Workbook();
//Accessing worksheet via index.
final Worksheet sheet = workbook.worksheets[0];

//Adding a picture
final List<int> bytes = File('image.png').readAsBytesSync();
final Picture picture = sheet.picutes.addStream(1, 1, bytes);

// Save the document.
final List<int> bytes = workbook.saveAsStream();
File('AddingImage.xlsx').writeAsBytes(bytes);
//Dispose the workbook.
workbook.dispose();



Add charts 

Import the following package to your project to create charts in Excel document from scratch.

import 'package:syncfusion_officechart/officechart.dart';

Use the following code to add charts to Excel worksheet.

// Create a new Excel document.
final Workbook workbook = Workbook();
// Accessing worksheet via index.
final Worksheet sheet = workbook.worksheets[0];

// Setting value in the cell.
sheet.getRangeByName('A1').setText('John');
sheet.getRangeByName('A2').setText('Amy');
sheet.getRangeByName('A3').setText('Jack');
sheet.getRangeByName('A4').setText('Tiya');
sheet.getRangeByName('B1').setNumber(10);
sheet.getRangeByName('B2').setNumber(12);
sheet.getRangeByName('B3').setNumber(20);
sheet.getRangeByName('B4').setNumber(21);

// Create an instances of chart collection.
final ChartCollection charts = ChartCollection(sheet);

// Add the chart.
final Chart chart = charts.add();

// Set Chart Type.
chart.chartType = ExcelChartType.column;

// Set data range in the worksheet.
chart.dataRange = sheet.getRangeByName('A1:B4');

// set charts to worksheet.
sheet.charts = charts;

// save and dispose the workbook.
final List<int> bytes = workbook.saveAsStream();
workbook.dispose();
File('Chart.xlsx').writeAsBytes(bytes);



Add hyperlinks 

Use the following code to add hyperlinks to Excel worksheet.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

//Creating a Hyperlink for a Website.
final Hyperlink hyperlink = sheet.hyperlinks.add(sheet.getRangeByName('A1'),
    HyperlinkType.url, 'https://www.syncfusion.com');
hyperlink.screenTip =
    'To know more about Syncfusion products, go through this link.';
hyperlink.textToDisplay = 'Syncfusion';

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('Hyperlinks.xlsx').writeAsBytes(bytes);
workbook.dispose();


Manipulate rows and Columns 

This section covers how rows and columns are manipulated in Excel Worksheets.

Apply Autofits

Use the following code to apply autofits to single cells of the Excel worksheet.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

final Range range = sheet.getRangeByName('A1');
range.setText('WrapTextWrapTextWrapTextWrapText');
range.cellStyle.wrapText = true;

final Range range1 = sheet.getRangeByName('B1');
range1.setText('This is long text');

// AutoFit applied to a single row
sheet.autoFitRow(1);

// AutoFit applied to a single Column.
sheet.autoFitColumn(2);

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('AutoFit.xlsx').writeAsBytes(bytes);
workbook.dispose();



Use the following code to apply autofits to multiple cells of the Excel worksheet.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

// Assigning text to cells
final Range range = sheet.getRangeByName('A1:D1');
range.setText('This is Long Text');
final Range range1 = sheet.getRangeByName('A2:A5');
range1.setText('This is Long Text using AutoFit Columns and Rows');
range1.cellStyle.wrapText = true;

// Auto-Fit column the range
range.autoFitColumns();

// Auto-Fit row the range
range1.autoFitRows();

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('AutoFits.xlsx').writeAsBytes(bytes);
workbook.dispose();

---------------
Insert/Delete Rows and Colums

Use the following code to insert rows and columns to the Excel worksheet.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

Range range = sheet.getRangeByName('A1');
range.setText('Hello');

range = sheet.getRangeByName('B1');
range.setText('World');

// Insert a row
sheet.insertRow(1, 1, ExcelInsertOptions.formatAsAfter);

// Insert a column.
sheet.insertColumn(2, 1, ExcelInsertOptions.formatAsBefore);

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('InsertRowandColumn.xlsx').writeAsBytes(bytes);
workbook.dispose();

Use the following code to delete rows and columns of Excel worksheet.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

Range range = sheet.getRangeByName('A2');
range.setText('Hello');

range = sheet.getRangeByName('C2');
range.setText('World');

// Delete a row
sheet.deleteRow(1, 1);

// Delete a column.
sheet.deleteColumn(2, 1);

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('DeleteRowandColumn.xlsx').writeAsBytes(bytes);
workbook.dispose();

Protect workbook and worksheets 

This section covers the various protection options in the Excel document.

Protect workbook elements

Use the following code to protect workbook element of Excel document.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

// Assigning text to cells
final Range range = sheet.getRangeByName('A1');
range.setText('WorkBook Protected');

final bool isProtectWindow = true;
final bool isProtectContent = true;

// Protect Workbook
workbook.protect(isProtectWindow, isProtectContent, 'password');

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('WorkbookProtect.xlsx').writeAsBytes(bytes);
workbook.dispose();

Protect worksheet

Use the following code to protect worksheets in the Excel document.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

// Assigning text to cells
final Range range = sheet.getRangeByName('A1');
range.setText('Worksheet Protected');

// ExcelSheetProtectionOption
final ExcelSheetProtectionOption options = ExcelSheetProtectionOption();
options.all = true;

// Protecting the Worksheet by using a Password
sheet.protect('Password', options);

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('WorksheetProtect.xlsx').writeAsBytes(bytes);
workbook.dispose();

Import data 

Use the following code to import list of data into Excel Worksheet.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

//Initialize the list
final List<Object> list = [
  'Toatal Income',
  20000,
  'On Date',
  DateTime(2021, 1, 1)
];

//Import the Object list to Sheet
sheet.importList(list, 1, 1, true);

// Save and dispose workbook.
final List<int> bytes = workbook.saveAsStream();
File('ImportDataList.xlsx').writeAsBytes(bytes);
workbook.dispose();

Apply conditional formatting 

Use the following code to add and apply conditional formatting to cell or range in Excel Worksheet.

// Create a new Excel Document.
final Workbook workbook = Workbook();

// Accessing sheet via index.
final Worksheet sheet = workbook.worksheets[0];

//Applying conditional formatting to "A2".
final ConditionalFormats conditions =
    sheet.getRangeByName('A2').conditionalFormats;
final ConditionalFormat condition = conditions.addCondition();

//Represents conditional format rule that the value in target range should be between 10 and 20
condition.formatType = ExcelCFType.cellValue;
condition.operator = ExcelComparisonOperator.between;
condition.firstFormula = '10';
condition.secondFormula = '20';
sheet.getRangeByIndex(2, 1).setText('Enter a number between 10 and 20');

//Setting format properties to be applied when the above condition is met.
//set back color by hexa decimal.
condition.backColor = '#00FFCC';
//set font color by RGB values.
condition.fontColorRgb = Color.fromARGB(255, 200, 20, 100);
//set font bold.
condition.isBold = true;
//set font italic.
condition.isItalic = true;
//set number format.
condition.numberFormat = '0.0';
//set font underline.
condition.underline = true;
//set top border line style
condition.topBorderStyle = LineStyle.thick;
// set top border color by RGB values.
condition.topBorderColorRgb = Color.fromARGB(255, 200, 1, 200);
//set bottom border line style.
condition.bottomBorderStyle = LineStyle.medium;
//set bottom border color by hexa decimal.
condition.bottomBorderColor = '#FF0000';
//set right border line style.
condition.rightBorderStyle = LineStyle.double;
// set right border color by RGB values.
condition.rightBorderColorRgb = Color.fromARGB(250, 24, 160, 200);
//set left border line style.
condition.leftBorderStyle = LineStyle.thin;
//set left border color by hexa decimal.
condition.leftBorderColor = '#AAFFAA';

//save and dispose.
final List<int> bytes = workbook.saveAsStream();
File('ConditionalFormatting.xlsx').writeAsBytes(bytes);
workbook.dispose();
*/

}

//final Directory directory = await getTemporaryDirectory();

//final Directory? directory = await getApplicationDocumentsDirectory();

//final Directory? directory = await getDownloadsDirectory();