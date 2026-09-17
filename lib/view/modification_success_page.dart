// ملف جديد: modification_success_page.dart
import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:lottie/lottie.dart';

class ModificationSuccessPage extends StatelessWidget {
  const ModificationSuccessPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
    //  backgroundColor: Colors.white,
      body: 
         Padding(
          padding: const EdgeInsets.all(20.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              // Animation
              Lottie.asset(
                'assets/animations/success.json',
                width: 200,
                height: 200,
              ),
              
              const SizedBox(height: 30),
              
              // Title
              const Text(
                'Modification Request Sent!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: Color(0xFF2F6F74),
                ),
              ),
              
              const SizedBox(height: 15),
              
              // Message
              const Text(
                'Your booking modification request has been sent to the property owner.',
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontSize: 16,
                  color: Colors.grey,
                ),
              ),
              
              const SizedBox(height: 10),
              
              // Waiting Message
              Container(
                padding: const EdgeInsets.all(12),
                decoration: BoxDecoration(
                  color: const Color(0xFFE6F3FF),
                  borderRadius: BorderRadius.circular(10),
                ),
                child: const Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      Icons.access_time,
                      color: Color(0xFF2F6F74),
                    ),
                    SizedBox(width: 8),
                    Text(
                      'Waiting for owner approval',
                      style: TextStyle(
                        fontWeight: FontWeight.bold,
                        color: Color(0xFF2F6F74),
                      ),
                    ),
                  ],
                ),
              ),
              
              const SizedBox(height: 40),
              
              // Buttons
              Column(
                children: [
                  SizedBox(
                    width: double.infinity,
                    child: ElevatedButton(
                      onPressed: () {
                        Get.until((route) => route.isFirst);
                        Get.toNamed('/my-bookings');
                      },
                      style: ElevatedButton.styleFrom(
                        backgroundColor: const Color(0xFF2F6F74),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                      ),
                      child: const Text(
                        'Back to My Bookings',
                        style: TextStyle(
                          fontSize: 16,
                          color: Colors.white,
                        ),
                      ),
                    ),
                  ),
                  
                  const SizedBox(height: 15),
                  
                  TextButton(
                    onPressed: () {
                      Get.back();
                    },
                    child: const Text(
                      'Edit Another Booking',
                      style: TextStyle(
                        color: Color(0xFF2F6F74),
                      ),
                    ),
                  ),
                ],
              ),
            ],
          ),
      
      ),
    );
  }
}