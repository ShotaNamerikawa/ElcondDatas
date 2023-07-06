function cal_static_conductivity_F(cdata::CalcDataPade,pade::PadeData)
    hbar_in_eV.*imag.(pade.interpolate_value).*tanh.(0.5*cdata.beta*real.(pade.interolate_arg))./real.(pade.interpolate_arg)
end

function cal_static_conductivity_B(pade::PadeData)
    hbar_in_eV.*imag.(pade.interpolate_value)./ real.(pade.interpolate_arg)
end

function cal_N_imags!(cdata::CalcData{Nevanlinna})
    cdata.N_imag_list = Int64[]
end