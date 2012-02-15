$: << File.dirname(__FILE__)

require 'RMagick'
require 'gsl'

require 'svd/svd'
require 'svd/svd_image'

if __FILE__ == $0
  #use jpgs to see decrease in file size!
  #
  #i think png isn't utilizing palette because size says the same after
  #different truncations

  svdimg = SvdImage.read "test1.png", :gray

  svdimg = svdimg.truncate 100

  svdimg.write("out.jpg")
end
