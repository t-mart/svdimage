require 'RMagick'
include Magick

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
      img = Image.read(path)

      r, g, b = [], [], []

      #get all the 
      #img.export_pixels(0, r, img.columns, 1, "RGB");
      #test this
      img.rows.each do |r|
        r << img.export_pixels(0, r, img.columns, 1, "R")
        g << img.export_pixels(0, r, img.columns, 1, "G")
        b << img.export_pixels(0, r, img.columns, 1, "B")
      end

      end


    end

    #my own file format
    def read_svd_file path

    end

    private :from_image_file, :from_svd_file

    #choose one of the above methods based on file extension, or maybe some
    #inspection?
    def read path

    end
  end

  #generate :image from this truncation
  def truncate k

  end

  #write out the image. if we haven't truncated, write out the original
  #image.
  def write path

  end
end
