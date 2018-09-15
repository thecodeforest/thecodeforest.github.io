library(breakDown)
library(caret)
library('sjPlot')
library(data.table)
library(readr)
library(dplyr)
library('janitor')
library(ggplot2)
library(prettyR)
library(pryr)
library(mgcv)
library(broom)
library(reshape2)
library(rvest)
library(tidyverse)
library(h2o)
library(Metrics)
library(reticulate)
library(pacman)
library(artyfarty)
py_path = '/Users/mlebo1/Desktop/site/content/post/college_rankings_images/college_rankings_scrape'
py_file = 'rankings_earnings_post_functions.py'
full_py_path = file.path(py_path,py_file)
reticulate::source_python(full_py_path)
a = collect_payscale_info() %>% 
  janitor::clean_names() %>% 
  dplyr::select(friendly_name,
                state,
                percent_female,
                percent_stem,
                undergraduate_enrollment,
                school_sector,
                mid_career_median_pay
  ) %>% 
  dplyr::rename(college_name = friendly_name)
b = collect_college_ranks(a$college_name)
b


plot_mo
pacman::p_load('readr', 'coolpackage')
model = lm(mpg ~ cyl + disp + hp, data = mtcars)
gam_fit_tmp = mgcv::gam(mpg ~ s(hp),
                        data = mtcars,
                        method = 'REML')
breakDown::broken.
out = breakDown::broken(gam_fit_tmp, mtcars[5,])
data.frame(predict(model,
                   new_data = mtcars))
out = breakDown::broken(model, mtcars[5,],
                  baseline = "Intercept"
                  )
# plot(out) + 
#   ggtitle("Blargh") + 
#   theme_bw()
# theme_set(theme_bw())
# Show Me the Money: THe relationship of College Rankings and Pay
#######
# q1: impact of school rank of earnings
# q2: what school outperform their rank
# q3: what part of the range do rankings matter the most? 
######
input_dir = '/Users/markleboeuf/Desktop/Start/college_rankings_scrape'
setwd(input_dir)
reticulate::use_python('//anaconda/bin/python', required = TRUE)
# brings our function into the R Environment
reticulate::source_python('collect_payscale_info.py')

college_ranks = collect_payscale_info() 
# names(college_ranks)
# college_ranks = college_ranks %>% 
#                 data.frame() %>% 
#                 janitor::clean_names()
# blank_df = data.frame(NULL)
# for(v in names(college_ranks)[1:19]){break}
#     blank_df = bind_cols(blank_df,
#                          as.vector(college_ranks[v])
#                          )
# }


college_ranks = read_csv(file.path(input_dir,
                                   'college_ranks.csv'
                                   )) %>% 
                clean_names() %>% 
                arrange(rank) %>% 
                filter(is.na(rank) == FALSE)



payscale_data = read_csv(file.path(input_dir,
                                   'payscale_college_data.csv'
                                   )) %>% 
                clean_names() %>%
                
                select(friendly_name,
                       state,
                       percent_female,
                       percent_high_job_meaning,
                       percent_pell,
                       percent_stem,
                       division_1_basketball_classifications,
                       division_1_football_classifications,
                       undergraduate_enrollment,
                       school_sector,
                       early_career_median_pay,
                       mid_career_median_pay
                       )

pay_ranks_data = payscale_data %>% 
                 inner_join(college_ranks) %>% 
                 arrange(rank) %>% 
                 select(friendly_name, rank, everything()) %>% 
                 mutate(percent_stem = as.numeric(percent_stem),
                        percent_female = as.numeric(percent_female),
                        percent_pell = as.numeric(percent_pell),
                        undergraduate_enrollment =  as.numeric(undergraduate_enrollment),
                        div1_fball = ifelse(division_1_football_classifications == 'Not Division 1 Football', 0, 1),
                        rank_bucket = case_when(rank >= 1 & rank <= 50 ~ '1 - 50',
                                   rank >= 51 & rank <= 100 ~ '51 - 100',
                                   rank > 100 & rank <= 200 ~ '101 - 200',
                                   rank > 200 & rank <= 400 ~ '201 - 400',
                                   rank > 400 ~ '> 400'
                                   )
                        ) %>% 
                 data.frame() %>% 
                 na.omit()
