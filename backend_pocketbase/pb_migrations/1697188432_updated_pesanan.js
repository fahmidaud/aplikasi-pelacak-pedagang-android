migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("yoe7icsrxhgfx5u")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "lmoguvpy",
    "name": "timestamp_terima_pemesanan",
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
  const collection = dao.findCollectionByNameOrId("yoe7icsrxhgfx5u")

  // remove
  collection.schema.removeField("lmoguvpy")

  return dao.saveCollection(collection)
})
