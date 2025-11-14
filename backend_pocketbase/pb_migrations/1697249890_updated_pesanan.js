migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("yoe7icsrxhgfx5u")

  // update
  collection.schema.addField(new SchemaField({
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
  }))

  return dao.saveCollection(collection)
})
