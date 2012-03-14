# -*- encoding: utf-8 -*-
$:.push File.expand_path("../lib", __FILE__)
require "svdimage/version"

Gem::Specification.new do |s|
  s.name        = "svdimage"
  s.version     = SvdImage::VERSION
  s.authors     = ["Tim Martin"]
  s.email       = ["me@timmart.in"]
  s.homepage    = 'https://github.com/t-mart/svdimage'
  s.summary     = "Represent images as their singular value decomposition."
  s.description = "A singular value decomposition of image matrices can result in compression of the original image with minimal loss of quality. This project explores this process. This project is for Georgia Tech's Spring 2012 MATH2605, taught by Zhiwu Lin."

  s.rubyforge_project = "svdimage"

  s.files         = `git ls-files`.split("\n")
  s.test_files    = `git ls-files -- {test,spec,features}/*`.split("\n")
  s.executables   = `git ls-files -- bin/*`.split("\n").map{ |f| File.basename(f) }
  s.require_paths = ["lib"]

  s.add_development_dependency 'rmagick'
  s.add_development_dependency 'gsl'
  s.add_development_dependency 'slop'
end
