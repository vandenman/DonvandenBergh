#=

    TODO:
        - order references by submitted, in press, 2020, 2019, 2018, ...
        - include paragraphs inbetween years
        - create method called find firsttwo (or find first n?)
        - only add . at the end if there is none.

    sidequests:
        - write tests
        - make the first const variables arguments to main?
        - error handling for nonexistent files?
        - create module + post on github?

    Long term:
        - read arbitrary bibtex file and filter on authors
        - skip bibtex2html and just parse the bibtex file instead?

=#

const bibfile   = "myReferences.bib"
const outfile   = "referenceList.html"

const path = joinpath(pwd(), "bibtexGenerator")
const destfile = joinpath(pwd(), "_includes", outfile)

# if isdir("/home/don")
#     const path      = "/home/don/surfdrive/PhD/Utilities/bib/"
#     const destfile  = "/home/don/github/DonvandenBergh/Publications/" * outfile
# else
#     const path      = "/home/dvdb/ownCloud/PhD/Utilities/bib/"
#     const destfile  = "/home/dvdb/github/DonvandenBergh/Publications/" * outfile
# end
cd(path)

const stem = splitext(bibfile)[1]
const htmlfile = stem * ".html"

function compileReferencesToHtml()
    run(`bibtex2html -nokeys --nobibsource -f psyarxiv -nf psyarxiv "PsyArXiv" -o $stem -s apa -nodoc -q $bibfile`)
end

function getHtmlFile()
    cd(compileReferencesToHtml, path)
    html = read("myReferences.html", String)
    # delete the start and end
    start = findfirst("<p>", html)
    tail = findlast("<hr>", html)
    # -1 since otherwise the < from <hr> is included
    return html[start[1]:(tail[1]-1)]
end

# TODO: there may be a better (platform independent) version than using \n
@inline splitReferences(html) = eachmatch(r"<p>(.|\n)*?<\/p>", html)

function getBibTexKey(s)
    i1 = findfirst("\"", s)
    i2 = findfirst("\"", s[(i1[1]+1):end])
    return s[i1[1]:(i1[1]+1 + i2[1])]
end

function removeNewLines(s)
    return replace(s, r"\s\s+" => " ")
end
# removeNewLines(" data\n  with")

function getYear(s)
    # @show s
    i1 = findfirst('(', s)
    i2 = findfirst(')', s)
    year = SubString(s, (i1+1), (i2-1))
    year = removeNewLines(year)
    if last(year) in 'a':'z' && lowercase(year) != "in press"
        return chop(year)
    end
    return year
    # match(r"(?<=\().+?(?=\))", s).match
end

function getAuthors(s)

    #string(match(r"^[^\(]+", s).match
    # get the second ", which ends the bibtexKey"
    start1 = findfirst("\"", s)
    start2 = findfirst("\"", s[(start1[1]+1):end])

    # +5 to be after ><\a>
    i0 = start1[1] + 1 + start2[1] + 5
    i1 = findfirst("(", s)[1] - 1

    snew = strip(s[i0:i1])
    return replace(snew, "&nbsp;" => " ")
end

function getJournal(s)
    i1 = findfirst("<em>", s)
    i2 = findfirst("</em>", s)
    if i1 === nothing || i2 === nothing
        return nothing
    end
    return s[(i1[2]+3):(i2[1]-1)]
end

function getTitle(s)
    i1 = findfirst(").", s)
    i2 = findfirst("<em>", s)
    return removeNewLines(strip(s[i1[2]+1 : i2[1] - 1]))
end

function getUrl(s)

    i0 = findfirst("href=\"", s)
    (i0 === nothing || length(i0) < 2) && return nothing, nothing
    i1 = findfirst(">", s[i0[2]:end])
    i1 === nothing && return nothing, nothing

    r = (i0[2]+5) : (i0[2]+i1[1]-3)
    url = s[r]

    i2 = findfirst("<", s[r[2]:end])
    i3 = findfirst(">", s[i2[1]:end])
    if i2 === nothing || i3 === nothing
        urlType = nothing
    else
        urlType = s[(i2[1]):(i2[1]+i3[1])]
    end

    return url, urlType
