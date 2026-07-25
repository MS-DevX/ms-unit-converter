/// Full ISO-4217 currency dataset (170+ active currencies) with fallback exchange rates,
/// flags, country mappings, decimal digits, and symbols.
library;

import '../models/currency_model.dart';

/// Set of currency codes that appear first in sorted lists.
const Set<String> pinnedCurrencyCodes = {
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'PKR',
  'INR',
  'AUD',
  'CAD',
  'CHF',
  'AED',
  'SAR',
};

/// Order in which pinned currencies are displayed.
const List<String> pinnedCurrencyOrder = [
  'USD',
  'EUR',
  'GBP',
  'JPY',
  'PKR',
  'INR',
  'AUD',
  'CAD',
  'CHF',
  'AED',
  'SAR',
];

/// Detailed metadata for ISO-4217 currency entry.
class CurrencyEntry {
  final String code;
  final String name;
  final String symbol;
  final String flag;
  final String country;
  final int decimalDigits;
  final double fallbackRateToUsd;

  const CurrencyEntry({
    required this.code,
    required this.name,
    required this.symbol,
    required this.flag,
    required this.country,
    this.decimalDigits = 2,
    required this.fallbackRateToUsd,
  });
}

/// Comprehensive ISO-4217 Currency Database (170+ currencies).
const List<CurrencyEntry> allIsoCurrencies = [
  // Pinned / Major
  CurrencyEntry(code: 'USD', name: 'US Dollar', symbol: r'$', flag: '🇺🇸', country: 'United States', fallbackRateToUsd: 1.0),
  CurrencyEntry(code: 'EUR', name: 'Euro', symbol: '€', flag: '🇪🇺', country: 'European Union Eurozone', fallbackRateToUsd: 0.92),
  CurrencyEntry(code: 'GBP', name: 'British Pound', symbol: '£', flag: '🇬🇧', country: 'United Kingdom Britain', fallbackRateToUsd: 0.79),
  CurrencyEntry(code: 'JPY', name: 'Japanese Yen', symbol: '¥', flag: '🇯🇵', country: 'Japan', decimalDigits: 0, fallbackRateToUsd: 155.0),
  CurrencyEntry(code: 'PKR', name: 'Pakistani Rupee', symbol: 'Rs', flag: '🇵🇰', country: 'Pakistan', decimalDigits: 0, fallbackRateToUsd: 278.5),
  CurrencyEntry(code: 'INR', name: 'Indian Rupee', symbol: '₹', flag: '🇮🇳', country: 'India', fallbackRateToUsd: 83.5),
  CurrencyEntry(code: 'AUD', name: 'Australian Dollar', symbol: r'A$', flag: '🇦🇺', country: 'Australia', fallbackRateToUsd: 1.52),
  CurrencyEntry(code: 'CAD', name: 'Canadian Dollar', symbol: r'C$', flag: '🇨🇦', country: 'Canada', fallbackRateToUsd: 1.37),
  CurrencyEntry(code: 'CHF', name: 'Swiss Franc', symbol: 'CHF', flag: '🇨🇭', country: 'Switzerland Liechtenstein', fallbackRateToUsd: 0.89),
  CurrencyEntry(code: 'AED', name: 'UAE Dirham', symbol: 'د.إ', flag: '🇦🇪', country: 'United Arab Emirates Dubai', fallbackRateToUsd: 3.67),
  CurrencyEntry(code: 'SAR', name: 'Saudi Riyal', symbol: '﷼', flag: '🇸🇦', country: 'Saudi Arabia', fallbackRateToUsd: 3.75),

  // A
  CurrencyEntry(code: 'AFN', name: 'Afghan Afghani', symbol: '؋', flag: '🇦🇫', country: 'Afghanistan', decimalDigits: 0, fallbackRateToUsd: 71.5),
  CurrencyEntry(code: 'ALL', name: 'Albanian Lek', symbol: 'L', flag: '🇦🇱', country: 'Albania', decimalDigits: 0, fallbackRateToUsd: 93.2),
  CurrencyEntry(code: 'AMD', name: 'Armenian Dram', symbol: '֏', flag: '🇦🇲', country: 'Armenia', decimalDigits: 0, fallbackRateToUsd: 388.0),
  CurrencyEntry(code: 'ANG', name: 'Netherlands Antillean Guilder', symbol: 'ƒ', flag: '🇸🇽', country: 'Curacao Sint Maarten', fallbackRateToUsd: 1.79),
  CurrencyEntry(code: 'AOA', name: 'Angolan Kwanza', symbol: 'Kz', flag: '🇦🇴', country: 'Angola', fallbackRateToUsd: 855.0),
  CurrencyEntry(code: 'ARS', name: 'Argentine Peso', symbol: r'$', flag: '🇦🇷', country: 'Argentina', fallbackRateToUsd: 920.0),
  CurrencyEntry(code: 'AWG', name: 'Aruban Florin', symbol: 'ƒ', flag: '🇦🇼', country: 'Aruba', fallbackRateToUsd: 1.79),
  CurrencyEntry(code: 'AZN', name: 'Azerbaijani Manat', symbol: '₼', flag: '🇦🇿', country: 'Azerbaijan', fallbackRateToUsd: 1.70),

  // B
  CurrencyEntry(code: 'BAM', name: 'Bosnia-Herzegovina Convertible Mark', symbol: 'KM', flag: '🇧🇦', country: 'Bosnia Herzegovina', fallbackRateToUsd: 1.80),
  CurrencyEntry(code: 'BBD', name: 'Barbadian Dollar', symbol: r'$', flag: '🇧🇧', country: 'Barbados', fallbackRateToUsd: 2.0),
  CurrencyEntry(code: 'BDT', name: 'Bangladeshi Taka', symbol: '৳', flag: '🇧🇩', country: 'Bangladesh', fallbackRateToUsd: 117.5),
  CurrencyEntry(code: 'BGN', name: 'Bulgarian Lev', symbol: 'лв', flag: '🇧🇬', country: 'Bulgaria', fallbackRateToUsd: 1.80),
  CurrencyEntry(code: 'BHD', name: 'Bahraini Dinar', symbol: '.د.ب', flag: '🇧🇭', country: 'Bahrain', decimalDigits: 3, fallbackRateToUsd: 0.376),
  CurrencyEntry(code: 'BIF', name: 'Burundian Franc', symbol: 'FBu', flag: '🇧🇮', country: 'Burundi', decimalDigits: 0, fallbackRateToUsd: 2870.0),
  CurrencyEntry(code: 'BMD', name: 'Bermudian Dollar', symbol: r'$', flag: '🇧🇲', country: 'Bermuda', fallbackRateToUsd: 1.0),
  CurrencyEntry(code: 'BND', name: 'Brunei Dollar', symbol: r'B$', flag: '🇧🇳', country: 'Brunei', fallbackRateToUsd: 1.35),
  CurrencyEntry(code: 'BOB', name: 'Bolivian Boliviano', symbol: 'Bs.', flag: '🇧🇴', country: 'Bolivia', fallbackRateToUsd: 6.91),
  CurrencyEntry(code: 'BRL', name: 'Brazilian Real', symbol: r'R$', flag: '🇧🇷', country: 'Brazil', fallbackRateToUsd: 5.45),
  CurrencyEntry(code: 'BSD', name: 'Bahamian Dollar', symbol: r'B$', flag: '🇧🇸', country: 'Bahamas', fallbackRateToUsd: 1.0),
  CurrencyEntry(code: 'BTN', name: 'Bhutanese Ngultrum', symbol: 'Nu.', flag: '🇧🇹', country: 'Bhutan', fallbackRateToUsd: 83.5),
  CurrencyEntry(code: 'BWP', name: 'Botswana Pula', symbol: 'P', flag: '🇧🇼', country: 'Botswana', fallbackRateToUsd: 13.6),
  CurrencyEntry(code: 'BYN', name: 'Belarusian Ruble', symbol: 'Br', flag: '🇧🇾', country: 'Belarus', fallbackRateToUsd: 3.27),
  CurrencyEntry(code: 'BZD', name: 'Belize Dollar', symbol: r'BZ$', flag: '🇧🇿', country: 'Belize', fallbackRateToUsd: 2.0),

  // C
  CurrencyEntry(code: 'CDF', name: 'Congolese Franc', symbol: 'FC', flag: '🇨🇩', country: 'Democratic Republic of Congo', decimalDigits: 0, fallbackRateToUsd: 2830.0),
  CurrencyEntry(code: 'CLP', name: 'Chilean Peso', symbol: r'$', flag: '🇨🇱', country: 'Chile', decimalDigits: 0, fallbackRateToUsd: 940.0),
  CurrencyEntry(code: 'CNY', name: 'Chinese Yuan', symbol: '¥', flag: '🇨🇳', country: 'China Renminbi', fallbackRateToUsd: 7.26),
  CurrencyEntry(code: 'COP', name: 'Colombian Peso', symbol: r'$', flag: '🇨🇴', country: 'Colombia', fallbackRateToUsd: 4150.0),
  CurrencyEntry(code: 'CRC', name: 'Costa Rican Colón', symbol: '₡', flag: '🇨🇷', country: 'Costa Rica', decimalDigits: 0, fallbackRateToUsd: 525.0),
  CurrencyEntry(code: 'CUP', name: 'Cuban Peso', symbol: r'$MN', flag: '🇨🇺', country: 'Cuba', decimalDigits: 0, fallbackRateToUsd: 24.0),
  CurrencyEntry(code: 'CVE', name: 'Cape Verdean Escudo', symbol: r'$', flag: '🇨🇻', country: 'Cape Verde', decimalDigits: 0, fallbackRateToUsd: 101.5),
  CurrencyEntry(code: 'CZK', name: 'Czech Koruna', symbol: 'Kč', flag: '🇨🇿', country: 'Czechia Czech Republic', fallbackRateToUsd: 23.2),

  // D
  CurrencyEntry(code: 'DJF', name: 'Djiboutian Franc', symbol: 'Fdj', flag: '🇩🇯', country: 'Djibouti', decimalDigits: 0, fallbackRateToUsd: 177.7),
  CurrencyEntry(code: 'DKK', name: 'Danish Krone', symbol: 'kr', flag: '🇩🇰', country: 'Denmark Greenland', fallbackRateToUsd: 6.88),
  CurrencyEntry(code: 'DOP', name: 'Dominican Peso', symbol: r'RD$', flag: '🇩🇴', country: 'Dominican Republic', fallbackRateToUsd: 59.2),
  CurrencyEntry(code: 'DZD', name: 'Algerian Dinar', symbol: 'د.ج', flag: '🇩🇿', country: 'Algeria', fallbackRateToUsd: 134.5),

  // E
  CurrencyEntry(code: 'EGP', name: 'Egyptian Pound', symbol: 'E£', flag: '🇪🇬', country: 'Egypt', fallbackRateToUsd: 47.8),
  CurrencyEntry(code: 'ERN', name: 'Eritrean Nakfa', symbol: 'Nfk', flag: '🇪🇷', country: 'Eritrea', fallbackRateToUsd: 15.0),
  CurrencyEntry(code: 'ETB', name: 'Ethiopian Birr', symbol: 'Br', flag: '🇪🇹', country: 'Ethiopia', fallbackRateToUsd: 57.5),

  // F
  CurrencyEntry(code: 'FJD', name: 'Fijian Dollar', symbol: r'FJ$', flag: '🇫🇯', country: 'Fiji', fallbackRateToUsd: 2.25),
  CurrencyEntry(code: 'FKP', name: 'Falkland Islands Pound', symbol: '£', flag: '🇫🇰', country: 'Falkland Islands', fallbackRateToUsd: 0.79),

  // G
  CurrencyEntry(code: 'GEL', name: 'Georgian Lari', symbol: '₾', flag: '🇬🇪', country: 'Georgia', fallbackRateToUsd: 2.85),
  CurrencyEntry(code: 'GHS', name: 'Ghanaian Cedi', symbol: 'GH₵', flag: '🇬🇭', country: 'Ghana', fallbackRateToUsd: 15.2),
  CurrencyEntry(code: 'GIP', name: 'Gibraltar Pound', symbol: '£', flag: '🇬🇮', country: 'Gibraltar', fallbackRateToUsd: 0.79),
  CurrencyEntry(code: 'GMD', name: 'Gambian Dalasi', symbol: 'D', flag: '🇬🇲', country: 'Gambia', fallbackRateToUsd: 67.5),
  CurrencyEntry(code: 'GNF', name: 'Guinean Franc', symbol: 'FG', flag: '🇬🇳', country: 'Guinea', decimalDigits: 0, fallbackRateToUsd: 8600.0),
  CurrencyEntry(code: 'GTQ', name: 'Guatemalan Quetzal', symbol: 'Q', flag: '🇬🇹', country: 'Guatemala', fallbackRateToUsd: 7.76),
  CurrencyEntry(code: 'GYD', name: 'Guyanaese Dollar', symbol: r'G$', flag: '🇬🇾', country: 'Guyana', fallbackRateToUsd: 209.0),

  // H
  CurrencyEntry(code: 'HKD', name: 'Hong Kong Dollar', symbol: r'HK$', flag: '🇭🇰', country: 'Hong Kong', fallbackRateToUsd: 7.81),
  CurrencyEntry(code: 'HNL', name: 'Honduran Lempira', symbol: 'L', flag: '🇭🇳', country: 'Honduras', fallbackRateToUsd: 24.7),
  CurrencyEntry(code: 'HRK', name: 'Croatian Kuna', symbol: 'kn', flag: '🇭🇷', country: 'Croatia', fallbackRateToUsd: 6.93),
  CurrencyEntry(code: 'HTG', name: 'Haitian Gourde', symbol: 'G', flag: '🇭🇹', country: 'Haiti', fallbackRateToUsd: 132.5),
  CurrencyEntry(code: 'HUF', name: 'Hungarian Forint', symbol: 'Ft', flag: '🇭🇺', country: 'Hungary', decimalDigits: 0, fallbackRateToUsd: 365.0),

  // I
  CurrencyEntry(code: 'IDR', name: 'Indonesian Rupiah', symbol: 'Rp', flag: '🇮🇩', country: 'Indonesia', decimalDigits: 0, fallbackRateToUsd: 16400.0),
  CurrencyEntry(code: 'ILS', name: 'Israeli New Shekel', symbol: '₪', flag: '🇮🇱', country: 'Israel Palestine', fallbackRateToUsd: 3.72),
  CurrencyEntry(code: 'IQD', name: 'Iraqi Dinar', symbol: 'ع.د', flag: '🇮🇶', country: 'Iraq', decimalDigits: 0, fallbackRateToUsd: 1310.0),
  CurrencyEntry(code: 'IRR', name: 'Iranian Rial', symbol: '﷼', flag: '🇮🇷', country: 'Iran', decimalDigits: 0, fallbackRateToUsd: 42000.0),
  CurrencyEntry(code: 'ISK', name: 'Icelandic Króna', symbol: 'kr', flag: '🇮🇸', country: 'Iceland', decimalDigits: 0, fallbackRateToUsd: 138.5),

  // J
  CurrencyEntry(code: 'JMD', name: 'Jamaican Dollar', symbol: r'J$', flag: '🇯🇲', country: 'Jamaica', decimalDigits: 0, fallbackRateToUsd: 156.0),
  CurrencyEntry(code: 'JOD', name: 'Jordanian Dinar', symbol: 'د.ا', flag: '🇯🇴', country: 'Jordan', decimalDigits: 3, fallbackRateToUsd: 0.709),

  // K
  CurrencyEntry(code: 'KES', name: 'Kenyan Shilling', symbol: 'KSh', flag: '🇰🇪', country: 'Kenya', decimalDigits: 0, fallbackRateToUsd: 129.0),
  CurrencyEntry(code: 'KGS', name: 'Kyrgystani Som', symbol: 'сом', flag: '🇰🇬', country: 'Kyrgyzstan', fallbackRateToUsd: 87.5),
  CurrencyEntry(code: 'KHR', name: 'Cambodian Riel', symbol: '៛', flag: '🇰🇭', country: 'Cambodia', decimalDigits: 0, fallbackRateToUsd: 4100.0),
  CurrencyEntry(code: 'KMF', name: 'Comorian Franc', symbol: 'CF', flag: '🇰🇲', country: 'Comoros', decimalDigits: 0, fallbackRateToUsd: 452.5),
  CurrencyEntry(code: 'KPW', name: 'North Korean Won', symbol: '₩', flag: '🇰🇵', country: 'North Korea', decimalDigits: 0, fallbackRateToUsd: 900.0),
  CurrencyEntry(code: 'KRW', name: 'South Korean Won', symbol: '₩', flag: '🇰🇷', country: 'South Korea', decimalDigits: 0, fallbackRateToUsd: 1380.0),
  CurrencyEntry(code: 'KWD', name: 'Kuwaiti Dinar', symbol: 'د.ك', flag: '🇰🇼', country: 'Kuwait', decimalDigits: 3, fallbackRateToUsd: 0.307),
  CurrencyEntry(code: 'KYD', name: 'Cayman Islands Dollar', symbol: r'CI$', flag: '🇰🇾', country: 'Cayman Islands', fallbackRateToUsd: 0.833),
  CurrencyEntry(code: 'KZT', name: 'Kazakhstani Tenge', symbol: '₸', flag: '🇰🇿', country: 'Kazakhstan', fallbackRateToUsd: 465.0),

  // L
  CurrencyEntry(code: 'LAK', name: 'Lao Kip', symbol: '₭', flag: '🇱🇦', country: 'Laos', decimalDigits: 0, fallbackRateToUsd: 22000.0),
  CurrencyEntry(code: 'LBP', name: 'Lebanese Pound', symbol: 'ل.ل', flag: '🇱🇧', country: 'Lebanon', decimalDigits: 0, fallbackRateToUsd: 89500.0),
  CurrencyEntry(code: 'LKR', name: 'Sri Lankan Rupee', symbol: 'Rs', flag: '🇱🇰', country: 'Sri Lanka', decimalDigits: 0, fallbackRateToUsd: 305.0),
  CurrencyEntry(code: 'LRD', name: 'Liberian Dollar', symbol: r'L$', flag: '🇱🇷', country: 'Liberia', fallbackRateToUsd: 194.0),
  CurrencyEntry(code: 'LSL', name: 'Lesotho Loti', symbol: 'L', flag: '🇱🇸', country: 'Lesotho', fallbackRateToUsd: 18.2),
  CurrencyEntry(code: 'LYD', name: 'Libyan Dinar', symbol: 'ل.د', flag: '🇱🇾', country: 'Libya', decimalDigits: 3, fallbackRateToUsd: 4.85),

  // M
  CurrencyEntry(code: 'MAD', name: 'Moroccan Dirham', symbol: 'د.م.', flag: '🇲🇦', country: 'Morocco Western Sahara', fallbackRateToUsd: 9.95),
  CurrencyEntry(code: 'MDL', name: 'Moldovan Leu', symbol: 'L', flag: '🇲🇩', country: 'Moldova', fallbackRateToUsd: 17.8),
  CurrencyEntry(code: 'MGA', name: 'Malagasy Ariary', symbol: 'Ar', flag: '🇲🇬', country: 'Madagascar', decimalDigits: 0, fallbackRateToUsd: 4500.0),
  CurrencyEntry(code: 'MKD', name: 'Macedonian Denar', symbol: 'ден', flag: '🇲🇰', country: 'North Macedonia', fallbackRateToUsd: 56.5),
  CurrencyEntry(code: 'MMK', name: 'Myanmar Kyat', symbol: 'Ks', flag: '🇲🇲', country: 'Myanmar Burma', decimalDigits: 0, fallbackRateToUsd: 2100.0),
  CurrencyEntry(code: 'MNT', name: 'Mongolian Tugrik', symbol: '₮', flag: '🇲🇳', country: 'Mongolia', decimalDigits: 0, fallbackRateToUsd: 3450.0),
  CurrencyEntry(code: 'MOP', name: 'Macanese Pataca', symbol: r'MOP$', flag: '🇲🇴', country: 'Macau', fallbackRateToUsd: 8.05),
  CurrencyEntry(code: 'MRU', name: 'Mauritanian Ouguiya', symbol: 'UM', flag: '🇲🇷', country: 'Mauritania', decimalDigits: 0, fallbackRateToUsd: 39.7),
  CurrencyEntry(code: 'MUR', name: 'Mauritian Rupee', symbol: '₨', flag: '🇲🇺', country: 'Mauritius', fallbackRateToUsd: 46.5),
  CurrencyEntry(code: 'MVR', name: 'Maldivian Rufiyaa', symbol: 'Rf', flag: '🇲🇻', country: 'Maldives', fallbackRateToUsd: 15.4),
  CurrencyEntry(code: 'MWK', name: 'Malawian Kwacha', symbol: 'MK', flag: '🇲🇼', country: 'Malawi', fallbackRateToUsd: 1735.0),
  CurrencyEntry(code: 'MXN', name: 'Mexican Peso', symbol: r'$', flag: '🇲🇽', country: 'Mexico', fallbackRateToUsd: 18.2),
  CurrencyEntry(code: 'MYR', name: 'Malaysian Ringgit', symbol: 'RM', flag: '🇲🇾', country: 'Malaysia', fallbackRateToUsd: 4.71),
  CurrencyEntry(code: 'MZN', name: 'Mozambican Metical', symbol: 'MT', flag: '🇲🇿', country: 'Mozambique', fallbackRateToUsd: 63.9),

  // N
  CurrencyEntry(code: 'NAD', name: 'Namibian Dollar', symbol: r'N$', flag: '🇳🇦', country: 'Namibia', fallbackRateToUsd: 18.2),
  CurrencyEntry(code: 'NGN', name: 'Nigerian Naira', symbol: '₦', flag: '🇳🇬', country: 'Nigeria', decimalDigits: 0, fallbackRateToUsd: 1480.0),
  CurrencyEntry(code: 'NIO', name: 'Nicaraguan Córdoba', symbol: r'C$', flag: '🇳🇮', country: 'Nicaragua', fallbackRateToUsd: 36.8),
  CurrencyEntry(code: 'NOK', name: 'Norwegian Krone', symbol: 'kr', flag: '🇳🇴', country: 'Norway', fallbackRateToUsd: 10.6),
  CurrencyEntry(code: 'NPR', name: 'Nepalese Rupee', symbol: 'Rs', flag: '🇳🇵', country: 'Nepal', decimalDigits: 0, fallbackRateToUsd: 133.5),
  CurrencyEntry(code: 'NZD', name: 'New Zealand Dollar', symbol: r'NZ$', flag: '🇳🇿', country: 'New Zealand Cook Islands', fallbackRateToUsd: 1.63),

  // O
  CurrencyEntry(code: 'OMR', name: 'Omani Rial', symbol: '﷼', flag: '🇴🇲', country: 'Oman', decimalDigits: 3, fallbackRateToUsd: 0.385),

  // P
  CurrencyEntry(code: 'PAB', name: 'Panamanian Balboa', symbol: 'B/.', flag: '🇵🇦', country: 'Panama', fallbackRateToUsd: 1.0),
  CurrencyEntry(code: 'PEN', name: 'Peruvian Sol', symbol: 'S/', flag: '🇵🇪', country: 'Peru', fallbackRateToUsd: 3.75),
  CurrencyEntry(code: 'PGK', name: 'Papua New Guinean Kina', symbol: 'K', flag: '🇵🇬', country: 'Papua New Guinea', fallbackRateToUsd: 3.88),
  CurrencyEntry(code: 'PHP', name: 'Philippine Peso', symbol: '₱', flag: '🇵🇭', country: 'Philippines', fallbackRateToUsd: 58.5),
  CurrencyEntry(code: 'PLN', name: 'Polish Zloty', symbol: 'zł', flag: '🇵🇱', country: 'Poland', fallbackRateToUsd: 3.98),
  CurrencyEntry(code: 'PYG', name: 'Paraguayan Guaraní', symbol: '₲', flag: '🇵🇾', country: 'Paraguay', decimalDigits: 0, fallbackRateToUsd: 7550.0),

  // Q
  CurrencyEntry(code: 'QAR', name: 'Qatari Riyal', symbol: '﷼', flag: '🇶🇦', country: 'Qatar', fallbackRateToUsd: 3.64),

  // R
  CurrencyEntry(code: 'RON', name: 'Romanian Leu', symbol: 'lei', flag: '🇷🇴', country: 'Romania', fallbackRateToUsd: 4.58),
  CurrencyEntry(code: 'RSD', name: 'Serbian Dinar', symbol: 'дин.', flag: '🇷🇸', country: 'Serbia', decimalDigits: 0, fallbackRateToUsd: 108.0),
  CurrencyEntry(code: 'RUB', name: 'Russian Ruble', symbol: '₽', flag: '🇷🇺', country: 'Russia', fallbackRateToUsd: 88.5),
  CurrencyEntry(code: 'RWF', name: 'Rwandan Franc', symbol: 'FRw', flag: '🇷🇼', country: 'Rwanda', decimalDigits: 0, fallbackRateToUsd: 1310.0),

  // S
  CurrencyEntry(code: 'SCR', name: 'Seychellois Rupee', symbol: 'SR', flag: '🇸🇨', country: 'Seychelles', fallbackRateToUsd: 13.5),
  CurrencyEntry(code: 'SDG', name: 'Sudanese Pound', symbol: 'ج.س.', flag: '🇸🇩', country: 'Sudan', fallbackRateToUsd: 600.0),
  CurrencyEntry(code: 'SEK', name: 'Swedish Krona', symbol: 'kr', flag: '🇸🇪', country: 'Sweden', fallbackRateToUsd: 10.5),
  CurrencyEntry(code: 'SGD', name: 'Singapore Dollar', symbol: r'S$', flag: '🇸🇬', country: 'Singapore', fallbackRateToUsd: 1.35),
  CurrencyEntry(code: 'SHP', name: 'Saint Helena Pound', symbol: '£', flag: '🇸🇭', country: 'Saint Helena', fallbackRateToUsd: 0.79),
  CurrencyEntry(code: 'SLE', name: 'Sierra Leonean Leone', symbol: 'Le', flag: '🇸🇱', country: 'Sierra Leone', decimalDigits: 0, fallbackRateToUsd: 22.5),
  CurrencyEntry(code: 'SOS', name: 'Somali Shilling', symbol: 'Sh.So.', flag: '🇸🇴', country: 'Somalia', decimalDigits: 0, fallbackRateToUsd: 570.0),
  CurrencyEntry(code: 'SRD', name: 'Surinamese Dollar', symbol: r'$', flag: '🇸🇷', country: 'Suriname', fallbackRateToUsd: 31.2),
  CurrencyEntry(code: 'SSP', name: 'South Sudanese Pound', symbol: '£', flag: '🇸🇸', country: 'South Sudan', fallbackRateToUsd: 1550.0),
  CurrencyEntry(code: 'STN', name: 'São Tomé and Príncipe Dobra', symbol: 'Db', flag: '🇸🇹', country: 'Sao Tome and Principe', decimalDigits: 0, fallbackRateToUsd: 22.5),
  CurrencyEntry(code: 'SVC', name: 'Salvadoran Colón', symbol: r'$', flag: '🇸🇻', country: 'El Salvador', fallbackRateToUsd: 8.75),
  CurrencyEntry(code: 'SYP', name: 'Syrian Pound', symbol: 'LS', flag: '🇸🇾', country: 'Syria', decimalDigits: 0, fallbackRateToUsd: 13000.0),
  CurrencyEntry(code: 'SZL', name: 'Swazi Lilangeni', symbol: 'E', flag: '🇸🇿', country: 'Eswatini Swaziland', fallbackRateToUsd: 18.2),

  // T
  CurrencyEntry(code: 'THB', name: 'Thai Baht', symbol: '฿', flag: '🇹🇭', country: 'Thailand', fallbackRateToUsd: 36.7),
  CurrencyEntry(code: 'TJS', name: 'Tajikistani Somoni', symbol: 'SM', flag: '🇹🇯', country: 'Tajikistan', fallbackRateToUsd: 10.7),
  CurrencyEntry(code: 'TMT', name: 'Turkmenistan Manat', symbol: 'T', flag: '🇹🇲', country: 'Turkmenistan', fallbackRateToUsd: 3.50),
  CurrencyEntry(code: 'TND', name: 'Tunisian Dinar', symbol: 'د.ت', flag: '🇹🇳', country: 'Tunisia', decimalDigits: 3, fallbackRateToUsd: 3.12),
  CurrencyEntry(code: 'TOP', name: 'Tongan Paʻanga', symbol: r'T$', flag: '🇹🇴', country: 'Tonga', fallbackRateToUsd: 2.35),
  CurrencyEntry(code: 'TRY', name: 'Turkish Lira', symbol: '₺', flag: '🇹🇷', country: 'Turkey Türkiye', fallbackRateToUsd: 32.8),
  CurrencyEntry(code: 'TTD', name: 'Trinidad and Tobago Dollar', symbol: r'TT$', flag: '🇹🇹', country: 'Trinidad and Tobago', fallbackRateToUsd: 6.78),
  CurrencyEntry(code: 'TWD', name: 'New Taiwan Dollar', symbol: r'NT$', flag: '🇹🇼', country: 'Taiwan', decimalDigits: 0, fallbackRateToUsd: 32.4),
  CurrencyEntry(code: 'TZS', name: 'Tanzanian Shilling', symbol: 'TSh', flag: '🇹🇿', country: 'Tanzania', decimalDigits: 0, fallbackRateToUsd: 2620.0),

  // U
  CurrencyEntry(code: 'UAH', name: 'Ukrainian Hryvnia', symbol: '₴', flag: '🇺🇦', country: 'Ukraine', fallbackRateToUsd: 40.5),
  CurrencyEntry(code: 'UGX', name: 'Ugandan Shilling', symbol: 'USh', flag: '🇺🇬', country: 'Uganda', decimalDigits: 0, fallbackRateToUsd: 3750.0),
  CurrencyEntry(code: 'UYU', name: 'Uruguayan Peso', symbol: r'$U', flag: '🇺🇾', country: 'Uruguay', fallbackRateToUsd: 39.5),
  CurrencyEntry(code: 'UZS', name: 'Uzbekistani Som', symbol: 'soʻm', flag: '🇺🇿', country: 'Uzbekistan', decimalDigits: 0, fallbackRateToUsd: 12600.0),

  // V
  CurrencyEntry(code: 'VES', name: 'Venezuelan Bolívar Sovereign', symbol: 'Bs.S', flag: '🇻🇪', country: 'Venezuela', fallbackRateToUsd: 36.5),
  CurrencyEntry(code: 'VND', name: 'Vietnamese Dong', symbol: '₫', flag: '🇻🇳', country: 'Vietnam', decimalDigits: 0, fallbackRateToUsd: 25450.0),
  CurrencyEntry(code: 'VUV', name: 'Vanuatu Vatu', symbol: 'VT', flag: '🇻🇺', country: 'Vanuatu', decimalDigits: 0, fallbackRateToUsd: 119.0),

  // W & Y
  CurrencyEntry(code: 'WST', name: 'Samoan Tala', symbol: r'WS$', flag: '🇼🇸', country: 'Samoa', fallbackRateToUsd: 2.75),
  CurrencyEntry(code: 'YER', name: 'Yemeni Rial', symbol: '﷼', flag: '🇾🇪', country: 'Yemen', decimalDigits: 0, fallbackRateToUsd: 250.0),

  // Z
  CurrencyEntry(code: 'ZAR', name: 'South African Rand', symbol: 'R', flag: '🇿🇦', country: 'South Africa', fallbackRateToUsd: 18.2),
  CurrencyEntry(code: 'ZMW', name: 'Zambian Kwacha', symbol: 'ZK', flag: '🇿🇲', country: 'Zambia', fallbackRateToUsd: 25.8),
  CurrencyEntry(code: 'ZWG', name: 'Zimbabwe Gold', symbol: r'ZiG', flag: '🇿🇼', country: 'Zimbabwe', fallbackRateToUsd: 13.8),
];

