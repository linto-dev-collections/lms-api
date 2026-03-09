class CreateCertificates < ActiveRecord::Migration[8.1]
  def change
    create_table :certificates do |t|
      t.references :enrollment, null: false, foreign_key: { on_delete: :restrict }, index: { unique: true }
      t.string :status, null: false, default: "pending", limit: 20
      t.timestamptz :issued_at
      t.string :certificate_number, null: false, limit: 50

      t.timestamps
    end

    add_index :certificates, :certificate_number, unique: true

    add_check_constraint :certificates,
      "status IN ('pending', 'issued', 'revoked')",
      name: "chk_certificates_status"
  end
end
