import 'package:flutter/material.dart';
import 'package:get/get.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:Transcripto/main.dart';
import 'package:Transcripto/presentation/controllers/user_info_service.dart';
import 'package:Transcripto/core/themes/app_themes.dart';

class ProfileEditScreen extends StatefulWidget {
  const ProfileEditScreen({super.key});

  @override
  State<ProfileEditScreen> createState() => _ProfileEditScreenState();
}

class _ProfileEditScreenState extends State<ProfileEditScreen> {
  TextEditingController _usernameController = TextEditingController();
  String _selectedToLanguage = '';
  String _selectedFromLanguage = '';
  String _selectedLevel = '';

  @override
  void initState() {
    _usernameController.text = currentUser!.username;
    _selectedFromLanguage = currentUser!.fromLang;
    _selectedToLanguage = currentUser!.toLang;
    _selectedLevel = currentUser!.level;
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: LayoutBuilder(
        builder: (context, constraints) {
          return Container(
            height: constraints.maxHeight,
            decoration: AppThemes.backgroundGradient,
            child: SafeArea(
              child: Stack(
                children: [
                  SingleChildScrollView(
                    child: Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16.0,
                        vertical: 24.0,
                      ),
                      child: Column(
                        mainAxisSize: MainAxisSize.max,
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Center(
                            child: Column(
                              children: [
                                const SizedBox(height: 16),
                                Text(
                                  'Edit Profile',
                                  style: GoogleFonts.poppins(
                                    fontSize: 28,
                                    fontWeight: FontWeight.w700,
                                    color: Colors.white,
                                    letterSpacing: 0.5,
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
                              color: Colors.white.withOpacity(0.9),
                              borderRadius: BorderRadius.circular(12.0),
                              boxShadow: [
                                BoxShadow(
                                  color: Colors.black.withOpacity(0.05),
                                  blurRadius: 8,
                                  offset: const Offset(0, 2),
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
                                  controller: _usernameController,
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
                                  value: _selectedToLanguage.capitalizeFirst,
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
                                      _selectedToLanguage = value!;
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
                                  value: _selectedLevel.capitalizeFirst,
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
                                      _selectedLevel = value!;
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
                                  value: _selectedFromLanguage.capitalizeFirst,
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
                                      _selectedFromLanguage = value!;
                                    }
                                  },
                                ),
                              ],
                            ),
                          ),
                          const SizedBox(height: 32),
                          SizedBox(
                            width: constraints.maxWidth,
                            child: GetBuilder<UserInfoService>(
                              builder:
                                  (controller) => ElevatedButton.icon(
                                    onPressed: () async {
                                      if (_selectedFromLanguage ==
                                          _selectedToLanguage) {
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'The two language must not be the same',
                                            ),
                                          ),
                                        );
                                        return;
                                      }
                                      if (_usernameController.text != '' &&
                                          _selectedToLanguage != '' &&
                                          _selectedLevel != '' &&
                                          _selectedFromLanguage != '') {
                                        final userName =
                                            _usernameController.text;
                                        final status =
                                            await Get.find<UserInfoService>()
                                                .saveUserInfo(
                                                  userName,
                                                  _selectedToLanguage,
                                                  _selectedLevel,
                                                  _selectedFromLanguage,
                                                );
                                        if (status) {
                                          Navigator.of(context).pop();
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
                                        ScaffoldMessenger.of(
                                          context,
                                        ).showSnackBar(
                                          SnackBar(
                                            content: Text(
                                              'Please make sure you select and fill all the fields',
                                            ),
                                          ),
                                        );
                                      }
                                    },
                                    style: ElevatedButton.styleFrom(
                                      backgroundColor: Colors.black,
                                      foregroundColor: Colors.white,
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 40,
                                        vertical: 18,
                                      ),
                                      shape: RoundedRectangleBorder(
                                        borderRadius: BorderRadius.circular(16),
                                      ),
                                      elevation: 6,
                                      shadowColor: AppThemes.primaryColor
                                          .withOpacity(0.3),
                                    ),
                                    iconAlignment: IconAlignment.end,
                                    icon:
                                        controller.isSavingUser
                                            ? SizedBox()
                                            : Icon(
                                              Icons.arrow_forward_ios,
                                              size: 16,
                                              color: Colors.white,
                                            ),
                                    label: Text(
                                      controller.isSavingUser
                                          ? 'Almost There...'
                                          : 'Save Changes',
                                      style: GoogleFonts.poppins(
                                        fontSize: 16,
                                        fontWeight: FontWeight.w600,
                                        color: Colors.white,
                                      ),
                                    ),
                                  ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                  Positioned(
                    top: 8,
                    left: 24,
                    child: IconButton(
                      onPressed: () {
                        Navigator.of(context).pop();
                      },
                      icon: Icon(Icons.arrow_back_ios, color: Colors.white),
                    ),
                  ),
                ],
              ),
            ),
          );
        },
      ),
    );
  }
}
