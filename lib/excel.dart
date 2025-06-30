//
//
// import 'dart:collection';
// import 'dart:convert';
// import 'dart:typed_data';
// import 'package:universal_html/html.dart' as html;
// import 'package:excel/excel.dart';
//
//
//
//
// void exportUserToExcel(List<Map<String, dynamic>> users) {
//   try {
//     print('🚀 Starting Excel export process...');
//
//     // Convert QueryDocumentSnapshot list to List<Map<String, dynamic>>
//     List<Map<String, dynamic>> userDataList = [];
//
//     for (int i = 0; i < users.length; i++) {
//       userDataList.add({
//         'nameAr': users[i]['nameAr'],
//         'name': users[i]['name'],
//         'catAr':users[i]['catAr'],
//         'cat':users[i]['cat'],
//         'desAr':users[i]['descAr'],
//         'des':users[i]['des'],
//         'price':users[i]['price'],
//         'quant':users[i]['quant'],
//         'rate':users[i]['rate'],
//
//         // 'phone': users[i]['phone'],
//         // 'country': users[i]['country'],
//         // 'city': users[i]['city'],
//       });
//     }
//
//     final arabicHeaders = LinkedHashMap<String, String>.from({
//       'name': 'الاسم',
//       'nameAr': 'الاسم بالعربية',
//       "cat":"القسم",
//       "catAr":"القسم بالعربية",
//       "desAr":"الوصف بالعربية",
//       "des":"الوصف",
//       "price":"السعر",
//       "quant":"الكمية",
//       "rate":"التقييم",
//       // 'phone': 'الهاتف',
//       // 'country': 'الدولة',
//       // 'city': 'المدينة',
//     });
//
//     String jsonData = jsonEncode(userDataList.map((transaction) {
//       Map<String, dynamic> converted = Map<String, dynamic>.from(transaction);
//       Map<String, dynamic> translated = {};
//
//       arabicHeaders.forEach((key, arabicKey) {
//         var value = converted[key];
//
//         translated[arabicKey] = value;
//       });
//
//       return translated;
//     }).toList());
//
//     List<dynamic> jsonList = jsonDecode(jsonData);
//     print('✅ Parsed ${jsonList.length} records');
//
//     var excel = Excel.createExcel();
//     Sheet sheet = excel['Sheet1'];
//     print('✅ Excel sheet created');
//
//     // Define general RTL cell style
//     final baseStyle = CellStyle(
//       horizontalAlign: HorizontalAlign.Right,
//     );
//
//     // RTL styles with conditional colors
//     final greenStyle =
//     baseStyle.copyWith(backgroundColorHexVal: "#C6EFCE"); // light green
//     final redStyle =
//     baseStyle.copyWith(backgroundColorHexVal: "#FFC7CE"); // light red
//
//     // Write headers
//     final headers = arabicHeaders.values.toList();
//     for (int i = 0; i < headers.length; i++) {
//       var cell =
//       sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
//       cell.value = headers[i];
//       cell.cellStyle = baseStyle;
//     }
//
//     print('✅ Headers written with RTL style');
//
//     // Write data rows
//     for (int row = 0; row < jsonList.length; row++) {
//       final item = jsonList[row] as Map<String, dynamic>;
//       for (int col = 0; col < headers.length; col++) {
//         var header = headers[col];
//         var value = item[header];
//         var displayValue = value?.toString() ?? '';
//
//         var cell = sheet.cell(
//             CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
//         cell.value = displayValue;
//
//         if (displayValue == 'نعم') {
//           cell.cellStyle = greenStyle;
//         } else if (displayValue == 'لا') {
//           cell.cellStyle = redStyle;
//         } else {
//           cell.cellStyle = baseStyle;
//         }
//       }
//     }
//
//     print('✅ Data rows written with RTL + conditional color style');
//
//     // Export
//     var bytes = excel.encode();
//     if (bytes == null) {
//       print('❌ Failed to encode Excel');
//       return;
//     }
//
//     final blob = html.Blob([Uint8List.fromList(bytes)]);
//     final url = html.Url.createObjectUrlFromBlob(blob);
//     final anchor = html.AnchorElement(href: url)
//       ..setAttribute("download", "المستخدمين.xlsx")
//       ..click();
//     html.Url.revokeObjectUrl(url);
//
//     print('🎉 Excel file downloaded successfully!');
//   } catch (e) {
//     print('❌ Export failed: $e');
//     print('🚨 Stack trace: ${e is Error ? e.stackTrace : ''}');
//   }
// }