migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("aoe9mev3bhdxq15")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "sqhmgecc",
    "name": "token_fcm",
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
  const collection = dao.findCollectionByNameOrId("aoe9mev3bhdxq15")

  // remove
  collection.schema.removeField("sqhmgecc")

  return dao.saveCollection(collection)
})
