import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_localizations/flutter_localizations.dart'; // เพิ่มบรรทัดนี้

void main() {
  runApp(const SilverPriceApp());
}

class SilverPriceApp extends StatelessWidget {
  const SilverPriceApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Silver Price Prediction',
      theme: ThemeData(primarySwatch: Colors.blue),
      home: const SilverPricePage(),
      debugShowCheckedModeBanner: false,
      localizationsDelegates: const [ // เพิ่มบรรทัดนี้
        GlobalMaterialLocalizations.delegate,
        GlobalWidgetsLocalizations.delegate,
        GlobalCupertinoLocalizations.delegate,
      ],
      supportedLocales: const [ // เพิ่มบรรทัดนี้
        Locale('en', 'US'),
        Locale('th', 'TH'),
      ],
    );
  }
}

class SilverPricePage extends StatefulWidget {
  const SilverPricePage({super.key});

  @override
  State<SilverPricePage> createState() => _SilverPricePageState();
}

class _SilverPricePageState extends State<SilverPricePage> {
  DateTime? selectedDate;
  bool loading = false;
  String? error;
  double? price;
  String? currency;

  Future<void> predictSilverPrice() async {
    setState(() {
      loading = true;
      error = null;
      price = null;
      currency = null;
    });

    final apiUrl = 'http://localhost:8000/api/silver';
    final dateStr = DateFormat('yyyy-MM-dd').format(selectedDate!);

    try {
      final response = await http.post(
        Uri.parse(apiUrl),
        headers: {'Content-Type': 'application/json'},
        body: jsonEncode({'silver_date': dateStr}),
      );
      final data = jsonDecode(response.body);

      if (data['status'] == true) {
        setState(() {
          price = data['price']?.toDouble();
          currency = data['currency'];
        });
      } else {
        setState(() {
          error = data['detail']?.toString() ?? data['error'] ?? 'Unknown error';
        });
      }
    } catch (e) {
      setState(() {
        error = e.toString();
      });
    }
    setState(() {
      loading = false;
    });
  }

  Future<void> pickDate(BuildContext context) async {
    final now = DateTime.now();
    final picked = await showDatePicker(
      context: context,
      initialDate: selectedDate ?? now,
      firstDate: DateTime(2000),
      lastDate: DateTime(now.year + 1),
      locale: const Locale('th', 'TH'),
    );
    if (picked != null) {
      setState(() {
        selectedDate = picked;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF9FAFB),
      body: Center(
        child: SingleChildScrollView(
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'ทำนายราคาซิลเวอร์ (Silver Price Prediction)',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 24),
              Container(
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: Colors.white,
                  borderRadius: BorderRadius.circular(12),
                  boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 8)],
                ),
                width: 350,
                child: Column(
                  children: [
                    Align(
                      alignment: Alignment.centerLeft,
                      child: Text(
                        'เลือกวันที่ (YYYY-MM-DD)',
                        style: const TextStyle(fontWeight: FontWeight.w500),
                      ),
                    ),
                    const SizedBox(height: 8),
                    InkWell(
                      onTap: () => pickDate(context),
                      child: InputDecorator(
                        decoration: InputDecoration(
                          border: OutlineInputBorder(),
                          contentPadding: const EdgeInsets.symmetric(horizontal: 12, vertical: 10),
                        ),
                        child: Text(
                          selectedDate != null
                              ? DateFormat('yyyy-MM-dd').format(selectedDate!)
                              : 'กรุณาเลือกวันที่',
                          style: TextStyle(
                            color: selectedDate != null ? Colors.black : Colors.grey,
                            fontSize: 16,
                          ),
                        ),
                      ),
                    ),
                    const SizedBox(height: 16),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: loading || selectedDate == null ? null : predictSilverPrice,
                        child: Text(loading ? 'กำลังทำนาย...' : 'ทำนายราคา'),
                      ),
                    ),
                  ],
                ),
              ),
              if (price != null && currency != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.green[100],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Text(
                    'ราคาซิลเวอร์: ${price!.toStringAsFixed(2)} $currency',
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 18),
                  ),
                ),
              if (error != null)
                Container(
                  margin: const EdgeInsets.only(top: 24),
                  padding: const EdgeInsets.all(16),
                  decoration: BoxDecoration(
                    color: Colors.red[100],
                    borderRadius: BorderRadius.circular(8),
                    boxShadow: [BoxShadow(color: Colors.black12, blurRadius: 4)],
                  ),
                  child: Text(
                    error!,
                    style: const TextStyle(color: Colors.red, fontSize: 16),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }
}