struct Quaternion{T <: Real} <: FieldVector{4,T}
    s::T
    v1::T
    v2::T
    v3::T
end

# Constructors
Quaternion(s::Real,v1::Real,v2::Real,v3::Real) = Quaternion(promote(s, v1, v2, v3)...)
Quaternion(s::Real) = Quaternion(s, 0, 0, 0)
Quaternion(v::Vector) = (@assert length(v)==3; Quaternion(0, v[1], v[2], v[3]))
Quaternion(s::T,v::Vector{T}) where T = (@assert length(v)==3; Quaternion(s, v[1], v[2], v[3]))
Quaternion(v::SVector{3,T}) where T = Quaternion(0, v[1], v[2], v[3])
Quaternion(s::T,v::SVector{3,T}) where T = Quaternion(s, v[1], v[2], v[3])
Quaternion(R::Rotation) = (q = UnitQuaternion(R); Quaternion(q.w, q.x, q.y, q.z))
Quaternion{T}() where T = Quaternion{T}(1, 0, 0, 0)

# Basic quaternion operations
LinearAlgebra.real(q::Quaternion) = q[1]
LinearAlgebra.imag(q::Quaternion) = q[SUnitRange(2, 4)]

LinearAlgebra.conj(q::Quaternion) = Quaternion(q.s, -q.v1, -q.v2, -q.v3)
Base.abs(q::Quaternion) = sqrt(q.s * q.s + q.v1 * q.v1 + q.v2 * q.v2 + q.v3 * q.v3)
Base.abs2(q::Quaternion) = q.s * q.s + q.v1 * q.v1 + q.v2 * q.v2 + q.v3 * q.v3
Base.inv(q::Quaternion) = conj(q)

Base.:*(q1::Quaternion, q2::Quaternion) = Quaternion(  q1.s * q2.s - q1.v1 * q2.v1 - q1.v2 * q2.v2 - q1.v3 * q2.v3,
                                                       q1.s * q2.v1 + q1.v1 * q2.s + q1.v2 * q2.v3 - q1.v3 * q2.v2,
                                                       q1.s * q2.v2 - q1.v1 * q2.v3 + q1.v2 * q2.s + q1.v3 * q2.v1,
                                                       q1.s * q2.v3 + q1.v1 * q2.v2 - q1.v2 * q2.v1 + q1.v3 * q2.s)
Base.:*(q::Quaternion, x::Number) = Quaternion(q.s * x, q.v1 * x, q.v2 * x, q.v3 * x)
Base.:*(x::Number, q::Quaternion) = q * x

Base.:/(q1::Quaternion, q2::Quaternion) = q1 * inv(q2)
Base.:\(q1::Quaternion, q2::Quaternion) = inv(q1) * q2

Base.:-(q::Quaternion) = Quaternion(-q.s,-q.v1,-q.v2,-q.v3)

angleaxis(q::Quaternion) = angle(q), axis(q)
angle(q::Quaternion) = 2 * atan(sqrt(q.v1^2 + q.v2^2 + q.v3^2), q.s) # This is the rotation angle φ (φ = 2θ)
function axis(q::Quaternion{T}) where T
    qv = SVector(q.v1, q.v2, q.v3)
    if norm(qv) == 0
        return SVector{3,T}(0, 0, 0)
    else 
        return qv / norm(qv)
    end
end

qrotate(x::Quaternion,q::Quaternion) = q * x / q
vrotate(x::AbstractVector,q::Quaternion) = imag(qrotate(Quaternion(x), q))

# Matrix equivalences
# 𝟙(::Type{T}) where T = Quaternion(one(T))
# 𝟙() = 𝟙(Float64)
Vmat(::Type{T}) where T = SMatrix{3,4,T,12}(0, 0, 0, 1, 0, 0, 0, 1, 0, 0, 0, 1)
Vmat() = Vmat(Float64)
Vmat(q::SVector) = q[SUnitRange(2, 4)]
Vmat(A::SMatrix) = A[SUnitRange(2, 4),:]
Vmat(q::Quaternion) = imag(q)
Vᵀmat(::Type{T}) where T = SMatrix{4,3,T,12}(0, 1, 0, 0, 0, 0, 1, 0, 0, 0, 0, 1)
Vᵀmat() = Vᵀmat(Float64)
Tmat(::Type{T}) where T = SMatrix{4,4,T,16}(1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1, 0, 0, 0, 0, -1)
Tmat() = Tmat(Float64)

Lmat(q::Quaternion{T}) where T = SMatrix{4,4,T,16}(q.s, q.v1, q.v2, q.v3, -q.v1, q.s, q.v3, -q.v2, -q.v2, -q.v3, q.s, q.v1, -q.v3, q.v2, -q.v1, q.s)
Lᵀmat(q::Quaternion) = Lmat(q)'
Rmat(q::Quaternion{T})  where T = SMatrix{4,4,T,16}(q.s, q.v1, q.v2, q.v3, -q.v1, q.s, -q.v3, q.v2, -q.v2, q.v3, q.s, -q.v1, -q.v3, -q.v2, q.v1, q.s)
Rᵀmat(q::Quaternion) = Rmat(q)'

VLmat(q::Quaternion{T}) where T = SMatrix{3,4,T,12}(q.v1, q.v2, q.v3, q.s, q.v3, -q.v2, -q.v3, q.s, q.v1, q.v2, -q.v1, q.s)
VLᵀmat(q::Quaternion{T}) where T = SMatrix{3,4,T,12}(-q.v1, -q.v2, -q.v3, q.s, -q.v3, q.v2, q.v3, q.s, -q.v1, -q.v2, q.v1, q.s)
VRmat(q::Quaternion{T})  where T = SMatrix{3,4,T,12}(q.v1, q.v2, q.v3, q.s, -q.v3, q.v2, q.v3, q.s, -q.v1, -q.v2, q.v1, q.s)
VRᵀmat(q::Quaternion{T})  where T = SMatrix{3,4,T,12}(-q.v1, -q.v2, -q.v3, q.s, q.v3, -q.v2, -q.v3, q.s, q.v1, q.v2, -q.v1, q.s)

LVᵀmat(q::Quaternion{T}) where T = SMatrix{4,3,T,12}(-q.v1, q.s, q.v3, -q.v2, -q.v2, -q.v3, q.s, q.v1, -q.v3, q.v2, -q.v1, q.s)
LᵀVᵀmat(q::Quaternion{T}) where T = SMatrix{4,3,T,12}(q.v1, q.s, -q.v3, q.v2, q.v2, q.v3, q.s, -q.v1, q.v3, -q.v2, q.v1, q.s)
RVᵀmat(q::Quaternion{T}) where T = SMatrix{4,3,T,12}(-q.v1, q.s, -q.v3, q.v2, -q.v2, q.v3, q.s, -q.v1, -q.v3, -q.v2, q.v1, q.s)
RᵀVᵀmat(q::Quaternion{T}) where T = SMatrix{4,3,T,12}(q.v1, q.s, q.v3, -q.v2, q.v2, -q.v3, q.s, q.v1, q.v3, q.v2, -q.v1, q.s)

skewplusdiag(v::AbstractVector{T},w::T) where T = SMatrix{3,3,T,9}(w, v[3], -v[2], -v[3], w, v[1], v[2], -v[1], w)

function slerp(q1,q2,h)
    s = q1'*q2
    if s < 0
        s = -s
        q2 = -q2
    end

    qdiff = q1\q2
    φdiff, udiff = angleaxis(qdiff)
    φint = φdiff*h
    qint = Quaternion(cos(φint/2),udiff*sin(φint/2))
    
    return q1*qint
end