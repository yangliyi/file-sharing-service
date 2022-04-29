class CreateUploadedFiles < ActiveRecord::Migration[6.1]
  def change
    create_table :uploaded_files do |t|
      t.string :user_id,  null: false
      t.timestamps

    end

    add_index :uploaded_files, :user_id
  end
end
