#' Make Zotero API request
#'
#' Fetch data from Zotero using API ver. 3. If the result is broken into
#' multiple parts, multiple requests are made to fetch everything.
#'
#' @param base_url API URL
#' @param path,query passed to [modify_url()]
#' @param user object returned by [zotero_user_id()] or [zotero_group_id()]
#' @param ... For [zotero_api()] passed to [httr::GET()].
#'
#' @details
#' The `user` argument expects Zotero user or group ID. Use [zotero_user_id()]
#' or [zotero_group_id()] to pass it. By default [zotero_usr()] is called which
#' fetches the ID from the option or the environment variable.
#'
#' The URL of the request will contain the appropriate user/group ID prefix
#' which will be combined with `path` or `query` when supplied.
#'
#' The function is responsive to the following options:
#'
#' - `zoterro.verbose` - (default `FALSE`) give more feedback when running
#' - `zoterro.sleep` - (default 1) sleep time between requests, see [Sys.sleep()]
#'
#' @return List of `response` objects (c.f. [httr::GET()]).
#'
#' @export
#'
#' @examples
#' \dontrun{
#' # Fetch groups for the default user
#' zotero_api(path = "groups")
#'
#' # Fetch top-level collections for the group with ID=12345
#' zotero_api(path="collections/top", user=zotero_group_id(12345))
#' }

zotero_api <- function(
  base_url = "https://api.zotero.org",
  query = NULL,
  path = NULL,
  user = zotero_usr(),
  ...
  ) {

  u <- modify_url(
    base_url,
    path = paste(url_prefix(user), path, sep="/"),
    query = query
  )

  resp <- zotero_get(
    url = u,
    ...
    )
  result <- list(resp)
  while(has_next(resp)) {
    l <- zotero_response_links(resp)
    if(getOption("zoterro.verbose", FALSE)) {
      pretty_links(l)
    }
    resp <- zotero_get(url = l["next"], ...)
    result <- c(result, list(resp))
    if(has_next(resp)) {
      Sys.sleep(getOption("zoterro.sleep", 1))
    }
  }
  parse_results(result) # List of responses
}


# Make a single request
#
#' @import httr
zotero_get <- function(
  url,
  ...
) {
  resp <- GET(
    url = url,
    config = add_headers(
      "Zotero-API-Key" = zotero_key(),
      "Zotero-API-Version" = 3
    ),
    ...
  )

  if(http_error(resp)) {
    stop(
      sprintf(
        "Zotero request failed with HTTP error [%s]\n<%s>",
        status_code(resp),
        resp$request$url
        )
    )
  }

  resp
}








# Extract the links to subsequent queries (pages) from Zotero response
#
# @param r response
#
# Returns named character vector with names from: first, prev, next, last. URL
# named alternate leads to corresponding webpage.
#
#' @import magrittr
zotero_response_links <- function(r, ...) {
  if(is.null(r$headers$link)) return(FALSE)
  # Links to the the other pages of the resultset
  r$headers$link %>%
    strsplit(", ") %>%
    unlist() -> z
  structure(
    stringi::stri_extract_first_regex(z, "(?<=<).*(?=>)"),
    names = stringi::stri_extract_first_regex(z, '(?<=").*(?=")')
  )
}

# Is there a "next" link in the header?
has_next <- function(r) {
  "next" %in% names(zotero_response_links(r))
}


# Content type of the response
response_content_type <- function(r) {
  r$headers[["content-type"]]
}


pretty_links <- function(x) {
  cat(
    paste(names(x), x, sep=": "),
    sep="\n"
  )
}




# Given a list of GET responses return a useful object
#
# @param r
#
parse_results <- function(x, ...) UseMethod("parse_results")

# By default extract content
parse_results.default <- function(x, ...) {
  do.call("c", lapply(x, content))
}
