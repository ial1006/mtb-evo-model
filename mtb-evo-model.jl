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

#	energy::Float64
#	size::Float64
end

function initialize_model(;
	init_popul = 1000,
	popul_limit = 10000,

#	timer = 0,

	repr_rate = 0, # probability of reproducing each frame
#	mut_rate = 5,
#	rec_rate = 5,
#	growth_rate = 5,
	death_rate = 0,
	transmit_rate = 5,

	extent = (100, 100),
	seed = 42,
	dt = 1,
)
    space2d = ContinuousSpace(extent; spacing = 2, periodic = false)
    rng = Random.MersenneTwister(seed)

    model = ABM(Mtb, space2d; rng, scheduler = Schedulers.Randomly())
    for _ in 1:init_popul
#        vel = Tuple(rand(model.rng, 2) * 0.1 .- 1)
	vel = sincos(2π * rand(model.rng)) .* 0.01
        add_agent!(
		model,
		vel,

		repr_rate,
#		mut_rate,
#		rec_rate,
#		growth_rate,
		death_rate,
		transmit_rate,

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

	if mtb.pos[1] > 50
		mtb.repr_rate = 5
#		mtb.growth_rate = 1
		mtb.death_rate = 80

#		if (mtb.vel[1] + mtb.pos[1] <= 50) && (rand(0:99) > mtb.transmit_rate)
#			if (mtb.vel[1] - mtb.vel[1] >= 100)
#			move_agent!(mtb, (100, (mtb.pos[2] + mtb.vel[2])), model, 1)
#			move_agent!(mtb, (51., mtb.pos[2]), model)
#			else
#				move_agent!(mtb, (mtb.pos[1] - mtb.vel[1], mtb.pos[2] + mtb.vel[2]), model)
#			end
#		end

	else
		mtb.repr_rate = 80
#		mtb.growth_rate = 5
		mtb.death_rate = 5

#		if (mtb.vel[1] + mtb.pos[1] >= 50) && (rand(0:99) > mtb.transmit_rate)
#			if (mtb.vel[1] - mtb.vel[1] <= 0)
#			move_agent!(mtb, (0, (mtb.pos[2] + mtb.vel[2])), model, 1)
#			move_agent!(mtb, (50., mtb.pos[2]), model)
#			else
#				move_agent!(mtb, (mtb.pos[1] - mtb.vel[1], mtb.pos[2] + mtb.vel[2]), model)
#			end
#		end

	end


move_agent!(mtb, model)

	#Randomly kill based on death_rate
	if rand(0:99) < mtb.death_rate
		remove_agent!(mtb, model)
	#Randomly reproduce based on repr_rate
	elseif rand(0:99) < mtb.repr_rate && nagents(model) <= 10000
#			replicate!(mtb, model, 0, 0)
			add_agent_pos!(Mtb(nextid(model), mtb.pos, mtb.vel, mtb.repr_rate, mtb.death_rate, mtb.transmit_rate), model)
	end



#=
    # Obtain the ids of neighbors within the bacterium's visual distance
    neighbor_ids = nearby_ids(mtb, model, mtb.visual_distance)
    N = 0
    match = separate = cohere = (0.0, 0.0)
    # Calculate behaviour properties based on neighbors
    for id in neighbor_ids
        N += 1
        neighbor = model[id].pos
        heading = neighbor .- bird.pos

        # `cohere` computes the average position of neighboring birds
        cohere = cohere .+ heading
        if euclidean_distance(bird.pos, neighbor, model) < bird.separation
            # `separate` repels the bird away from neighboring birds
            separate = separate .- heading
        end
        # `match` computes the average trajectory of neighboring birds
        match = match .+ model[id].vel
    end
    N = max(N, 1)
    # Normalise results based on model input and neighbor count
    cohere = cohere ./ N .* bird.cohere_factor
    separate = separate ./ N .* bird.separate_factor
    match = match ./ N .* bird.match_factor
    # Compute velocity based on rules defined above
    bird.vel = (bird.vel .+ cohere .+ separate .+ match) ./ 2
    bird.vel = bird.vel ./ norm(bird.vel)
=#
    # Move bird according to new velocity and speed
end

using CairoMakie

const bird_polygon = Makie.Polygon(Point2f[(-1, -1), (1, 0), (-1, 1)])
function bird_marker(b::Mtb)
    φ = atan(b.vel[2], b.vel[1]) #+ π/2 + π
    rotate_polygon(bird_polygon, φ)
end

model = initialize_model()
figure, = abmplot(model; am = bird_marker)
figure

abmvideo(
    "testing.mp4", model, agent_step!;
    am = bird_marker,
    framerate = 20, frames = 2000,
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
