import 'country_helper.dart';
import 'http_helper.dart';
import 'language_helper.dart';
import 'open_food_api_configuration.dart';

///Helper class for constructing urls with the in the [OpenFoodAPIConfiguration] specified settings
class UriHelper {
  const UriHelper({
    required this.host,
    this.scheme = 'https',
    this.isTestMode = false,
    this.defaultAddUserAgentParameters = false,
  });

  final String host;
  final String scheme;
  final bool isTestMode;
  final bool defaultAddUserAgentParameters;

  /// Returns a OFF uri with the [OpenFoodAPIConfiguration] specified settings
  ///
  /// Typical use-case of "[addUserAgentParameters] = false" is for other
  /// request than GET, e.g. POST or MULTIPART, where we add the user agent
  /// parameters in another part of the code.
  Uri getUri({
    required final String path,
    final Map<String, dynamic>? queryParameters,
    final bool? addUserAgentParameters,
    final String? userInfo,
  }) =>
      Uri(
        scheme: scheme,
        host: host,
        path: path,
        queryParameters: addUserAgentParameters ?? defaultAddUserAgentParameters
            ? HttpHelper.addUserAgentParameters(queryParameters)
            : queryParameters,
        userInfo: userInfo,
      );

  Uri getPostUri({
    required final String path,
  }) =>
      getUri(
        path: path,
        addUserAgentParameters: false,
      );

  /// Replaces the subdomain of an URI with specific country and language.
  ///
  /// Default language and country will be used as fallback, if available.
  /// For instance
  /// * https://world.xxx... would be standard
  /// * https://world-fr.xxx... would be "standard country" in French
  /// * https://fr.xxx... would be France
  /// * https://fr-es.xxx... would be France in Spanish
  static Uri replaceSubdomain(
    final Uri uri, {
    OpenFoodFactsLanguage? language,
    OpenFoodFactsCountry? country,
  }) =>
      replaceSubdomainWithCodes(
        uri,
        languageCode: language?.code ??
            (OpenFoodAPIConfiguration.globalLanguages != null &&
                    OpenFoodAPIConfiguration.globalLanguages!.isNotEmpty
                ? OpenFoodAPIConfiguration.globalLanguages![0].code
                : null),
        countryCode:
            country?.offTag ?? OpenFoodAPIConfiguration.globalCountry?.offTag,
      );

  /// Replaces the subdomain of an URI with specific country and language.
  ///
  /// No default language nor country: null means no parameter.
  /// For instance
  /// * https://world.xxx... would be standard
  /// * https://world-fr.xxx... would be "no country" in French
  /// * https://fr.xxx... would be France
  /// * https://fr-es.xxx... would be France in Spanish
  static Uri replaceSubdomainWithCodes(
    final Uri uri, {
    final String? languageCode,
    String? countryCode,
  }) {
    final String initialSubdomain = uri.host.split('.')[0];
    countryCode = countryCode ?? initialSubdomain;
    final String subdomain;
    if (languageCode != null) {
      subdomain = '$countryCode-$languageCode';
    } else {
      subdomain = countryCode;
    }
    return uri.replace(
      host: uri.host.replaceFirst('$initialSubdomain.', '$subdomain.'),
    );
  }
}

/// [UriHelper] specific for products (e.g. off, obf, opf, opff).
class UriProductHelper extends UriHelper {
  const UriProductHelper({
    required super.host,
    super.scheme = 'https',
    super.isTestMode = false,
    this.userInfoForPatch,
    required this.imageUrlBase,
    super.defaultAddUserAgentParameters = true,
  });

  final String? userInfoForPatch;

  /// Url base for images: needs to match more or less scheme and host.
  final String imageUrlBase;

  Uri getPatchUri({
    required final String path,
  }) =>
      getUri(
        path: path,
        addUserAgentParameters: false,
        userInfo: userInfoForPatch,
      );
}
