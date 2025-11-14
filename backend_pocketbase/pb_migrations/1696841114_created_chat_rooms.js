migrate((db) => {
  const collection = new Collection({
    "id": "rpnx6b74xzhfh8b",
    "created": "2023-10-09 08:45:14.822Z",
    "updated": "2023-10-09 08:45:14.822Z",
    "name": "chat_rooms",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "sixwe28i",
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
        "id": "nidw75pc",
        "name": "id_pembeli",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "aoe9mev3bhdxq15",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": null,
          "displayFields": []
        }
      }
    ],
    "indexes": [],
    "listRule": null,
    "viewRule": null,
    "createRule": null,
    "updateRule": null,
    "deleteRule": null,
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b");

  return dao.deleteCollection(collection);
})
