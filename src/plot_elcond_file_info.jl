function get_nevanlinna_data_from_file!(cdata::CalcData, file::String)
    file = joinpath([cdata.dir, file])
    nevan = NevanlinnaRealData(cdata.temperature,
        file
        ;
        cdata.elcond_kwargs...)
    push!(cdata.ndatas, nevan)
end

function get_information_from_files!(cdata::CalcData)
    cdata.ndatas = NevanlinnaRealData[]
    for file in cdata.files
        get_nevanlinna_data_from_file!(cdata, file)
    end
end