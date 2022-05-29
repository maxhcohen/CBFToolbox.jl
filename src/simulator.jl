struct Simulator
    x0
    t0
    dt
    tf
    ts
end

Simulator(x0) = Simulator(x0, 0.0, 0.01, 10.0, 0.0:0.01:10.0)
Simulator(x0, tf) = Simulator(x0, 0.0, 0.01, tf, 0.0:0.01:tf)
Simulator(x0, dt, tf) = Simulator(x0, 0.0, dt, tf, 0.0:dt:tf)

function (sim::Simulator)(Σ::ControlAffineSystem)
    trajectory = simulate(Σ, sim.x0, [sim.t0, sim.tf])

    return trajectory
end

Base.length(sim::Simulator) = length(sim.ts)

function (sim::Simulator)(Σ::ControlAffineSystem, k::FeedbackController)
    rhs(x, p, t) = _f(Σ, x) + _g(Σ, x)*k(x)
    prob = ODEProblem(rhs, sim.x0, [sim.t0, sim.tf])
    sol = solve(prob, Tsit5())

    return sol
end

function (sim::Simulator)(Σ::ControlAffineSystem, k::Union{CLFController, CBFController, CBFCLFController})
    rhs(x, p, t) = _f(Σ, x) + _g(Σ, x)*k(Σ, x)
    prob = ODEProblem(rhs, sim.x0, [sim.t0, sim.tf])
    sol = solve(prob, Tsit5())

    return sol
end

function (sim::Simulator)(Σ::ControlAffineSystem, k::CBFController, k0::CLFController)
    rhs(x, p, t) = _f(Σ, x) + _g(Σ, x)*k(Σ, x, k0(Σ, x))
    prob = ODEProblem(rhs, sim.x0, [sim.t0, sim.tf])
    sol = solve(prob, Tsit5())

    return sol
end

function (sim::Simulator)(Σ::ControlAffineSystem, k0::CLFController, k::CBFController)
    rhs(x, p, t) = _f(Σ, x) + _g(Σ, x)*k(Σ, x, k0(Σ, x))
    prob = ODEProblem(rhs, sim.x0, [sim.t0, sim.tf])
    sol = solve(prob, Tsit5())

    return sol
end