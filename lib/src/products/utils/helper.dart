import 'dart:async';
import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/services.dart';

final FirebaseFirestore db = FirebaseFirestore.instance;

class SalesAI {
  Future<int> uploadData() async {
    String jsonData =
        await rootBundle.loadString('assets/data/amazon_uk_shoes_dataset.json');
    final data = jsonDecode(jsonData);
    int count = 0;
    final batch = db.batch();
    for (var record in data) {
      if (count == 5000) break;
      batch.set(db.collection('products').doc(), record);
      count++;
    }
    await batch.commit();
    debugPrint('Total records uploaded: $count');
    return count;
  }
}
