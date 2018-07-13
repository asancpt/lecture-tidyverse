io:
	Rscript -e "rmarkdown::render('examples.Rmd', encoding = 'UTF-8', output_format = 'ioslides_presentation', output_file = 'examples-ioslides.html')"


html:
	Rscript -e "rmarkdown::render('examples.Rmd', encoding = 'UTF-8', output_format = 'html_document', output_file = 'examples-html.html')"

word:
	Rscript -e "rmarkdown::render('examples.Rmd', encoding = 'UTF-8', output_format = 'word_document', output_file = 'examples.docx')"

all:
	make io ;\
	make html ;\
	make word


#  ioslides_presentation: default
#  html_document: default
#  flexdashboard::flex_dashboard: default
#  slidy_presentation: default
#  word_document: default
