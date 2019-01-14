github:
	Rscript -e "rmarkdown::render('README.Rmd', encoding = 'UTF-8', output_format = 'github_document')"

html:
	Rscript -e "rmarkdown::render('README.Rmd', encoding = 'UTF-8', output_format = 'html_document')"