head(final_df)
lm_estimates = pay_ranks_data %>% 
                group_by(rank_bucket) %>% 
                do(tidy(lm(mid_career_median_pay ~ rank, data=.))) %>% 
                select(rank_bucket, term, estimate) %>% 
                reshape::cast(rank_bucket ~ term, value = 'estimate') %>% 
                clean_names() %>% 
                dplyr::rename(rank_coeff = rank) %>% 
                data.frame()
rank_bucket_est
lm_estimates %>% 
    inner_join(pay_ranks_data) %>% 
    mutate(predicted_income = rank * rank_coeff + intercept) %>% 
    mutate(rank_bucket = factor(rank_bucket,
                                levels = c('1 - 50',
                                           '51 - 100',
                                           '101 - 200',
                                           '201 - 400',
                                           '> 400'
                                           )
                                )
          ) %>% 
    ggplot(aes(x = rank, y = predicted_income, color = rank_bucket)) + 
    geom_point() + 
    geom_line() + 
    geom_point(data = pay_ranks_data, aes(x = rank,
                                          y = mid_career_median_pay),
               alpha = 0.25
               )

ggplot(final_df, aes(x = rank, y = mid_career_median_pay)) + 
  geom_point(size = 2) + 
  stat_smooth(size = 2) + 
  ylab("Mid Career Median Pay") + 
  xlab("College Rank") + 
  my_plot_theme() + 
  scale_y_continuous(labels=scales::dollar) + 
  scale_x_continuous(breaks = seq(0, max(final_df$rank), by = 50))


ggplot(pay_ranks_data, aes(x = reorder(state, mid_career_median_pay, FUN = median), y = mid_career_median_pay)) + 
    geom_boxplot() + 
    theme(axis.text.x = element_text(angle = 90))

## 
table_path = '/html/body/div[5]/div/table'
url = "https://www.missourieconomy.org/indicators/cost_of_living/"
col_table = url %>% 
  xml2::read_html() %>% 
  rvest::html_nodes(xpath = table_path) %>% 
  rvest::html_table(header = TRUE)

col_df = data.frame(col_table[[1]])[,c(1, 3)] %>% 
    stats::setNames(., c('state', 'col_index')) %>% 
    dplyr::slice(2:(n() - 1)) %>% 
    dplyr::mutate(col_index = as.numeric(col_index))
head(col_df)
# check to see which do not match

pay_ranks_data %>% 
    dplyr::select(state) %>% 
    dplyr::distinct() %>% 
    dplyr::left_join(col_df) %>% 
    dplyr::filter(is.na(col_index) == TRUE)
#
head(college_salary_df)
head(college_rankings_df)
pay_ranks_data = 
    pay_ranks_data %>% 
    dplyr::inner_join(col_df %>% 
                      dplyr::mutate(state = ifelse(state == 'District of    Columbia', 
                                                            'District of Columbia',
                                                             state
                                                  )
                                    )
                       ) %>% 
    dplymutate(school_sector = as.factor(school_sector))

  

final_df$rank_sq = final_df$rank^2
head(final_df)
y_var = 'mid_career_median_pay'
x_var = setdiff(names(final_df), y_var)
model_form = as.formula(paste0(y_var,
                               " ~ ",
                               paste0(x_var, collapse = " + ")
                               ))

  

summary(results)
final_df$pred_value = as.vector(predict(lm_fit, newdata = final_df))
final_df$residual = final_df$mid_career_median_pay - final_df$pred_value
ggplot(final_df, aes(x = pred_value, y = residual)) + 
  geom_point()
final_df %>% 
  select(rank, pred_value, mid_career_median_pay) %>% 
  reshape::melt('rank') %>% 
  ggplot(aes(x = rank, y = value, color = variable)) + 
  geom_point()
ggplot(final_df, aes(x = rank, y = pred_value)) + 
  geom_point() + 
  stat_smooth()







model_lm = lm(model_form,
              data = final_df
              )
rank_break_points = seq(1, 400, length.out = 8)
plot_list = list()
for(i in rank_break_points){
  print(i)
  out = breakDown::broken(model_lm,
                          final_df[i,],
                          baseline = "Intercept")
  plot(out)
}

out = breakDown::broken(model_lm,
                        final_df[225,],
                        baseline = "Intercept"
)
plot(out)


school_rank = ggplot(pay_ranks_data, aes(x = rank, y = mid_career_median_pay)) + 
              geom_point() + stat_smooth()
