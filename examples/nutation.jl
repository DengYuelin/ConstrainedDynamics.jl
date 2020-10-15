using ConstrainedDynamics
using ConstrainedDynamicsVis
using LinearAlgebra


# Parameters
h = .1
r = 1.
b1 = Cylinder(r, h, h*r, color = RGBA(1., 0., 0.))

# Links
origin = Origin{Float64}()
link1 = Body(b1)

# Constraints
joint1 = EqualityConstraint(Floating(origin, link1))

links = [link1]
constraints = [joint1]
shapes = [b1]


mech = Mechanism(origin, links, constraints, g = 0., shapes = shapes)

axis = [0;0;1.]
speed = 20pi #*0
setVelocity!(link1, ω = speed*axis)

function controller!(mechanism, k)
    if k==1
        setForce!(mechanism.bodies[1], F = [0;0;2.], p=[0;1.;0])
    else
        setForce!(mechanism.bodies[1], F = [0;0;0.], p=[0;0.0;0])
    end
    return
end

storage = simulate!(mech, 10., controller!, record = true)
visualize(mech, storage, shapes)