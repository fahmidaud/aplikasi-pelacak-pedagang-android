migrate((db) => {
  const collection = new Collection({
    "id": "hy4o8rzo993xgqj",
    "created": "2023-09-23 03:25:52.735Z",
    "updated": "2023-09-23 03:25:52.735Z",
    "name": "pengguna_anonim",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "vc9jqhor",
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
        "id": "pngj00cl",
        "name": "is_online",
        "type": "bool",
        "required": false,
        "unique": false,
        "options": {}
      },
      {
        "system": false,
        "id": "u8pdd8is",
        "name": "online_details",
        "type": "json",
        "required": false,
        "unique": false,
        "options": {}
      }
    ],
    "indexes": [],
    "listRule": "",
    "viewRule": "",
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj");

  return dao.deleteCollection(collection);
})
