"""
    jacobi(x, n [, a [, b]])
    djacobi(x, n [, a [, b]])
    
Computes Jacobi polynomial and derivatives of Jacobi polynomials.

This function computes the jacobi polynomial of degree `n` with weights
`a` and `b` at point x (\$P_n^{a,b}(x)\$). There are several variants of the function
with default values:

 * `jacobi(x, n)` (`a` and `b` are both zero)
 * `jacobi(x, n, a)` (`b` is zero)

The derivative of Jacobi polynomials (\$\\frac{dP_n^{a,b}(x)}{dx}\$)are computed with functions that add a `d` in front of its name:

 * `djacobi`

Parameters:
 * `x` Where to calculate the polynomial
 * `n` Order of polynomial
 * `a` Weight α of the Jacobi polynomial
 * `b` Weight β of the Jacobi polynomial
 * returns: the value of the polynomial


### Examples
```julia
julia> x = 0.3; a = 0.2; b = 0.1; m = 5;

julia> y = jacobi(x, m, a, b)
0.3780304524166406

julia> dy = djacobi(x, m, a, b)
-0.4343764194492186
```

"""
function jacobi(x, n, a, b)
    ox = one(x)
    zx = zero(x)
    if n==0
        return ox
    elseif n==1
        return ox/2 * (a - b + (a + b + 2)*x)
    end

    p0 = ox
    p1 = ox/2 * (a - b + (a + b + 2)*x)
    p2 = zx;

    for i = 1:(n-1)
	a1 = 2*(i+1)*(i+a+b+1)*(2*i+a+b);
	a2 = (2*i+a+b+1)*(a*a-b*b);
	a3 = (2*i+a+b)*(2*i+a+b+1)*(2*i+a+b+2);
	a4 = 2*(i+a)*(i+b)*(2*i+a+b+2);
	p2 = ox/a1*( (a2 + a3*x)*p1 - a4*p0);

        p0 = p1
        p1 = p2
    end

    return p2
end
jacobi(x, n) = jacobi(x, n, zero(x), zero(x))
jacobi(x, n, a) = jacobi(x, n, a, zero(x))

djacobi(x, n, a, b) =  one(x)/2 * (a + b + n + 1) * jacobi(x, n-1, a+1, b+1)

djacobi(x, n) = djacobi(x, n, zero(x), zero(x))
djacobi(x, n, a) = djacobi(x, n, a, zero(x))


eps1(::Type{T}) where {T<:AbstractFloat} = eps(T)
eps1(::Type{Complex{T}}) where {T<:AbstractFloat} = eps(T)

"""
    jacobi_zeros(m, alpha, beta, x)

Compute the zeros of Jacobi polynomials

This function computes the zeros of Jacobi polynomials:

 * \$P_m^{a,b}(x) = 0 \$

The `jacobi_zeros!` is the modifying version and the memory where the zeros
will be stored are preallocated. The non-modifying version, `jacobi_zeros`
allocates a the memory and calls the modifying version. The function `legendre_zeros`
compute the zeros of Legendre polynomials (`a = b = 0`)

Parameters:
 * `m` Order of polynomial
 * `alpha` Weight α of the Jacobi polynomial
 * `beta` Weight β of the Jacobi polynomial
 * `x` Place to store the zeros
 * `T` A float type to compute the zeros
 * returns: the array with zeros.

# Examples
```julia-repl
z = jacobi_zeros(7, 0.3, 0.2)
```
"""
function jacobi_zeros!(m, alpha, beta, x::AbstractArray{T}) where {T<:Number}

    o = one(T)
    z = zero(T)

    a = convert(T,alpha)
    b = convert(T,beta)

    MAXITER = 500
    EPS::T = 100 * eps1(T)
    local i; local k; local iter=0

    for k = 1:m
        # Initial guess.
        r = -cos( (2k-o)/(2*m) * pi)
        if (k > 1)
            r = (r + x[k-1]) / 2
        end
        iter = 0
        while(true)
            s = z
            for i = 1:(k-1)
                s += o/(r - x[i])
            end

            poly = jacobi(r, m, a, b)
            delta = -poly / (djacobi(r, m, a, b) - poly*s)

            r += delta
            iter += 1

            if iter > MAXITER
                throw("Program did not converge")
            end

            if abs(delta) < abs(EPS)
                break
            end
        end
        x[k] = r
    end

    return x

end



function jacobi_zeros(m, a, b, ::Type{T}=Float64) where {T<:Number}
    jacobi_zeros!(m, a, b, zeros(T,m))
end

jacobi_zeros(m) = jacobi_zeros(m, 0.0, 0.0)
jacobi_zeros(m, a) = jacobi_zeros(m, a, zero(a))

@doc (@doc jacobi) djacobi
@doc (@doc jacobi) djacobi!
@doc (@doc jacobi) jacobi!
@doc (@doc jacobi_zeros!) jacobi_zeros
