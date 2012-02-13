include GSL

class String
  #parse a string (from export_pixels_to_str) into an array of bytes
  def parse_bytes
    bytes.inject(Array.new) { |all, next_byte| all << next_byte }
  end
end

class SvdImage

  VERSION = '1.0.0'

  #k is the number of largest singular values
  attr_reader :k
  
  #the lossless svd for each channel (no k truncation)
  attr_reader :r_svd, :g_svd, :b_svd

  #image is resulting RMagick image corresponding to k
  #so, this image may be compressed
  attr_reader :image

  class << self
    #in other words, RMagick can open it
    def read_image_file path
      img = Magick::Image.read(path)[0]

      r, g, b = [], [], []

      img.rows.times do |row|
        r << img.export_pixels_to_str(0, row, img.columns, 1, "R").parse_bytes
        g << img.export_pixels_to_str(0, row, img.columns, 1, "G").parse_bytes
        b << img.export_pixels_to_str(0, row, img.columns, 1, "B").parse_bytes
      end

      rm = Matrix.alloc(*r)
      gm = Matrix.alloc(*g)
      bm = Matrix.alloc(*b)

      svdimage = new(Svd.a(rm), Svd.a(gm), Svd.a(bm))

      return svdimage
    end

    #my own file format
    #considering the audience, minimal sanity checks will be done
    def read_svd_file path

    end

    #private :read_image_file, :read_svd_file

    #choose one of the above methods based on file extension, or maybe some
    #inspection?
    def read path
      return read_svd_file path if File.extname(path) == ".svd"
      return read_image_file path
    end

    def svd_channels r_svd, g_svd, b_svd
      new(r_svd, g_svd, b_svd)
    end

  end

  def initialize r_svd, g_svd, b_svd
    @r_svd = r_svd
    @g_svd = g_svd
    @b_svd = b_svd
  end

  #use read
  private_class_method :new

  #returns an RMagicK::Image object and sets this SvdObject.image to that image
  #yuck this implementation seems horribly expensive
  def svd_to_img 
    #don't compute this if we already have it
    return @image if @image

    rows = @r_svd.rows
    cols = @r_svd.cols
    pixels = rows * cols

    r_matrix = @r_svd.compose.to_a.flatten
    g_matrix = @g_svd.compose.to_a.flatten
    b_matrix = @b_svd.compose.to_a.flatten

    image = Magick::Image.new(cols, rows)

    data = ""

    pixels.times do |i|
      data << [r_matrix[i].truncate].pack("C")
      data << [g_matrix[i].truncate].pack("C")
      data << [b_matrix[i].truncate].pack("C")
    end

    image.import_pixels(0, 0, cols, rows, "RGB", data)

    @image = image
    return image
  end

  #return a new truncated SvdImage
  def truncate k
    return SvdImage.svd_channels(@r_svd.truncate(k),
               @g_svd.truncate(k),
               @b_svd.truncate(k))
  end

  #write out the image corresponding to the r, g, and b svd's of this object
  #inspect the extenstion to see if we should write in svd format or another
  #format that RMagick can handle
  def write path
    #if we've called truncate, there will be @image, otherwise, make a new one
    #from the original
    @image ||= svd_to_img

    @image.write(path)
  end
end
