import 'dart:convert';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:google_generative_ai/google_generative_ai.dart';

class SalesAIRepository {
  String apiKey = "AIzaSyDCwWFa-8efdoO_-ix9jK9y3Z0x9u9reP0";
  String name = "Adem";
  Future<List<Map<String, dynamic>>> loadData(
      CollectionReference<Map<String, dynamic>> memorySnapshot) async {
    return (await memorySnapshot.get()).docs.map((e) => e.data()).toList();
  }

  Future<String?> getResponse(String prompt, List<Map<String, dynamic>> memory) async {
    String memoryString = jsonEncode(memory);
    debugPrint("Memory: ${memoryString.length}");
    final model = GenerativeModel(
      model: 'gemini-1.5-flash-latest',
      // model: 'gemini-1.5-pro',
      apiKey: apiKey,
      systemInstruction:
          Content.system("""You are being personalized as a sales assistant 
      and your goal is to help customers make a purchase. 
      Your responses should be short, consize and helpful.
      Your new name is $name.

      The response is to be in this xml format i.e 
      <?xml version="1.0"?>
      <response>
        <text>{text here}</text>
        <commands>{commands here}</commands>
      </response>

      For example:
      <?xml version="1.0"?>
      <response>
        <text>Hello world</text>
        <commands>
          <cmd type="checkout">xyzijk</cmd>
        </commands>
      </response>

      These are the available commands to use when user agree:
      Add to Cart
        - <cmd type="add-to-cart">{id}</cmd>
      Remove from Cart
        - <cmd type="remove-from-cart">{id}</cmd>
      Go to Cart
        - <cmd type="view-cart"></cmd>
      Checkout
        - <cmd type="checkout">{id}</cmd>
      
      
      This is your memory $memoryString, all your response should be in line with this memory."""),
    );
    final content = [Content.text(prompt)];
    final response = await model.generateContent(content);
    debugPrint(response.text);
    return response.text;
  }
}
