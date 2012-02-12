require 'matrix'

class Matrix::EigenvalueDecomposition

  def eigenvalues_decr
    eigenvalues.sort.reverse
  end

  def eigenvalue_matrix_decr
    Matrix.diagonal(*(eigenvalues.sort.reverse))
  end

  def eigenvector_matrix_decr
    cols = {}

    evalues = eigenvalues #don't compute this each time in following loop
    evectors = eigenvector_matrix #or this
    
    evalues.each_with_index do |evalue, i|
      cols[evalue] = evectors.column(i)
    end

    decr_cols = cols.keys.sort.reverse.inject(Array.new) do |working, next_col|
      working << cols[next_col]
    end

    Matrix.columns(decr_cols)
  end
  
  def eigenvector_matrix_inv_decr
    cols = {}

    evalues = eigenvalues #don't compute this each time in following loop
    evectors = eigenvector_matrix_inv #or this
    
    evalues.each_with_index do |evalue, i|
      cols[evalue] = evectors.column(i)
    end

    decr_cols = cols.keys.sort.reverse.inject(Array.new) do |working, next_col|
      working << cols[next_col]
    end

    Matrix.columns(decr_cols)
  end
end

class Matrix
  #divide the column vectors of this matrix by the first element of that column.
  #this is helpful when we need to compare 2 augmented non-unique matricies,
  #such as eigenvector augmentations. only the ratio matters between the
  #elements of the columns.
  def normalize_to_top
    cols = column_vectors

    cols.size.times do |i|
      cols[i] /= cols[i][0].to_f
    end

    Matrix.columns( cols )
  end

end

class SvdImage
  VERSION = '1.0.0'
  def SvdImage.svd a
    #steps
    #  ata = a_transpose * a
    #  aat = a * a_transpose
    #  S = ata's eigenvals placed along diagonal in decreasing order
    #  S = S**0.5 (since its a_transpose * a)
    #  V = [augmented eigenvectors of ata] (ensure correct order!)
    #  U = [augmented eigenvectors of aat] (ensure correct order!)
    #  return U, S, V.t (which = A)

    ata = a.t * a

    aat = a * a.t

    s = ata.eigen.eigenvalue_matrix_decr ** 0.5

    v_t = ata.eigen.eigenvector_matrix_decr.transpose

    u = aat.eigen.eigenvector_matrix_decr

    return u, s, v_t
  end
end


