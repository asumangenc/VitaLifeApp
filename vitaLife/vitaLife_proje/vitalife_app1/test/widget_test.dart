// test/widget_test.dart dosyanın içeriğini bununla değiştir:

import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';

// Kendi paket isminle import ettiğinden emin ol
import 'package:vitalife_app1/main.dart'; 

void main() {
  // Testin adını projenle uyumlu hale getirdik
  testWidgets('VitaLifeApp loading and initial screen test', (WidgetTester tester) async {
    
    // HATA BURADAYDI: MyApp yerine VitaLifeApp yazıyoruz
    await tester.pumpWidget(const VitaLifeApp());

    // Uygulaman açılırken StreamBuilder nedeniyle bir yükleme ekranı (CircularProgressIndicator)
    // göstereceği için başlangıçta onu kontrol edebilirsin.
    expect(find.byType(CircularProgressIndicator), findsOneWidget);
  });
}