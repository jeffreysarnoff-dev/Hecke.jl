export NfMaximalOrder

abstract ComOrder 

################################################################################
#
#  Types and memory management
#
################################################################################

NfMaximalOrderID = Dict{Tuple{NfNumberField, FakeFmpqMat}, ComOrder}()

type NfMaximalOrder <: ComOrder 
  nf::NfNumberField
  basis_nf::Array{nf_elem, 1}   # Array of number field elements
  basis_ord                     # Array of order elements
  basis_mat::FakeFmpqMat        # basis matrix of order wrt basis of K
  basis_mat_inv::FakeFmpqMat    # inverse of basis matrix
  index::fmpz                   # the determinant of basis_mat_inv
  disc::fmpz                    # discriminant
  disc_fac                      # factorized discriminant

  function NfMaximalOrder(a::NfNumberField)
    r = new(a)
    return r
  end
end

################################################################################
#
#  Constructors
#
################################################################################

function NfMaximalOrder(K::NfNumberField, x::FakeFmpqMat)
  if haskey(NfMaximalOrderID, (K,x))
    return NfMaximalOrderID[(K,x)]
  end

  z = NfMaximalOrder(K)
  n = degree(K)
  B_K = basis(K)
  d = Array(nf_elem, n)
  for i in 1:n
    d[i] = dot(x.num[i],basis(K))//K(x.den)
  end
  
  z.basis_nf = d
  z.basis_mat_inv = inv(x)
  B = Array(NfMaximalOrderElem, n)

  for i in 1:n
    v = fill(zero(ZZ), n)
    v[i] = ZZ(1)
    B[i] = z(d[i], v)
  end

  z.basis_ord = B
  NfMaximalOrderID[(K,x)] = z
  return z
end

function NfMaximalOrder(b::Array{nf_elem, 1})
  K = parent(b[1])
  n = degree(K)
  A = FakeFmpqMat(basis_mat(K,b))

  if haskey(NfMaximalOrderID, (K,A))
    return NfMaximalOrderID[(K,A)]
  end

  z = NfMaximalOrder(K)
  z.basis_nf = b
  z.basis_mat = A
  z.basis_mat_inv = inv(A)

  B = Array(NfMaximalOrderElem, n)

  for i in 1:n
    v = fill(zero(ZZ), n)
    v[i] = ZZ(1)
    B[i] = z(b[i], v)
  end

  z.basis_ord = B

  NfMaximalOrderID[(K,A)] = z
  return z
end

function NfMaximalOrder(O::PariMaximalOrder)
  K = O.pari_nf.nf
  z = NfMaximalOrder(K)
  data = pari_load(O.pari_nf.data, 8)
  pol_type = PariPolyRing{PariRationalField}
  par = pol_type(PariQQ, var(parent(K.pol)))
  b =  pari_vec{pol_type}(data, par)
  n = degree(K)
  d = Array(nf_elem, n)
  Qx = K.pol.parent
  B = Array(NfMaximalOrderElem, n)

  for i in 1:n
    d[i] = K(Qx(b[i]))
  end
  return NfMaximalOrder(d)
end

################################################################################
#
#  Field access
#
################################################################################

function basis_ord(O::NfMaximalOrder)
  if isdefined(O, :basis_ord)
    return O.basis_ord
  end
  b = O.basis_nf
  B = Array(NfMaximalOrderElem, length(b))
  for i in 1:length(b)
    v = fill(ZZ(0), length(b))
    v[i] = ZZ(1)
    B[i] = O(b[i], v; check = false)
  end
  O.basis_ord = B
  return B
end

function basis_mat_inv(O::NfMaximalOrder)
  return O.basis_mat_inv
end

function basis_mat(O::NfMaximalOrder)
  return O.basis_mat
end

function basis(O::NfMaximalOrder)
  return basis_ord(O)
end

function basis(O::NfMaximalOrder, K::NfNumberField)
  nf(O) != K && error()
  return basis_nf(O)
end

function basis_nf(O::NfMaximalOrder)
  return O.basis_nf
end

nf(O::NfMaximalOrder) = O.nf

rank(x::NfMaximalOrder) = degree(nf(x))

degree(x::NfMaximalOrder) = degree(nf(x))

################################################################################
#
#  Containment
#
################################################################################

function _check_elem_in_maximal_order(x::nf_elem, O::NfMaximalOrder)
  d = denominator(x)
  b = d*x 
  M = MatrixSpace(ZZ, 1, rank(O))()
  element_to_mat_row!(M,1,b)
  t = FakeFmpqMat(M,d)
  z = t*basis_mat_inv(O)
  return (z.den == 1, map(ZZ,vec(Array(z.num))))  
end

function in(a::nf_elem, O::NfMaximalOrder)
  (x,y) = _check_elem_in_maximal_order(a,O)
  return x
end

################################################################################
#
#  Denominator
#
################################################################################

@doc """
  denominator(a::nf_elem, O::NfMaximalOrder) -> fmpz

  Compute the smalles positive integer k such that k*a in O.
""" ->
function denominator(a::nf_elem, O::NfMaximalOrder)
  d = denominator(a)
  b = d*a 
  M = MatrixSpace(ZZ, 1, rank(O))()
  element_to_mat_row!(M,1,b)
  t = FakeFmpqMat(M,d)
  z = t*basis_mat_inv(O)
  return z.den
end

################################################################################
#
#  Constructors for users
#
################################################################################

@doc """
  MaximalOrder(O::PariMaximalOrder) -> NfMaximalOrder

  Compute the NfMaximalOrder corresponding to O.
""" ->
function MaximalOrder(O::PariMaximalOrder)
  return NfMaximalOrder(O)
end

@doc """
  MaximalOrder(K::NfNumberField) -> NfMaximalOrder

  Compute the maximal order of K.
""" ->
function MaximalOrder(K::NfNumberField)
  @vprint :NfMaximalOrder 1 "Computing the PariMaximalOrder...\n"
  @vtime :NfMaximalOrder 1 O = PariMaximalOrder(PariNumberField(K))
  @vprint :NfMaximalOrder 1 "...DONE \n"

  return NfMaximalOrder(O)
end

################################################################################
#
#  String I/O
#
################################################################################

function show(io::IO, O::NfMaximalOrder)
  print(io, "Maximal order of $(nf(O)) \nwith basis $(basis_nf(O))")
end