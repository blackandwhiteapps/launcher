class WeatherIconHelper {
  static String getIconPath(String? condition) {
    if (condition == null) return 'assets/weather_icons/cloudy.svg';
    
    final lowerCondition = condition.toLowerCase();
    
    if (lowerCondition.contains('sunny') || lowerCondition.contains('clear')) {
      return 'assets/weather_icons/sunny.svg';
    } else if (lowerCondition.contains('partly') || lowerCondition.contains('mostly sunny')) {
      return 'assets/weather_icons/partly_cloudy.svg';
    } else if (lowerCondition.contains('rain') || lowerCondition.contains('shower')) {
      return 'assets/weather_icons/rainy.svg';
    } else if (lowerCondition.contains('snow')) {
      return 'assets/weather_icons/snowy.svg';
    } else if (lowerCondition.contains('wind')) {
      return 'assets/weather_icons/windy.svg';
    } else {
      return 'assets/weather_icons/cloudy.svg';
    }
  }
}

