library(ggplot2)
library(plotrix)
library(plyr)
library(waffle)
library(grid)

tc <- function(x) {
  return (head(color.id(x), n = 1))
}
printf <- function(...) {
  invisible(print(sprintf(...)))
}
myletters <- function(n)
  unlist(Reduce(
    paste0,
    replicate(n %/% length(letters), letters, simplify = FALSE),
    init = letters,
    accumulate = TRUE
  ))[1:n]

letters1000 = myletters(1000)

waffle2 <-
  function (parts,
            rows = 10,
            xlab = NULL,
            title = NULL,
            colors = NA,
            size = 2,
            flip = FALSE,
            reverse = FALSE,
            equal = TRUE,
            pad = 0,
            use_glyph = FALSE,
            glyph_size = 12,
            legend_pos = "right")
  {
    part_names <- names(parts)
    print("part_names BEFORE adding LETTERS:")
    print(part_names)
    if (length(part_names) < length(parts)) {
      print("Adding LETTERS to part_names!!!")
      printf("length:parts:%d", length(parts))
      printf("length partname:%d", length(part_names))
      part_names <- c(part_names, letters1000[1:length(parts) -
                                                length(part_names)])
    }
    print("part_names after adding LETTERS:")
    print(part_names)
    if (all(is.na(colors))) {
      colors <- brewer.pal(length(parts), "Set2")
    }
    print("parts after adding LETTERS:")
    print(parts)
    printf("BEFORE unlist() length:parts:%d", length(parts))
    parts_vec <- unlist(sapply(1:length(parts), function(i) {
      rep(letters1000[i + 1], parts[i])
    }))
    if (reverse) {
      parts_vec <- rev(parts_vec)
    }
    print("parts_vec:")
    print(parts_vec)
    dat <-
      expand.grid(y = 1:rows, x = seq_len(pad + (ceiling(sum(
        parts
      ) / rows))))
    dat$value <- c(parts_vec, rep(NA, nrow(dat) - length(parts_vec)))
    print(dat)
    if (!inherits(use_glyph, "logical")) {
      fontlab <- rep(fa_unicode[use_glyph], length(unique(parts_vec)))
      dat$fontlab <- c(fontlab[as.numeric(factor(parts_vec))],
                       rep(NA, nrow(dat) - length(parts_vec)))
    }
    if (flip) {
      gg <- ggplot(dat, aes(x = y, y = x))
    }
    else {
      gg <- ggplot(dat, aes(x = x, y = y))
    }
    gg <- gg + theme_bw()
    if (inherits(use_glyph, "logical")) {
      gg <- gg + geom_tile(aes(fill = value), color = "white",
                           size = size)
      gg <- gg + scale_fill_manual(name = "",
                                   values = colors,
                                   labels = part_names)
      gg <-
        gg + guides(fill = guide_legend(override.aes = list(colour = NULL)))
    }
    else {
      if (choose_font("FontAwesome", quiet = TRUE) == "") {
        stop(
          "FontAwesome not found. Install via: https://github.com/FortAwesome/Font-Awesome/tree/master/fonts",
          call. = FALSE
        )
      }
      suppressWarnings(suppressMessages(font_import(
        system.file("fonts",
                    package = "waffle"),
        recursive = FALSE,
        prompt = FALSE
      )))
      if (!(!interactive() || stats::runif(1) > 0.1)) {
        message("Font Awesome by Dave Gandy - http://fontawesome.io")
      }
      gg <- gg + geom_tile(
        color = NA,
        fill = NA,
        size = size,
        alpha = 0,
        show_guide = FALSE
      )
      gg <- gg + geom_point(
        aes(color = value),
        fill = NA,
        size = 0,
        show_guide = TRUE
      )
      gg <- gg + geom_text(
        aes(color = value, label = fontlab),
        family = "FontAwesome",
        size = glyph_size,
        show_guide = FALSE
      )
      gg <- gg + scale_color_manual(name = "",
                                    values = colors,
                                    labels = part_names)
      gg <-
        gg + guides(color = guide_legend(override.aes = list(shape = 15,
                                                             size = 7)))
      gg <- gg + theme(legend.background = element_rect(fill = NA,
                                                        color = NA))
      gg <- gg + theme(legend.key = element_rect(color = NA))
    }
    gg <- gg + labs(x = xlab, y = NULL, title = title)
    gg <- gg + scale_x_continuous(expand = c(0, 0))
    gg <- gg + scale_y_continuous(expand = c(0, 0))
    if (equal) {
      gg <- gg + coord_equal()
    }
    gg <- gg + theme(panel.grid = element_blank())
    gg <- gg + theme(panel.border = element_blank())
    gg <- gg + theme(panel.background = element_blank())
    gg <- gg + theme(panel.margin = unit(0, "null"))
    gg <- gg + theme(axis.text = element_blank())
    gg <- gg + theme(axis.title.x = element_text(size = 10))
    gg <- gg + theme(axis.ticks = element_blank())
    gg <- gg + theme(axis.line = element_blank())
    gg <- gg + theme(axis.ticks.length = unit(0, "null"))
    gg <- gg + theme(plot.title = element_text(size = 18))
    gg <- gg + theme(plot.background = element_blank())
    gg <- gg + theme(plot.margin = unit(c(0, 0, 0, 0), "null"))
    gg <- gg + theme(plot.margin = rep(unit(0, "null"), 4))
    gg <- gg + theme(legend.position = legend_pos)
    gg
  }

main <- function() {
  data3 = read.csv(
    file = "01-january2016-ig-van-avgcolour-id-mf-month-day-daynum-unixtime-hour.csv",
    stringsAsFactors = F)
  numphotos = 1000
  print(numphotos)
  data3 = head(data3, numphotos)
  
  data3$colourname <- sapply(data3$colour, tc)
  
  countcolourname = count(data3, "colourname")
  countcolourname <- countcolourname[order(-countcolourname$freq),]
  
  colour_vector2 <-
    setNames(countcolourname$freq, countcolourname$colourname)
  print(colour_vector2)
  print(sum(colour_vector2))
  magic_row_size_number = 100
  
  numrows = numphotos %/% magic_row_size_number
  if (numrows == 0) {
    numrows = 1
  }
  else if ((numphotos %% magic_row_size_number) != 0) {
    numrows = numrows + 2
  }
  print (numrows)
  print(countcolourname$colourname)
  p = waffle2(
    colour_vector2,
    rows = numrows,
    size = 1.0,
    colors = countcolourname$colourname) +
    theme(legend.position = "none")
  
  filename = sprintf(
    "%4.4d-%s",
    numphotos,
    "debugwaffle-01-january2016-ig-van-avgcolour-id-mf-month-day-daynum-unixtime-hour.png"
  )
  ggsave(filename,
         p#,
  )
         #width = 36.50,
         #height = 6.66667,
         #dpi = 72,
         #limitsize = FALSE) #multiply height and width by dpi to get px
         #warnings()
}

sink("log.txt")

main()

sink()
