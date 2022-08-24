using InteractiveFunction
using Documenter

DocMeta.setdocmeta!(InteractiveFunction, :DocTestSetup, :(using InteractiveFunction); recursive=true)

makedocs(;
    modules=[InteractiveFunction],
    authors="michikawa07 <michikawa.ryohei@gmail.com> and contributors",
    repo="https://github.com/michikawa07/InteractiveFunction.jl/blob/{commit}{path}#{line}",
    sitename="InteractiveFunction.jl",
    format=Documenter.HTML(;
        prettyurls=get(ENV, "CI", "false") == "true",
        canonical="https://michikawa07.github.io/InteractiveFunction.jl",
        edit_link="main",
        assets=String[],
    ),
    pages=[
        "Home" => "index.md",
    ],
)

deploydocs(;
    repo="github.com/michikawa07/InteractiveFunction.jl",
    devbranch="main",
)
