migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("aoe9mev3bhdxq15")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "ubgldjul",
    "name": "is_log_out",
    "type": "bool",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("aoe9mev3bhdxq15")

  // remove
  collection.schema.removeField("ubgldjul")

  return dao.saveCollection(collection)
})
