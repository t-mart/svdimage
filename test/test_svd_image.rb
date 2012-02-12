require "test/unit"
require "svd_image"

class TestSvdImage < MiniTest::Unit::TestCase

  def setup
    #this kinda sucks with how much data i'm entering, but the point of these
    #tests is to verify that my ruby is following the correct math, and i can
    #only do that with precomputed values.
    @a = Matrix[[2,-2],[1,1]]
    @a_normalized_to_top = Matrix[[1,1],[0.5,-0.5]]

    @aat = @a * @a.t
    @aat_eigenvalues_decr = [8.0, 2.0]
    @aat_eigenvalue_matrix_decr = Matrix.diagonal(*@aat_eigenvalues_decr)
    @aat_eigenvector_matrix_decr = Matrix.columns( [[-1, 0], [0, 1]] )

    @ata = @a.t * @a
    @ata_eigenvalues_decr = [8.0, 2.0]
    @ata_eigenvalue_matrix_decr = Matrix.diagonal(*@ata_eigenvalues_decr)
    @ata_eigenvector_matrix_decr = Matrix.columns( [[-(2**0.5)/2, (2**0.5)/2], [(2**0.5)/2, (2**0.5)/2]] )

    @lots_moar = [Matrix[[1, -2], [-2, 1]],
      Matrix[[1, -2/3.0], [1/2.0, -1/6.0]],
      Matrix[[3, 1], [-1, 1]],
      Matrix[[1, 2], [-1, 1]],
      Matrix[[3, -1, 0], [-1, 2, -1], [0, -1, 3]],
      Matrix[[-1, -1, 4], [1, 3, -2], [1, 1, -1]],
      Matrix[[1, -3, 11], [2, -6, 16], [1, -3, 7]],
      Matrix[[-4, -4, 2], [3, 4, -1], [-3, -2, 3]],
      Matrix[[3, 4, 0, 0], [4, 3, 0, 0], [0, 0, 1, 3], [0, 0, 4, 5]],
      Matrix[[4, 0, 0, 0], [1, 3, 0, 0], [-1, 1, 2, 0], [1, -1, 1, 1]],
      Matrix[[2, 0, 0], [0, 3, 0]],
      Matrix[[2, 1, 0, -1], [0, -1, 1, 1]]]
  end

  def test_svd
    #u, s, v_t = SvdImage.svd (@a)

    #product = u * s * v_t

    #product = product.map { |element| element.round }

    #assert_equal @a, product, "SVD product does not equal original matrix"
    @lots_moar.each do |a|
      u, s, v_t = SvdImage.svd a

      puts "", u, s, v_t
      
      product = u * s * v_t

      product = product.map { |element| element.round }

      assert_equal a, product, "SVD product does not equal original matrix"
    end
  end

  def test_normalize_to_top
    assert_equal @a_normalized_to_top, @a.normalize_to_top,
      "Matrix columns not normalized to first element of each column"
  end

  def test_eigenvalues_decr
    evalues = @ata.eigen.eigenvalues_decr
    assert_equal @ata_eigenvalues_decr , evalues, "Eigenvalues not decreasing"

    evalues = @aat.eigen.eigenvalues_decr
    assert_equal @aat_eigenvalues_decr , evalues, "Eigenvalues not decreasing"
  end

  def test_eigenvalue_matrix_decr
    evalue_matrix = @ata.eigen.eigenvalue_matrix_decr
    assert_equal @ata_eigenvalue_matrix_decr, evalue_matrix, "Eigenvalue matrix not decreasing"

    evalue_matrix = @aat.eigen.eigenvalue_matrix_decr
    assert_equal @aat_eigenvalue_matrix_decr, evalue_matrix, "Eigenvalue matrix not decreasing"
  end

  def test_eigenvector_matrix_decr
    skip("Skipping until I write a way to compare non-unique eigenvectors")

    evector_matrix = @ata.eigen.eigenvector_matrix_decr
    assert_equal @ata_eigenvector_matrix_decr.normalize_to_top, evector_matrix.normalize_to_top,
      "Eigenvector matrix does not match respective decreasing eigenvalues"

    evector_matrix = @aat.eigen.eigenvector_matrix_decr
    assert_equal @aat_eigenvector_matrix_decr.normalize_to_top, evector_matrix.normalize_to_top,
      "Eigenvector matrix does not match respective decreasing eigenvalues"
  end
end
