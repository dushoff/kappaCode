
theme_set(theme_bw() + theme(
  plot.background = element_blank(),
  panel.grid = element_blank(),
  axis.title.x = element_text(size = xlabelFontSize),
  axis.title.y = element_text(size = ylabelFontSize)
))
update_geom_defaults("line", list(
  linewidth = 1     
))
update_geom_defaults("vline", list(
  linewidth = 0.5
  ,linetype = "dotted"
))
update_geom_defaults("hline", list(
  linewidth = 0.5
  ,linetype = "dotted"
))
update_geom_defaults("point", list(
  size = 1.5
))
scale_colour_discrete <- function(...) {
  ggplot2::scale_colour_brewer(palette = "Dark2", ...)
}

scale_fill_discrete <- function(...) {
  ggplot2::scale_fill_brewer(palette = "Dark2", ...)
}