summary(pay_ranks_data)
gam_fit = mgcv::gam(mid_career_median_pay ~ s(rank,bs="ps") + 
              s(percent_stem,bs="ps") + 
              s(col_index, bs="ps") + 
              s(percent_female, bs="ps"),
              data = pay_ranks_data,
              method = 'REML'
              )
summary(gam_fit)
caret::varImp(gam_fit)
insample_mape = Metrics::mape(pay_ranks_data$mid_career_median_pay,
                              gam_fit$fitted.values
                              )
print(scales::percent(insample_mape))

mape_vector = c()
set.seed(1)
for(i in 1:100){
    print(i)
    train_segment = floor(nrow(pay_ranks_data) * 0.8)
    
    train_df = pay_ranks_data %>% 
               sample_n(train_segment)
    
    test_df =  pay_ranks_data %>% 
               filter(! friendly_name %in% train_df$friendly_name)
    
    gam_fit_tmp = mgcv::gam(mid_career_median_pay ~ 
                            s(rank,bs="ps") + 
                            s(percent_stem,bs="ps") + 
                            s(col_index, bs="ps") + 
                            s(percent_female, bs="ps"),
                        data = train_df,
                        method = 'REML')
    
    gam_pred = predict(gam_fit_tmp, test_df)
    
    mape_vector = c(mape_vector,
                    Metrics::mape(actual = test_df$mid_career_median_pay,
                                                  predicted = gam_pred
                                  )
                    )
    
}

qplot(mape_vector, bins = 6) + 
    xlab("Mape") + 
    scale_x_continuous(labels = scales::percent) + 
    geom_vline(xintercept = insample_mape)
head(pay_ranks_data)

lm_fit = lm(mid_career_median_pay ~ rank + percent_stem + col_index + percent_female + div1_fball,
            data = pay_ranks_data)

# h2o.init()
# rf_fit = h2o.randomForest(x = c('rank', 
#                                 'percent_stem',
#                                 'col_index',
#                                 'school_sector'),
#                  y = 'mid_career_median_pay',
#                  training_frame = as.h2o(pay_ranks_data)
#                  )

broken:
pay_ranks_data$gam_fit = gam_fit$fitted.values
pay_ranks_data$lm_fit = lm_fit$fitted.values
#pay_ranks_data$rf_fit = predict(rf_fit, as.h2o(pay_ranks_data))
scales::percent(Metrics::mape(actual = pay_ranks_data$mid_career_median_pay,
             predicted = pay_ranks_data$gam_fit
             ))
scales::percent(Metrics::mape(actual = pay_ranks_data$mid_career_median_pay,
                              predicted = pay_ranks_data$lm_fit
             ))

x_var_plot = x_var[!x_var %in% c('percent_pell', 'school_sector')]
rank_margin_effect = plot_model(model_gam$finalModel, 
                                type = "pred", 
                                terms = "rank")


marginal_effects_plots = list()
for(var in x_var_plot){
  marginal_effects_plots[[var]] =  
    plot_model(model_gam$finalModel, 
               type = "pred", 
               terms = var)

}
marginal_effects_plots$rank + 
  ggtitle("Predicted Pay by College Rank") + 
  xlab("Rank") + 
  ylab("Mid Career Median Pay") + 
  my_plot_theme() + 
  scale_y_continuous(labels=scales::dollar)
  
tmp_effects_plot

(marginal_effects_plots$rank + 
  marginal_effects_plots$percent_female + 
  marginal_effects_plots$percent_stem +
  #marginal_effects_plots$undergraduate_enrollment + 
  marginal_effects_plots$col_index + 
  plot_layout(ncol = 2)
)

patchwork::plot_layout(ncol = 2)

marginal_effects_plots$rank + marginal_effects_plots$percent_female + 
pay_ranks_data = pay_ranks_data %>% 
                 inner_join(rank_margin_effect$data %>% 
                                janitor::clean_names() %>% 
                                dplyr::select(-group) %>% 
                                dplyr::rename(rank = x,
                                              pred_mid_career_pay = predicted
                                )
                            )
broom::tidy()
unclass(summary(model_gam))
a = summary(model_gam)
a$s.table
a$p.table
bind_rows(broom::tidy(a$s.table)
)
a$s.table
summary(model_gam) %>% 
  data.frame()


