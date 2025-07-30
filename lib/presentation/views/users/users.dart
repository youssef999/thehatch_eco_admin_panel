import 'dart:collection';
import 'dart:convert';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:flutter/material.dart';
import 'package:universal_html/html.dart' as html;

class UsersView extends StatefulWidget {
  const UsersView({super.key});

  @override
  State<UsersView> createState() => _UsersViewState();
}

class _UsersViewState extends State<UsersView> {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  late List<User> _users = [];
  String _searchQuery = '';
  bool _isLoading = true;
  int _sortColumnIndex = 0;
  bool _sortAscending = true;
  final TextEditingController _nameController = TextEditingController();
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _phoneController = TextEditingController();
  User? _editingUser;

  @override
  void initState() {
    super.initState();
    _loadUsers();
  }

  @override
  void dispose() {
    _nameController.dispose();
    _emailController.dispose();
    _phoneController.dispose();
    super.dispose();
  }

  Future<void> _loadUsers() async {
    try {
      final snapshot = await _firestore.collection('Users').get();
      final users = snapshot.docs.map((doc) {
        return User.fromMap(doc.data() as Map<String, dynamic>);
      }).toList();
      
      setState(() {
        _users = users;
        _isLoading = false;
      });
    } catch (e) {
      setState(() {
        _isLoading = false;
      });
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error loading users: $e')),
      );
    }
  }

  Future<void> _refreshUsers() async {
    setState(() => _isLoading = true);
    await _loadUsers();
  }

  List<User> _filterUsers(List<User> users) {
    if (_searchQuery.isEmpty) return users;
    return users.where((user) {
      return user.name.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.email.toLowerCase().contains(_searchQuery.toLowerCase()) ||
          user.phone.toLowerCase().contains(_searchQuery.toLowerCase());
    }).toList();
  }

  void _sortUsers(List<User> users, int columnIndex, bool ascending) {
    setState(() {
      _sortColumnIndex = columnIndex;
      _sortAscending = ascending;
    });

    users.sort((a, b) {
      int comparison;
      switch (columnIndex) {
        case 0: // Name
          comparison = a.name.compareTo(b.name);
          break;
        case 1: // Email
          comparison = a.email.compareTo(b.email);
          break;
        case 2: // Phone
          comparison = a.phone.compareTo(b.phone);
          break;
        default:
          comparison = a.name.compareTo(b.name);
      }
      return ascending ? comparison : -comparison;
    });
  }

  Future<void> _showEditDialog(User user) async {
    _editingUser = user;
    _nameController.text = user.name;
    _emailController.text = user.email;
    _phoneController.text = user.phone;

    await showDialog(
      context: context,
      builder: (context) {
        return Directionality(
          textDirection: TextDirection.rtl,
          child: AlertDialog(
            title: const Text('تعديل المستخدم'),
            content: SingleChildScrollView(
              child: Column(
                mainAxisSize: MainAxisSize.min,
                children: [
                  TextField(
                    controller: _nameController,
                    decoration: const InputDecoration(labelText: 'الاسم'),
                  ),
                  TextField(
                    controller: _emailController,
                    decoration: const InputDecoration(labelText: 'البريد الإلكتروني'),
                    enabled: false, // Email shouldn't be changed as it's used as identifier
                  ),
                  TextField(
                    controller: _phoneController,
                    decoration: const InputDecoration(labelText: 'الهاتف'),
                    keyboardType: TextInputType.phone,
                  ),
                ],
              ),
            ),
            actions: [
              TextButton(
                onPressed: () => Navigator.pop(context),
                child: const Text('إلغاء'),
              ),
              ElevatedButton(
                onPressed: () async {
                  await _updateUser();
                  Navigator.pop(context);
                },
                child: const Text('حفظ'),
              ),
            ],
          ),
        );
      },
    );
  }

  Future<void> _updateUser() async {
  if (_editingUser == null) return;

  try {
    // First query for documents with matching email
    final querySnapshot = await _firestore.collection('Users')
      .where('email', isEqualTo: _editingUser!.email)
      .get();

    // Check if we found any documents
    if (querySnapshot.docs.isEmpty) {
      throw Exception('No user found with email ${_editingUser!.email}');
    }

    // Update each matching document (should only be one if email is unique)
    for (final doc in querySnapshot.docs) {
      await doc.reference.update({
        'name': _nameController.text,
        'phone': _phoneController.text,
      });
    }
    
    await _refreshUsers();
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('تم تحديث المستخدم بنجاح')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('فشل في تحديث المستخدم: $e')),
    );
  }
}

