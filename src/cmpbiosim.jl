using ArgParse
using DataFrames
using PyPlot

function parse_commandline()
    s = ArgParseSettings()

    @add_arg_table s begin
        "--bio"
            help = "Biological csv file."
            required = true
        "--sim"
            help = "Simulated csv file."
            required = true
        "--bioelectrode"
            help = "Bio electrode."
            required = true
            arg_type = Int
        "--biounit"
            help = "Bio unit."
            required = true
            arg_type = Int
        "--simcell"
            help = "Simulated cell."
            required = true
            arg_type = Int
        "--simtype"
            help = "Simulated type."
            required = true
            arg_type = Int
    end

    return parse_args(s)
end

function plot_spike_rasters(biodatafile, simdatafile, bio_electrode, bio_unit, sim_cell, sim_type)
    # Read CSV data
    biodata = readtable(biodatafile)
    simdata = readtable(simdatafile)
    biodata = groupby(biodata, [:Electrode, :Unit])
    simdata = groupby(simdata, [:Cell, :Type])

    # Get spikes of bio cell
    biocellspikes = []
    for g in biodata
        if g[:Electrode][1] == bio_electrode && g[:Unit][1] == bio_unit
            biocellspikes = Array(g[:Spikes])
            break
        end
    end

    # Get spikes of simulated cell
    simcellspikes = []
    for g in simdata
        if g[:Cell][1] == sim_cell && g[:Type][1] == sim_type
            simcellspikes = Array(g[:Time]) * 1000.0  # From s to ms
            break
        end
    end

    # Plot
    scatter(biocellspikes, ones(length(biocellspikes)) + 0.0, s=3)
    scatter(simcellspikes, ones(length(simcellspikes)) + 0.1, s=3)
    show()
end

function main()
    println("Utility to compare spike rasters.")

    # Parse commands
    parsed_args = parse_commandline()
    println("Parsed args:")
    for (arg,val) in parsed_args
        println("> $arg  =>  $val")
    end

    # Plot spike rasters
    plot_spike_rasters(parsed_args["bio"],
                       parsed_args["sim"], 
                       parsed_args["bioelectrode"],
                       parsed_args["biounit"],
                       parsed_args["simcell"],
                       parsed_args["simtype"])
end

main()

