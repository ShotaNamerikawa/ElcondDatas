function get_data_from_file!(cdata::CalcData{NevanlinnaRealData}, file::String)
    file = joinpath([cdata.dir, file])
    nev_data = NevanlinnaRealData(cdata.temperature,
                file
                ;
                cdata.elcond_kwargs...)
    push!(cdata.ipdatas, nev_data)
end

function get_data_from_file!(cdata::CalcData{PadeData}, file::String)
    file = joinpath([cdata.dir, file])
    padedata = Pade.read_file(file,cdata.elcond_kwargs[:pade_args][:real_mesh];positive_only = true)
    N_imag_reduce = haskey(cdata.elcond_kwargs, :N_imag_reduce) ? cdata.elcond_kwargs[:N_imag_reduce] : 0
    if cdata.elcond_kwargs[:statistics] == "F"
        if haskey(cdata.elcond_kwargs,:Pick_condition) && cdata.elcond_kwargs[:Pick_condition] == true 
            Pick_num = Pade.apply_Pick_condition_Fermi!(padedata; N_imag_reduce=N_imag_reduce)
            push!(cdata.N_imag_list, Pick_num - N_imag_reduce)
        end
        #particle hole symmetry
        if haskey(cdata.elcond_kwargs, :ph_symmetry) && cdata.elcond_kwargs[:ph_symmetry] == true
            println("ph symmery is imposed to sample value!")
            padedata.sample_value = 1.0im*imag.(padedata.sample_value)
        end
    else cdata.elcond_kwargs[:statistics] == "B"
        padedata.sample_value = -padedata.sample_value #input value is minus correlation function for Boson!  
        #particle hole symmetry
        if haskey(cdata.elcond_kwargs, :ph_symmetry) && cdata.elcond_kwargs[:ph_symmetry] == true
            println("ph symmery is imposed to sample value!")
            padedata.sample_value = real.(padedata.sample_value)
        end
    end
    push!(cdata.ipdatas, padedata)
end

function get_information_from_files!(cdata::CalcData{T}) where {T <: Union{NevanlinnaRealData, PadeData}}
    cdata.ipdatas = T[]
    for file in cdata.files
        get_data_from_file!(cdata, file)
    end
end
