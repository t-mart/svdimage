#include GSL

module SvdImage
  #a collection of Svds corresponding to the channels of an image
  class Image

    #map a colorspace to it's component channels
    #these channel strings correspond to what Magick::Image.import_pixels expects
    #to represent a channel
    COLORSPACES = {rgb: ['R', 'G', 'B'],
                   cmyk: ['C', 'M', 'Y', 'K'],
                   gray: ['I']}

    #the largest value a channel pixel can have
    MAX_COLOR_VALUE = 255 #8 bit
    #the smallest value a channel pixel can have
    MIN_COLOR_VALUE = 0

    SVD_EXTNAME = '.svd'

    #k is the number of largest singular values
    attr_reader :k
    
    attr_reader :colorspace, :channel_strings, :channel_svds

    #image is resulting RMagick image corresponding to k
    #so, this image may be compressed
    attr_reader :image

    class << self
      #in other words, RMagick can open it
      def read_image_file path, colorspace
        raise(ArgumentError, "\"#{colorspace}\" not a valid colorspace. pick one of #{COLORSPACES.keys}") unless COLORSPACES.keys.include? colorspace

        img = Magick::Image.read(path)[0]

        channel_values = COLORSPACES[colorspace].map do |channel_str|
          img.rows.times.map do |row|
            img.export_pixels_to_str(0, row, img.columns, 1, channel_str).bytes.to_a
          end
        end

        channel_matricies = channel_values.map do |channel|
          SvdImage::Svd.a(Matrix.alloc(*channel))
        end

        new colorspace, *channel_matricies
      end

      #my own file format
      #considering the audience, minimal sanity checks will be done
      def read_svd_file path
        File.open(path) do |f|
          Marshal.load(f)
        end
      end

      #private :read_image_file, :read_svd_file

      #choose one of the above methods based on file extension, or maybe some
      #inspection?
      def read path, colorspace=nil

        return read_svd_file(path) if File.extname(path) == SVD_EXTNAME
        return read_image_file(path, colorspace)
      end
    end

    def initialize colorspace, *channel_svds
      raise(ArgumentError, "not a valid colorspace. pick one of #{COLORSPACES.keys}") unless COLORSPACES.keys.include? colorspace

      raise(ArgumentError, "size of channel_svds must match colorspace's expectations") unless channel_svds.size == COLORSPACES[colorspace].size

      @colorspace = colorspace

      @channel_svds = channel_svds
    end

    #use read
    private_class_method :new

    def channel_strings
      COLORSPACES[@colorspace]
    end

    def each
      @channel_svds.each { |svd| yield svd }
    end

    include Enumerable

    #returns an RMagicK::Image object and sets this SvdObject.image to that image
    #yuck this implementation seems horribly expensive
    def to_image 
      #don't compute this if we already have it
      return @image if @image

      pixels = rows * cols

      channel_matricies = map do |channel_svd|
        channel_svd.compose(upper_bound: MAX_COLOR_VALUE, lower_bound: MIN_COLOR_VALUE).to_a.flatten
      end


      #the matricies go from
      # [ *channel1[0..n],
      #   *channel2[0..n],
      #   *channel3[0..n],
      #   ...
      # ]
      #
      # to
      #
      # [ channel1[0],channel2[0],channel3[0],
      #   channel1[1],channel2[1],channel3[1],
      #   ...
      # ]  
      #
      # this is scanline order
      # ex:
      # [RRRGGGBBB] -> [RGBRGBRGB]
      scanline_order = channel_matricies.transpose.flatten

      #puts scanline_order.minmax

      #scanline_order.map! do |v|
        #if v <= 255
          #v
        #else
          #255
        #end
      #end

      scanline_data = scanline_order.pack "C*"

      image = Magick::Image.new(cols, rows)

      colorspace_str = channel_strings.join

      image.import_pixels(0, 0, cols, rows, colorspace_str, scanline_data)

      @image = image

      image
    end

    #return a new truncated SvdImage
    def truncate k
      truncated = map do |channel|
        channel.truncate k
      end
    
      each_with_index do |channel, i|
        puts "#{@colorspace[i]} channel: sigma_{0} = #{channel.s[0].to_f.round{4}}, sigma_{#{k}} = #{channel.s[k].to_f.round{4}}"
      end

      self.class.send( :new, @colorspace, *truncated )
    end

    #return a new truncated SvdImage trucated with a value k determined by each
    #channel's sigma ratio < threshold
    def truncate_choosing_k threshold
      kvals = []
      truncated = map do |channel|
        k = channel.choose_k(threshold)
        kvals << k
        channel.truncate(k)
      end
    
      each_with_index do |channel, i|
        puts "#{@colorspace[i]} channel: sigma_{0} = #{channel.s[0].to_f.round{4}}, sigma_{#{kvals[i]}} = #{channel.s[kvals[i]].to_f.round{4}}"
      end

      self.class.send( :new, @colorspace, *truncated )
    end

    #write out the image corresponding to the channel svd's of this object
    #inspect the extenstion to see if we should write in svd format or another
    #format that RMagick can handle
    def write path
      return write_svd_format(path) if File.extname(path) == SVD_EXTNAME
      return write_standard_format(path)
    end

    #returns the rows of the composed matrix
    def rows
      #these should all be the same
      @channel_svds[0].rows
    end

    #returns the columns of the composed matrix
    def cols
      #again, these should all be the same
      @channel_svds[0].cols
    end

    #private

    #standard format is a format RMagick knows how to handle.
    def write_standard_format(path)
      #if we've called truncate, there will be @image, otherwise, make a new one
      #from the original
      @image ||= to_image

      @image.write(path)
    end

    #my own format
    def write_svd_format(path)
      File.open(path, 'w') do |f|
        Marshal.dump(self, f)
      end
    end

    def marshal_dump
      channel_matricies = @channel_svds.map do |channel|
        channel.a.to_a
      end

      {colorspace: @colorspace, channel_svds: channel_matricies}
    end

    def marshal_load data
      @colorspace = data[:colorspace]
      @channel_svds = []
      data[:channel_svds].each do |channel_array|
        @channel_svds << SvdImage::Svd.a(Matrix.alloc(*channel_array))
      end
    end

  end
end
