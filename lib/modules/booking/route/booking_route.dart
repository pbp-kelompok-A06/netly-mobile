import 'package:flutter/material.dart';
import 'package:netly_mobile/modules/booking/screen/create_booking_screen.dart';  
import 'package:netly_mobile/modules/booking/model/dummy_lapangan_model.dart';

class BookingRoutes {
  static const tes = '/tes';
  static final Lapangan dummyLapangan = Lapangan(
  id: "abc1",
  adminLapaganId: 1, // atau string → tergantung kebutuhan kamu
  name: "Lapangan Futsal A",
  location: "Jakarta",
  description: "Lapangan futsal testing",
  price: 100000.0,
  image: null,
  createdAt: DateTime.now(),
  updatedAt: DateTime.now(),
);

  static final Map<String, WidgetBuilder> routes = {
    
    tes: (context) => CreateBookingScreen(lapanganId: dummyLapangan.id),
  };
}
