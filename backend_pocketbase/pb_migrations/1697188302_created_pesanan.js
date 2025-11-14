migrate((db) => {
  const collection = new Collection({
    "id": "yoe7icsrxhgfx5u",
    "created": "2023-10-13 09:11:42.083Z",
    "updated": "2023-10-13 09:11:42.083Z",
    "name": "pesanan",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "xa10x0hq",
        "name": "id_penjual",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "hzwi3c1ddvyng4x",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": []
        }
      },
      {
        "system": false,
        "id": "ghj2vn2p",
        "name": "id_pembeli",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "aoe9mev3bhdxq15",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": []
        }
      },
      {
        "system": false,
        "id": "f1tjytpv",
        "name": "alamat_tujuan",
        "type": "json",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "2ohx6wph",
        "name": "is_terima",
        "type": "bool",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "oxnfwl6i",
        "name": "is_batal",
        "type": "bool",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "ppenh0lq",
        "name": "is_sukses",
        "type": "bool",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "auv37mg0",
        "name": "timestamp_awal_pemesanan",
        "type": "text",
        "required": false,
        "unique": false,
        "options": {
          "min": null,
          "max": null,
          "pattern": ""
        }
      }
    ],
    "indexes": [],
    "listRule": "",
    "viewRule": "",
    "createRule": "",
    "updateRule": "",
    "deleteRule": "",
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("yoe7icsrxhgfx5u");

  return dao.deleteCollection(collection);
})
