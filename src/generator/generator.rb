require 'kramdown'
require_relative './dropbox'

class Generator
    RAW_DIR = File.dirname(__FILE__) + '/download'
    PARTIALS_DIR = File.expand_path('../partials', File.dirname(__FILE__))
    PUBLIC_DIR = File.expand_path('../../public', File.dirname(__FILE__))
    IMAGES_DIR = PUBLIC_DIR + '/imgs'
    DOWNLOAD_DIR = File.dirname(__FILE__) + '/download'

    private_constant :RAW_DIR, :PARTIALS_DIR, :PUBLIC_DIR, :IMAGES_DIR, :DOWNLOAD_DIR

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

        pages = Dir[RAW_DIR + '/*.md']
        generate_pages(pages)


        generate_index projects, pages

    end

    def generate_pages(pages)
        pages.each do |page|
            name = File.basename(page, '.*')
            content = File.read(PARTIALS_DIR + '/header.html')
            content << Kramdown::Document.new(File.read(page)).to_html
            content << File.read(PARTIALS_DIR + '/footer.html')
            File.write(PUBLIC_DIR + '/' + name + '.html', content)
        end
    end

    def get_projects
        projects = []
        dirs = Dir.new RAW_DIR
        dirs.each do |project|
            projects << project unless project.include? '.'
        end
        projects
    end

    def generate_index(projects, pages)
        index = '<ol class="project-index">'
        projects.each do |project|
            index << "<li><a href=\"/#{project}.html\">#{project}</a></li>"
        end
        pages.each do |page|
            page = File.basename(page, '.*')
            index << "<li><a href=\"/#{page}.html\">#{page}</a></li>"
        end

        index << '</ol>'
        File.write(PUBLIC_DIR + '/index.html', index)
    end

    def generate_project_page(project)
        images = get_images_files project
        page = File.read(PARTIALS_DIR + '/header.html')
        page << get_description(project)

        images.each do |image|
            page << image_html(image)
        end

        page << File.read(PARTIALS_DIR + '/footer.html')

        File.write(PUBLIC_DIR + '/' + project + '.html', page)
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
        image = image.gsub PUBLIC_DIR, ''
        "<figure class='project-image'><img src='#{image}' alt=''></figure>"
    end

end