Future<void> _deleteUser(String email) async {
  final confirmed = await showDialog(
    context: context,
    builder: (context) {
      return Directionality(
        textDirection: TextDirection.rtl,
        child: AlertDialog(
          title: const Text('تأكيد الحذف'),
          content: const Text('هل أنت متأكد أنك تريد حذف هذا المستخدم؟'),
          actions: [
            TextButton(
              onPressed: () => Navigator.pop(context, false),
              child: const Text('إلغاء'),
            ),
            ElevatedButton(
              onPressed: () => Navigator.pop(context, true),
              style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
              child: const Text('حذف'),
            ),
          ],
        ),
      );
    },
  );

  if (confirmed == true) {
    try {
      // First query for documents with matching email
      final querySnapshot = await _firestore.collection('Users')
        .where('email', isEqualTo: email)
        .get();

      // Check if we found any documents
      if (querySnapshot.docs.isEmpty) {
        throw Exception('No user found with email $email');
      }

      // Delete each matching document (should only be one if email is unique)
      for (final doc in querySnapshot.docs) {
        await doc.reference.delete();
      }

      await _refreshUsers();
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف المستخدم بنجاح')),
      );
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('فشل في حذف المستخدم: $e')),
      );
    }
  }
}

bool isLoadingExcel = false;
void exportToExcel2() async {
  setState(() {
    isLoadingExcel = true;
  });
  try {
    print('🚀 Starting Excel export process...');

    // Convert List<User> to List<Map<String, dynamic>>
    List<Map<String, dynamic>> userDataList = _users.map((user) {
      return {
        'name': user.name,
        'email': user.email,
        'phone': user.phone,
      };
    }).toList();

    final arabicHeaders = LinkedHashMap<String, String>.from({
      'name': 'الاسم',
      'email': 'البريد الالكتروني',
      'phone': 'الهاتف',
    });

    String jsonData = jsonEncode(userDataList.map((user) {
      Map<String, dynamic> converted = Map<String, dynamic>.from(user);
      Map<String, dynamic> translated = {};

      arabicHeaders.forEach((key, arabicKey) {
        var value = converted[key];
        translated[arabicKey] = value;
      });

      return translated;
    }).toList());

    List<dynamic> jsonList = jsonDecode(jsonData);
    print('✅ Parsed ${jsonList.length} records');

    var excel = Excel.createExcel();
    Sheet sheet = excel['Sheet1'];
    print('✅ Excel sheet created');

    // Define general RTL cell style
    final baseStyle = CellStyle(
      horizontalAlign: HorizontalAlign.Right,
    );

    // Write headers
    final headers = arabicHeaders.values.toList();
    for (int i = 0; i < headers.length; i++) {
      var cell = sheet.cell(CellIndex.indexByColumnRow(columnIndex: i, rowIndex: 0));
      cell.value = TextCellValue(headers[i]);
      cell.cellStyle = baseStyle;
    }

    // ignore: avoid_print
    print('✅ Headers written with RTL style');

    // Write data rows
    for (int row = 0; row < jsonList.length; row++) {
      final item = jsonList[row] as Map<String, dynamic>;
      for (int col = 0; col < headers.length; col++) {
        var header = headers[col];
        var value = item[header];
        var displayValue = value?.toString() ?? '';

        var cell = sheet.cell(
            CellIndex.indexByColumnRow(columnIndex: col, rowIndex: row + 1));
        cell.value = TextCellValue(displayValue);
        cell.cellStyle = baseStyle;
      }
    }

    print('✅ Data rows written');

    // Export
    var bytes = excel.encode();
    if (bytes == null) {
      print('❌ Failed to encode Excel');
      return;
    }

    final blob = html.Blob([Uint8List.fromList(bytes)]);
    final url = html.Url.createObjectUrlFromBlob(blob);
    final anchor = html.AnchorElement(href: url)
      ..setAttribute("download", "المستخدمين.xlsx")
      ..click();
    html.Url.revokeObjectUrl(url);

    print('🎉 Excel file downloaded successfully!');
  } catch (e) {
    print('❌ Export failed: $e');
    print('🚨 Stack trace: ${e is Error ? e.stackTrace : ''}');
  } finally {
    setState(() {
      isLoadingExcel = false;
    });
  }
}

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;

    return Scaffold(
      appBar: AppBar(
        backgroundColor:Colors.blue,
        title: const Text('إدارة المستخدمين', style: TextStyle(fontWeight: FontWeight.bold,
        color:Colors.white
        )),
        centerTitle: true,
        elevation: 0,
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            onPressed: _refreshUsers,
            tooltip: 'تحديث',
          ),
        ],
      ),
      body: Column(
        children: [

          const SizedBox(height: 11,),
          ElevatedButton(onPressed: (){
            exportToExcel2();
          }, child: const Text('تصدير ملف اكسيل عن المستخدمين')),
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: Directionality(
              textDirection: TextDirection.rtl,
              child: TextField(
                decoration: InputDecoration(
                  hintText: 'ابحث عن مستخدم...',
                  prefixIcon: const Icon(Icons.search),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(30),
                  ),
                  filled: true,
                  fillColor: isDarkMode ? Colors.grey[800] : Colors.grey[200],
                ),
                onChanged: (value) {
                  setState(() {
                    _searchQuery = value;
                  });
                },
              ),
            ),
          ),
          Expanded(
            child: _isLoading
                ? _buildShimmerEffect()
                : _buildUsersTable(),
          ),
        ],
      ),
    );
  }

  Widget _buildUsersTable() {
    var users = _filterUsers(_users);
    _sortUsers(users, _sortColumnIndex, _sortAscending);

    if (users.isEmpty) {
      return const Center(
        child: Text('لا يوجد مستخدمين متاحين', style: TextStyle(fontSize: 18)),
      );
    }

    return SingleChildScrollView(
      scrollDirection: Axis.horizontal,
      child: DataTable(
        columnSpacing: 20,
        sortColumnIndex: _sortColumnIndex,
        sortAscending: _sortAscending,
        columns: const [
          DataColumn(
            label: Text('الاسم', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('البريد الإلكتروني', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('الهاتف', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
          DataColumn(
            label: Text('الإجراءات', style: TextStyle(fontWeight: FontWeight.bold)),
          ),
        ],
        rows: users.map((user) {
          return DataRow(
            cells: [
              DataCell(
                Row(
                  children: [
                    const SizedBox(width: 10),
                    Text(user.name),
                  ],
                ),
              ),
              DataCell(Text(user.email)),
              DataCell(Text(user.phone)),
              DataCell(
                Row(
                  children: [
                    IconButton(
                      icon: const Icon(Icons.edit, color: Colors.blue),
                      onPressed: () => _showEditDialog(user),
                      tooltip: 'تعديل',
                    ),
                    IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () => _deleteUser(user.email),
                      tooltip: 'حذف',
                    ),
                  ],
                ),
              ),
            ],
          );
        }).toList(),
      ),
    );
  }

  Widget _buildShimmerEffect() {
    return ListView.builder(
      itemCount: 5,
      itemBuilder: (context, index) {
        return Card(
          child: Padding(
            padding: const EdgeInsets.all(16.0),
            child: Row(
              children: [
                Container(
                  width: 50,
                  height: 50,
                  decoration: BoxDecoration(
                    color: Colors.grey[300],
                    shape: BoxShape.circle,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Container(
                        width: double.infinity,
                        height: 16,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 200,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                      const SizedBox(height: 8),
                      Container(
                        width: 150,
                        height: 14,
                        color: Colors.grey[300],
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}

class User {
  final String name;
  final String email;
  final String phone;
  final String? token;

  User({
    required this.name,
    required this.email,
    required this.phone,
    this.token,
  });

  factory User.fromMap(Map<String, dynamic> map) {
    return User(
      name: map['name'] ?? 'غير معروف',
      email: map['email'] ?? '',
      phone: map['phone'] ?? '',
      token: map['token'] ?? "",
    );
  }
}