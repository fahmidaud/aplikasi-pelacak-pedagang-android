migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  collection.createRule = ""
  collection.updateRule = ""
  collection.deleteRule = ""

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("hy4o8rzo993xgqj")

  collection.createRule = null
  collection.updateRule = null
  collection.deleteRule = null

  return dao.saveCollection(collection)
})
