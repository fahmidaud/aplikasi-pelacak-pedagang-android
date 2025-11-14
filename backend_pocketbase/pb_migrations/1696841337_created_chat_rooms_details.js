migrate((db) => {
  const collection = new Collection({
    "id": "pmyl8qyrxwhsd83",
    "created": "2023-10-09 08:48:57.151Z",
    "updated": "2023-10-09 08:48:57.151Z",
    "name": "chat_rooms_details",
    "type": "base",
    "system": false,
    "schema": [
      {
        "system": false,
        "id": "7rdy6kir",
        "name": "id_chat_room",
        "type": "relation",
        "required": false,
        "unique": false,
        "options": {
          "collectionId": "rpnx6b74xzhfh8b",
          "cascadeDelete": false,
          "minSelect": null,
          "maxSelect": 1,
          "displayFields": []
        }
      },
      {
        "system": false,
        "id": "pjruwixx",
        "name": "messages",
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
    "options": {}
  });

  return Dao(db).saveCollection(collection);
}, (db) => {
  const dao = new Dao(db);
  const collection = dao.findCollectionByNameOrId("pmyl8qyrxwhsd83");

  return dao.deleteCollection(collection);
})
