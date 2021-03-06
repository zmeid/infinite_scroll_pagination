import 'package:flutter/material.dart';
import 'package:flutter/widgets.dart';

/// Informs the current state of a paged list and fetches items on demand.
///
/// You're expected to subclass it and provide your own implementation for
/// [fetchItems]. You can do whatever you want in there, from directly calling a
/// remote API to sending an event to a BLoC. Once you have your items *or* an
/// error, you have two options:
///
/// 1. Manually change the values of [itemList], [error], [nextPageKey] and then
/// call [notifyListeners].
/// 2. Use one of the convenience functions to do the above: [notifyError],
/// [notifyNewPage] or [notifyChange]. The last one overrides the value of all
/// three properties at once.
///
/// * [itemList]: All items loaded so far. Initially `null`.
/// * [nextPageKey]: The key for the next page in the API. It may be, for
/// example, a page number, a page token or the number of items to offset. The
/// initial value is received in the constructor. Must be `null` once there are
/// no more items to fetch in the API.
/// * [error]: An error, if any. In cases where a subsequent page loading
/// fails, both [itemList] and [error] will have values. Must be set back to
/// `null` on every successful response.
///
/// Subclasses must specify both the [PageKeyType] and [ItemType] generic types,
/// and should always make a call to the `super` constructor in order to provide
/// the first page’s key.
///
/// This object should generally have a lifetime longer than the
/// widgets itself; it should be reused each time a paged widget
/// constructor is called.
abstract class PagedDataSource<PageKeyType, ItemType> extends ChangeNotifier {
  PagedDataSource(this.firstPageKey)
      : nextPageKey = firstPageKey,
        assert(firstPageKey != null) {
    fetchItems(firstPageKey);
  }

  /// Should fetch a new items chunk for the given page's [pageKey].
  ///
  /// When the work is done, don't forget to update [itemList], [error],
  /// [nextPageKey] and call [notifyListeners]. Or simply call one of the
  /// convenience functions: [notifyChange], [notifyNewPage] or [notifyError].
  void fetchItems(PageKeyType pageKey);

  /// List of currently loaded items. Initially `null`.
  List<ItemType> itemList;

  /// Holds the current error, if any. Initially `null`.
  dynamic error;

  /// The key for the next page to be fetched.
  ///
  /// Initialized with the same value as [firstPageKey], received in the
  /// constructor.
  PageKeyType nextPageKey;

  /// The key for the first page to be fetched.
  ///
  /// Needed for being able to reset state.
  final PageKeyType firstPageKey;

  /// Resets `this` to its initial state and fetches the initial key again.
  void refresh() {
    itemList = null;
    error = null;
    nextPageKey = firstPageKey;
    notifyListeners();
    fetchItems(firstPageKey);
  }

  /// Erases the current error so that we're back to loading state and retries
  /// the latest request.
  void retryLastRequest() {
    error = null;
    notifyListeners();
    fetchItems(nextPageKey);
  }

  /// Updates all three variables. Useful if the state is being managed
  /// elsewhere, like a BLoC.
  void notifyChange(
    List<ItemType> itemList,
    dynamic error,
    PageKeyType nextPageKey,
  ) {
    this.itemList = itemList;
    this.error = error;
    this.nextPageKey = nextPageKey;
    notifyListeners();
  }

  /// Notifies a new page fetch by appending [newItems] to the previous loaded
  /// items ([itemList]). Also sets the next key to be fetched and erases any
  /// previous error.
  void notifyNewPage(List<ItemType> newItems, PageKeyType nextPageKey) {
    itemList ??= [];
    itemList.addAll(newItems);
    this.nextPageKey = nextPageKey;
    error = null;
    notifyListeners();
  }

  /// Notify that an error has occurred. Works for both first and subsequent
  /// page fetches.
  void notifyError(dynamic error) {
    this.error = error;
    notifyListeners();
  }
}
