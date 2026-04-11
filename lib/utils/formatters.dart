import "package:intl/intl.dart";

final NumberFormat decimalFormatter = .decimalPattern()
  ..minimumFractionDigits = 1
  ..maximumFractionDigits = 1;

final NumberFormat percentFormatter = .percentPattern()
  ..minimumFractionDigits = 1
  ..maximumFractionDigits = 1;
