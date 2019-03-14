function (query, path = ".", classes = "", subjects = "", courts = "",
    date_start = "", date_end = "", min_page = 1, max_page = 1,
    cores = 1, tj = "tjsp")
{
    stopifnot(tj == "tjsp")
    stopifnot(min_page <= max_page)
    strings <- list(classes, subjects, courts) %>%
        purrr::modify(stringr::str_c,
        collapse = ",")
    dates <- list(date_start, date_end) %>% purrr::modify(date_pt)
    query_post <- list(conversationId = "", dadosConsulta.pesquisaLivre = query,
        tipoNumero = "UNIFICADO", classeTreeSelection.values = strings[[1]],
        assuntoTreeSelection.values = strings[[2]], contadoragente = 0,
        contadorMaioragente = 0, dadosConsulta.dtInicio = dates[[1]],
        dadosConsulta.dtFim = dates[[2]], varasTreeSelection.values = strings[[3]],
        dadosConsulta.ordenacao = "DESC")
    dir.create(path, FALSE, TRUE)
    path <- normalizePath(path)
    file <- stringr::str_c(path, "/search.html")
    httr::POST("https://esaj.tjsp.jus.br/cjpg/pesquisar.do",
        body = query_post, httr::config(ssl_verifypeer = FALSE),
        httr::write_disk(file, TRUE))

    download_pages <- function(page, path) {
        query_get <- list(pagina = page, conversationId = "")
        GET <- purrr::possibly(httr::GET, "")
        file <- stringr::str_c(path, "/page_", stringr::str_pad(page,
            4, "left", "0"), ".html")
        out <- GET("https://esaj.tjsp.jus.br/cjpg/trocarDePagina.do",
            query = query_get, httr::config(ssl_verifypeer = FALSE),
            httr::write_disk(file, TRUE))
        if (is.character(out)) {
            file <- out
        }
        else {
            file <- normalizePath(file)
        }
        return(file)
    }

    files <- parallel::mcmapply(download_pages, min_page:max_page,
        list(path = path), SIMPLIFY = FALSE, mc.cores = cores)
    return(c(file, purrr::flatten_chr(files)))
}