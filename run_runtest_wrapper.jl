# Wrapper to include the repository's runtest.jl explicitly
f = raw"d:\2_Study\2_Study Abroad\Master\KLU\Courses\Scientific Programming\Git_clone_Retail_Fashion_Boutique\Dynamic-Pricing-Optimization-for-Retail-Fashion-1\runtest.jl"
println("Including: ", f)
println(read(f, String)[1:min(end, 600)])
include(f)