end

function printTypes()
    html = getHtmlFile()
    it = splitReferences(html)

    for i in it
        s = i.match
        println(i.match * "\n")
        year = getYear(i.match)
        println("the year is:\n$year")
        key = getBibTexKey(i.match)
        println("bibtexKey is:\n$key")
        authors = getAuthors(i.match)
        println("the authors are:\n$authors")
        journal = getJournal(i.match)
        if journal !== nothing
            println("the journal is:\n$journal")
        else
            println("no journal")
        end
        url, urlType = getUrl(s)
        println("the url is $url of type $urlType")

        print("\n")
    end
end

function getReferencesFromHtml(html)
    it = splitReferences(html)
    references = Vector{Reference}()
    for i in it
        try
            ref = Reference(i.match)
            push!(references, ref)
        catch e
            println("An error occured with reference:")
            @show i.match
            throw(e)
        end
    end
    return references
end

# what types to use? AbstractString? Parametric types?
struct Reference
    authors     ::String
    year        ::String
    journal     ::String
    title       ::String
    url         ::Union{String, Nothing}
    urlType     ::Union{String, Nothing}
    bibtexId    ::String
    submitted   ::Bool
    inpress     ::Bool

    function Reference(s::AbstractString)

        year = getYear(s)
        isnothing(year) && throw(DomainError(s, "No journal in bibtex entry!"))
        journal = getJournal(s)
        isnothing(journal) && throw(DomainError(s, "No journal in bibtex entry!"))
        url, urlType = getUrl(s)

        new(
            getAuthors(s),
            year,
            journal,
            getTitle(s),
            url,
            urlType,
            getBibTexKey(s),
            lowercase(journal) == "manuscript submitted for publication",
            lowercase(year) == "in press"
        )
    end
end

function Base.show(io::IO, ref::Reference)
    print(io, refToHtml(ref))
end
hasUrl(ref::Reference) = ref.url !== nothing

function refToHtml(ref::Reference, boldAuthors = nothing)

    if (boldAuthors === nothing)
        authors = ref.authors
    else
        authors = makeAuthorsBold(ref.authors, boldAuthors)
    end

    if hasUrl(ref)
        return "$(authors) ($(ref.year)). &nbsp;<a href=\"$(ref.url)\">$(ref.title)</a>&nbsp; <em>$(ref.journal)</em>."
    else
        return "$(authors) ($(ref.year)). $(ref.title) <em>$(ref.journal)</em>."
    end
end

function makeAuthorsBold(authors::String, toBold::String)
    newBold = "<strong>$toBold</strong>"
    return replace(authors, toBold => newBold)
end

function Base.isless(x::Reference, y::Reference)

    x.submitted && return true
    y.submitted && return false
    x.inpress   && return true
    y.inpress   && return false

    xYear = parse(Int, x.year)
    yYear = parse(Int, y.year)
    return isless(yYear, xYear)

end

function paragraphTitle(ref::Reference)
    if ref.submitted
        base = "Submitted or under revision"
    elseif ref.inpress
        base = "In press"
    else
        base = ref.year
    end
    return  "<hr>\n<h3>" * base * "</h3>\n"
end

function joinAndAddParagraphs(cleanStrings::Vector{String}, references::Vector{Reference})
    refList = string()
    currentPtitle = paragraphTitle(references[1])
    for (i, str) in enumerate(cleanStrings)

        if (i == 1)
            refList *= currentPtitle
        end

        newPtitle = paragraphTitle(references[i])
        if  newPtitle != currentPtitle
            currentPtitle = newPtitle
            refList *= currentPtitle
        end

        refList *= "<p>\n" * cleanStrings[i] * "\n</p>\n"
    end
    return refList * "<hr>"
end

function main()
    html = getHtmlFile()
    references = getReferencesFromHtml(html)
    sort!(references)
    cleanStrings = refToHtml.(references, "van den Bergh, D.")
    refList = joinAndAddParagraphs(cleanStrings, references)

    write(outfile, refList)
    cp(outfile, destfile; force=true)
end
main()

# bundle exec jekyll serve
