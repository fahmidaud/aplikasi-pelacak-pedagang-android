migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "9chmdqki",
    "name": "last_message",
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
  collection.schema.removeField("9chmdqki")

  return dao.saveCollection(collection)
})
