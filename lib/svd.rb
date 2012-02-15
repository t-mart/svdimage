$: << File.dirname(__FILE__)

require 'RMagick'
require 'gsl'

require 'svd/svd'
require 'svd/svd_image'
require 'svd/channel_svds.rb'

if __FILE__ == $0
  svdimg = SvdImage.read "cmyk.low.png", :gray

  svdimg = svdimg.truncate 10

  svdimg.write("out.jpg")
end
