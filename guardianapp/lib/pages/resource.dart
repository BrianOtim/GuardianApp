import 'package:flutter/material.dart';
import 'package:url_launcher/url_launcher.dart';

class ResourceScreen extends StatefulWidget {
  const ResourceScreen({super.key});
  @override
  State<ResourceScreen> createState() => _ResourceScreenState();
}

class _ResourceScreenState extends State<ResourceScreen> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color.fromARGB(255, 117, 20, 14),
      appBar: AppBar(
        title: const Text('Resources',
            style: TextStyle(fontSize: 16.0, color: Colors.black)),
        centerTitle: true,
      ),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.start,
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          const Text(
            '1. Articles on Domestic Violence.',
            style: TextStyle(fontSize: 22.0, color: Colors.white),
          ),
          TextButton(
            child: const Text(
              'Domestic Violence and Abuse in Intimate Relationship from Public Health Perspective',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () async {
              final uri = Uri.parse(
                  'https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4768593/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
          ),
          TextButton(
            child: const Text(
              'What Is Domestic Abuse?',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () async {
              final uri = Uri.parse(
                  'https://www.un.org/en/coronavirus/what-is-domestic-abuse');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
          ),
          const Text(
            '2. NGOS',
            style: TextStyle(fontSize: 22.0, color: Colors.white),
          ),
          TextButton(
            child: const Text(
              'Center for Domestic Violence Prevention (CEDOVIP)',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () async {
              final uri = Uri.parse('https://www.cedovip.org/about-us');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
          ),
          TextButton(
            child: const Text(
              'UGANET',
              style: TextStyle(fontSize: 20),
            ),
            onPressed: () async {
              final uri = Uri.parse('https://uganet.org/');
              if (await canLaunchUrl(uri)) {
                await launchUrl(uri);
              } else {
                throw 'Could not launch $uri';
              }
            },
          ),
          const Text(
            '3. Organizations to call.',
            style: TextStyle(fontSize: 22.0, color: Colors.white),
          ),
          const Text(
            'Emergency Number for Police:',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          TextButton(
            onPressed: () => launchUrl(Uri.parse('tel://0800199195')),
            child: const Text(
              '0800199195',
              style: TextStyle(fontSize: 20),
            ),
          ),
          const Text(
            'UGANET Shelters\' Contact:',
            style: TextStyle(fontSize: 20.0, color: Colors.white),
          ),
          TextButton(
            onPressed: () => launchUrl(Uri.parse('tel://0800333123')),
            child: const Text(
              "0800333123",
              style: TextStyle(fontSize: 20),
            ),
          ),
        ],
      ),
    );
  }
}
