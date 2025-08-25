import 'dart:io';
import 'dart:convert';

void main() async {
  const apiKey = 'AIzaSyA-vzeBYm038AmdvgK2R8T-ycbckU8HWIA';
  
  print('🔍 Testing Google Maps API Key...');
  print('API Key: $apiKey');
  print('');
  
  // Test 1: Static Maps API
  print('📍 Test 1: Static Maps API');
  try {
    final url = 'https://maps.googleapis.com/maps/api/staticmap?center=40.7128,-74.0060&zoom=13&size=400x400&key=$apiKey';
    final response = await HttpClient().getUrl(Uri.parse(url)).then((request) => request.close());
    
    if (response.statusCode == 200) {
      print('✅ Static Maps API: SUCCESS');
    } else {
      print('❌ Static Maps API: FAILED (Status: ${response.statusCode})');
      final body = await response.transform(utf8.decoder).join();
      print('Response: $body');
    }
  } catch (e) {
    print('❌ Static Maps API: ERROR - $e');
  }
  
  print('');
  
  // Test 2: Geocoding API
  print('🌍 Test 2: Geocoding API');
  try {
    final url = 'https://maps.googleapis.com/maps/api/geocode/json?address=New+York&key=$apiKey';
    final response = await HttpClient().getUrl(Uri.parse(url)).then((request) => request.close());
    
    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body);
      
      if (data['status'] == 'OK') {
        print('✅ Geocoding API: SUCCESS');
      } else {
        print('❌ Geocoding API: FAILED - ${data['status']}');
        print('Error: ${data['error_message'] ?? 'Unknown error'}');
      }
    } else {
      print('❌ Geocoding API: FAILED (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('❌ Geocoding API: ERROR - $e');
  }
  
  print('');
  
  // Test 3: Places API
  print('🏢 Test 3: Places API');
  try {
    final url = 'https://maps.googleapis.com/maps/api/place/findplacefromtext/json?input=New+York&inputtype=textquery&key=$apiKey';
    final response = await HttpClient().getUrl(Uri.parse(url)).then((request) => request.close());
    
    if (response.statusCode == 200) {
      final body = await response.transform(utf8.decoder).join();
      final data = json.decode(body);
      
      if (data['status'] == 'OK') {
        print('✅ Places API: SUCCESS');
      } else {
        print('❌ Places API: FAILED - ${data['status']}');
        print('Error: ${data['error_message'] ?? 'Unknown error'}');
      }
    } else {
      print('❌ Places API: FAILED (Status: ${response.statusCode})');
    }
  } catch (e) {
    print('❌ Places API: ERROR - $e');
  }
  
  print('');
  print('📋 Summary:');
  print('If all tests show ❌, your API key likely needs:');
  print('1. Billing enabled in Google Cloud Console');
  print('2. Required APIs enabled (Maps SDK, Geocoding, Places)');
  print('3. Proper API key restrictions');
  print('');
  print('If some tests show ✅ but maps still don\'t work, check:');
  print('1. Network connectivity');
  print('2. App permissions');
  print('3. Platform-specific configuration');
}
