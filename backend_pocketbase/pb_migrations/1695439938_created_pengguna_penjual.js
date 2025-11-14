migrate((db) => {
  const collection = new Collection({
    "id": "hzwi3c1ddvyng4x",
    "created": "2023-09-23 03:32:18.711Z",
    "updated": "2023-09-23 03:32:18.711Z",
    "name": "pengguna_penjual",
    "type": "auth",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "ru0z4rge",
        "name": "imei",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "knbkqxtc",
        "name": "nama_dagang",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "s6enc8ec",
        "name": "nama_penjual",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      },
      {
        "system": false,
        "id": "ap1u2vy2",
        "name": "tipe_penjual",
        "type": "select",
        "required": false,
        "unique": false,
        "options": {
          "maxSelect": 2,
          "values": [
            "Keliling",
            "Tetap"
          ]
        }
      },
      {
        "system": false,
        "id": "vi5bywuy",
        "name": "alamat_tetap",
        "type": "json",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "fbm37jal",
        "name": "alamat_keliling",
        "type": "json",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "b2sct2a9",
        "name": "is_online",
        "type": "bool",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "tru3cekb",
        "name": "online_details",
        "type": "json",
        "required": false,
        "unique": false,
        "options": {}
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {
      "allowEmailAuth": true,
      "allowOAuth2Auth": true,
      "allowUsernameAuth": true,
      "exceptEmailDomains": null,
      "manageRule": null,
      "minPasswordLength": 8,
      "onlyEmailDomains": null,
      "requireEmail": false
    }
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("hzwi3c1ddvyng4x");

  return dao.deleteCollection(collection);
})
