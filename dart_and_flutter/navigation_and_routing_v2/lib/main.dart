import 'package:flutter/material.dart';

// Entry
void main() {
  runApp(BooksApp());
}

// Data model
class Book {
  final String title;
  final String author;

  const Book(this.title, this.author);
}

// Abstract path model
class BooksAppPath {
  static const home = 'home';
  static const book = 'book';

  final int? id;

  BooksAppPath._constructor(this.id);

  // Uri string to abstract path model
  factory BooksAppPath.fromString(String? path) {
    if (path == null) {
      return BooksAppPath._constructor(null);
    }

    var uri = Uri.parse(path);
    if (uri.pathSegments.length == 2 && uri.pathSegments[0] == book) {
      return BooksAppPath._constructor(int.tryParse(uri.pathSegments[1]));
    }

    return BooksAppPath._constructor(null);
  }

  // App's state to abstract path model
  factory BooksAppPath.fromBooksAppState(BooksAppState state) {
    var selectedBook = state.selectedBook;
    if (selectedBook == null) {
      return BooksAppPath._constructor(null);
    }

    return BooksAppPath._constructor(BooksAppState.books.indexOf(selectedBook));
  }

  bool get isDetailsPage => id != null;
  bool get isHomePage => !isDetailsPage;

  // Abstract path model to uri string
  @override
  String toString() {
    if (isDetailsPage) {
      return '/$book/$id';
    }

    return '/$home';
  }
}

// App state model
//
// An instance of this class represents the whole app state.
// We need to notify our listeners when the app state has been changed,
// so we extend the ChangeNotifier class.
class BooksAppState extends ChangeNotifier {
  static const books = [
    Book('SICP', 'Harold Abelson and Gerald Jay Sussman with Julie Sussman'),
    Book('Algorithms', 'Robert Sedgewick and Kevin Wayne'),
    Book('CSAPP', 'Randal E. Bryant and David R. O\'Hallaron'),
  ];

  // For this app's state, we only care about the selected book (may be null).
  Book? _selectedBook;
  Book? get selectedBook => _selectedBook;
  set selectedBook(Book? book) {
    _selectedBook = book;
    notifyListeners();
  }
}

// Abstract path parser
class BooksAppPathParser extends RouteInformationParser<BooksAppPath> {
  // Flutter calls this method when the route information has been
  // changed (e.g. the uri in the browser has been changed).
  @override
  Future<BooksAppPath> parseRouteInformation(
      RouteInformation routeInformation) async {
    print(
        'In RouteInformationParser, call parseRouteInformation, routeInformation.location: ${routeInformation.location}');
    return BooksAppPath.fromString(routeInformation.location);
  }

  // Flutter calls this method after it accessed RouterDelegate.currentConfiguration.
  @override
  RouteInformation? restoreRouteInformation(BooksAppPath configuration) {
    print(
        'In RouteInformationParser, call restoreRouteInformation, configuration: $configuration');
    return RouteInformation(location: configuration.toString());
  }
}

// Abstract path delegate
//
// Generally, you can treat the mixing of ChangeNotifier and
// PopNavigatorRouterDelegateMixin as a requirement by the Flutter framework.
class BooksAppPathDelegate extends RouterDelegate<BooksAppPath>
    with ChangeNotifier, PopNavigatorRouterDelegateMixin<BooksAppPath> {
  // This is required. See the source code of PopNavigatorRouterDelegateMixin.
  final GlobalKey<NavigatorState> navigatorKey = GlobalKey();
  final BooksAppState _booksAppState;

  BooksAppPathDelegate(this._booksAppState) {
    _booksAppState.addListener(notifyListeners);
  }

  // Flutter accesses this method when we have notified the router that
  // something may have been changed (e.g. when we called the
  // notifyListeners() method).
  @override
  BooksAppPath get currentConfiguration {
    print(
        'In RouterDelegate, call currentConfiguration, _booksAppState.selectedBook.title: ${_booksAppState.selectedBook?.title}');
    return BooksAppPath.fromBooksAppState(_booksAppState);
  }

  // Flutter calls this method after it called
  // RouteInformationParser.parseRouteInformation.
  @override
  Future<void> setNewRoutePath(BooksAppPath configuration) async {
    print(
        'In RouterDelegate, call setNewRoutePath, configuration: $configuration');
    if (configuration.isHomePage) {
      _booksAppState.selectedBook = null;
      return;
    }

    _booksAppState.selectedBook = BooksAppState.books[configuration.id!];
  }

  void _onBookTapped(Book book) {
    _booksAppState.selectedBook = book;
  }

  @override
  Widget build(BuildContext context) {
    // print('In RouterDelegate, call build');
    return Navigator(
      key: navigatorKey,
      pages: [
        MaterialPage(
            child: BooksListScreen(
          books: BooksAppState.books,
          onBookTapped: _onBookTapped,
        )),
        if (_booksAppState.selectedBook != null)
          MaterialPage(
              child: BookDetailsScreen(
            book: _booksAppState.selectedBook!,
          ))
      ],
      onPopPage: (route, result) {
        _booksAppState.selectedBook = null;
        return route.didPop(result);
      },
    );
  }
}

class BooksListScreen extends StatelessWidget {
  final List<Book> books;
  // typedef ValueChanged<T> = void Function(T value);
  final ValueChanged<Book> onBookTapped;

  const BooksListScreen(
      {Key? key, required this.books, required this.onBookTapped})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Books List'),
      ),
      body: ListView(children: [
        for (var book in books)
          ListTile(
            title: Text(book.title),
            subtitle: Text(book.author),
            onTap: () => onBookTapped(book),
          )
      ]),
    );
  }
}

class BookDetailsScreen extends StatelessWidget {
  final Book book;

  const BookDetailsScreen({Key? key, required this.book}) : super(key: key);

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Book Details'),
      ),
      body: Container(
        padding: const EdgeInsets.all(8),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(book.title, style: Theme.of(context).textTheme.headline6),
            Text(book.author, style: Theme.of(context).textTheme.subtitle1),
          ],
        ),
      ),
    );
  }
}

// App
class BooksApp extends StatelessWidget {
  final BooksAppPathParser _booksAppPathParser;
  final BooksAppPathDelegate _booksAppPathDelegate;

  BooksApp({Key? key})
      : _booksAppPathParser = BooksAppPathParser(),
        _booksAppPathDelegate = BooksAppPathDelegate(BooksAppState()),
        super(key: key);

  @override
  Widget build(BuildContext context) {
    return MaterialApp.router(
        routeInformationParser: _booksAppPathParser,
        routerDelegate: _booksAppPathDelegate);
  }
}
