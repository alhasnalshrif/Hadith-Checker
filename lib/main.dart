// lib/main.dart
import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith_cheker/blocs/hadith_bloc.dart';
import 'package:hadith_cheker/models/hadith.dart';
import 'package:hadith_cheker/services/url_handler_service.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await UrlHandlerService.initialize();
  runApp(const HadithScraperApp());
}

class HadithScraperApp extends StatelessWidget {
  const HadithScraperApp({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => HadithBloc(),
      child: MaterialApp(
        title: 'Hadith Scraper',
        theme: ThemeData(
          primarySwatch: Colors.green,
          visualDensity: VisualDensity.adaptivePlatformDensity,
          textTheme: const TextTheme(bodyMedium: TextStyle(fontSize: 16)),
        ),
        home: const HadithSearchScreen(),
      ),
    );
  }
}

class HadithSearchScreen extends StatefulWidget {
  const HadithSearchScreen({super.key});

  @override
  _HadithSearchScreenState createState() => _HadithSearchScreenState();
}

class _HadithSearchScreenState extends State<HadithSearchScreen> {
  final TextEditingController _searchController = TextEditingController();
  late StreamSubscription<String> _textStreamSubscription;

  @override
  void initState() {
    super.initState();
    _textStreamSubscription = UrlHandlerService.textStream.listen((sharedText) {
      _searchController.text = sharedText;
      _searchHadith(context);
    });
  }

  @override
  void dispose() {
    _textStreamSubscription.cancel();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Hadith Search'),
        actions: [
          IconButton(
            icon: const Icon(Icons.clear),
            onPressed: () {
              _searchController.clear();
              context.read<HadithBloc>().add(ClearResultsEvent());
            },
          ),
        ],
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _searchController,
              decoration: InputDecoration(
                labelText: 'Search Hadith',
                border: const OutlineInputBorder(),
                suffixIcon: IconButton(
                  icon: const Icon(Icons.search),
                  onPressed: () => _searchHadith(context),
                ),
              ),
              onSubmitted: (_) => _searchHadith(context),
            ),
            const SizedBox(height: 16),
            Expanded(
              child: BlocBuilder<HadithBloc, HadithState>(
                builder: (context, state) {
                  if (state is HadithLoading) {
                    return const Center(child: CircularProgressIndicator());
                  }
                  if (state is HadithError) {
                    return Center(
                      child: Text(
                        state.message,
                        style: const TextStyle(color: Colors.red),
                        textAlign: TextAlign.center,
                      ),
                    );
                  }
                  if (state is HadithLoaded) {
                    if (state.hadiths.isEmpty) {
                      return const Center(child: Text('No results found'));
                    }
                    return ListView.builder(
                      itemCount: state.hadiths.length,
                      itemBuilder: (context, index) {
                        final hadith = state.hadiths[index];
                        return _buildHadithCard(context, hadith);
                      },
                    );
                  }
                  return const Center(child: Text('Search for a Hadith'));
                },
              ),
            ),
          ],
        ),
      ),
    );
  }

  void _searchHadith(BuildContext context) {
    final query = _searchController.text.trim();
    if (query.isNotEmpty) {
      context.read<HadithBloc>().add(SearchHadithEvent(query));
    }
  }

  Widget _buildHadithCard(BuildContext context, Hadith hadith) {
    return Card(
      elevation: 2,
      margin: const EdgeInsets.symmetric(vertical: 8),
      child: Padding(
        padding: const EdgeInsets.all(12.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            SelectionArea(
              contextMenuBuilder: (context, editableTextState) {
                final selection = editableTextState.textEditingValue.selection;
                final selectedText = selection.textInside(
                  editableTextState.textEditingValue.text,
                );
                return AdaptiveTextSelectionToolbar.buttonItems(
                  anchors: editableTextState.contextMenuAnchors,
                  buttonItems: [
                    ...editableTextState.contextMenuButtonItems,
                    ContextMenuButtonItem(
                      label: 'Check Hadith',
                      onPressed: () {
                        if (selectedText.isNotEmpty) {
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Checking: "$selectedText"'),
                            ),
                          );
                          context.read<HadithBloc>().add(
                            SearchHadithEvent(selectedText),
                          );
                        }
                        Navigator.pop(context);
                      },
                    ),
                  ],
                );
              },
              child: Text(
                hadith.english.hadith,
                style: const TextStyle(fontWeight: FontWeight.bold),
              ),
            ),
            const SizedBox(height: 8),
            Text('Narrated: ${hadith.english.hadithNarrated}'),
            Text('Collection: ${hadith.collection} | Book: ${hadith.book}'),
            if (hadith.english.grade != null)
              Text(
                'Grade: ${hadith.english.grade}',
                style: const TextStyle(color: Colors.blue),
              ),
            const SizedBox(height: 8),
            Text(
              hadith.arabic.hadith,
              textDirection: TextDirection.rtl,
              style: const TextStyle(fontSize: 18),
            ),
          ],
        ),
      ),
    );
  }
}
