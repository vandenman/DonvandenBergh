import Markdown, Bibliography, DocumenterCitations, Dates

function comparer(x, y)

    submitted(x) && !submitted(y) && return true
    submitted(y) && !submitted(x) && return false
    inpress(x)   && !inpress(y)   && return true
    inpress(y)   && !inpress(x)   && return false

    xYear = parse(Int, get_year(x))
    yYear = parse(Int, get_year(y))

    xMonth = get_month(x)
    yMonth = get_month(y)

    if xYear == yYear
        # we intentionally reverse the order here, so that higher months come first, as they are more recent
        return isless(xMonth, yMonth)
    end

    return isless(yYear, xYear)
end

get_year(b)     = b.date.year
get_journal(b)  = b.in.journal
function get_month(b)
    (isnothing(b.date.month) || isempty(b.date.month)) && return 12

    m = b.date.month
    if all(isdigit, m)
        result = tryparse(Int, m)
        !isnothing(result) && return result
    end

    m = lowercase(m)
    for i in 1:12
        m == lowercase.(Dates.monthname(i)) && return i
        m == lowercase.(Dates.monthabbr(i)) && return i
    end
    return 12
end

submitted(b)  = lowercase(get_journal(b)) == "manuscript submitted for publication"
inpress(b)    = lowercase(get_year(b))    == "in press"

get_split(b) = submitted(b) ? 3001 : inpress(b) ? 3000 : parse(Int, get_year(b))
format_header(i) = "## " * (i == 3001 ? "Submitted or under revision" : i == 3000 ? "In press" : string(i) )

function print_reference(b)
    pattern = r"(van[\s\u00A0]+den[\s\u00A0]+Bergh,\s*(?:D\.|Don))"
    replace(DocumenterCitations.format_authoryear_bibliography_reference(:authoryear, b, article_link_doi_in_title = true), pattern => s"**\1**")
end

function main()
    bibfile = "publications/myReferences.bib"
    bib_content = Bibliography.import_bibtex(bibfile)
    bib_values = collect(values(bib_content))
    # b = popfirst!(bib_values)

    sort!(bib_values, lt = comparer)

    # TODO: need to update the months... in the bibtex file.
    # twice, once when it's online, and once more when it's officialy published.

    # bib_values[3].title
    # bib_values[3].date.month
    # bib_values[4].date.month
    # bib_values[5].date.month

    # origName1 = BibInternal.Name("{van den", "Bergh}", "", "Don",  "")
    # origName2 = BibInternal.Name("{van den", "Bergh}", "", "D.",   "")
    # newName   = BibInternal.Name("**van den**", "**Bergh**", "", "**D.**", "")
    # foreach(bib_values) do b
    #     replace!(b.authors, origName1 => newName, origName2 => newName)
    # end

    # b = bib_content["Guillaume2019Outcome"]
    # b.authors
    # DocumenterCitations.format_bibliography_reference(:authoryear, b)

    # b.authors
    # replace!(b.authors, origName1 => newName, origName2 => newName)
    # str = DocumenterCitations.format_bibliography_reference(:authoryear, b)
    # Markdown.parse(str)

    # could also not allocate this one
    split_values = get_split.(bib_values)
    @assert issorted(split_values, rev = true)
    # u_split_values = unique(split_values)

    # index_split = indexin(split_values, u_split_values)
    # u_index_split = unique(index_split)

    io = IOBuffer()

    iter = zip(bib_values, split_values)
    (b_first, s_prev), iter_rem = Iterators.peel(iter)


    println(io, format_header(s_prev))
    println(io, print_reference(b_first))
    for (b, s) in iter_rem

        # @show b, s, s_prev

        s != s_prev && println(io, format_header(s))
        println(io, print_reference(b))
        s_prev = s

        print(io, "\n\n\n")

    end

    str = String(take!(io))
    return Markdown.parse(str)
    # return Markdown.html(Markdown.parse(str))
end

main()

# test_path = joinpath(dirname(dirname(pathof(DocumenterCitations))), "test/test_formatting/preprints.bib")
# bib = DocumenterCitations.CitationBibliography(test_path)
# b = first(values(bib.entries))
# DocumenterCitations.format_published_in(b) # doi
# DocumenterCitations.format_published_in(b, article_link_doi_in_title = true) # no doi

# DocumenterCitations.format_authoryear_bibliography_reference(:authoryear, b) # doi around journal
# DocumenterCitations.format_authoryear_bibliography_reference(:authoryear, b, article_link_doi_in_title = true) # doi around journal and title
