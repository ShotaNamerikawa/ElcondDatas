mutable struct CalcDataPade
    dir::String
    fnamereader::Reader
    temperature::Float64
    element::Union{String,Nothing}
    elcond_kwargs::Dict
    xdata::String
    padedatas::Array{PadeData}
    elcond_list::Array{Float64}
    N_imag_list::Array{Int64}
    fermi_energy::Float64
    function CalcData(dir,
        expression,
        temperature
        ;
        elcond_kwargs=Dict(),
        xdata="mu",
        xdata_type=Float64,
        element=nothing,
        fermi_energy::Float64=0.0) 
        cdata = new()
        cdata.dir = dir
        cdata.fnamereader = Reader(dir, expression, Symbol(xdata), xdata_type)
        cdata.temperature = temperature
        cdata.element = element
        cdata.fermi_energy = fermi_energy
        default_kwargs = Dict(:N_real => 2,
                              :omega_max_in_eV => 0.00001, #10^(-6)
                              :eta => 0.000001, #10^(-6)
                              :N_imag_reduce => 1)
        cdata.elcond_kwargs = merge(default_kwargs, elcond_kwargs)
        cdata.xdata = xdata
        get_information_from_files!(cdata)
        cal_static_conductivities!(cdata)
        cal_N_imags!(cdata)
        cdata
    end
end