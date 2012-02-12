require 'gsl'
include GSL

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

class Svd

  attr_reader :a
  attr_reader :u, :s, :v_t

  def initialize a
    @a = a

    @u, @s, @v_t = Svd.svd
  end

  def s_diag
    Matrix.diagonal s
  end

  def Svd.svd
    begin
      u, v, s = @a.SV_decomp
      return u, s, v.transpose
    rescue ERROR::EUNIMPL
      #happens when the matrix is wider than it is tall
      #for some reason, gsl hasn't implemented this, yet it seems pretty easy to
      #fix. here's what's going on:
      #u is v
      #v is u
      #transpose s
      u, v, s = @a.transpose.SV_decomp
      return v, Matrix.diagonal(s).transpose, u.transpose
    end
  end

  def truncate k, diag = true
    #k columns of U
    #k-wide diagonal s (largest)
    #k rows of V^T

    r = 0...k

    trun_u = u.submatrix(nil, r)
    trun_s = ( diag ? s_diag.submatrix(r, r) :
              s.subvector k )
    trun_v_t = v_t.submatrix(r, nil)

    return trun_u, trun_s, trun_v_t
  end
end
