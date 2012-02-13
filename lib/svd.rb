$: << File.dirname(__FILE__)

require 'RMagick'
require 'gsl'

require 'svd/svd'
require 'svd/svd_image'

if __FILE__ == $0
  img = SvdImage.read("test1.jpg")

  img = img.truncate 1

  img.write("out.jpg")
end
