require 'dropbox_sdk'

class Downloader
    APP_KEY = '4ytm96e1tvmetgu'
    APP_SECRET = 'u6kuo7j16wq26vh'
    CREDENTIALS_FILE = File.dirname(__FILE__) + '/credentials.txt'
    DOWNLOAD_DIR = File.dirname(__FILE__) + '/download'

    private_constant :APP_KEY, :APP_SECRET, :CREDENTIALS_FILE, :DOWNLOAD_DIR

    def initialize
        @access_token, @user_id = get_credentials
        Dir.mkdir(DOWNLOAD_DIR) unless Dir.exists?(DOWNLOAD_DIR)
    end

    def connect
        @client = DropboxClient.new @access_token
    end

    def download
        connect
        projects = project_list
        files = file_list(projects)

        create_folders(projects)
        files.each do |file|
            download_file(file)
        end
    end

    def project_list
        projects = []
        folders = @client.metadata('/')

        folders['contents'].each do |content|
            projects << content['path'] if content['is_dir']
        end

        projects
    end

    def create_folders(projects)
        projects.each do |project|
            dir_path = DOWNLOAD_DIR + project
            Dir.mkdir(dir_path) unless Dir.exists?(dir_path)
        end
    end

    def file_list(projects)
        files = []
        projects.each do |project|
            project_files = @client.metadata(project)['contents']
            project_files.each do |file|
                files << file['path']

            end
        end
        files
    end

    def download_file(file)
        contents = @client.get_file file
        File.write DOWNLOAD_DIR + file, contents
    end

    def get_credentials
        if File.exists? CREDENTIALS_FILE then
            return get_credentials_from_file
        end

        generate_access_token
    end

    def get_credentials_from_file
        credentials = []

        File.read(CREDENTIALS_FILE).each_line do |line|
            credentials << line.strip
        end

        credentials
    end

    def generate_access_token
        flow = DropboxOAuth2FlowNoRedirect.new APP_KEY, APP_SECRET

        authorize_url = flow.start

        puts '1. Go to: ' + authorize_url
        puts '2. Click "Allow" (you might have to log in first)'
        puts '3. Copy the authorization code'
        print 'Enter the authorization code here: '

        credentials = flow.finish(gets.strip)

        File.write CREDENTIALS_FILE, credentials.join("\n")

        credentials
    end

end
