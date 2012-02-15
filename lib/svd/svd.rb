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
        u, v, s = a.transpose.SV_decomp
        return v, s, u.transpose
      end
    end

    alias :svd :decompose


    #returns a new Svd with all values > bound replaced by bound
    #helper function (particularly for making sure truncated SVD-compositions are
    #between certain values (e.g. 0-255, for 8 bit color per channel)
    def bound a, upper, lower
      size = a.size1 * a.size2

      size.times do |i|
       value = a[i] 
        if upper and value > upper
          a[i] = upper
        elsif lower and value < lower
          a[i] = lower
        end
      end
      
      a
    end
  end

  def initialize u, s, v_t
    @u, @s, @v_t = u, s, v_t

    @a = compose
  end

  private_class_method :new

  #returns the composition the components of the SVD
  #
  #sets instance var @a to this composition
  #
  #options will be applied to the return value, but not to a!
  #as of now, the options all cause a to lose information, to it is more
  #efficient to keep the original and just make more compositions as needed
  def compose options = {}

    @a ||= @u * s_diag * @v_t

    optioned = @a

    if options[:upper_bound] or options[:lower_bound]
      optioned = Svd.bound @a, options[:upper_bound], options[:lower_bound]
    end

    return optioned
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
