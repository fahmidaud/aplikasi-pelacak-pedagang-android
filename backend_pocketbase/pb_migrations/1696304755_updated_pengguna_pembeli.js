migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("aoe9mev3bhdxq15")

  // remove
  collection.schema.removeField("qowkoduy")

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("aoe9mev3bhdxq15")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "qowkoduy",
    "name": "imei",
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
})
