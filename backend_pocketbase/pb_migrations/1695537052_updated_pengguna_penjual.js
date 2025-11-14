migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hzwi3c1ddvyng4x")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "9i2xdhgc",
    "name": "sub_locality",
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
  const collection = dao.findCollectionByNameOrId("hzwi3c1ddvyng4x")

  // remove
  collection.schema.removeField("9i2xdhgc")

  return dao.saveCollection(collection)
})
