import 'calendar_dates.dart' show searchKey;

/// How long an address stays in the Address_History without being used.
const Duration addressRetention = Duration(days: 30);

/// The most Address_Suggestions the Event_Form shows.
const int maxAddressSuggestions = 5;

/// The key of an address in the history: letter case does not make a new entry.
String addressKey(String address) => address.trim().toLowerCase();

/// Whether [address] is a suggestion for the [typed] text: it contains the text
/// (ignoring case and diacritics) and is not the same address.
bool matchesAddress(String address, String typed) {
  final String needle = searchKey(typed.trim());
  if (needle.isEmpty) return true;
  final String hay = searchKey(address);
  return hay != needle && hay.contains(needle);
}
