require 'minitest/autorun'
require 'RMagick'

require 'svdimage'

class TestCLI < MiniTest::Unit::TestCase

  IN_IMAGE_NAME = "test_in.jpg"
  OUT_IMAGE_NAME = "test_out.jpg"
  SVD_OUT_IMAGE_NAME = "test_out.svd"

  def setup
    @testimg = Magick::Image.new(32,32) do
      self.background_color = 'red'
    end

    @testimg.write(IN_IMAGE_NAME)
  end

  def teardown
    File.delete(IN_IMAGE_NAME)
    File.delete(OUT_IMAGE_NAME) if File.exists?(OUT_IMAGE_NAME)
  end

  def test_good_command_with_k
    #without colorspace flag
    command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} -k 1"

    status = system command

    assert status
    assert File.exists? OUT_IMAGE_NAME
  end

  def test_good_with_k_with_colorspace
    colorspaces = SvdImage::Image::COLORSPACES.keys
    flags = ["-c", "--colorspace"]

    colorspaces.each do |cs|
      flags.each do |flag|
        command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} -k 1 #{flag} #{cs.to_s}"

        status = system command

        assert status
        assert File.exists? OUT_IMAGE_NAME

        #eek, this seems like bad style, but it saves a lot of methods
        teardown
        setup
      end
    end
  end

  def test_good_with_a
    a = [5, nil] #nil because this should be an optional arg

    a.each do |flag|
      command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} -a #{a}"

      status = system command

      assert status
      assert File.exists? OUT_IMAGE_NAME

      #eek, this seems like bad style, but it saves a lot of methods
      teardown
      setup
    end
  end

  def test_good_with_a_with_colorspace
    colorspaces = SvdImage::Image::COLORSPACES.keys
    cs_flags = ["-c", "--colorspace"]
    a = [5, nil] #nil because this should be an optional arg
    a_flags = ["-a", "--auto-k"]

    colorspaces.each do |cs|
      flags.each do |cs_flag|
        a.each do |a|
          a_flags.each do |a_flag|
            command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} #{a_flag} #{a} #{cs_flag} #{cs.to_s}"

            status = system command

            assert status
            assert File.exists? OUT_IMAGE_NAME

            #eek, this seems like bad style, but it saves a lot of methods
            teardown
            setup
          end
        end
      end
    end
  end

  def test_fail_with_a_and_k
    a = [5, nil] #nil because this should be an optional arg
    a_flags = ["-a", "--auto-k"]

    a.each do |a|
      a_flags.each do |a_flag|
        command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} #{a_flag} #{a} -k 1"

        status = system command

        refute status
        refute File.exists? OUT_IMAGE_NAME

        #eek, this seems like bad style, but it saves a lot of methods
        teardown
        setup
      end
    end
  end

  def test_fail_bad_k
    k = [0, -5, 1.1] #can only be integer between 1 and rank of image

    k.each do |k|
      command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} -k #{k}"

      status = system command

      refute status
      refute File.exists? OUT_IMAGE_NAME

      #eek, this seems like bad style, but it saves a lot of methods
      teardown
      setup
    end
  end

  def test_fail_bad_a
    a = [-5, 1.1, 2] #can only be real 0 <= x <= 1
    a_flags = ["-a", "--auto-k"]

    a.each do |a|
      a_flags.each do |a_flag|
        command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} #{a_flag} #{a}"

        status = system command

        refute status
        refute File.exists? OUT_IMAGE_NAME

        #eek, this seems like bad style, but it saves a lot of methods
        teardown
        setup
      end
    end
  end

  def test_fail_bad_colorspace
    bad_cs = "foobar"
    cs_flags = ["-c", "--colorspace"]

    cs_flags.each do |cs_flag|
      command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME} -k 1 #{cs_flag} #{bad_cs}"

      status = system command

      refute status
      refute File.exists? OUT_IMAGE_NAME
    end
  end

  #this test is actually an acceptable scenario. if you want to change to the
  #.svd format for example
  #def test_fail_no_k_or_a
    #command = "svdimage #{IN_IMAGE_NAME} #{OUT_IMAGE_NAME}"

    #status = system command

    #refute status
    #refute File.exists? OUT_IMAGE_NAME
  #end
  
  def test_fail_bad_infile
    command = "svdimage #{IN_IMAGE_NAME + "not_exist"} #{OUT_IMAGE_NAME} -k 1 #{cs_flag} #{bad_cs}"

    status = system command

    refute status
    refute File.exists? OUT_IMAGE_NAME
  end

  def test_fail_no_outfile
    command = "svdimage #{IN_IMAGE_NAME + "not_exist"} -k 1 #{cs_flag} #{bad_cs}"

    status = system command

    refute status
    refute File.exists? OUT_IMAGE_NAME
  end
end
