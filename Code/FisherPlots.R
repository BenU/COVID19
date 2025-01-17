# Fisher Plots
internationalFisherPlot <- function (X, title, ylabel, emailTitle, N, OneIn = FALSE, addPlot = FALSE, comparator = "most")
{ 
  X$Country[X$Country == "United States of America"] <- "USA"
  X <- X[order(X$Y, decreasing = TRUE),]
  X <- X[1:65,]
  X$Rank <- 1:nrow(X)
  ggObject <- ggplot(X, aes(x = Rank, y = Y)) +
    geom_point() +
    geom_point(data=X[X$Country == "USA",], color = "red") +
    geom_text(aes(y = Y, label = paste0(" ",Country)), angle = 90, size = 2.6, hjust = 0) +
    geom_text(
      data=X[X$Country == "USA",], 
      aes(y = Y, label = paste0(" ",Country)), 
      color = "red", 
      angle = 90, size = 2.6, hjust = 0) +
    labs(
      title = paste(title, "as of", today),
      y = ylabel,
      x = "Rank",
      caption = "Excludes countries with population < 5,000,000"
    ) +
    scale_x_continuous(
      limits = c(1, nrow(X)),
      breaks = c(0:13*5 + 1)
    )
  if (OneIn)
  {
    breaks <- pretty(X$Y)
    labels <- paste("1 in", prettyNum(round(1000000 / breaks, 0), big.mark = ",", scientific = FALSE))
    labels[labels== "1 in Inf"] <- "None"
    ggObject <- ggObject + scale_y_continuous(
      limits = c(0, max(X$Y) * 1.1),
      breaks = breaks, 
      labels = labels
    ) 
  } else {
    ggObject <- ggObject + scale_y_continuous(
      limits = c(0, max(X$Y) * 1.1),
      labels = scales::number_format(big.mark = ",", decimal.mark = '.')
    )
  }
  # +
  #   coord_cartesian(
  #     xlim = c(1, nrow(X))
  #   )
  nextSlide(ggObject, title)
  if (emailTitle != "") emailText <<- textRanksInternational(X, emailTitle, N, addPlot, ggObject, comparator)
}

stateFisherPlot <- function (
  X, 
  title, 
  ylabel, 
  emailTitle, 
  N, OneIn = FALSE, 
  addPlot = FALSE,
  minimum = 0,
  decreasing = TRUE,
  comparator = "most"
  )
{
  X <- X[order(X$Y, decreasing = decreasing),]
  X$Rank <- 1:nrow(X)
  pMasks <- p <- signif(wilcox.test(X$Rank[X$Masks == "Yes"], X$Rank[X$Masks == "No"])$p.value, 2)
  pGov <- signif(wilcox.test(X$Rank[X$Governor == "Republican"], X$Rank[X$Governor == "Democratic"])$p.value, 2)
  pLean <- signif(wilcox.test(X$Rank[X$'2020 Election' == "Trump"], X$Rank[X$'2020 Election' == "Biden"])$p.value, 2)
  ggObject <- ggplot(
    X, 
    aes(
      x = Rank, 
      y = Y, 
      color = `2020 Election`, 
      shape = Masks
      )
    ) +
    geom_point() +
    geom_text(aes(y = Y, label = paste0("  ",State)), angle = 90, size = 2.6, hjust = 0) +
    scale_color_manual(values = c("blue","red")) +
    scale_shape_manual(values = c(0, 15)) +
    labs(
      title = paste(title, "as of", today),
      subtitle = "Mask mandate is from July 20th. Political lean is based on election results.",
      y = ylabel,
      x = "Rank",
      caption = paste0
      (
        "p masks as of July 20, 2020: ", 
        signif(pMasks,2), 
        ", p 2020 Election: ",
        format(signif(pLean,2), scientific = FALSE),
        "."
      )
    ) +
    scale_x_continuous(
      limits = c(1, nrow(X)),
      breaks = c(0:10*5 + 1)
    )
  if (OneIn)
  {
    breaks <- pretty(c(0, max(X$Y)*1.1))
    labels <- paste("1 in", prettyNum(round(1000000 / breaks, 0), big.mark = ",", scientific = FALSE))
    labels[labels== "1 in Inf"] <- "None"
    ggObject <- ggObject + scale_y_continuous(
      limits = c(0, max(X$Y) * 1.1),
      breaks = breaks, 
      labels = labels
    ) 
  } else {
    ggObject <- ggObject + scale_y_continuous(
      limits = c(min(minimum, X$Y)*0.9, max(X$Y) * 1.1),
      labels = scales::number_format(big.mark = ",", decimal.mark = '.')
    )
    if (min(X$Y) < 0)
    {
      ggObject <- ggObject +
        annotate(
          "segment",
          y = 0,
          yend = 0,
          x = 1,
          xend = 51,
        )
    }
  }
  # +
  #   coord_cartesian(
  #     xlim = c(1, nrow(X))
  #   )
  nextSlide(ggObject, title)
  if (emailTitle != "") emailText <<- textRanksStates(X, emailTitle, N, addPlot, ggObject, comparator)
}
