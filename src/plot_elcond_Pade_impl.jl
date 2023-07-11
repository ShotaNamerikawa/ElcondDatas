function min_ind_cal(pdata::PadeData)
    min_ind = argmin(abs.(real.(pdata.interpolate_arg)))
    if in(0.0, pdata.interpolate_arg) == true
        min_ind += 1
    end
    min_ind
end

function cal_opt_conductivity_F(cdata::CalcData{PadeData},pade::PadeData)
    -hbar_in_eV.*imag.(pade.interpolate_value).*tanh.(0.5*cdata.beta*real.(pade.interpolate_arg))./real.(pade.interpolate_arg)
end

"""
Static conductivity is calculated from optical conductity whose frequency is nearest to origin!
"""
function cal_static_conductivity_F(cdata::CalcData{PadeData}, pade::PadeData)
    min_ind = min_ind_cal(pade)
    cal_opt_conductivity_F(cdata,pade)[min_ind]
end

function cal_opt_conductivity_B(pade::PadeData)
    hbar_in_eV.*imag.(pade.interpolate_value)./ real.(pade.interpolate_arg)
end

function cal_static_conductivity_B(pade::PadeData)
    min_ind = min_ind_cal(pade)
    return cal_opt_conductivity_B(pade)[min_ind]
end

function cal_static_conductivities!(cdata::CalcData{PadeData})
    cdata.elcond_list = Float64[]
    if cdata.elcond_kwargs[:statistics] == "F"
        for padedata in cdata.ipdatas
            elcond = cal_static_conductivity_F(cdata,padedata)
            append!(cdata.elcond_list, elcond)
        end
    elseif cdata.elcond_kwargs[:statistics] == "B"
        for padedata in cdata.ipdatas
            elcond = cal_static_conductivity_B(padedata)
            append!(cdata.elcond_list, elcond)
        end
    end
end

function cal_N_imags!(cdata::CalcData{PadeData})
    return nothing
end
