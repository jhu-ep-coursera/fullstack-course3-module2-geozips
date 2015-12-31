class AddIndexToZips < ActiveRecord::Migration

  # add a 2dsphere index to Zip.loc field
  def up
      Zip.collection.indexes.create_one({:loc => Mongo::Index::GEO2DSPHERE})
  end

  def down
      Zip.collection.indexes.drop_one("loc_2dsphere")
  end
end
