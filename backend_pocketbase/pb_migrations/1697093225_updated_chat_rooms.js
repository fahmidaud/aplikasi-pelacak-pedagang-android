migrate((db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "sixwe28i",
    "name": "id_penjual",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "collectionId": "hzwi3c1ddvyng4x",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": null,
      "displayFields": []
    }
  }))

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "nidw75pc",
    "name": "id_pembeli",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "collectionId": "aoe9mev3bhdxq15",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": null,
      "displayFields": []
    }
  }))

  return dao.saveCollection(collection)
}, (db) => {
  const dao = new Dao(db)
  const collection = dao.findCollectionByNameOrId("rpnx6b74xzhfh8b")

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "sixwe28i",
    "name": "id_penjual",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "collectionId": "hzwi3c1ddvyng4x",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": 1,
      "displayFields": []
    }
  }))

  // update
  collection.schema.addField(new SchemaField({
    "system": false,
    "id": "nidw75pc",
    "name": "id_pembeli",
    "type": "relation",
    "required": false,
    "unique": false,
    "options": {
      "collectionId": "aoe9mev3bhdxq15",
      "cascadeDelete": false,
      "minSelect": null,
      "maxSelect": 1,
      "displayFields": []
    }
  }))

  return dao.saveCollection(collection)
})
