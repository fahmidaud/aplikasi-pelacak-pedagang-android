migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("pmyl8qyrxwhsd83")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "be835kog",
    "name": "timestamp",
    "type": "text",
    "required": false,
    "unique": false,
    "options": {
      "min": null,
      "max": null,
      "pattern": ""
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("pmyl8qyrxwhsd83")

  // remove
  collection.schema.removeField("be835kog")

  return dao.saveCollection(collection)
})
