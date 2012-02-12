require "test/unit"
require "svd"

class TestSvd < MiniTest::Unit::TestCase

  def setup
    @test_matricies = [Matrix[[1, -2], [-2, 1]],
      Matrix[[2,-2],[1,1]],
      Matrix[[1, -2/3.0], [1/2.0, -1/6.0]],
      Matrix[[3, 1], [-1, 1]],
      Matrix[[1, 2], [-1, 1]],
      Matrix[[3, -1, 0], [-1, 2, -1], [0, -1, 3]],
      Matrix[[-1, -1, 4], [1, 3, -2], [1, 1, -1]],
      Matrix[[1, -3, 11], [2, -6, 16], [1, -3, 7]],
      Matrix[[-4, -4, 2], [3, 4, -1], [-3, -2, 3]],
      Matrix[[3, 4, 0, 0], [4, 3, 0, 0], [0, 0, 1, 3], [0, 0, 4, 5]],
      Matrix[[4, 0, 0, 0], [1, 3, 0, 0], [-1, 1, 2, 0], [1, -1, 1, 1]],
      Matrix[[1, 2, 8], [2, 5, 6]],
      Matrix[[1, 2], [2, 5], [8, 6]],
      Matrix.I(3),
      Matrix.I(10),
      Matrix.ones(3),
      Matrix.ones(10),
      Matrix.zeros(3),
      Matrix.zeros(10)]
  end

  def test_svd
    @test_matricies.each do |a|
      u, s, v_t = Svd.svd a
      
      product = u * s * v_t

      assert_equal a, product, "SVD product does not equal original matrix"
    end
  end

  def test_svd_truncate
    #okay, uhm, just make sure there are no errors?
    @test_matricies.each do |a|
      u, s, v_t = Svd.svd_truncate a, 1
      
      product = u * s * v_t
    end
  end
end
