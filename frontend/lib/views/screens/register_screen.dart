import 'package:flutter/material.dart';

class RegisterScreen extends StatelessWidget {
  
  final TextEditingController emailController = TextEditingController();

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.symmetric(horizontal: 24),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            children: [
              const SizedBox(height: 24),

              // Back arrow and Cog Icon
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [     

                  IconButton(
                      icon: const Icon(Icons.arrow_back, color: Colors.blue),
                      onPressed: () {},
                    ),

                  IconButton(
                        icon: Icon(Icons.settings),
                        iconSize: 32,
                        color: Colors.blue,
                        onPressed: () {
                          Navigator.pushNamed(context, '/contentCreation');
                        },
                      ),
                ],
              ),
    
              const SizedBox(height: 16),
    
              // Title
              const Text(
                "Create an account using Email",
                textAlign: TextAlign.center,
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
                ),
              ),

              const SizedBox(height: 32),
    
              // Email Input
              TextField(
                controller: emailController,
                decoration: InputDecoration(
                  hintText: "Email address",
                  contentPadding: const EdgeInsets.symmetric(
                      vertical: 18, horizontal: 16),
                  border: OutlineInputBorder(
                    borderRadius: BorderRadius.circular(12),
                    borderSide: BorderSide(color: Colors.grey.shade300),
                  ),
                ),
              ),
    
              const SizedBox(height: 24),
    
              // Continue Button
              SizedBox(
                width: double.infinity,
                height: 50,
                child: ElevatedButton(
                  style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.lightBlueAccent,
                    shape: RoundedRectangleBorder(
                      borderRadius: BorderRadius.circular(12),
                    ),
                    elevation: 2,
                  ),
                  onPressed: () {
                      Navigator.pushNamed( context, '/inputUser' );     
                    },
                  child: const Text(
                    "CONTINUE",
                    style: TextStyle(fontWeight: FontWeight.bold),
                  ),
                ),
              ),
    
              const SizedBox(height: 16),
    
              // Skip for now
              TextButton(
                onPressed: () {
                  Navigator.pushNamed( context, '/inputUser' );    
                },
                child: const Text(
                  "SKIP FOR NOW",
                  style: TextStyle(color: Colors.lightBlueAccent),
                ),
              ),
    
              const Spacer(),
    
              const SizedBox(height: 12),
    
              const SizedBox(height: 24),
            ],
          ),
        ),
      ),
    );
  }
}