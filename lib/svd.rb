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

  infile = "wide.jpg"
  colorspace = :rgb

  truncate_to = 100

  outfile = "out#{File.extname(infile)}"


  puts "Let's do this!"
  STDOUT.flush

  print "SVD-ing image..."
  STDOUT.flush
  svdimg = SvdImage.read infile, colorspace
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
