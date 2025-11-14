migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hzwi3c1ddvyng4x")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "dhhfxmje",
    "name": "is_log_out",
    "type": "bool",
    "required": false,
    "unique": false,
    "options": {}
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hzwi3c1ddvyng4x")

  // remove
  collection.schema.removeField("dhhfxmje")

  return dao.saveCollection(collection)
})
