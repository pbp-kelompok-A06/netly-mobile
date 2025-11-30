import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/booking/screen/booking_detail_screen.dart';
import 'package:netly_mobile/modules/booking/screen/create_booking_screen.dart';  
import 'package:netly_mobile/modules/booking/model/dummy_lapangan_model.dart';
import 'package:netly_mobile/modules/booking/screen/booking_list_screen.dart';
import 'package:netly_mobile/utils/path_web.dart';

class BookingRoutes {
  static const tes = '/tes';
  static const tes2 = '/tes2';
  static const tes3 = '/tes3';
  static final Lapangan dummyLapangan = Lapangan(
  id: "abc1",
  
  name: "Lapangan Futsal A",

  price: 100000.0,

);

  static final Map<String, WidgetBuilder> routes = {
    
    tes: (context) => CreateBookingScreen(lapanganId: dummyLapangan.id),
    tes2: (context) => BookingDetailScreen(bookingId: "19c233c2-83c2-4138-b24e-89090d2440a3"),
    tes3: (context) => BookingListPage(),
  };
  // static WidgetBuilder getDetailPageBuilder(Uuid id) {
  //   // Mengarahkan ke halaman detail dengan ID yang diterima
  //   return (context) => BookingDetailScreen(bookingId: id);
  // }
}
