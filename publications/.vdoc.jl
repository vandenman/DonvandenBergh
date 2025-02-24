#
#
#
#
#
#
#
#| echo: false
#| output: asis

# import Pkg
# Pkg.status()

import Markdown, Bibliography, BibInternal, DocumenterCitations

function comparer(x, y)

    submitted(x) && !submitted(y) && return true
    submitted(y) && !submitted(x) && return false
    inpress(x)   && !inpress(y)   && return true
    inpress(y)   && !inpress(x)   && return false

    xYear = parse(Int, get_year(x))
    yYear = parse(Int, get_year(y))
    return isless(yYear, xYear)
end

get_year(b)     = b.date.year
get_journal(b)  = b.in.journal

submitted(b)  = lowercase(get_journal(b)) == "manuscript submitted for publication"
inpress(b)    = lowercase(get_year(b))    == "in press"

get_split(b) = submitted(b) ? 3001 : inpress(b) ? 3000 : parse(Int, get_year(b))
format_header(i) = "## " * (i == 3001 ? "Submitted or under revision" : i == 3000 ? "In press" : string(i) )

function print_reference(b)
    pattern = r"(van[\s\u00A0]+den[\s\u00A0]+Bergh,\s*(?:D\.|Don))"
    # replace(DocumenterCitations.format_bibliography_reference(:authoryear, b), pattern => s"**\1**")
    # replace(
    #     DocumenterCitations.format_authoryear_bibliography_reference(
    #         :authoryear, b, article_link_doi_in_title = true
    #     ),
    #     pattern => s"**\1**",
    #     ';' => ','
    # )
    replace(

        DocumenterCitations.format_labeled_bibliography_reference(
            :alpha, b,
            namesfmt=:lastfirst,
            article_link_doi_in_title = true
        ),
        # change bold volume number into italic
        r"\*(\*.*\*)\*" => s"\1",
        # bold name
        pattern => s"**\1**",
        # replace semicolons into commas for author separators
        ';' => ','
    )
end

function main()
    bibfile = "myReferences.bib"
    bib_content = Bibliography.import_bibtex(bibfile)
    bib_values = collect(values(bib_content))

    sort!(bib_values, lt = comparer)

    # could also not allocate this one
    split_values = get_split.(bib_values)
    @assert issorted(split_values, rev = true)

    io = IOBuffer()

    iter = zip(bib_values, split_values)
    (b_first, s_prev), iter2 = Iterators.peel(iter)

    println(io, format_header(s_prev))
    # println(io, "\n<p>")
    # ref =
    println(io, print_reference(b_first))
    print(io, "\n\n\n")
    # println(io, "\n</p>")

    for (b, s) in iter2

        s != s_prev && println(io, format_header(s))
        # println(io, "\n<p>")
        # ref =
        println(io, print_reference(b))
        # println(io, "\n</p>")
        s_prev = s

        print(io, "\n\n\n")
    end

    str = String(take!(io))
    return Markdown.parse(str)
end

main()

#
#
#
#