summary(lm_fit)
final_df[578,]
final_df$pred_value = as.vector(predict(lm_fit, final_df))
ggplot(final_df, aes(x = ))


    dplyr::rename(rank = x
                  ) %>% 
    ggplot(aes(x = rank, 
               y = predicted
               )) + 
    geom_ribbon(aes(ymin = conf.low, ymax = conf.high), fill = "grey70", alpha = 0.5)+
    geom_line(size = 1) + 
    scale_x_continuous(breaks = seq(0, max(blargh$data$x), by = 50)) + 
    ylab("Predicted Mid Career Salary") + 
    xlab("Rank")
    

# over underperform -------------------------------------------------------
top_10_over_under = 
      bind_rows(
        
        
        
        
        
        
      )
pay_ranks_data$gam_residual = pay_ranks_data$mid_career_median_pay - pay_ranks_data$gam_fit
top_10_error = bind_rows(pay_ranks_data %>% 
                             arrange(desc(gam_residual)) %>% 
                             head(10) %>% 
                             mutate(earnings_group = 'More Than Expected') %>% 
                             rownames_to_column(df, var = "college_name"),      
                         pay_ranks_data %>% 
                             arrange(gam_residual) %>% 
                             head(10) %>% 
                             mutate(earnings_group = 'Less Than Expected') %>% 
                           rownames_to_column(df, var = "college_name")
) 

final_df$college_name = row.names(final_df)
head(final_df)
top_10_over_under = 
  bind_rows(final_df %>% 
              arrange(desc(residual_pay)) %>% 
              head(10) %>% 
              mutate(earnings_group = 'More Than Expected') %>% 
              rownames_to_column(var = "college_name")
              ,
            final_df %>% 
              arrange(residual_pay) %>% 
              head(10) %>% 
              mutate(earnings_group = 'Less Than Expected') %>% 
              rownames_to_column(var = "college_name")
  )

top_10_over_under

ggplot(top_10_error, aes(x = reorder(friendly_name, gam_residual),
                         y = gam_residual,
                         fill = income_group
                         )) + 
    geom_bar(stat = 'identity', color = 'black') + 
    coord_flip()


head(final_df)

top_10_over_under



# However you most likely want a single-column frame including all cv preds
# cvpreds = h2o.getFrame(gbm_fit@model[["cross_validation_holdout_predictions_frame_id"]][["name"]])
# pay_ranks_data$gbm_cv = as.vector(cvpreds)
# help("h2o.getFrame")
# gbm_fit@model[['cross_validation_holdout_predictions_frame_id']]$name
# scales::percent(Metrics::mape(pay_ranks_data$mid_career_median_pay,
#                               pay_ranks_data$gbm_cv)
#                 )
# 
# Metrics::mape(pay_ranks_data$mid_career_median_pay,
#                               pay_ranks_data$rf_fit)
#                 )
# Metrics::mae(pay_ranks_data$mid_career_median_pay,
#              pay_ranks_data$gam_fit
#              )
# pay_ranks_data %>% 
#     dplyr::select(rank, mid_career_median_pay, gam_fit, rf_fit) %>% 
#     reshape::melt('rank') %>% 
#     ggplot(aes(x = rank, y = value, color = variable)) + 
#     geom_point() + 
#     stat_smooth(se = FALSE) + 
#     facet_grid(variable ~ .)
#     
# 
# (425 - 279)/279
my_fit = mgcv::gam(mid_career_median_pay ~ s(rank) + s(percent_female) + s(percent_stem) + s(undergraduate_enrollment) + 
            s(col_index) + school_sector,
          data = final_df
            )
out_put = sjPlot::plot_model(model_gam$finalModel, 
                   type = "pred", 
                   terms = 'rank'
)
head(out_put$data)
tmp_input = data.frame(rank = 1, 
                       percent_female = mean(final_df$percent_female),
                       percent_stem = mean(final_df$percent_stem),
                       school_sector = 'Private not-for-profit',
                       col_index = mean(final_df$col_index),
                       undergraduate_enrollment = mean(final_df$undergraduate_enrollment)
                       )

# setdiff(names(final_df),
#         names(tmp_input)
#         )
summary()
519/20

predict.gam(model_gam$finalModel,
            newdata = tmp_input
            )

predict(model_gam$finalModel, newdata = tmp_input)

