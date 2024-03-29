#' @name ggheatmap
#' @title ggplot2 Version of Heatmap
#' @description  The flexibility and excellence of 'ggplot2' is unquestionable,
#'     so many drawing tools basically need 'ggplot2' as the operating object.
#'     In order to develop a heatmap drawing system based on ggplot2, we developed
#'     this tool, mainly to solve the heatmap puzzle problem and the flexible
#'     connection between the heatmap and the 'ggplot2' object.
#'    The advantages of this tool are as follows:
#'     1. More flexible label settings;
#'     2. Realize the linkage of heatmap and 'ggplot2' drawing system,
#'        which is helpful for operations such as puzzles;
#'     3. Simple and easy to operate;
#'     4. Optimization of clustering tree visualization.
#' @usage
#' ggheatmap(data,
#'   color=colorRampPalette(c( "#0073c2","white","#efc000"))(100),
#'   legendName="Express",
#'   scale="none",
#'   shape=NULL,
#'   border=NA,
#'   cluster_rows = F,
#'   cluster_cols = F,
#'   dist_method="euclidean",
#'   hclust_method="complete",
#'   text_show_rows=waiver(),
#'   text_show_cols=waiver(),
#'   text_position_rows="right",
#'   text_position_cols="bottom",
#'   annotation_cols=NULL,
#'   annotation_rows=NULL,
#'   annotation_color,
#'   annotation_width=0.03,
#'   annotation_position_rows="left",
#'   annotation_position_cols="top",
#'   show_cluster_cols=T,
#'   show_cluster_rows=T,
#'   cluster_num=NULL,
#'   tree_height_rows=0.1,
#'   tree_height_cols=0.1,
#'   tree_color_rows=NULL,
#'   tree_color_cols=NULL,
#'   tree_position_rows="left",
#'   tree_position_cols="top",
#'   levels_rows=NULL,
#'   levels_cols=NULL
#' )
#' @author Baiwei Luo
#' @param data input data(matrix or data.frame)
#' @param color the color of heatmap
#' @param legendName character,the title of heatmap legend
#' @param scale character,the way of scale data("none", "row" or "column")
#' @param border character, the colour of border
#' @param shape character, the shape of cell("square", "circle" and "triangle").Default is NULL
#' @param cluster_rows whether rows should be clustered(TRUE of FALSE)
#' @param cluster_cols whether column should be clustered(TRUE of FALSE)
#' @param dist_method character,the method parameter of dist function. see \link{dist}
#' @param hclust_method character,the method parameter of hclust function, see \link{hclust}
#' @param text_show_rows a character you want to show for y-axis
#' @param text_show_cols a character you want to show for x-axis
#' @param text_position_rows character,the position of y-axis label("right" or "left")
#' @param text_position_cols character,the position of x-axis label("bottom" or "top")
#' @param annotation_cols a data.frame for column annotation
#' @param annotation_rows a data.frame for row annotation
#' @param annotation_color a list for annotation color
#' @param annotation_width  a numeric for annotation width
#' @param annotation_position_rows character,the position of column annotation("right" or "left")
#' @param annotation_position_cols character,the position of row annotation("bottom" or "top")
#' @param show_cluster_cols whether show column cluster tree(TRUE of FALSE)
#' @param show_cluster_rows whether show row cluster tree(TRUE of FALSE)
#' @param cluster_num a numeric for cut cluster tree
#' @param tree_height_rows row cluster tree height
#' @param tree_height_cols column cluster tree height
#' @param tree_color_rows a character for row cluster tree color
#' @param tree_color_cols a character for column cluster tree color
#' @param tree_position_rows character,the position of row cluster tree("right" or "left")
#' @param tree_position_cols character,the position of column cluster tree("bottom" or "top")
#' @param levels_rows a character for  y-axis label levels
#' @param levels_cols a character for  x-axis label levels
#' @return p
#' @import ggplot2
#' @import ggpubr
#' @import aplot
#' @import tibble
#' @import factoextra
#' @import tidyr
#' @import grDevices
#' @import stats
#' @import patchwork
#' @example 
#' #More examples please read https://github.com/XiaoLuo-boy/ggheatmap
#'
#' @export
NULL