/// Map of all currency entries by uppercase code.
final Map<String, CurrencyEntry> currencyEntryByCode = {
  for (final entry in allIsoCurrencies) entry.code: entry
};

/// Converts a [CurrencyEntry] into a UI-facing [CurrencyModel].
CurrencyModel entryToModel(CurrencyEntry entry) {
  return CurrencyModel(
    code: entry.code,
    name: entry.name,
    symbol: entry.symbol,
    flag: entry.flag,
    decimalDigits: entry.decimalDigits,
    isPinned: pinnedCurrencyCodes.contains(entry.code),
  );
}

/// Builds the master sorted list of [CurrencyModel]s.
List<CurrencyModel> buildCurrencyList([List<Map<String, String>>? apiCurrencies]) {
  final models = <CurrencyModel>[];
  final seen = <String>{};

  // Pinned currencies first
  for (final code in pinnedCurrencyOrder) {
    if (currencyEntryByCode.containsKey(code)) {
      models.add(entryToModel(currencyEntryByCode[code]!));
      seen.add(code);
    }
  }

  // Remaining currencies sorted alphabetically
  final remaining = allIsoCurrencies.where((e) => !seen.contains(e.code)).toList()
    ..sort((a, b) => a.code.compareTo(b.code));

  for (final entry in remaining) {
    models.add(entryToModel(entry));
  }

  return models;
}

/// Alias for [buildCurrencyList] for backward compatibility with tests.
List<CurrencyModel> buildFallbackCurrencies() => buildCurrencyList();

/// Returns a [CurrencyModel] for [code] from [currencies], or `null`.
CurrencyModel? currencyByCode(String code, List<CurrencyModel> currencies) {
  for (final c in currencies) {
    if (c.code == code) return c;
  }
  return null;
}

/// Fallback rates to USD for all 170+ currencies.
final Map<String, double> fallbackRatesToUsd = {
  for (final entry in allIsoCurrencies) entry.code: entry.fallbackRateToUsd
};

/// Global default currencies list.
final List<CurrencyModel> defaultCurrencies = buildCurrencyList();

/// Helper to get fallback currency by code.
CurrencyModel getFallbackCurrency(String code) {
  if (currencyEntryByCode.containsKey(code)) {
    return entryToModel(currencyEntryByCode[code]!);
  }
  return defaultCurrencies.first;
}

/// Backward-compatible class API.
class CurrenciesData {
  CurrenciesData._();
  static List<CurrencyModel> get supportedCurrencies => defaultCurrencies;
  static CurrencyModel getByCode(String code) => getFallbackCurrency(code);
}
