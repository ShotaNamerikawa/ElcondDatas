module ElcondDatas
using NevanlinnaCalc
using Plots
default(legend=false)
using Printf
using LaTeXStrings
using DelimitedFiles
#using TOML
using Parameters
export CalcData,calc_all_process,plot_elcond,export_data,export_all
export compare_N_imag, data_N_imag, generate_ydata, setprecision!
include("plot_elcond_nevanlinna_data.jl")
include("plot_elcond_nevanlinna_impl.jl")
include("plot_elcond_nevanlinna_compare_N_imag.jl")
include("plot_elcond_nevanlinna_result_export.jl")
include("plot_elcond_nevanlinna_post.jl")
end
