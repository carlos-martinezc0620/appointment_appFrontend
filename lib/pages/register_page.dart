import 'package:flutter/gestures.dart';
import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'home_page.dart';
import '../main.dart';

class RegisterPage extends StatefulWidget {
  const RegisterPage({super.key});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final _formKey = GlobalKey<FormState>();
  final emailController = TextEditingController();
  final passwordController = TextEditingController();
  final confirmController = TextEditingController();
  final nicknameController = TextEditingController();

  // Campos para Doctor
  final nombreController = TextEditingController();
  final especialidadController = TextEditingController();

  String selectedRole = "Paciente";

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  Future<void> _register() async {
    if (_formKey.currentState!.validate()) {
      try {
        UserCredential userCred = await _auth.createUserWithEmailAndPassword(
          email: emailController.text.trim(),
          password: passwordController.text.trim(),
        );

        Map<String, dynamic> data = {
          'email': emailController.text.trim(),
          'nickname': nicknameController.text.trim(),
          'uid': userCred.user!.uid,
          'rol': selectedRole.toLowerCase(), // 🔥 Siempre minúsculas
          'createdAt': Timestamp.now(),
        };

        // Datos según el rol
        if (selectedRole.toLowerCase() == "doctor") {
          data['nombre'] = nombreController.text.trim();
          data['especialidad'] = especialidadController.text.trim();
        } else {
          data['nombre'] = "";
          data['telefono'] = "";
          data['enfermedades'] = "";
        }

        await _firestore
            .collection('usuarios')
            .doc(userCred.user!.uid)
            .set(data);

        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Cuenta creada con éxito')),
        );

        Navigator.pushReplacement(
          context,
          MaterialPageRoute(builder: (context) => LoginPage()),
        );
      } on FirebaseAuthException catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Error al registrar')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Center(
        child: SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 32),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Text(
                'Crea tu cuenta',
                style: TextStyle(
                  fontSize: 26,
                  fontWeight: FontWeight.bold,
                  color: Colors.lightBlueAccent,
                ),
              ),
              const SizedBox(height: 32),

              Card(
                elevation: 4,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                child: Padding(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 20,
                    vertical: 25,
                  ),
                  child: Form(
                    key: _formKey,
                    child: Column(
                      children: [
                        TextFormField(
                          controller: nicknameController,
                          decoration: const InputDecoration(
                            labelText: 'Nombre de usuario',
                            prefixIcon: Icon(Icons.person_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa un nombre de usuario';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        DropdownButtonFormField(
                          value: selectedRole,
                          decoration: const InputDecoration(
                            labelText: 'Rol',
                            prefixIcon: Icon(Icons.badge_outlined),
                          ),
                          items: ['Paciente', 'Doctor'].map((rol) {
                            return DropdownMenuItem(
                              value: rol,
                              child: Text(rol),
                            );
                          }).toList(),
                          onChanged: (value) {
                            setState(() {
                              selectedRole = value!;
                            });
                          },
                        ),
                        const SizedBox(height: 18),

                        // 🔥 Campos extra solo si Doctor
                        if (selectedRole.toLowerCase() == "doctor") ...[
                          TextFormField(
                            controller: nombreController,
                            decoration: const InputDecoration(
                              labelText: 'Nombre completo del Doctor',
                              prefixIcon: Icon(Icons.person),
                            ),
                            validator: (value) {
                              if (selectedRole.toLowerCase() == "doctor" &&
                                  (value == null || value.isEmpty)) {
                                return 'Ingresa el nombre del doctor';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),

                          TextFormField(
                            controller: especialidadController,
                            decoration: const InputDecoration(
                              labelText: 'Especialidad',
                              prefixIcon: Icon(Icons.medical_services_outlined),
                            ),
                            validator: (value) {
                              if (selectedRole.toLowerCase() == "doctor" &&
                                  (value == null || value.isEmpty)) {
                                return 'Ingresa la especialidad';
                              }
                              return null;
                            },
                          ),
                          const SizedBox(height: 18),
                        ],

                        TextFormField(
                          controller: emailController,
                          decoration: const InputDecoration(
                            labelText: 'Correo electrónico',
                            prefixIcon: Icon(Icons.email_outlined),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa tu correo';
                            }
                            if (!value.contains('@') || !value.contains('.')) {
                              return 'Correo inválido';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: passwordController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Contraseña',
                            prefixIcon: Icon(Icons.lock_outline),
                          ),
                          validator: (value) {
                            if (value == null || value.isEmpty) {
                              return 'Ingresa una contraseña';
                            }
                            if (value.length < 6) {
                              return 'Debe tener al menos 6 caracteres';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 18),

                        TextFormField(
                          controller: confirmController,
                          obscureText: true,
                          decoration: const InputDecoration(
                            labelText: 'Confirmar contraseña',
                            prefixIcon: Icon(Icons.lock_reset_outlined),
                          ),
                          validator: (value) {
                            if (value != passwordController.text) {
                              return 'Las contraseñas no coinciden';
                            }
                            return null;
                          },
                        ),
                        const SizedBox(height: 25),

                        SizedBox(
                          width: double.infinity,
                          height: 48,
                          child: ElevatedButton(
                            style: ElevatedButton.styleFrom(
                              backgroundColor: Colors.lightBlueAccent,
                              shape: RoundedRectangleBorder(
                                borderRadius: BorderRadius.circular(14),
                              ),
                              elevation: 2,
                            ),
                            onPressed: _register,
                            child: const Text(
                              'Registrarse',
                              style: TextStyle(
                                fontSize: 16,
                                color: Colors.white,
                              ),
                            ),
                          ),
                        ),
                        const SizedBox(height: 16),

                        RichText(
                          text: TextSpan(
                            text: "¿Ya tienes una cuenta? ",
                            style: const TextStyle(color: Colors.black54),
                            children: [
                              TextSpan(
                                text: "Inicia sesión",
                                style: const TextStyle(
                                  color: Colors.lightBlueAccent,
                                  fontWeight: FontWeight.bold,
                                ),
                                recognizer: TapGestureRecognizer()
                                  ..onTap = () {
                                    Navigator.pushReplacement(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => LoginPage(),
                                      ),
                                    );
                                  },
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
