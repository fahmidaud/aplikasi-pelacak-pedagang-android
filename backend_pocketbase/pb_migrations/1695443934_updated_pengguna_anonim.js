migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // remove
  collection.schema.removeField("u8pdd8is")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "maiereks",
    "name": "online_details",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "u8pdd8is",
    "name": "online_details",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  // remove
  collection.schema.removeField("maiereks")

  return dao.saveCollection(collection)
})
