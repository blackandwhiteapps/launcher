import 'package:flutter/material.dart';
import 'package:flutter_svg/flutter_svg.dart';
import '../services/word_of_day_service.dart';
import '../services/weather_service.dart';
import '../services/random_fact_service.dart';
import '../theme/app_theme.dart';
import '../utils/weather_icon_helper.dart';

class InfoScreen extends StatefulWidget {
  const InfoScreen({super.key});

  @override
  State<InfoScreen> createState() => _InfoScreenState();
}

class _InfoScreenState extends State<InfoScreen> {
  WordOfDay? _wordOfDay;
  WeatherData? _weather;
  RandomFact? _randomFact;
  bool _isLoadingWord = true;
  bool _isLoadingWeather = true;
  bool _isLoadingFact = true;
  String? _wordError;
  String? _weatherError;
  String? _factError;

  @override
  void initState() {
    super.initState();
    _loadAllData();
  }

  void _loadAllData() {
    _loadWordOfDay();
    _loadWeather();
    _loadRandomFact();
  }

  Future<void> _loadWordOfDay() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingWord = true;
      _wordError = null;
    });

    try {
      final word = await WordOfDayService.getWordOfDay();
      if (mounted) {
        setState(() {
          _wordOfDay = word;
          _isLoadingWord = false;
          if (word == null) {
            _wordError = 'Unable to load word of the day';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWord = false;
          _wordError = 'Failed to load word of the day';
        });
      }
    }
  }

  Future<void> _loadWeather() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingWeather = true;
      _weatherError = null;
    });

    try {
      final weather = await WeatherService.getWeather();
      if (mounted) {
        setState(() {
          _weather = weather;
          _isLoadingWeather = false;
          if (weather.currentCondition == null && weather.currentTemp == null) {
            _weatherError = 'Unable to load weather data';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingWeather = false;
          _weatherError = 'Failed to load weather';
        });
      }
    }
  }

  Future<void> _loadRandomFact() async {
    if (!mounted) return;
    
    setState(() {
      _isLoadingFact = true;
      _factError = null;
    });

    try {
      final fact = await RandomFactService.getRandomFact();
      if (mounted) {
        setState(() {
          _randomFact = fact;
          _isLoadingFact = false;
          if (fact == null) {
            _factError = 'Unable to load random fact';
          }
        });
      }
    } catch (e) {
      if (mounted) {
        setState(() {
          _isLoadingFact = false;
          _factError = 'Failed to load random fact';
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Container(
      color: AppTheme.background,
      child: SafeArea(
        child: SingleChildScrollView(
                padding: const EdgeInsets.all(24.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    // Header
                    Row(
                      mainAxisAlignment: MainAxisAlignment.spaceBetween,
                      children: [
                        Text(
                          'Information',
                          style: Theme.of(context).textTheme.headlineLarge,
                        ),
                        IconButton(
                          icon: const Icon(Icons.refresh, color: AppTheme.foreground),
                          onPressed: _loadAllData,
                        ),
                      ],
                    ),
                    const SizedBox(height: 32),

                    // Word of the Day
                    Text(
                      'Word of the Day',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.foreground, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingWord
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.foreground,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _wordError != null
                              ? Column(
                                  children: [
                                    Text(
                                      _wordError!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.foregroundMuted,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: _loadWordOfDay,
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(color: AppTheme.foreground),
                                      ),
                                    ),
                                  ],
                                )
                              : _wordOfDay != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _wordOfDay!.word,
                                          style: Theme.of(context).textTheme.headlineLarge?.copyWith(
                                                fontWeight: FontWeight.bold,
                                              ),
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          _wordOfDay!.definition,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        const SizedBox(height: 12),
                                        Text(
                                          'via Wordsmith.org',
                                          style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                fontSize: 12,
                                                color: AppTheme.foregroundMuted,
                                              ),
                                        ),
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),

                    // Weather
                    Text(
                      'Weather',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.foreground, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingWeather
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.foreground,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _weatherError != null
                              ? Column(
                                  children: [
                                    Text(
                                      _weatherError!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.foregroundMuted,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: _loadWeather,
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(color: AppTheme.foreground),
                                      ),
                                    ),
                                  ],
                                )
                              : _weather != null &&
                                      (_weather!.currentCondition != null ||
                                          _weather!.currentTemp != null)
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        if (_weather!.locationName != null) ...[
                                          Text(
                                            _weather!.locationName!,
                                            style: Theme.of(context).textTheme.headlineMedium,
                                          ),
                                          const SizedBox(height: 16),
                                        ],
                                        Row(
                                          children: [
                                            if (_weather!.currentCondition != null)
                                              SvgPicture.asset(
                                                WeatherIconHelper.getIconPath(
                                                    _weather!.currentCondition),
                                                width: 48,
                                                height: 48,
                                                colorFilter: const ColorFilter.mode(
                                                  AppTheme.foreground,
                                                  BlendMode.srcIn,
                                                ),
                                              ),
                                            const SizedBox(width: 16),
                                            Expanded(
                                              child: Column(
                                                crossAxisAlignment: CrossAxisAlignment.start,
                                                children: [
                                                  if (_weather!.currentTemp != null)
                                                    Text(
                                                      '${_weather!.currentTemp!.round()}°F',
                                                      style: Theme.of(context)
                                                          .textTheme
                                                          .headlineLarge
                                                          ?.copyWith(
                                                            fontWeight: FontWeight.bold,
                                                          ),
                                                    ),
                                                  if (_weather!.highTemp != null ||
                                                      _weather!.lowTemp != null)
                                                    Text(
                                                      [
                                                        if (_weather!.highTemp != null)
                                                          'H: ${_weather!.highTemp!.round()}°',
                                                        if (_weather!.lowTemp != null)
                                                          'L: ${_weather!.lowTemp!.round()}°',
                                                      ].join(' • '),
                                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                                            color: AppTheme.foregroundMuted,
                                                          ),
                                                    ),
                                                  if (_weather!.currentCondition != null)
                                                    Text(
                                                      _weather!.currentCondition!,
                                                      style: Theme.of(context).textTheme.bodyMedium,
                                                    ),
                                                ],
                                              ),
                                            ),
                                          ],
                                        ),
                                        if (_weather!.hourlyForecast.isNotEmpty) ...[
                                          const SizedBox(height: 24),
                                          Text(
                                            'Hourly Forecast',
                                            style: Theme.of(context).textTheme.bodyLarge?.copyWith(
                                                  fontWeight: FontWeight.bold,
                                                ),
                                          ),
                                          const SizedBox(height: 12),
                                          SizedBox(
                                            height: 100,
                                            child: ListView.builder(
                                              scrollDirection: Axis.horizontal,
                                              itemCount: _weather!.hourlyForecast.length,
                                              itemBuilder: (context, index) {
                                                final forecast = _weather!.hourlyForecast[index];
                                                return Container(
                                                  width: 80,
                                                  margin: const EdgeInsets.only(right: 12),
                                                  padding: const EdgeInsets.all(8),
                                                  decoration: BoxDecoration(
                                                    border: Border.all(
                                                      color: AppTheme.foregroundMuted
                                                          .withValues(alpha: 0.3),
                                                      width: 1,
                                                    ),
                                                    borderRadius: BorderRadius.circular(8),
                                                  ),
                                                  child: Column(
                                                    mainAxisAlignment: MainAxisAlignment.center,
                                                    children: [
                                                      Text(
                                                        '${forecast.time.hour % 12 == 0 ? 12 : forecast.time.hour % 12}${forecast.time.hour >= 12 ? 'pm' : 'am'}',
                                                        style: Theme.of(context)
                                                            .textTheme
                                                            .labelMedium,
                                                      ),
                                                      const SizedBox(height: 4),
                                                      if (forecast.temperature != null)
                                                        Text(
                                                          '${forecast.temperature!.round()}°',
                                                          style: Theme.of(context)
                                                              .textTheme
                                                              .bodyMedium
                                                              ?.copyWith(
                                                                fontWeight: FontWeight.bold,
                                                              ),
                                                        ),
                                                    ],
                                                  ),
                                                );
                                              },
                                            ),
                                          ),
                                        ],
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                    ),
                    const SizedBox(height: 32),

                    // Random Fact
                    Text(
                      'Random Fact',
                      style: Theme.of(context).textTheme.headlineMedium,
                    ),
                    const SizedBox(height: 16),
                    Container(
                      width: double.infinity,
                      padding: const EdgeInsets.all(20),
                      decoration: BoxDecoration(
                        border: Border.all(color: AppTheme.foreground, width: 1),
                        borderRadius: BorderRadius.circular(12),
                      ),
                      child: _isLoadingFact
                          ? const Center(
                              child: Padding(
                                padding: EdgeInsets.all(16.0),
                                child: CircularProgressIndicator(
                                  color: AppTheme.foreground,
                                  strokeWidth: 2,
                                ),
                              ),
                            )
                          : _factError != null
                              ? Column(
                                  children: [
                                    Text(
                                      _factError!,
                                      style: Theme.of(context).textTheme.bodyMedium?.copyWith(
                                            color: AppTheme.foregroundMuted,
                                          ),
                                    ),
                                    const SizedBox(height: 12),
                                    TextButton(
                                      onPressed: _loadRandomFact,
                                      child: const Text(
                                        'Retry',
                                        style: TextStyle(color: AppTheme.foreground),
                                      ),
                                    ),
                                  ],
                                )
                              : _randomFact != null
                                  ? Column(
                                      crossAxisAlignment: CrossAxisAlignment.start,
                                      children: [
                                        Text(
                                          _randomFact!.text,
                                          style: Theme.of(context).textTheme.bodyLarge,
                                        ),
                                        if (_randomFact!.source.isNotEmpty) ...[
                                          const SizedBox(height: 12),
                                          Text(
                                            'Source: ${_randomFact!.source}',
                                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                                  fontSize: 12,
                                                  color: AppTheme.foregroundMuted,
                                                ),
                                          ),
                                        ],
                                      ],
                                    )
                                  : const SizedBox.shrink(),
                    ),

                        const SizedBox(height: 24),
                        // Swipe hint
                        Center(
                          child: Text(
                            'Swipe left for home',
                            style: Theme.of(context).textTheme.labelMedium?.copyWith(
                                  color: AppTheme.foregroundMuted.withValues(alpha: 0.5),
                                ),
                          ),
                        ),
                      ],
                    ),
                  ),
      ),
    );
  }
}

