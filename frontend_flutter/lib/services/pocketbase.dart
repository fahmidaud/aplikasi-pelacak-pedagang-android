import 'dart:convert';

import 'package:flutter/services.dart';
import 'package:pocketbase/pocketbase.dart';

import '../bloc/bloc.dart';
import 'shared_preferences.dart';

// export 'package:pocketbase/pocketbase.dart';

// final pb = PocketBase('http://192.168.43.74:1001');
// final pb = PocketBase('http://192.168.43.75:1001');
final pb = PocketBase('https://yo-pb.pockethost.io');

class PocketbaseService {
  Future<bool?> cekAuth() async {
    final isValid = await pb.authStore.isValid;

    return isValid;
  }

  Future<Map<String, dynamic>> getAuthStoreData() async {
    final getTokenAuthStore = pb.authStore.token;
    final getModelAuthStore = pb.authStore.model;

    var obj = {"token": getTokenAuthStore, "model": getModelAuthStore};

    return obj;
  }

  Future<ResultList<RecordModel>?> cekPenggunaAnonim(imei) async {
    final resultList = await pb.collection('pengguna_anonim').getList(
          page: 1,
          perPage: 50,
          filter: 'imei = "$imei"',
        );

    return resultList;
  }

  Future<RecordModel?> tambahPenggunaAnonim(imei) async {
    final _cekPenggunaAnonim = await cekPenggunaAnonim(imei);
    var toString = jsonEncode(_cekPenggunaAnonim);
    var toMap = jsonDecode(toString);
    print("toMap['items'].length diPB_service = ${toMap['items'].length}");

    if (toMap['items'].length == 0) {
      print('Sedang tambahPenggunaAnonim, dengan imei $imei');
      final body = <String, dynamic>{
        "imei": imei,
        "is_online": false,
        "online_details": null
      };

      final record = await pb.collection('pengguna_anonim').create(body: body);

      return record;
    }
  }

  Future<RecordModel?> setStatusActivePenggunaAnonim(
      idPenggunaAnonim, isAuth) async {
    bool? isActive;

    if (isAuth) {
      // jika sudah login, berarti status anonimnya tidak aktif
      isActive = false;
    } else {
      isActive = true;
    }

    final body = <String, dynamic>{
      "is_active": isActive,
    };

    final record = await pb
        .collection('pengguna_anonim')
        .update(idPenggunaAnonim, body: body);

    return record;
  }

  Future<RecordModel?> setNullPenggunaAnonim(idPenggunaAnonim) async {
    print('Sedang setNullPenggunaAnonim, dengan id = $idPenggunaAnonim');

    final body = <String, dynamic>{
      "sub_locality": null,
      "is_online": false,
      "id_socket": null,
      "online_details": null,
    };

    final record = await pb
        .collection('pengguna_anonim')
        .update(idPenggunaAnonim, body: body);

    return record;
  }

