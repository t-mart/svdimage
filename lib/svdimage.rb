$: << File.dirname(__FILE__)

require 'RMagick'
require 'gsl'

require 'svdimage/svd'
require 'svdimage/image'
require 'svdimage/version'

module SvdImage

end

if __FILE__ == $0
  #use jpgs to see decrease in file size!
  #
  #i think png isn't utilizing palette because size says the same after
  #different truncations

  infile = "test1.jpg"
  colorspace = :rgb

  truncate_to = 50
  #ask yourself, how much information do you want to leave out? that is
  #threshold. the info you keep is 1 - threshold
  threshold = 0.0002

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
  svdimg = svdimg.truncate_choosing_k threshold 
  puts "done."
  STDOUT.flush

  print "Writing image..."
  STDOUT.flush
  svdimg.write outfile
  puts "done."
  STDOUT.flush

  #svdimg = SvdImage::Image.read outfile + ".svd"
  #svdimg.write "outsvd#{File.extname(infile)}"
end
