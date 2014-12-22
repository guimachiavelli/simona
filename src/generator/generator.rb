require 'kramdown'
require_relative './dropbox'

class Generator
    RAW_DIR = File.dirname(__FILE__) + '/download'
    VIEW_DIR = './views'
    PUBLIC_DIR = './public'
    IMAGES_DIR = PUBLIC_DIR + '/imgs'

    def initialize(download)
        download ||= false
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
