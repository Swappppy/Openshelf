import 'package:flutter_riverpod/flutter_riverpod.dart';
import '../models/search_filters.dart';

/// Small buffer to pass filters from Search to Shelf creation
class ShelfCreationBuffer extends Notifier<SearchFilters?> {
  @override
  SearchFilters? build() => null;

  void set(SearchFilters filters) => state = filters;
  void clear() => state = null;
}

final shelfCreationBufferProvider = NotifierProvider<ShelfCreationBuffer, SearchFilters?>(
  ShelfCreationBuffer.new,
);
