"""
    CalcData
abstact type for electrical conductivity calculation.
"""
abstract type AbstractCalcData end

"""
change precision of CalcData
"""
function setprecision! end
