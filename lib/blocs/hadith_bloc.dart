// lib/blocs/hadith_bloc.dart
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:hadith_cheker/models/hadith.dart';
import 'package:hadith_cheker/services/hadith_scraper.dart';

// Events
abstract class HadithEvent {}

class SearchHadithEvent extends HadithEvent {
  final String query;
  SearchHadithEvent(this.query);
}

class ClearResultsEvent extends HadithEvent {}

// States
abstract class HadithState {}

class HadithInitial extends HadithState {}

class HadithLoading extends HadithState {}

class HadithLoaded extends HadithState {
  final List<Hadith> hadiths;
  final String query;
  HadithLoaded(this.hadiths, this.query);
}

class HadithError extends HadithState {
  final String message;
  HadithError(this.message);
}

// Bloc
class HadithBloc extends Bloc<HadithEvent, HadithState> {
  final HadithScraper _scraper = HadithScraper();

  HadithBloc() : super(HadithInitial()) {
    on<SearchHadithEvent>(_onSearchHadith);
    on<ClearResultsEvent>(_onClearResults);
  }

  Future<void> _onSearchHadith(
      SearchHadithEvent event, Emitter<HadithState> emit) async {
    if (event.query.trim().isEmpty) {
      emit(HadithError('Please enter a search term'));
      return;
    }

    emit(HadithLoading());
    try {
      final hadiths = await _scraper.searchHadith(event.query);
      emit(HadithLoaded(hadiths, event.query));
    } catch (e) {
      emit(HadithError('Failed to fetch Hadith: $e'));
    }
  }

  void _onClearResults(ClearResultsEvent event, Emitter<HadithState> emit) {
    emit(HadithInitial());
  }
}