migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "yixzdgyj",
    "name": "is_hapus_chat",
    "type": "json",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b")

  // remove
  collection.schema.removeField("yixzdgyj")

  return dao.saveCollection(collection)
})
