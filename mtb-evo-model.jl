using Agents
using Random, LinearAlgebra

@agent Mtb ContinuousAgent{2} begin
#	timer::Int

	repr_rate::Float64
#	mut_rate::Float64
#	rec_rate::Float64	
#	growth_rate::Float64
	death_rate::Float64
	transmit_rate::Float64

	loc::String
#	energy::Float64
#	size::Float64
end

function initialize_model(;
	# population-related parameters still need tuning
	init_popul = 1000,
	popul_limit = 500000,

#	timer = 0,

	repr_rate = 0, # probability of reproducing each frame
#	mut_rate = 5,
#	rec_rate = 5,
#	growth_rate = 5,
	death_rate = 0,
	transmit_rate = 30,
	loc = "bod",

	extent = (200, 200),
	seed = 42,
	dt = 1,
)
    space2d = ContinuousSpace(extent; spacing = 2, periodic = false)
    rng = Random.MersenneTwister(seed)

	properties = (
#		numEnv = 0,
#		numHum = 0,
		popul_limit = popul_limit,
		dt = dt,
	)

    model = ABM(Mtb, space2d; rng, properties)
    for _ in 1:init_popul
#        vel = Tuple(rand(model.rng, 2) * 0.1 .- 1)
	vel = (rand(-1:1), rand(-1:1)) .* 1
#	vel = sincos(2π * rand(model.rng)) .* 0.01
        add_agent!(
		model,
		vel,

		repr_rate,
#		mut_rate,
#		rec_rate,
#		growth_rate,
		death_rate,
		transmit_rate,
		loc,

#		energy,
#		size,
        )
    end
    return model
end

model = initialize_model()

function agent_step!(mtb, model)
	# how complex should the population growth be
	# - simple capped exponential growth
	#	- different growth and death rates for "human" and "environment" sections
	# - complex resource tracking 

	mtb.vel = (rand(-1:1), rand(-1:1)) .* rand(1:5)
	if mtb.pos[1] > 100 #

		# Reproduction and death rate on right half of screen (env), rates still need to be tuned
		mtb.repr_rate = 5
#		mtb.growth_rate = 1
		mtb.death_rate = 4

		# only let through midline transmite_rate% of the time
		if (mtb.vel[1] + mtb.pos[1] <= 100) && (rand(0:99) > mtb.transmit_rate)
			mtb.vel = (mtb.vel[1] * -1, mtb.vel[2]) # deflect agent if it would pass through the midline in the next frame if it loses transmit_rate dice roll
			mtb.loc = "bod"
		end
		
		move_agent!(mtb, model, 1)

		#Randomly kill based on death_rate
		if rand(0:99) < mtb.death_rate
			remove_agent!(mtb, model)
		#Randomly reproduce based on repr_rate
		elseif rand(0:99) < mtb.repr_rate * (1 - (nagents(model)/model.popul_limit))# && nagents(model) <= 1000000
			add_agent_pos!(Mtb(nextid(model), mtb.pos, (rand(-1:1), rand(-1:1)) .* 1, mtb.repr_rate, mtb.death_rate, mtb.transmit_rate, mtb.loc), model)
		end

	else
		# Reproduction and death rate on left half of screen (human), rates still need to be tuned
		mtb.repr_rate = 8
#		mtb.growth_rate = 5
		mtb.death_rate = 7

		if (mtb.vel[1] + mtb.pos[1] >= 100) && (rand(0:99) > mtb.transmit_rate)
			mtb.vel = (mtb.vel[1] * -1, mtb.vel[2])
			mtb.loc = "env"
		end

		move_agent!(mtb, model, 1)

		#Randomly kill based on death_rate
		if rand(0:99) < mtb.death_rate
			remove_agent!(mtb, model)
		#Randomly reproduce based on repr_rate
		elseif rand(0:99) < mtb.repr_rate * (1 - (nagents(model)/model.popul_limit)) # reproduction rate decreases as total agents in model get closer to popul_limit
			add_agent_pos!(Mtb(nextid(model), mtb.pos, (rand(-1:1), rand(-1:1)) .* 1, mtb.repr_rate, mtb.death_rate, mtb.transmit_rate, mtb.loc), model)
		end
	end
end

using CairoMakie

model = initialize_model()
figure = abmplot(model)
figure

abmvideo(
    "testing.mp4", model, agent_step!;
    framerate = 20, frames = 1000,
    title = "testing"
)


#=
using InteractiveDynamics
using CairoMakie

abmvideo(
    "testing.mp4",
    model,
    agent_step!,
    model_step!;
    title = "mtb",
    frames = 50,
    spf = 2,
    framerate = 25,
)=#
