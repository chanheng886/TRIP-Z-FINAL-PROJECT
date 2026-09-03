import 'package:frontend/shared/model/bus_station.dart';

class BusStationRepository {
  static final List<BusStation> sampleStations = [
    // Phnom Penh
    const BusStation(
      id: 1,
      name: 'Phnom Penh Central Bus Terminal',
      nameKh: 'ស្ថានីយ៍រថយន្តក្រុងកណ្តាលភ្នំពេញ',
      city: 'Phnom Penh',
      address: 'St. 106, Near Wat Phnom, Daun Penh, Phnom Penh',
      addressKh: 'ផ្លូវ ១០៦ ក្បែរវត្តភ្នំ ដូនពេញ ភ្នំពេញ',
      latitude: 11.5762,
      longitude: 104.9231,
      operators: ['Sorya Bus', 'Capitol Tours', 'Phnom Penh Sorya'],
      openingHours: '05:00 AM - 10:30 PM',
      phone: '+855 23 210 359',
      imageUrl:
          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80',
      facilities: ['Air Conditioned Lounge', 'Ticketing Counter', 'Restrooms', 'Luggage Storage', 'Free WiFi', 'Mini Mart'],
      rating: 4.8,
    ),
    const BusStation(
      id: 2,
      name: 'Virak Buntham Olympic Terminal',
      nameKh: 'ស្ថានីយ៍ វីរៈ ប៊ុនថាំង អូឡាំពិក',
      city: 'Phnom Penh',
      address: 'St. 199, Near Olympic Market, Chamkarmon, Phnom Penh',
      addressKh: 'ផ្លូវ ១៩៩ ក្បែរផ្សារអូឡាំពិក ចំការមន ភ្នំពេញ',
      latitude: 11.5563,
      longitude: 104.9125,
      operators: ['Virak Buntham Express', 'VET Air Bus VIP'],
      openingHours: '24 Hours / 7 Days',
      phone: '+855 12 522 777',
      imageUrl:
          'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=600&q=80',
      facilities: ['24/7 Service', 'Coffee Shop', 'VIP Waiting Lounge', 'Luggage Drop', 'Charging Stations'],
      rating: 4.9,
    ),
    const BusStation(
      id: 3,
      name: 'Giant Ibis Riverside Terminal',
      nameKh: 'ស្ថានីយ៍ ហ្សាយអិន អាយប៊ីស មាត់ទន្លេ',
      city: 'Phnom Penh',
      address: 'St. 106, Night Market Area, Riverside, Phnom Penh',
      addressKh: 'ផ្លូវ ១០៦ ក្បែរផ្សាររាត្រី មាត់ទន្លេ ភ្នំពេញ',
      latitude: 11.5714,
      longitude: 104.9315,
      operators: ['Giant Ibis Transport'],
      openingHours: '06:00 AM - 11:30 PM',
      phone: '+855 23 999 333',
      imageUrl:
          'https://images.unsplash.com/photo-1494515843206-f3117d3f51b7?auto=format&fit=crop&w=600&q=80',
      facilities: ['Premium Lounge', 'Free Water & Snack', 'AC Waiting Area', 'WiFi'],
      rating: 4.9,
    ),
    const BusStation(
      id: 4,
      name: 'Larryta Express BKK1 Hub',
      nameKh: 'ស្ថានីយ៍ ឡារីតា អិចប្រេស បឹងកេងកង១',
      city: 'Phnom Penh',
      address: 'Pasteur St. 51, BKK1, Boeung Keng Kang, Phnom Penh',
      addressKh: 'ផ្លូវ ប៉ាស្ទ័រ ៥១ បឹងកេងកង១ ភ្នំពេញ',
      latitude: 11.5642,
      longitude: 104.9201,
      operators: ['Larryta Express'],
      openingHours: '06:00 AM - 09:30 PM',
      phone: '+855 11 811 118',
      imageUrl:
          'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=600&q=80',
      facilities: ['VIP Vans', 'Clean Restrooms', 'Air-Conditioned Waiting', 'Beverages'],
      rating: 4.7,
    ),

    // Siem Reap
    const BusStation(
      id: 5,
      name: 'Siem Reap Central Bus Terminal',
      nameKh: 'ស្ថានីយ៍រថយន្តក្រុងកណ្តាលសៀមរាប',
      city: 'Siem Reap',
      address: 'Chong Kov Sou Terminal, National Road 6, Siem Reap',
      addressKh: 'ស្ថានីយ៍ ចុងកៅស៊ូ ផ្លូវជាតិលេខ ៦ សៀមរាប',
      latitude: 13.3640,
      longitude: 103.8601,
      operators: ['Sorya Bus', 'Capitol Tours', 'Seila Angkor'],
      openingHours: '05:30 AM - 11:00 PM',
      phone: '+855 63 963 888',
      imageUrl:
          'https://images.unsplash.com/photo-1569154941061-e231b4725ef1?auto=format&fit=crop&w=600&q=80',
      facilities: ['Tuk-Tuk Stand', 'Luggage Check', 'Restrooms', 'Food Stalls', 'WiFi'],
      rating: 4.6,
    ),
    const BusStation(
      id: 6,
      name: 'Virak Buntham Sivutha Terminal',
      nameKh: 'ស្ថានីយ៍ វីរៈ ប៊ុនថាំង វិថីស៊ីវត្ថា សៀមរាប',
      city: 'Siem Reap',
      address: 'Sivutha Blvd, Old Market Area, Siem Reap',
      addressKh: 'វិថីស៊ីវត្ថា តំបន់ផ្សារចាស់ សៀមរាប',
      latitude: 13.3571,
      longitude: 103.8550,
      operators: ['Virak Buntham Express', 'VET Air Bus VIP'],
      openingHours: '24 Hours / 7 Days',
      phone: '+855 12 522 777',
      imageUrl:
          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80',
      facilities: ['24/7 Waiting Area', 'Night Bus Check-in', 'Luggage Storage', 'Free WiFi'],
      rating: 4.8,
    ),
    const BusStation(
      id: 7,
      name: 'Giant Ibis Wat Bo Station',
      nameKh: 'ស្ថានីយ៍ ហ្សាយអិន អាយប៊ីស វត្តបូព៌ សៀមរាប',
      city: 'Siem Reap',
      address: 'Wat Bo Road, Near Old Stone Bridge, Siem Reap',
      addressKh: 'ផ្លូវវត្តបូព៌ ក្បែរស្ពានថ្មចាស់ សៀមរាប',
      latitude: 13.3605,
      longitude: 103.8588,
      operators: ['Giant Ibis Transport'],
      openingHours: '06:30 AM - 11:30 PM',
      phone: '+855 63 966 669',
      imageUrl:
          'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=600&q=80',
      facilities: ['Air-Con Lounge', 'Welcome Drinks', 'Clean Restrooms', 'Luggage Tagging'],
      rating: 4.9,
    ),

    // Sihanoukville
    const BusStation(
      id: 8,
      name: 'Sihanoukville Downtown Bus Terminal',
      nameKh: 'ស្ថានីយ៍រថយន្តក្រុងក្រុងព្រះសីហនុ',
      city: 'Sihanoukville',
      address: 'Ekareach Street, Downtown, Sihanoukville',
      addressKh: 'ផ្លូវឯករាជ្យ កណ្តាលក្រុង ក្រុងព្រះសីហនុ',
      latitude: 10.6275,
      longitude: 103.5230,
      operators: ['Virak Buntham', 'Larryta', 'Mey Hong'],
      openingHours: '06:00 AM - 10:00 PM',
      phone: '+855 34 933 888',
      imageUrl:
          'https://images.unsplash.com/photo-1507525428034-b723cf961d3e?auto=format&fit=crop&w=600&q=80',
      facilities: ['Beach Shuttle Connection', 'Ticket Booking', 'Restrooms', 'Cafe'],
      rating: 4.7,
    ),
    const BusStation(
      id: 9,
      name: 'Virak Buntham Ochheuteal Beach Hub',
      nameKh: 'ស្ថានីយ៍ វីរៈ ប៊ុនថាំង ឆ្នេរអូរឈើទាល',
      city: 'Sihanoukville',
      address: 'Near 2 Lions Roundabout, Ochheuteal Beach, Sihanoukville',
      addressKh: 'ក្បែររង្វង់មូលតោពីរ ឆ្នេរអូរឈើទាល ក្រុងព្រះសីហនុ',
      latitude: 10.6310,
      longitude: 103.5180,
      operators: ['Virak Buntham Express'],
      openingHours: '24 Hours / 7 Days',
      phone: '+855 12 522 777',
      imageUrl:
          'https://images.unsplash.com/photo-1517649763962-0c623266ddc0?auto=format&fit=crop&w=600&q=80',
      facilities: ['Ferry Transfer to Koh Rong', '24/7 Lounge', 'Luggage Check'],
      rating: 4.8,
    ),

    // Battambang
    const BusStation(
      id: 10,
      name: 'Battambang Central Bus Station',
      nameKh: 'ស្ថានីយ៍រថយន្តក្រុងកណ្តាលបាត់ដំបង',
      city: 'Battambang',
      address: 'St. 101, Near Psar Nat Market, Battambang',
      addressKh: 'ផ្លូវ ១០១ ក្បែរផ្សារណាត់ បាត់ដំបង',
      latitude: 13.0957,
      longitude: 103.2022,
      operators: ['Virak Buntham', 'Capitol Tours', 'Sorya Bus'],
      openingHours: '06:00 AM - 09:30 PM',
      phone: '+855 53 952 777',
      imageUrl:
          'https://images.unsplash.com/photo-1544620347-c4fd4a3d5957?auto=format&fit=crop&w=600&q=80',
      facilities: ['Ticketing Counters', 'Restrooms', 'Waiting Area', 'Tuk-Tuk Stand'],
      rating: 4.7,
    ),

    // Kampot
    const BusStation(
      id: 11,
      name: 'Kampot Durian Roundabout Station',
      nameKh: 'ស្ថានីយ៍រថយន្តក្រុងរង្វង់មូលធុរេន កំពត',
      city: 'Kampot',
      address: 'National Road 33, Near Durian Roundabout, Kampot',
      addressKh: 'ផ្លូវជាតិ ៣៣ ក្បែររង្វង់មូលផ្លែធុរេន កំពត',
      latitude: 10.6105,
      longitude: 104.1812,
      operators: ['Larryta', 'Virak Buntham', 'Giant Ibis', 'Champa Tourist Bus'],
      openingHours: '06:00 AM - 09:00 PM',
      phone: '+855 33 932 555',
      imageUrl:
          'https://images.unsplash.com/photo-1570125909232-eb263c188f7e?auto=format&fit=crop&w=600&q=80',
      facilities: ['Coffee & Drinks', 'AC Lounge', 'Free WiFi', 'Tour Assistance'],
      rating: 4.8,
    ),
  ];

  List<BusStation> getAllStations() => List.unmodifiable(sampleStations);

  List<BusStation> getStationsByCity(String city) {
    if (city == 'All' || city.isEmpty) return getAllStations();
    return sampleStations
        .where((s) => s.city.toLowerCase() == city.toLowerCase())
        .toList();
  }

  List<String> getAvailableCities() {
    final cities = sampleStations.map((s) => s.city).toSet().toList();
    cities.sort();
    return ['All', ...cities];
  }

  BusStation? getStationById(int id) {
    try {
      return sampleStations.firstWhere((s) => s.id == id);
    } catch (_) {
      return null;
    }
  }

  List<BusStation> searchStations(String query) {
    if (query.trim().isEmpty) return getAllStations();
    final lower = query.toLowerCase();
    return sampleStations.where((s) {
      return s.name.toLowerCase().contains(lower) ||
          s.nameKh.toLowerCase().contains(lower) ||
          s.city.toLowerCase().contains(lower) ||
          s.address.toLowerCase().contains(lower) ||
          s.operators.any((op) => op.toLowerCase().contains(lower));
    }).toList();
  }
}
