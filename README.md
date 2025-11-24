# Kelompok A06
- Cathlin Abigail Elfably (2406418774)
- Edlyn Marva (2406410494)
- Evan Haryo Widodo (2406435824)
- Khalisa Adzkiyah (2406418995)
- Nisyyah Azzahra (2406495823)



# Latar Belakang Aplikasi
**Netly** adalah aplikasi yang dibuat untuk mempermudah pencarian dan pemesanan lapangan badminton yang semakin banyak diminati masyarakat luas. Melalui netly, pengguna dapat:
- Mencari lapangan badminton berdasarkan lokasi, harga, dan ketersediaan.
- Melakukan booking dengan jadwal terintegrasi.
- Memberikan review/rating pada lapangan badminton.
- Membuat komunitas dan berinteraksi langsung dengan fitur forum diskusi
- Melihat daftar event atau turnamen badminton
- Mengikuti event atau turnamen badminton yang terdaftar pada aplikasi


# Sumber Initial Dataset
Aplikasi ini menggunakan dataset dari https://ayo.co.id/venues. Pengambilan data diambil dengan teknik web scraping atau ekstraksi data dari suatu halaman web dan disimpan di dalam file .csv dan .json. Hal ini, kami lakukan karena kami tidak menemukan dataset yang memiliki lokasi di Indonesia beserta dengan biaya sewanya. Maka dari itu, data-data yang diekstrak, antara lain:
- Nama tempat
- Lokasi tempat ,
- Kota
- Jenis olahraga
- Link lapangan
- Harga tempat
- Link gambar
## Tautan dataset
https://drive.google.com/drive/folders/1ZavKO5MArsdd4mvhmcku6fB9GIWp51Ro?usp=sharing

# Tautan Web Aplikasi
[https://evan-haryo-netly.pbp.cs.ui.ac.id/](url)

# Timeline Pekerjaan
https://docs.google.com/spreadsheets/d/1vjy8Oa-lG54ZwlMTUrBfx4CQ659ORvYdx8pJW2HG2e0/edit?usp=sharing](url)

# Tautan Figma
https://www.figma.com/design/NKrUTgJaI3YfUvom0AVwPK/Untitled?node-id=0-1&t=zV5wKtPf4rfcJr77-1a.com/design/NKrUTgJaI3YfUvom0AVwPK/Untitled?node-id=0-1&t=zV5wKtPf4rfcJr77-1

# Daftar Modul
## Autentikasi dan Profil Pengguna
Modul ini berperan dalam autentikasi pengguna dalam sign up maupun sign in. Saat pertama kali registrasi, pengguna akan diminta untuk membuat username dan password, setelah itu user diminta untuk memasukan beberapa data diri opsional, seperti lokasi dan foto. Setelah berhasil sign up atau sign in, user akan diarahkan ke halaman utama. Modul ini juga akan handle pengaturan profile pengguna untuk mengubah data diri yang dimasukan di awal.


## Home Page (Khalisa)
Modul ini berisi halaman utama ketika user telah berhasil sign up/sign in. Halaman ini akan berisi carousel event,  card pilihan lapangan yang ketika diklik akan menampilkan pop-up (modal) lapangan yang berisi deskripsi dan button untuk book lapangan. Selain itu, di halaman utama juga terdapat search bar dengan filter untuk mencari lapangan yang sesuai.


## Community (Evan)
Modul ini berisi kumpulan forum komunitas unik yang dibuat oleh pengguna / user untuk saling berinteraksi satu sama lain secara daring. Di dalamnya, setiap user dapat menginisiasi suatu forum atau bergabung ke dalamnya dengan maksud untuk bertukar cerita atau wawasan tentang hal yang menjadi topik utama pembahasan. Konten modul ini secara garis besar akan dipenuhi dengan teks yang dikirimkan pengguna.


## Lapangan (Nisyyah)
Modul lapangan bertanggung jawab dalam menambahkan, edit, dan hapus (CRUD) data lapangan baru secara detail (nama, lokasi, jadwal, dll). Di modul ini juga dilakukan manajemen ketersediaan lapangan untuk mengatur slot ketersediaan booking jadwal lapangan.
## Booking (Edlyn)
Modul Booking berisi fungsi dan keperluan untuk booking, seperti booking form, add booking berhasil ke riwayat (daftar booking yang aktif dan sudah selesai), serta pembatalan booking.
## Event and Tournament (Cathlin)
Modul ini berfungsi untuk menambah, edit, hapus, dan detail terkait event dan tournament, serta pendaftaran event (untuk user yang ingin join event tertentu).


# Jenis user / Peran Role
## Admin
Admin platform yang mengatur dan memantau seluruh aktivitas di sistem. Pemilik atau pengelola lapangan yang ingin mendaftarkan dan mengelola lapangannya di platform.
Hak akses & fitur:
- Mengelola  data lapangan.
- Pendaftaran lapangan baru.
- Menambahkan profil lapangan (nama, alamat, foto, harga).
- Menambahkan jadwal ketersediaan lapangan.
- Menambahkan daftar event.


## User player
Ini peran utama (end-user) yang menggunakan aplikasi untuk mencari dan memesan lapangan.
Hak akses & fitur:
- Registrasi/login.
- Mencari lapangan berdasarkan lokasi, harga, atau waktu.
- Melakukan booking dan pembayaran.
- Melihat riwayat booking.
- Mengikuti event/turnamen komunitas.
- Berinteraksi / membuat forum di modul komunitas.

# Alur Pengintegrasian Aplikasi Mobile dengan Sistem Web Sebelumnya
1. Sistem web menyediakan endpoint yang dapat menerima request body dan mengembalikan response dalam bentuk JSON (JavaScript Object Notation)
2. Sistem web menerapkan mekanisme CORS dan juga penyimpanan session serta cookies sehingga aplikasi eksternal (dalam hal ini adalah aplikasi mobile) dapat melakukan komunikasi dan proses autentikasi dapat berjalan di aplikasi eksternal
4. Aplikasi mobile juga akan melakukan asynchronous request terhadap sistem web sebelumnya dan menampilkan hasilnya menggunakan FutureBuilder. Hal tersebut juga diikuti dengan penyimpanan autentikasi dengan CookieRequest sehingga user dapat tetap terautentikasi pada halaman yang membutuhkan proses autentikasi tersebut
5. Aplikasi mobile pun, dalam hal ini flutter, menerapkan modelling terhadap request dan response JSON yang dilakukan secara berkala sehingga integritas dan konsistensi data tetap terjaga.

