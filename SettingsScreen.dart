import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';
import '../theme_provider.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({Key? key}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Consumer<ThemeProvider>(
      builder: (context, themeProvider, child) {
        return Scaffold(
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          appBar: AppBar(
            backgroundColor: Theme.of(context).appBarTheme.backgroundColor,
            title: Text(
              'Settings',
              style: GoogleFonts.poppins(
                color: Theme.of(context).appBarTheme.foregroundColor,
                fontSize: 24,
                fontWeight: FontWeight.bold,
              ),
            ),
          ),
          body: SafeArea(
            child: Padding(
              padding: const EdgeInsets.all(16.0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Card(
                    elevation: Theme.of(context).cardTheme.elevation,
                    shape: Theme.of(context).cardTheme.shape,
                    color: Theme.of(context).cardTheme.color,
                    child: ListTile(
                      title: Text(
                        'Dark Mode',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: Switch(
                        value: themeProvider.themeMode == ThemeMode.dark,
                        onChanged: (value) {
                          themeProvider.toggleTheme(value);
                        },
                        activeColor: Colors.tealAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: Theme.of(context).cardTheme.elevation,
                    shape: Theme.of(context).cardTheme.shape,
                    color: Theme.of(context).cardTheme.color,
                    child: ListTile(
                      title: Text(
                        'Notifications',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: Switch(
                        value: true,
                        onChanged: (value) {
                          // Implement notification toggle logic
                        },
                        activeColor: Colors.tealAccent,
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: Theme.of(context).cardTheme.elevation,
                    shape: Theme.of(context).cardTheme.shape,
                    color: Theme.of(context).cardTheme.color,
                    child: ListTile(
                      title: Text(
                        'Language',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: DropdownButton<String>(
                        value: 'English',
                        items: ['English', 'Spanish', 'French']
                            .map((String value) => DropdownMenuItem<String>(
                          value: value,
                          child: Text(
                            value,
                            style: GoogleFonts.poppins(
                              color: Theme.of(context).textTheme.bodyLarge?.color,
                            ),
                          ),
                        ))
                            .toList(),
                        onChanged: (value) {
                          // Implement language change logic
                        },
                      ),
                    ),
                  ),
                  const SizedBox(height: 16),
                  Card(
                    elevation: Theme.of(context).cardTheme.elevation,
                    shape: Theme.of(context).cardTheme.shape,
                    color: Theme.of(context).cardTheme.color,
                    child: ListTile(
                      title: Text(
                        'Clear Cache',
                        style: GoogleFonts.poppins(
                          fontSize: 16,
                          fontWeight: FontWeight.w500,
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                        ),
                      ),
                      trailing: const Icon(Icons.delete, color: Colors.redAccent),
                      onTap: () {
                        // Implement cache clearing logic
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                            content: Text(
                              'Cache cleared',
                              style: GoogleFonts.poppins(
                                color: Theme.of(context).textTheme.bodyLarge?.color,
                              ),
                            ),
                          ),
                        );
                      },
                    ),
                  ),
                ],
              ),
            ),
          ),
        );
      },
    );
  }
}