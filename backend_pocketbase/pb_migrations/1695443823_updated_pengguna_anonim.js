migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "al9wqluk",
    "name": "id_socket",
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
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // remove
  collection.schema.removeField("al9wqluk")

  return dao.saveCollection(collection)
})
