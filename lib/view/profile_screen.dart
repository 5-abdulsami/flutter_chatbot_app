import 'dart:developer';
import 'dart:io';
import 'package:flutter/material.dart';
import 'package:flutter_chatbot_app/hive/boxes.dart';
import 'package:flutter_chatbot_app/hive/settings.dart';
import 'package:flutter_chatbot_app/hive/user_model.dart';
import 'package:flutter_chatbot_app/provider/settings_provider.dart';
import 'package:flutter_chatbot_app/widgets/build_display_image.dart';
import 'package:flutter_chatbot_app/widgets/settings_tile.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:hive_flutter/hive_flutter.dart';
import 'package:image_picker/image_picker.dart';
import 'package:provider/provider.dart';
import 'package:uuid/uuid.dart';

class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});

  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  File? imageFile;
  String userImage = '';
  String userName = 'Sami';
  final ImagePicker _picker = ImagePicker();

  String generateUniqueId() {
    const uuid = Uuid();
    return uuid.v4();
  }

  // pick an image
  void pickImage() async {
    try {
      final pickedImage = await _picker.pickImage(
        source: ImageSource.gallery,
        maxHeight: 800,
        maxWidth: 800,
        imageQuality: 95,
      );
      if (pickedImage != null) {
        setState(() {
          imageFile = File(pickedImage.path);
        });
      }
    } catch (e) {
      log('error : $e');
    }
  }

  // get user data
  void getUserData() {
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      // get user data from box
      final userBox = Boxes.getUser();

      // check if user data is not empty
      if (userBox.isNotEmpty) {
        final user = userBox.getAt(0) as UserModel;
        setState(() {
          if (imageFile != null) {
            userImage = imageFile!.path;
          } else {
            userImage = user.image;
          }
          userName = user.name;
        });
      }
    });
  }

  void saveUserData() async {
    final userBox = Boxes.getUser();

    // Check if image was picked
    if (imageFile != null) {
      // Get the absolute path of the image file
      final imagePath = imageFile!.path;

      // Update user image in the UserModel
      final user =
          UserModel(uid: generateUniqueId(), name: userName, image: imagePath);

      // Clear the existing user data before saving (if any)
      userBox.clear();

      // Add the updated user data to the box
      await userBox.add(user);
    } else {
      // Handle case where no image is picked
      print('No image picked to save.');
    }
  }

  @override
  void initState() {
    getUserData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        appBar: AppBar(
          title: Text(
            'Profile',
            style: GoogleFonts.poppins(),
          ),
          centerTitle: true,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          actions: [
            IconButton(
              icon: const Icon(Icons.check),
              onPressed: () {
                // save data
              },
            ),
          ],
        ),
        body: Padding(
          padding: const EdgeInsets.symmetric(
            horizontal: 20.0,
            vertical: 20.0,
          ),
          child: SingleChildScrollView(
            child: Column(
              children: [
                Center(
                  child: BuildDisplayImage(
                      file: imageFile,
                      userImage: userImage,
                      onPressed: () {
                        // open camera or gallery
                        pickImage();
                      }),
                ),

                const SizedBox(height: 20.0),

                // user name
                Text(userName, style: GoogleFonts.poppins(fontSize: 30)),

                const SizedBox(height: 40.0),

                ValueListenableBuilder<Box<Settings>>(
                    valueListenable: Boxes.getSettings().listenable(),
                    builder: (context, box, child) {
                      if (box.isEmpty) {
                        return Column(
                          children: [
                            // ai voice
                            SettingsTile(
                                icon: Icons.mic,
                                title: 'Enable AI voice',
                                value: false,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleSpeak(
                                    value: value,
                                  );
                                }),

                            const SizedBox(height: 10.0),

                            // theme
                            SettingsTile(
                                icon: Icons.light_mode,
                                title: 'Theme',
                                value: false,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleDarkMode(
                                    value: value,
                                  );
                                }),
                          ],
                        );
                      } else {
                        final settings = box.getAt(0);
                        return Column(
                          children: [
                            // ai voice
                            SettingsTile(
                                icon: Icons.mic,
                                title: 'Enable AI voice',
                                value: settings!.shouldSpeak,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleSpeak(
                                    value: value,
                                  );
                                }),

                            const SizedBox(height: 10.0),

                            // theme
                            SettingsTile(
                                icon: settings.isDarkTheme
                                    ? Icons.dark_mode
                                    : Icons.light_mode,
                                title: 'Theme',
                                value: settings.isDarkTheme,
                                onChanged: (value) {
                                  final settingProvider =
                                      context.read<SettingsProvider>();
                                  settingProvider.toggleDarkMode(
                                    value: value,
                                  );
                                }),
                          ],
                        );
                      }
                    })
              ],
            ),
          ),
        ));
  }
}
