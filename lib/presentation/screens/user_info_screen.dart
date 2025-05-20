import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Transcripto/main.dart';
import 'package:Transcripto/presentation/screens/home_screen.dart';
import 'package:Transcripto/presentation/controllers/user_info_service.dart';
import 'package:Transcripto/core/themes/app_themes.dart';

class UserInfoScreen extends StatefulWidget {
  const UserInfoScreen({super.key});

  @override
  State<UserInfoScreen> createState() => _UserInfoScreenState();
}

class _UserInfoScreenState extends State<UserInfoScreen> {
  String _selectedToLanguage = '';
  String _selectedLevel = '';
  String _selectedFromLanguage = '';

  late TextEditingController _userNameController;

  @override
  void initState() {
    _userNameController = TextEditingController();
    super.initState();
  }

  @override
  void dispose() {
    _userNameController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder:
            (context, constraints) => Container(
              height: constraints.maxHeight,
              padding: const EdgeInsets.symmetric(horizontal: 16.0),
              decoration: AppThemes.backgroundGradient,
              child: SafeArea(
                child: SingleChildScrollView(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      const SizedBox(height: 60),
                      Center(
                        child: Column(
                          children: [
                            Text(
                              'Inter-train!',
                              style: GoogleFonts.poppins(
                                fontSize: 32,
                                fontWeight: FontWeight.w600,
                                color: Colors.white,
                              ),
                              textAlign: TextAlign.center,
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Welcome! Let’s Personalize Your Experience',
                              style: GoogleFonts.poppins(
                                fontSize: 18,
                                fontWeight: FontWeight.w600,
                                color: Colors.white70,
                              ),
                              textAlign: TextAlign.center,
                            ),
                          ],
                        ),
                      ),
                      const SizedBox(height: 32),
                      Container(
                        padding: const EdgeInsets.all(16.0),
                        decoration: BoxDecoration(
                          color: Colors.white,
                          borderRadius: BorderRadius.circular(12.0),
                          boxShadow: [
                            BoxShadow(
                              color: Colors.black.withOpacity(0.1),
                              blurRadius: 8.0,
                              offset: const Offset(0, 4),
                            ),
                          ],
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(
                              'Your Name',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            TextField(
                              controller: _userNameController,
                              decoration: InputDecoration(
                                hintText: 'e.g. John Doe',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 14,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Language You Want to Learn',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Select a language',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              items:
                                  ['French', 'Spanish', 'Arabic']
                                      .map(
                                        (lang) => DropdownMenuItem(
                                          value: lang,
                                          child: Text(
                                            lang,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != '') {
                                  _selectedToLanguage = value!.toLowerCase();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your Current Level in That Language',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Select your level',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              items:
                                  ['A1', 'A2', 'B1', 'B2', 'C1', 'C2']
                                      .map(
                                        (level) => DropdownMenuItem(
                                          value: level,
                                          child: Text(
                                            level,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != '') {
                                  _selectedLevel = value!.toLowerCase();
                                }
                              },
                            ),
                            const SizedBox(height: 16),
                            Text(
                              'Your Native Language',
                              style: GoogleFonts.poppins(
                                fontSize: 14,
                                fontWeight: FontWeight.w500,
                                color: Colors.black54,
                              ),
                            ),
                            const SizedBox(height: 8),
                            DropdownButtonFormField<String>(
                              decoration: InputDecoration(
                                hintText: 'Select your native language',
                                hintStyle: GoogleFonts.poppins(
                                  fontSize: 12,
                                  color: Colors.grey,
                                ),
                                border: OutlineInputBorder(
                                  borderRadius: BorderRadius.circular(8.0),
                                  borderSide: BorderSide.none,
                                ),
                                filled: true,
                                fillColor: Colors.grey[100],
                              ),
                              items:
                                  ['French', 'Spanish', 'Arabic']
                                      .map(
                                        (lang) => DropdownMenuItem(
                                          value: lang,
                                          child: Text(
                                            lang,
                                            style: GoogleFonts.poppins(
                                              fontSize: 14,
                                            ),
                                          ),
                                        ),
                                      )
                                      .toList(),
                              onChanged: (value) {
                                if (value != '') {
                                  _selectedFromLanguage = value!.toLowerCase();
                                }
                              },
                            ),
                          ],
                        ),
                      ),
                      SizedBox(height: 32),
                      GetBuilder<UserInfoService>(
                        builder:
                            (controller) => SizedBox(
                              width: constraints.maxWidth,
                              child: ElevatedButton.icon(
                                onPressed: () async {
                                  if (_selectedFromLanguage ==
                                      _selectedToLanguage) {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please make sure to select two different languages.',
                                        ),
                                      ),
                                    );
                                    return;
                                  }
                                  if (_userNameController.text != '' &&
                                      _selectedToLanguage != '' &&
                                      _selectedLevel != '' &&
                                      _selectedFromLanguage != '') {
                                    final userName = _userNameController.text;
                                    final status =
                                        await Get.find<UserInfoService>()
                                            .saveUserInfo(
                                              userName,
                                              _selectedToLanguage,
                                              _selectedLevel,
                                              _selectedFromLanguage,
                                            );
                                    if (status) {
                                      Navigator.of(context).pushReplacement(
                                        MaterialPageRoute(
                                          builder: (context) => HomeScreen(),
                                        ),
                                      );
                                    } else {
                                      ScaffoldMessenger.of(
                                        context,
                                      ).showSnackBar(
                                        SnackBar(
                                          content: Text(
                                            'Something went wrong. Please try again.',
                                          ),
                                        ),
                                      );
                                    }
                                  } else {
                                    ScaffoldMessenger.of(context).showSnackBar(
                                      SnackBar(
                                        content: Text(
                                          'Please make sure you select and fill all the fields',
                                        ),
                                      ),
                                    );
                                  }
                                },
                                style: ElevatedButton.styleFrom(
                                  backgroundColor: Colors.black87,
                                  foregroundColor: Colors.white,
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 32.0,
                                    vertical: 16.0,
                                  ),
                                  shape: RoundedRectangleBorder(
                                    borderRadius: BorderRadius.circular(8.0),
                                  ),
                                  elevation: 4.0,
                                ),
                                label: Text(
                                  controller.isSavingUser
                                      ? 'Almost There ...'
                                      : 'Start Learning',
                                  style: GoogleFonts.poppins(
                                    fontSize: 16,
                                    fontWeight: FontWeight.w600,
                                    color: Colors.white,
                                  ),
                                ),
                                iconAlignment: IconAlignment.end,
                                icon:
                                    controller.isSavingUser
                                        ? SizedBox()
                                        : Icon(
                                          Icons.arrow_forward_ios,
                                          size: 14,
                                          color: Colors.white,
                                        ),
                              ),
                            ),
                      ),
                      const SizedBox(height: 16),
                      Center(
                        child: Text(
                          'You can change these preferences anytime in your profile settings.',
                          style: GoogleFonts.poppins(
                            fontSize: 12,
                            fontWeight: FontWeight.w400,
                            color: Colors.grey.shade300,
                          ),
                          textAlign: TextAlign.center,
                        ),
                      ),
                      const SizedBox(height: 32),
                    ],
                  ),
                ),
              ),
            ),
      ),
    );
  }
}
