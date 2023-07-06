"""
    CalcData
abstact type for electrical conductivity calculation.
"""
abstract type CalcData{S<:AC} end

"""
change precision of CalcData
"""
function setprecision! end
