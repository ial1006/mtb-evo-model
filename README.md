# mtb-evo-model
This contains an attempt to model the evolution of the evolvability of *Mycobacterium tuberculosis*.

# First batch of things to do: population with fixed parameters
1. Implement population of cells with logistic growth (equal fitness)
2. Implement bacteria moving from one subpopulation to another at a fixed rate for each cell
3. Implement bacteria moving between different types of subpopulations (environmental or host) with different growth parameters
4. Test what the equilibria look like

# Second batch of things to do: fitness genes
5. Add different growth rates inside hosts based on virulence genes
6. Add different growth rates outside hosts based on environmental adaptation genes
7. Add different rates of transfer to another host based on infectivity genes

# Third batch of things to do: ecological context
8. Test what the equilibria look like across initially mixed populations, see if optimum growth rates in hosts prevail
9. Make fitness payoffs context frequency dependent
10. Make fitness payoffs change periodically
   
# Fourth batch of things to do: mutability
11. Add a fixed mutation rate for the probability of a genotype changing
12. Add a fixed recombination for the probability to acquiring a neighboring genotype for each locus
13. Test population equilibria across a range of mutation and recombination rates
14. Adjust increment/decrement values as needed

# Fifth batch of things to do: evolvability
15. Make the mutation rate dynamic, based on its own gene
16. Make the recombination rate dynamic, based on its own gene
17. See if these rates evolve to more optimal values based on **13**
