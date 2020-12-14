require 'rubygems'
require 'rmagick'
require 'find'
require 'fileUtils'
require 'yaml'

### reading config file
config = YAML.load_file('config.yml')
base = config['setting']['base_directory'] + '/'
compile = config['setting']['compile_directory'] + '/'
over_path = config['setting']['over_path']

### change extname
def change_ext(filename)
  file_extname = File.extname(filename)
  ext = '.'

  if file_extname =~ /\.(jpeg|jpg)$/i
    ext += 'jpg'
  elsif file_extname =~ /\.png$/i
    ext += 'png'
  elsif file_extname =~ /\.gif$/i
    ext += 'gif'
  end

  filename.gsub(/\.\w+$/, ext)
end



Dir::glob(base + '**/*').each {|f|
  next unless FileTest.file?(f)

  ### make directory
  FileUtils.mkdir_p(compile + File.dirname(f)) unless FileTest.exist?(compile + File.dirname(f))

  ### only jpeg,jpg,png,gif and each uppercase
  if File.extname(f) =~ /\.(jpeg|jpg)$/i || File.extname(f) =~ /\.png$/i || File.extname(f) =~ /\.gif$/i

    ### read
    image = Magick::ImageList.new(f)

    ### resize
    image.resize_to_fit!(config['setting']['resize']['width'], config['setting']['resize']['height'].to_i)

    ### delete image profile
    if config['setting']['profile']
      image.profile!("*", nil)
    end

    ### over image
    if over_path
      over = Magick::Image.read(over_path).first
      image = image.composite(over, Magick::SouthEastGravity, Magick::OverCompositeOp)
    end

    ### write
    image.write(compile + change_ext(f)){ self.quality = 100 }

    ### change quality sizing
    # i = 100
    # while i > 0 do
    #   if image.filesize >= config['setting']['max_KB'] * 1024
    #     image = image.write(compile + change_ext(f)){ self.quality = i }
    #     puts "#{File.basename(image.filename)} --- quality: #{i} --- size: #{image.filesize / 1024}KB"
    #   else
    #     break
    #   end
    #   i = i - config['setting']['quality_reduce']
    # end

  end
}
