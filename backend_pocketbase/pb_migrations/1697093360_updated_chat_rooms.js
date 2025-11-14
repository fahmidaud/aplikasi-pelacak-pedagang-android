migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b")

  // update
  collection.schema.addField(new SchemaField({
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
      "displayFields": [
        "id",
        "nama"
      ]
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b")

  // update
  collection.schema.addField(new SchemaField({
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
  }))

  return dao.saveCollection(collection)
})
