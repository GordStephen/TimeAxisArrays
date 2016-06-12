using Documenter, TimeAxisArrays

makedocs(
    modules = [TimeAxisArrays]
)

deploydocs(
    deps   = Deps.pip("mkdocs", "python-markdown-math"),
    repo   = "github.com/GordStephen/TimeAxisArrays.jl.git",
    julia  = "0.4",
    osname = "linux"
)
