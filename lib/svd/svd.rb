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

  VERSION = '1.0.0'

  attr_reader :a
  attr_reader :u, :s, :v_t

  #experiment with s/self/Svd
  class << self

    def a a
      u, s, v_t = decompose a

      return new(u, s, v_t)
    end

    def usvt u, s, v_t
      return new(u, s, v_t)
    end

    def decompose a
      begin
        u, v, s = a.SV_decomp
        return u, s, v.transpose
      rescue ERROR::EUNIMPL
        #happens when the matrix is wider than it is tall
        #for some reason, gsl hasn't implemented this, yet it seems pretty easy to
        #fix. here's what's going on:
        #u is v
        #v is u
        #transpose s
        u, v, s = a.transpose.SV_decomp
        return v, s, u.transpose
      end
    end

    alias :svd :decompose

  end

  def initialize u, s, v_t
    @u, @s, @v_t = u, s, v_t

    @a = compose
  end

  private_class_method :new

  def compose
    @a ||= @u * s_diag * @v_t
    return @a
  end

  def s_diag
    Matrix.diagonal @s
  end

  #return a new svd object that's been truncated
  #note this doesn't affect the original u, s, and v_t
  def truncate k
    raise(ArgumentError, "k may not be > than total singular values (#{n_sigmas}) or < 1") if k > n_sigmas || k < 1

    return self if k == n_sigmas

    #k columns of U
    #k-wide diagonal s (largest)
    #k rows of V^T

    r = 0...k

    trun_u = u.submatrix(nil, r)
    trun_s = s.subvector(k)
    trun_v_t = v_t.submatrix(r, nil)

    return Svd.usvt(trun_u, trun_s, trun_v_t)
  end

  def n_sigmas
    @s.size
  end

  alias :n_singular_values :n_sigmas

  def rows
    @u.size1
  end

  def cols
    @v_t.size2
  end

end