ggheatmap <- function(data,
                      color=colorRampPalette(c( "#0073c2","white","#efc000"))(100),
                      legendName="Express",
                      scale="none",
                      shape=NULL,
                      border=NA,
                      cluster_rows = F,
                      cluster_cols = F,
                      dist_method="euclidean",
                      hclust_method="complete",
                      text_show_rows=waiver(),
                      text_show_cols=waiver(),
                      text_position_rows="right",
                      text_position_cols="bottom",
                      annotation_cols=NULL,
                      annotation_rows=NULL,
                      annotation_color,
                      annotation_width=0.03,
                      annotation_position_rows="left",
                      annotation_position_cols="top",
                      show_cluster_cols=T,
                      show_cluster_rows=T,
                      cluster_num=NULL,
                      tree_height_rows=0.1,
                      tree_height_cols=0.1,
                      tree_color_rows=NULL,
                      tree_color_cols=NULL,
                      tree_position_rows="left",
                      tree_position_cols="top",
                      levels_rows=NULL,
                      levels_cols=NULL

){
  gene=NULL
  cluster=NULL
  #step1.scale data
  if(scale=="column"){
    scale_df <- scale(data)
  }else if(scale=="row"){
    scale_df <- t(scale(t(data)))
  }else{
    scale_df <- data
  }
  #step2. draw cluster tree
  dat <- as.data.frame(scale_df)%>%
    rownames_to_column(var = "gene")%>%
    tidyr::gather(key = "cluster",value = "expression",-gene)
  if(cluster_rows){
    row_clust <- hclust(dist(as.matrix(scale_df),method = dist_method),method = hclust_method)
    roworder <- row_clust$labels[row_clust$order]

    dat$gene <- factor(dat$gene,levels = roworder)
    if(show_cluster_rows){
      row_ggtreeplot <- fviz_dend(row_clust, k = cluster_num[1],
                                  k_colors = tree_color_rows,
                                  color_labels_by_k = TRUE,
                                  show_labels = FALSE,
                                  labels_track_height = 0,
                                  horiz = TRUE,
                                  ggtheme = theme_classic())+
        theme(title = element_blank(),
              axis.text.x = element_blank(),
              axis.ticks = element_blank(),
              axis.line.x = element_blank())
    }else{
      row_ggtreeplot <- NULL
    }
  }else{

    dat <- as.data.frame(scale_df)%>%
      rownames_to_column(var = "gene")%>%
      tidyr::gather(key = "cluster",value = "expression",-gene)
    if(!is.null(levels_rows)){
      dat$gene <- factor(dat$gene,levels = levels_rows)
    }else{
      dat$gene <- as.factor(dat$gene)
    }

    row_ggtreeplot <- NULL
  }


  if(cluster_cols){
    cols_clust <-  hclust(dist(t(as.matrix(scale_df)),method = dist_method),method = hclust_method)
    colorder <- cols_clust$labels[cols_clust$order]
    dat$cluster <- factor(dat$cluster,levels = colorder)
    if(show_cluster_cols){
      col_ggtreeplot <- fviz_dend(cols_clust, k = cluster_num[2],
                                  k_colors = tree_color_cols,
                                  color_labels_by_k = TRUE,
                                  show_labels = FALSE,
                                  labels_track_height = 0,
                                  ggtheme = theme_classic())+
        theme(title = element_blank(),
              axis.text.y = element_blank(),
              axis.ticks = element_blank(),
              axis.line.x = element_blank())
    }else{
      col_ggtreeplot <- NULL
    }
  }else{
    if(!is.null(levels_cols)){
      dat$cluster <- factor(dat$cluster,levels = levels_cols)
    }else{
      dat$cluster <- as.factor(dat$cluster)
    }

    col_ggtreeplot <- NULL
  }
  #step3.axis label

  if(is.character(text_show_rows)){
    text_rows <- as.character(sapply(levels(dat$gene),function(x){ifelse(!x%in%text_show_rows,NA,x)}))
  }else{text_rows <- text_show_rows}
  if(is.character(text_show_cols)){
    text_cols <- as.character(sapply(levels(dat$cluster),function(x){ifelse(!x%in%text_show_cols,NA,x)}))
  }else{text_cols <- text_show_cols}

  #step4.Draw the main body of the heatmap

  if(is.null(shape)){
    p <- ggplot(dat, aes(cluster, gene, fill= expression)) +
      geom_tile(colour=border) +
      scale_fill_gradientn(colours = color)+
      scale_y_discrete(position = text_position_rows,breaks=text_rows)+
      scale_x_discrete(position = text_position_cols,breaks=text_cols)+
      theme(axis.title.x = element_blank(),
            axis.title.y = element_blank(),
            axis.ticks = element_blank(),
            panel.background = element_rect(fill = "white", colour = "white"),
            legend.key = element_rect(fill = "white", colour = "white")
      )+
      labs(fill=legendName)
  }else{
    if(shape=="square"){
      p <- ggplot(dat, aes(cluster, gene)) +
        geom_tile(colour=border,fill="white")+
        geom_point(aes(colour= expression),shape=15,size=5) +
        scale_color_gradientn(colours = color)+
        scale_y_discrete(position = text_position_rows,breaks=text_rows)+
        scale_x_discrete(position = text_position_cols,breaks=text_cols)+
        theme(axis.title.x = element_blank(),
              axis.title.y = element_blank(),
              axis.ticks = element_blank(),
              panel.background = element_rect(fill = "white", colour = "white"),
              legend.key = element_rect(fill = "white", colour = "white")
        )+
        labs(colour=legendName)
    }else{
      if(shape=="circle"){
        p <- ggplot(dat, aes(cluster, gene)) +
          geom_tile(colour=border,fill="white")+
          geom_point(aes(colour= expression),shape=16,size=5) +
          scale_color_gradientn(colours = color)+
          scale_y_discrete(position = text_position_rows,breaks=text_rows)+
          scale_x_discrete(position = text_position_cols,breaks=text_cols)+
          theme(axis.title.x = element_blank(),
                axis.title.y = element_blank(),
                axis.ticks = element_blank(),
                panel.background = element_rect(fill = "white", colour = "white"),
                legend.key = element_rect(fill = "white", colour = "white")
          )+
          labs(colour=legendName)
      }else{
        if(shape=="triangle"){
          p <- ggplot(dat, aes(cluster, gene)) +
            geom_tile(colour=border,fill="white")+
            geom_point(aes(colour= expression),shape=17,size=5) +
            scale_color_gradientn(colours = color)+
            scale_y_discrete(position = text_position_rows,breaks=text_rows)+
            scale_x_discrete(position = text_position_cols,breaks=text_cols)+
            theme(axis.title.x = element_blank(),
                  axis.title.y = element_blank(),
                  axis.ticks = element_blank(),
                  panel.background = element_rect(fill = "white", colour = "white"),
                  legend.key = element_rect(fill = "white", colour = "white")
            )+
            labs(colour=legendName)
        }else{
          message("please choose 'square', 'circle' or 'triangle'")
        }
      }
    }
  }


  #step5.draw your annotation
  if(!is.null(annotation_rows)){
    annotation_rows <- rownames_to_column(annotation_rows,var = "none1")
    for(i in 1:(ncol(annotation_rows)-1)){
      annotation_rows$none <- factor(rep(names(annotation_rows)[i+1],nrow(annotation_rows)))
      rowlist <- list()
      rowanno <- ggplot()+
        geom_exec(geom_tile,data = annotation_rows,x="none1",y="none",fill=names(annotation_rows)[i+1])+
        scale_fill_manual(values =annotation_color[names(annotation_color)==names(annotation_rows)[i+1]][[1]])+
        theme(axis.title = element_blank(),axis.text.y = element_blank(),
              axis.ticks = element_blank(),panel.background = element_blank(),
              axis.text.x.bottom = element_text(angle = 90,hjust = 0.5,vjust = 0.5))+
        coord_flip()+labs(fill=names(annotation_rows)[i+1])
      if(annotation_position_rows=="left"){
        p <- p%>%insert_left(rowanno,width =annotation_width )
      }else{
        p <- p%>%insert_right(rowanno,width =annotation_width )
      }
    }
  }else{
    rowanno <- NULL
  }
  if(!is.null(annotation_cols)){
    annotation_cols <- rownames_to_column(annotation_cols,var = "none1")
    for(i in 1:(ncol(annotation_cols)-1)){
      annotation_cols$none <- factor(rep(names(annotation_cols)[i+1],nrow(annotation_cols)))
      collist <- list()
      colanno <- ggplot()+
        geom_exec(geom_tile,data = annotation_cols,x="none1",y="none",fill=names(annotation_cols)[i+1])+
        scale_fill_manual(values = annotation_color[names(annotation_color)==names(annotation_cols)[i+1]][[1]])+
        scale_y_discrete(position = "right")+
        theme(axis.title = element_blank(),axis.text.x = element_blank(),
              axis.ticks = element_blank(),panel.background = element_blank())+
       labs(fill=names(annotation_cols)[i+1])
      if(annotation_position_cols=="top"){
        p <- p%>%insert_top(colanno,height =annotation_width)
      }else{
        p <- p%>%insert_bottom(colanno,height =annotation_width)
      }
    }
  }else{
    colanno <- NULL
  }

  #step6.Merge pictures


  if(!is.null(row_ggtreeplot)){
    if(tree_position_rows=="left"){
      p <- p%>%insert_left(row_ggtreeplot,width = tree_height_rows)
    }else{
      p <- p%>%insert_right(row_ggtreeplot+scale_y_continuous(),width = tree_height_rows)
    }
  }
  if(!is.null(col_ggtreeplot)){
    if(tree_position_cols=="top"){
      p <- p%>%insert_top(col_ggtreeplot,height = tree_height_cols)
    }else{
      p <- p%>%insert_bottom(col_ggtreeplot+scale_y_reverse(),height = tree_height_cols)
    }
  }
  return(p)
}

