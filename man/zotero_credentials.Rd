% Generated by roxygen2: do not edit by hand
% Please edit documentation in R/zotero_credentials.R
\name{zotero_credentials}
\alias{zotero_credentials}
\alias{zotero_usr}
\alias{zotero_key}
\alias{zotero_user_id}
\alias{zotero_group_id}
\alias{print.zotero_id}
\title{Get Zotero username and key}
\usage{
zotero_usr()

zotero_key()

zotero_user_id(id)

zotero_group_id(id)

\method{print}{zotero_id}(x, ...)
}
\arguments{
\item{id}{user or group iD}

\item{x}{Zotero user/group ID}

\item{...}{other arguments}
}
\value{
Functions \code{zotero_user_id()} and \code{zotero_group_id()} return objects
of class "zotero_user_id" and "zotero_group_id", both inheriting from class
"zotero_id".
}
\description{
\itemize{
\item \code{zotero_usr()} - return Zotero user ID
}

\itemize{
\item \code{zotero_key()} - return Zotero key
}

\code{zotero_user_id()}, \code{zotero_group_id()} - supply user/group ID
to other functions
}
\details{
These functions look for Zotero user ID and key by looking into the
following places and returning as soon as a value found:
\itemize{
\item Options \code{zotero.user} and \code{zotero.key} respectively
\item Environment variables \code{ZOTERO_USER} and \code{ZOTERO_KEY} respectively.
}

Best practice is to store both the user ID and the key in read-protected
\verb{~/.Renviron} as environment variables.

Functions \code{zotero_user_id()} and \code{zotero_group_id()} are used to
supply user or group ID to other functions in the package, primarly
\code{\link[=zotero_api]{zotero_api()}}.
}
