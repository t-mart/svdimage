$: << File.dirname(__FILE__)

require 'RMagick'
require 'gsl'

require 'svdimage/svd'
require 'svdimage/image'

module SvdImage

  VERSION = '1.0.0'

end

if __FILE__ == $0
  #use jpgs to see decrease in file size!
  #
  #i think png isn't utilizing palette because size says the same after
  #different truncations

  infile = "tall.jpg"
  colorspace = :rgb

  truncate_to = 150

  outfile = "out#{File.extname(infile)}"


  puts "Let's do this!"
  STDOUT.flush

  print "SVD-ing image..."
  STDOUT.flush
  svdimg = SvdImage::Image.read infile, colorspace
  puts "done."
  STDOUT.flush

  print "Truncating SVD..."
  STDOUT.flush
  svdimg = svdimg.truncate truncate_to
  puts "done."
  STDOUT.flush

  print "Writing image..."
  STDOUT.flush
  svdimg.write outfile
  puts "done."
  STDOUT.flush
end
