$: << File.dirname(__FILE__)

require 'RMagick'
require 'gsl'

require 'svd/svd'
require 'svd/svd_image'

if __FILE__ == $0
  img = SvdImage.read("tb.jpg")

  img = img.truncate 20

  img.write("out.jpg")
end
