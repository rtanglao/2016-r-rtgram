# inspired by first R program http://www.r-chart.com/2010/07/pie-charts-in-ggplot2.html
library(ggplot2)
data3 = read.csv(
  file="https://raw.githubusercontent.com/rtanglao/2016-rtgram/master/THUMBNAIL_150x150/2016-january-2016-avgcolor-id-mf-month-day-daynum.csv", 
    stringsAsFactors=F)
p = ggplot(data=data3, 
       aes(x=factor(1),
           y=colour,
           fill = I(data3$colour)
      ),
) 
p=p + geom_bar(stat="identity", width = 1)
p=p+facet_grid(facets=. ~ daynumber)
ggsave("ig-van-january-2016-piechart-as-barchart.png", p, width = 26.666666667, height = 26.666666667, dpi = 72, limitsize = FALSE) # 26.6666667 = 1920/72dpi
