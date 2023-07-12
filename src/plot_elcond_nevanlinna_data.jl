mutable struct CalcData{T<:Union{NevanlinnaRealData,PadeData}} 
    dir::String
    fnamereader::Reader
    temperature::Float64
    element::Union{String,Nothing}
    elcond_kwargs::Dict
    xdata::String
    ipdatas::Array{T}
    elcond_list::Array{Float64}
    N_imag_list::Array{Int64}
    fermi_energy::Float64
    function CalcData(dir,
                      expression,
                      temperature
                      ;
                      elcond_kwargs=Dict(),
                      xdata="mu", 
                      xdata_type = Float64,
                      element = nothing,
                      fermi_energy::Float64 = 0.0,
                      ac_type=NevanlinnaRealData,
                      merge_args = true,
                      show_information = true) #where {T<:Type}
        cdata = new{ac_type}()
        cdata.dir = dir
        cdata.fnamereader = Reader(dir,expression,Symbol(xdata),xdata_type)
        cdata.temperature = temperature
        cdata.element = element
        cdata.fermi_energy = fermi_energy 
        if merge_args == true
            elcond_kwargs = merge_elcond_kwargs!(cdata,elcond_kwargs)
        end
        cdata.elcond_kwargs = elcond_kwargs
        cdata.xdata = xdata
        cdata.N_imag_list = Int64[]
        get_information_from_files!(cdata)
        cal_static_conductivities!(cdata)
        cal_N_imags!(cdata)
        if show_information == true
            println(cdata)
        end
        cdata
    end
end

function Base.getproperty(cdata::CalcData,d::Symbol)
    if d === :files
        return cdata.fnamereader.file_list
    elseif d === :xdata_list
        println("xdata")
        println(Symbol(cdata.xdata))
        return cdata.fnamereader.data_list[Symbol(cdata.xdata)]# FixMe data_list is now dictionary
    elseif d === :beta
        1/(k_B_in_eV*cdata.temperature)
    else
        return Base.getfield(cdata, d)
    end
end

function Base.println(cdata::CalcData)
    for data in fieldnames(CalcData)
        field_value = getfield(cdata,data)
        if (typeof(field_value) <: Array) == true
            continue
        elseif typeof(field_value) == Reader
            continue
        else
            print(String(data))
            print(":")
            println(field_value)
        end
    end
end

function merge_elcond_kwargs!(cdata::CalcData{NevanlinnaRealData},elcond_kwargs)
    default_kwargs = Dict(:N_real => 2,
                          :omega_max_in_eV => 10^(-8), #10^(-6)
                          :eta => 10^(-8), #10^(-6)
                          :N_imag_reduce => 1)
    return merge(default_kwargs, elcond_kwargs)
end

"""
apply default setting for Pade interpolation.
"""
function merge_elcond_kwargs!(cdata::CalcData{PadeData},elcond_kwargs)
    default_kwargs = Dict(:statistics => "F",:N_imag_reduce => 1)
    elcond_kwargs = merge(default_kwargs,elcond_kwargs)
    pade_default_args = Dict(:real_mesh => collect(range(-10^(-8), 10^(-8); length=2)) .+ 1.0im*10^(-8))
    if haskey(elcond_kwargs,:pade_args) == true
        elcond_kwargs[:pade_args] = merge(pade_default_args, elcond_kwargs[:pade_args]) 
    else
        elcond_kwargs[:pade_kwargs] = pade_default_args               
    end
    return elcond_kwargs
end


"""
reset N_imag or N_imag_reduce and recalculate conductivities
"""
function reset_N_imag!(cdata::CalcData;N_imag::Union{Int64,Nothing}=nothing,N_imag_reduce::Union{Int64,Nothing}=nothing)
    if isnothing(N_imag) == false
        cdata.elcond_kwargs[:N_imag] = N_imag
    elseif isnothing(N_imag_reduce) == false
        cdata.elcond_kwargs[:N_imag] = 0
        cdata.elcond_kwargs[:N_imag_reduce] = N_imag_reduce
    else
        return 1
    end
    cal_static_conductivities!(cdata)
    cal_N_imags!(cdata)
    return 0
end

#when set precision, call this function!
function setprecision!(cdata::CalcData,precision)
    setprecision(precision)
    cdata = CalcData(cdata.dir,cdata.file_expression,cdata.temperature,
                    ;elcond_kwargs = cdata.elcond_kwargs,
                     xdata=cdata.xdata,
                     element = cdata.element,
                     fermi_energy = cdata.fermi_energy)
end
