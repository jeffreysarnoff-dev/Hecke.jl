<!-- Generated by Docile.jl -->

# Maximal orders in number fields

### Introduction

I am explaining the mathemics and conventions

## Creation and access

–––

<a name="Hecke.MaximalOrder"></a>

```
MaximalOrder(K::AnticNumberField) -> NfMaximalOrder
```

###### Description

Compute the maximal order of `K` using Dedekind's criterion and the classical Round two algorithm.

###### Example

```jl
Qx, x = QQ["x"]
K, a = NumberField(x^3 + 2, "a")
O = MaximalOrder(K)
```

–––

<a name="nf(O::Hecke.NfMaximalOrder) at /home/thofmann/.julia/v0.4/Hecke/src/NfMaximalOrder/NfMaximalOrder.jl:44"></a>

```
nf(O::NfMaximalOrder) -> AnticNumberField
```

###### Description

Returns the associated number field of `O`.

–––

<a name="degree(O::Hecke.NfMaximalOrder) at /home/thofmann/.julia/v0.4/Hecke/src/NfMaximalOrder/NfMaximalOrder.jl:53"></a>

```
degree(O::NfMaximalOrder) -> Int
```

###### Description

Returns the degree of `O`, which is just the rank of `O` as a $\mathbb{Z}$-module.

–––

<a name="index(O::Hecke.NfMaximalOrder) at /home/thofmann/.julia/v0.4/Hecke/src/NfMaximalOrder/NfMaximalOrder.jl:117"></a>

###### `index(O::NfMaximalOrder) -> fmpz`

**Description**: Returns the index $[ \mathcal{O} : \mathbf{Z}[\alpha]]$ of the equation order in the given maximal order $\mathcal O$. Here $\alpha$ is the primitive element of the ambient number field.

–––

## Elements

## Ideals

–––

<a name="nf(x::Hecke.NfMaximalOrderIdeal) at /home/thofmann/.julia/v0.4/Hecke/src/NfMaximalOrder/Ideal.jl:130"></a>

```
nf(I::NfMaximalOrderIdeal) -> AnticNumberField
```

###### Description

Returns the number field, of which `I` is an integral ideal.

–––