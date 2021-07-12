# frozen_string_literal: true

# various app-specific config settings
# use file name "a_load_commonwealth_vlr_configs" so Rails loads this file before other initializers

ASSET_STORE = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'asset_store.yml'))).result, aliases: true)[Rails.env]

GOOGLE_ANALYTICS = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'google_analytics.yml'))).result, aliases: true)[Rails.env]

CONTACT_EMAILS = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'contact_emails.yml'))).result, aliases: true)[Rails.env]

IIIF_SERVER = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'iiif_server.yml'))).result, aliases: true)[Rails.env]

GEOJSON_STATIC_FILE = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'geojson_static_file.yml'))).result, aliases: true)[Rails.env]

CURATOR = YAML.safe_load(ERB.new(File.read(Rails.root.join('config', 'curator.yml'))).result, aliases: true)[Rails.env]
