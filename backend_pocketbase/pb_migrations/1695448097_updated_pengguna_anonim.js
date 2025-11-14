migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // add
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "jfcp2vf4",
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
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  // remove
  collection.schema.removeField("jfcp2vf4")

  return dao.saveCollection(collection)
})