  Future<Map?> getSemuaPenggunaAnonimBerdasarkanSubLocaltiy(subLocality) async {
    try {
      // sub_locality = "${subLocality}" && is_online = true
      final resultList = await pb.collection('pengguna_anonim').getList(
            page: 1,
            perPage: 1,
            filter:
                'sub_locality = "${subLocality}" && is_active = true && is_online = true',
          );

      print("resultList getSemuaPenggunaAnonim , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<RecordModel?> updateSubLocality(
      jenisPengguna, idPengguna, subLocality) async {
    final body = <String, dynamic>{
      "sub_locality": subLocality,
    };

    if (jenisPengguna == 'anonim') {
      print(
          'Sedang UPDATE subLocality pada collection pengguna_anonim dengan id = ${idPengguna} , menjadi = $subLocality');

      final record =
          await pb.collection('pengguna_anonim').update(idPengguna, body: body);

      return record;
    } else if (jenisPengguna == 'pembeli') {
      // Hanya pedangan keliling
      print(
          'Sedang UPDATE subLocality pada collection pengguna_pembeli dengan id = ${idPengguna} , menjadi = $subLocality');
      final body = <String, dynamic>{
        "sub_locality": subLocality,
      };

      final record = await pb
          .collection('pengguna_pembeli')
          .update(idPengguna, body: body);

      return record;
    } else if (jenisPengguna == 'penjual') {
      // Hanya pedangan keliling
      print(
          'Sedang UPDATE subLocality pada collection pengguna_penjual dengan id = ${idPengguna} , menjadi = $subLocality');
      final body = <String, dynamic>{
        "sub_locality": subLocality,
      };

      final record = await pb
          .collection('pengguna_penjual')
          .update(idPengguna, body: body);

      return record;
    }
  }

  Future<RecordModel?> updateAlamatKeliling(idPengguna, alamatKeliling) async {
    final body = <String, dynamic>{"alamat_keliling": alamatKeliling};

    final record =
        await pb.collection('pengguna_penjual').update(idPengguna, body: body);

    return record;
  }

  Future<ResultList<RecordModel>?> cekApakahSudahGabung(
      jenisPengguna, email) async {
    print('Sedang cekApakahSudahGabung ${jenisPengguna} dengan ${email}');

    if (jenisPengguna == 'pembeli') {
      final resultList = await pb.collection('pengguna_pembeli').getList(
            page: 1,
            perPage: 50,
            filter: 'email = "$email"',
          );

      return resultList;
    } else {
      final resultList = await pb.collection('pengguna_penjual').getList(
            page: 1,
            perPage: 50,
            filter: 'email = "$email"',
          );

      return resultList;
    }
  }

  Future<RecordModel?> tambahPenggunaPembeli(
      email, password, namaPengguna) async {
    // example create body
    final body = <String, dynamic>{
      "email": email,
      "emailVisibility": true,
      "password": password,
      "passwordConfirm": password,
      "nama": namaPengguna,
      "sub_locality": null,
      "is_online": true,
      "id_socket": null,
      "online_details": null
    };

    final record = await pb.collection('pengguna_pembeli').create(body: body);

    // (optional) send an email verification request
    await pb.collection('pengguna_pembeli').requestVerification(email);

    return record;
  }

  Future<Map?> authWithPasswordPenggunaPembeli(email, password) async {
    try {
      var result = await pb
          .collection('pengguna_pembeli')
          .authWithPassword(email, password);
      var authData = result;

      print('authData = ');
      print(result);

      var obj = {"message": "success", "data": authData};

      String convertToJSONString = jsonEncode(obj);
      var toMap = jsonDecode(convertToJSONString);

      return toMap;
    } catch (error) {
      print("onError dari authWithPasswordPenggunaPembeli");
      print(error);

      var obj = {"message": "Password anda salah.", "data": null};

      String convertToJSONString = jsonEncode(obj);
      var toMap = jsonDecode(convertToJSONString);

      return toMap;
    }
  }

  Future<RecordModel?> setLogoutPenggunaPembeli(idPembeli, isLogout) async {
    final body = <String, dynamic>{
      "is_log_out": isLogout,
    };

    final record =
        await pb.collection('pengguna_pembeli').update(idPembeli, body: body);

    return record;
  }

  Future<RecordModel?> getPenggunaPembeli(idPenggunaPembeli) async {
    final record = await pb.collection('pengguna_pembeli').getOne(
          idPenggunaPembeli,
        );
    print('getPenggunaPembeli , ');
    print(record);

    return record;
  }

  Future<Map?> getSemuaPenggunaPembeliBerdasarkanSubLocaltiy(
      subLocality) async {
    try {
      // sub_locality = "${subLocality}" && is_online = true
      final resultList = await pb.collection('pengguna_pembeli').getList(
            page: 1,
            perPage: 1,
            filter:
                'sub_locality = "${subLocality}" && is_log_out != true && is_online = true',
          );

      print("resultList getSemuaPenggunaPembeli , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<Map?>
      getSemuaPenggunaPembeliBerdasarkanSubLocaltiyUntukPromosiDagangan(
          subLocality) async {
    try {
      // sub_locality = "${subLocality}" && is_online = true
      final resultList = await pb.collection('pengguna_pembeli').getList(
            page: 1,
            perPage: 1,
            filter: 'sub_locality = "${subLocality}" && is_log_out != true',
          );

      print("resultList getSemuaPenggunaPembeli , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<RecordModel?> tambahPenggunaPenjual(email, password, namaDagang,
      namaPengguna, tipePenjual, alamatTetap, subLocality) async {
    // print("alamatTetap saat tambahPenggunaPenjual");
    // print(alamatTetap);

    String? tipePenjualVal;
    String? alamatTetapVal, alamatKelilingVal;
    String? subLocalityVal;

    //     {
    //   "latitude": 0.1,
    //   "longitude": 0.1
    // }
    var defaultAlamatKeliling = {"latitude": 0.1, "longitude": 0.1};

    //     {
    //   "latitude": 0.1,
    //   "longitude": 0.1,
    //   "alamat_lengkap": ""
    // }
    var defaultAlamatTetap = {
      "latitude": 0.1,
      "longitude": 0.1,
      "alamat_lengkap": ""
    };

    if (tipePenjual == 1) {
      tipePenjualVal = "Keliling";
      alamatTetapVal = jsonEncode(defaultAlamatTetap);
      alamatKelilingVal = jsonEncode(defaultAlamatKeliling);
    } else {
      tipePenjualVal = "Tetap";
      alamatTetapVal = jsonEncode(alamatTetap);
      alamatKelilingVal = jsonEncode(defaultAlamatKeliling);
      subLocalityVal = subLocality;
    }
    // print("alamatTetapVal saat tambahPenggunaPenjual");
    // print(alamatTetapVal);

    final body = <String, dynamic>{
      "email": email,
      "emailVisibility": true,
      "password": password,
      "passwordConfirm": password,
      "is_log_out": false,
      "nama_dagang": namaDagang,
      "nama_penjual": namaPengguna,
      "tipe_penjual": [tipePenjualVal],
      "alamat_tetap": alamatTetapVal,
      "alamat_keliling": alamatKelilingVal,
      "sub_locality": subLocalityVal,
      "is_online": true,
      "id_socket": null,
      "online_details": null
    };

    final record = await pb.collection('pengguna_penjual').create(body: body);

    return record;
  }

  Future<Map?> authWithPasswordPenggunaPenjual(email, password) async {
    try {
      var result = await pb
          .collection('pengguna_penjual')
          .authWithPassword(email, password);
      var authData = result;

      print('authData = ');
      print(result);

      var obj = {"message": "success", "data": authData};

      String convertToJSONString = jsonEncode(obj);
      var toMap = jsonDecode(convertToJSONString);

      return toMap;
    } catch (error) {
      print("onError dari authWithPasswordPenggunaPembeli");
      print(error);

      var obj = {"message": "Password anda salah.", "data": null};

      String convertToJSONString = jsonEncode(obj);
      var toMap = jsonDecode(convertToJSONString);

      return toMap;
    }
  }

  Future<RecordModel?> setLogoutPenggunaPenjual(idPenjual, isLogout) async {
    final body = <String, dynamic>{
      "is_log_out": isLogout,
    };

    final record =
        await pb.collection('pengguna_penjual').update(idPenjual, body: body);

    return record;
  }

  Future<RecordModel?> getPenggunaPenjual(idPenggunaPenjual) async {
    final record = await pb.collection('pengguna_penjual').getOne(
          idPenggunaPenjual,
        );
    // print('getPenggunaPembeli , ');
    // print(record);

    return record;
  }

  SharedPreferencesService sharedPreferencesService =
      SharedPreferencesService();
  Future<Map?> getSemuaPenggunaPenjualBerdasarkanSubLocaltiy(
      subLocality) async {
    bool isSayaAdalahPenjual = false;
    final cariLocalDataStringAuthStore =
        await sharedPreferencesService.cariLocalDataString('authStoreData');

    String? idPenjualYangTidakDipanggil;
    if (cariLocalDataStringAuthStore!) {
      final getLocalAuthStoreData =
          await sharedPreferencesService.getLocalDataString('authStoreData');

      var toString = jsonEncode(getLocalAuthStoreData);
      var toMap = jsonDecode(toString);

      var modelAuthStore = toMap['model'];
      var collectionName = modelAuthStore['collectionName'];
      if (collectionName == 'pengguna_penjual') {
        isSayaAdalahPenjual = true;
        idPenjualYangTidakDipanggil = modelAuthStore['id'];
      }
    }

    try {
      // sub_locality = "${subLocality}" && is_online = true

      String? filterKhusus;
      if (isSayaAdalahPenjual) {
        filterKhusus =
            'sub_locality = "${subLocality}" && id != "${idPenjualYangTidakDipanggil}"';
      } else {
        filterKhusus = 'sub_locality = "${subLocality}"';
      }
      print(
          'getSemuaPenggunaPenjualBerdasarkanSubLocaltiy menggunakan filter = ${filterKhusus}');

      final resultList = await pb.collection('pengguna_penjual').getList(
          page: 1,
          perPage: 449,
          // filter: 'sub_locality = "${subLocality}"',
          filter: filterKhusus);

      print("resultList getSemuaPenggunaPenjual , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
    // print('getPenggunaPembeli , ');
    // print(record);

    // return record;
  }

  void unsubscribePenggunaPenjualDanPembeli() {
    // pb.collection('pengguna_penjual').unsubscribe();
    pb.collection('pengguna_penjual').unsubscribe('*');
    pb.collection('pengguna_pembeli').unsubscribe('*');
  }

  Future<Map?> updateTokenFcmByIdPengguna(
      collectionName, idPengguna, tokenFcm) async {
    try {
      final body = <String, dynamic>{
        "token_fcm": tokenFcm,
      };

      final record =
          await pb.collection(collectionName).update(idPengguna, body: body);

      var obj = {
        "data": record,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<RecordModel?> updateProfilePengguna(
      rolePengguna, idPengguna, objProfileNew) async {
    String? collectionName;
    if (rolePengguna == 'Pembeli') {
      collectionName = "pengguna_pembeli";
    } else {
      collectionName = "pengguna_penjual";
    }

    final record = await pb
        .collection(collectionName)
        .update(idPengguna, body: objProfileNew);

    return record;
  }

  Future<Map?> cekApakahSudahPernahChat(idPenjual, idPembeli) async {
    try {
      final resultList = await pb.collection('chat_rooms').getList(
            page: 1,
            perPage: 449,
            filter:
                'id_penjual = "${idPenjual}" && id_pembeli = "${idPembeli}"',
          );

      print("resultList cekApakahSudahPernahChat , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<Map?> getChatRoomsByIdSaya(collectionName, idSaya) async {
    try {
      final resultList;
      if (collectionName == 'pengguna_pembeli') {
        resultList = await pb.collection('chat_rooms').getList(
              page: 1,
              perPage: 449,
              filter: 'id_pembeli = "${idSaya}"',
              expand: 'id_penjual,id_pembeli',
              sort: '-updated',
            );
      } else {
        resultList = await pb.collection('chat_rooms').getList(
              page: 1,
              perPage: 449,
              filter: 'id_penjual = "${idSaya}"',
              expand: 'id_penjual,id_pembeli',
              sort: '-updated',
            );
      }
      print("resultList getChatRoomsByIdSaya , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  void unsubscribeChatRooms() {
    pb.collection('chat_rooms').unsubscribe('*');
  }

  Future<Map?> createChatRoom(idPenjual, idPembeli, message, senderId,
      timestamp, collectionName) async {
    try {
      var objLastMsg = {
        "message": message,
        "sender_id": senderId,
        "timestamp": timestamp
      };

      var objIsRead;
      if (collectionName == 'pengguna_pembeli') {
        objIsRead = {"by_pembeli": true, "by_penjual": false};
      } else {
        objIsRead = {"by_pembeli": false, "by_penjual": true};
      }

      var objIsHapusChat = {"by_pembeli": false, "by_penjual": false};

      final body = <String, dynamic>{
        "id_penjual": idPenjual,
        "id_pembeli": idPembeli,
        "last_message": objLastMsg,
        "is_read": objIsRead,
        "is_hapus_chat": objIsHapusChat
      };

      final record = await pb.collection('chat_rooms').create(body: body);

      print("resultList getChatRoomDetailsByIdChatRoom , ");
      print(record);

      var obj = {
        "data": record,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<RecordModel?> updateChatRoomLastMessage(
      collectionName, idChatRoom, message, senderId, timestamp) async {
    final body;
    if (collectionName == "pengguna_pembeli") {
      var objLastMessage = {
        "message": message,
        "sender_id": senderId,
        "timestamp": timestamp
      };
      var objIsRead = {"by_pembeli": true, "by_penjual": false};
      var objIsHapusChat = {"by_pembeli": false, "by_penjual": false};
      body = <String, dynamic>{
        "last_message": objLastMessage,
        "is_read": objIsRead,
        "is_hapus_chat": objIsHapusChat
      };
    } else {
      var objLastMessage = {
        "message": message,
        "sender_id": senderId,
        "timestamp": timestamp
      };
      var objIsRead = {"by_pembeli": false, "by_penjual": true};
      var objIsHapusChat = {"by_pembeli": false, "by_penjual": false};
      body = <String, dynamic>{
        "last_message": objLastMessage,
        "is_read": objIsRead,
        "is_hapus_chat": objIsHapusChat
      };
    }

    final record =
        await pb.collection('chat_rooms').update(idChatRoom, body: body);

    return record;
  }

  Future<RecordModel?> updateChatBaruTelahDibaca(
      collectionName, itemChatRoom) async {
    final body;
    if (collectionName == "pengguna_penjual") {
      var obj = {
        "by_pembeli": itemChatRoom.isRead.byPembeli,
        "by_penjual": true
      };
      body = <String, dynamic>{
        "is_read": obj,
      };
    } else {
      var obj = {
        "by_pembeli": true,
        "by_penjual": itemChatRoom.isRead.byPenjual,
      };
      body = <String, dynamic>{
        "is_read": obj,
      };
    }

    final record =
        await pb.collection('chat_rooms').update(itemChatRoom.id, body: body);

    return record;
  }

  Future<RecordModel?> updateChatBaruTelahDibacaSaatPenerimaPosisiAktif(
      collectionName, idChatRoom) async {
    final body;
    if (collectionName == "pengguna_penjual") {
      var obj = {"by_pembeli": true, "by_penjual": true};
      body = <String, dynamic>{
        "is_read": obj,
      };
    } else {
      var obj = {"by_pembeli": true, "by_penjual": true};
      body = <String, dynamic>{
        "is_read": obj,
      };
    }

    final record =
        await pb.collection('chat_rooms').update(idChatRoom, body: body);

    return record;
  }

  Future<RecordModel?> updateHapusChatRoom(collectionName, itemChatRoom) async {
    final body;
    if (collectionName == "pengguna_penjual") {
      var obj = {
        "by_pembeli": itemChatRoom.isHapusChat.byPembeli,
        "by_penjual": true
      };
      body = <String, dynamic>{
        "is_hapus_chat": obj,
      };
    } else {
      var obj = {
        "by_pembeli": true,
        "by_penjual": itemChatRoom.isHapusChat.byPenjual,
      };
      body = <String, dynamic>{
        "is_hapus_chat": obj,
      };
    }

    final record =
        await pb.collection('chat_rooms').update(itemChatRoom.id, body: body);

    return record;
  }

  Future<RecordModel?> createMessageChatRoomDetails(
      idChatRoom, message, senderId, timestamp) async {
    var obj = {
      "message": message,
      "sender_id": senderId,
      // "timestamp": timestamp
    };

    final body = <String, dynamic>{
      "id_chat_room": idChatRoom,
      "messages": obj,
      "timestamp": timestamp
    };

    final record = await pb.collection('chat_rooms_details').create(body: body);

    return record;
  }

  Future<Map?> getChatRoomDetailsByIdChatRoom(idChatRoom) async {
    try {
      final resultList = await pb.collection('chat_rooms_details').getList(
            page: 1,
            perPage: 449,
            filter: 'id_chat_room = "${idChatRoom}"',
            // expand:
            //     'id_chat_room,id_chat_room.id_pembeli,id_chat_room.id_penjual',
          );

      print("resultList getChatRoomDetailsByIdChatRoom , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<RecordModel?> tambahPesanan(
      idPenjual, idPembeli, alamatTujuan, timestampAwalPemesanan) async {
    final body = <String, dynamic>{
      "id_penjual": idPenjual,
      "id_pembeli": idPembeli,
      "alamat_tujuan": alamatTujuan,
      "is_terima": false,
      "is_batal": false,
      "is_sukses": false,
      "timestamp_awal_pemesanan": timestampAwalPemesanan,
      "timestamp_terima_pemesanan": null
    };

    final record = await pb.collection('pesanan').create(body: body);

    return record;
  }

  Future<Map?> cekPesanan(idPenjual, idPembeli) async {
    try {
      final resultList = await pb.collection('pesanan').getList(
            page: 1,
            perPage: 449,
            filter:
                'id_penjual = "${idPenjual}" && id_pembeli = "${idPembeli}"',
          );

      print("resultList cekPesanan , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<Map?> getPesananByIdPengguna(collectionName, idPengguna) async {
    try {
      final resultList;
      if (collectionName == "pengguna_pembeli") {
        resultList = await pb.collection('pesanan').getList(
              page: 1,
              perPage: 449,
              filter: 'id_pembeli = "${idPengguna}"',
              expand: 'id_penjual,id_pembeli',
            );
      } else {
        resultList = await pb.collection('pesanan').getList(
              page: 1,
              perPage: 449,
              filter: 'id_penjual = "${idPengguna}"',
              expand: 'id_penjual,id_pembeli',
            );
      }

      print("resultList cekPesanan , ");
      print(resultList);

      var obj = {
        "data": resultList,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<RecordModel?> batalkanPesanan(idPesanan) async {
    final body = <String, dynamic>{
      "is_batal": true,
    };

    final record = await pb.collection('pesanan').update(idPesanan, body: body);

    return record;
  }

  Future<Map?> terimaPesanan(idPesanan, timestamp) async {
    try {
      final body = <String, dynamic>{
        "is_terima": true,
        "timestamp_terima_pemesanan": timestamp,
      };

      final record =
          await pb.collection('pesanan').update(idPesanan, body: body);

      var obj = {
        "data": record,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<Map?> selesaikanPesanan(idPesanan) async {
    try {
      final body = <String, dynamic>{
        "is_sukses": true,
      };

      final record =
          await pb.collection('pesanan').update(idPesanan, body: body);

      var obj = {
        "data": record,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }

  Future<Map?> deletePesanan(idPesanan) async {
    try {
      await pb.collection('pesanan').delete(idPesanan);

      var obj = {
        // "data": record,
        "status": "sukses",
      };

      var toString = jsonEncode(obj);
      // print(toString);
      var toMap = jsonDecode(toString);

      return toMap;
    } catch (e) {
      print("e.toString()");
      print(e.toString());

      if (e is ClientException && e.response != null) {
        final errorMessage = e.response;

        print("errorMessage");
        print(errorMessage);

        print("errorMessage['message']");
        print(errorMessage['message']);

        // emit(BestPracticeReadOnlyStateError(errorMessage['message']));

        var obj = {
          "data": errorMessage['message'],
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      } else {
        var obj = {
          "data": "Maaf tidak berhasil menampilkan data",
          "status": "error",
        };

        var toString = jsonEncode(obj);
        var toMap = jsonDecode(toString);

        return toMap;
      }
    }
  }
}
