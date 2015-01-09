require 'kramdown'
require_relative './dropbox'

class Generator
    RAW_DIR = File.dirname(__FILE__) + '/download'
    VIEW_DIR = File.expand_path('../../views', File.dirname(__FILE__))
    PUBLIC_DIR = File.expand_path('../../public', File.dirname(__FILE__))
    IMAGES_DIR = PUBLIC_DIR + '/imgs'
    DOWNLOAD_DIR = File.dirname(__FILE__) + '/download'

    private_constant :RAW_DIR, :VIEW_DIR, :PUBLIC_DIR, :IMAGES_DIR, :DOWNLOAD_DIR

    def initialize(download)
        download ||= false
        Dir.mkdir(IMAGES_DIR) unless Dir.exists?(IMAGES_DIR)
        Dir.mkdir(DOWNLOAD_DIR) unless Dir.exists?(DOWNLOAD_DIR)

        download_content if download
        generate_site
    end

    def generate_site
        projects = get_projects
        projects.each do |project|
            generate_project_page project
        end
        generate_index projects
    end

    def get_projects
        projects = []
        dirs = Dir.new RAW_DIR
        dirs.each do |project|
            projects << project unless project.start_with? '.'
        end
        projects
    end

    def generate_index(projects)
        index = '<ol class="project-index">'
        projects.each do |project|
            index << "<li><a href=\"/#{project}\">#{project}</a></li>"
        end
        index << '</ol>'
        File.write(VIEW_DIR + '/index.html', index)
    end

    def generate_project_page(project)
        images = get_images_files project
        page = get_description project

        images.each do |image|
            page << image_html(image)
        end

        File.write(VIEW_DIR + '/' + project + '.html', page)
    end

    def download_content
        dropbox = Downloader.new
        dropbox.download
    end

    def get_description(project)
        file = File.read(RAW_DIR + '/' + project + '/desc.md')

        Kramdown::Document.new(file).to_html
    end

    def get_images_files(project)
        project_image_dir = IMAGES_DIR + '/' + project
        Dir.mkdir(project_image_dir) unless Dir.exists? project_image_dir
        Dir[RAW_DIR + '/' + project + '/*.{jpg,gif,png}'].map do |image|
            path = project_image_dir + '/' + File.basename(image)
            file = File.read(image)
            File.write(path, file)
            path.gsub './public', ''
        end
    end

    def create_views

    end

    def image_html(image)
        "<figure class='project-image'><img src='#{image}' alt=''></figure>"
    end

end
