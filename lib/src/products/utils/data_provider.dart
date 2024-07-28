import 'dart:async';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';

final db = FirebaseFirestore.instance;

class DBRepository {
  QueryDocumentSnapshot? _lastDocument, _lastSearchDocument;
  Future<List<Map<String, dynamic>>> fetchProducts([int limit = 20]) async {
    /// Fetches products from the database
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    if (_lastDocument != null) {
      querySnapshot = await db
          .collection("products")
          .orderBy("title")
          .startAfterDocument(_lastDocument!)
          .limit(limit)
          .get();
    } else {
      querySnapshot =
          await db.collection("products").orderBy("title").limit(limit).get();
    }
    _lastDocument = querySnapshot.docs.last;
    final products = querySnapshot.docs
        .map((doc) => {
              ...doc.data(),
              "id": doc.id,
            })
        .toList();
    return products;
  }

  Future<List<Map<String, dynamic>>> searchProducts(String query,
      [int limit = 20]) async {
        // Search products from the database
    QuerySnapshot<Map<String, dynamic>> querySnapshot;
    querySnapshot = await db
        .collection("products")
        .where("title", isGreaterThanOrEqualTo: query)
        .limit(limit)
        .get();

    final products = querySnapshot.docs
        .map((doc) => {
              ...doc.data(),
              "id": doc.id,
            })
        .toList();
    debugPrint("DATA: ${products.length}");
    return products;
  }

  Future<Map<String, dynamic>> getProduct(String id) async {
    // Fetches a single product from the database by id
    final item = await db.collection("products").doc(id).get();
    return {...?item.data(), "id": item.id};
  }
}
