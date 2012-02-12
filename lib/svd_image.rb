require 'gsl'
include GSL

class SvdImage

  VERSION = '1.0.0'

  def SvdImage.svd a
    begin
      u, v, s = a.SV_decomp
      return u, Matrix.diagonal(s), v.transpose
    rescue ERROR::EUNIMPL
      #for some reason, gsl hasn't implemented this, yet it seems pretty easy to
      #fix. here's what's going on:
      #u is v
      #v is u
      #transpose s
      u, v, s = a.transpose.SV_decomp
      return v, Matrix.diagonal(s).transpose, u.transpose
    end
  end

  def SvdImage.svd_truncate a, k
    #k columns of U
    #k-wide diagonal s (largest)
    #k rows of V^T
    u, s, v_t = SvdImage.svd a
    return u.submatrix(nil, 0...k),
      s.submatrix(0...k, 0...k),
      v_t.submatrix(0...k, nil)
  end
end
#http://www.gnu.org/software/gsl/manual/html_node/Singular-Value-Decomposition.html
#The singular value decomposition of a matrix has many practical uses. The
#condition number of the matrix is given by the ratio of the largest
#singular value to the smallest singular value. The presence of a zero
#singular value indicates that the matrix is singular. The number of
#non-zero singular values indicates the rank of the matrix. In practice
#singular value decomposition of a rank-deficient matrix will not
#produce exact zeroes for singular values, due to finite numerical
#precision. Small singular values should be edited by choosing a suitable
#tolerance. 


