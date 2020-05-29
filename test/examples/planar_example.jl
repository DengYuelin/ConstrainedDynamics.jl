using ConstrainedDynamics


# Parameters
ex = [1.;0.;0.]
ey = [0.;1.;0.]
ez = [0.;0.;1.]

l1 = 1.0
x, y = .1, .1
b1 = Box(x, l1, y, l1, color = RGBA(1., 1., 0.))

vert11 = [0.;l1 / 2;0.]
vert12 = -vert11

# Initial orientation
phi1, phi2, phi3 = 0., 2pi / 3, 4pi / 3
q1, q2, q3 = Quaternion(RotZ(phi1)), Quaternion(RotZ(phi2)), Quaternion(RotZ(phi3))

# Links
origin = Origin{Float64}()
link1 = Body(b1)
link2 = deepcopy(link1, b1)

# Constraints
joint0to123 = EqualityConstraint(Planar(origin, link1, zeros(3), vert12, ez), Planar(origin, link2, zeros(3), vert12, ez))
joint1to23 = EqualityConstraint(Spherical(link1, link2, vert11, vert11))



links = [link1; link2]
constraints = [joint0to123;joint1to23]
shapes = [b1]

mech = Mechanism(origin, links, constraints, shapes = shapes)
setPosition!(origin,link1,p2 = vert11,Δq = q1)
setPosition!(origin,link2,p2 = vert11,Δq = q2)