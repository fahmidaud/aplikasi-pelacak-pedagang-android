migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "1iyhccno",
    "name": "is_active",
    "type": "bool",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // remove
  collection.schema.removeField("1iyhccno")

  return dao.saveCollection(collection)
})
