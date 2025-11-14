migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("yoe7icsrxhgfx5u")

  // update
  collection.schema.addField(new SchemaField({
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
      "displayFields": [
        "id",
        "email"
      ]
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("yoe7icsrxhgfx5u")

  // update
  collection.schema.addField(new SchemaField({
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
  }))

  return dao.saveCollection(collection)
})
