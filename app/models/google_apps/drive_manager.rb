module GoogleApps
  class DriveManager

    include ClassLogger

    def initialize(credential_store)
      @credential_store = credential_store
    end

    def find_folders_by_title(title, parent_id = nil)
      find_items_by_title(title, mime_type: 'application/vnd.google-apps.folder', parent_id: parent_id)
    end

    def find_items_by_title(title, options = {})
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      items = []
      parent_id = options[:parent_id] || 'root'
      query = "'#{parent_id}' in parents and title='#{title}' and trashed=false"
      query.concat " and mimeType='#{options[:mime_type]}'" if options.has_key? :mime_type
      page_token = nil
      begin
        parameters = { :q => query }
        parameters[:pageToken] = page_token unless page_token.nil?
        api_response = client.execute(:api_method => drive_api.files.list, :parameters => parameters)
        if api_response.status == 200
          files = api_response.data
          items.concat files.items
          page_token = files.next_page_token
        else
          puts "An error occurred: #{api_response.data['error']['message']}"
          page_token = nil
        end
      end while page_token.to_s != ''
      items
    end

    def create_folder(title, parent_id)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      metadata = { :title => title, :mimeType => 'application/vnd.google-apps.folder' }
      dir = drive_api.files.insert.request_schema.new metadata
      dir.parents = [{ :id => parent_id }] if parent_id
      result = client.execute(:api_method => drive_api.files.insert, :body_object => dir)
      success = result.status == 200
      logger.error "An error occurred: #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    def upload_file(title, description, parent_id, mime_type, file_absolute_path)
      client = get_google_api
      drive_api = client.discovered_api('drive', 'v2')
      metadata = { :title => title, :description => description, :mimeType => mime_type }
      file = drive_api.files.insert.request_schema.new metadata
      # Target directory is optional
      file.parents = [{ :id => parent_id }] if parent_id
      media = Google::APIClient::UploadIO.new(file_absolute_path, mime_type)
      result = client.execute(
        :api_method => drive_api.files.insert,
        :body_object => file,
        :media => media,
        :parameters => { :uploadType => 'multipart', :alt => 'json'})
      success = result.status == 200
      logger.error "An error occurred: #{result.data['error']['message']}" unless success
      success ? result.data : nil
    end

    private

    def get_google_api
      client = GoogleApps::Client.client
      client.authorization = GoogleApps::Client.new_auth @credential_store
      client
    end

  end
end