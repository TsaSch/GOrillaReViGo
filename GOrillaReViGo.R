library("RSelenium")

# get path for working directory and downloads
path = str_replace_all(getwd(), "/", "\\\\")
downloadpath = "C:\\Downloads"

# project name
filename = "test"

# test background and target file names (double backslash before the file name)
backgroundfile = "\\backgroundtest.txt"
targetfile = "\\targettest.txt"

# open browser
rD <- rsDriver(browser="firefox", port=sample(1:65500, 1), verbose=F)
remDr <- rD[["client"]]

# navigate to GOrilla web page
remDr$navigate("http://cbl-gorilla.cs.technion.ac.il/")

# choose organism
optionOrganism <- remDr$findElement(using = 'xpath', "//*/option[@value = 'MUS_MUSCULUS']")
optionOrganism$clickElement()

# change run mode
optionrunmode <- remDr$findElement(using = 'xpath', "//*/INPUT[@value = 'hg']")
optionrunmode$clickElement()

# output results in Excel file
optionExcel <- remDr$findElement(using = 'name', value = 'output_excel')
optionExcel$clickElement()

# output results in Excel file
optionReViGo <- remDr$findElement(using = 'name', value = 'output_revigo')
optionReViGo$clickElement()

# paste target set
optiontargetset <- remDr$findElement(using = 'name', value = 'target_file_name')
optiontargetset$sendKeysToElement(list(paste0(path, targetfile)))

# paste background set 
optiontargetset <- remDr$findElement(using = 'name', value = 'background_file_name')
optiontargetset$sendKeysToElement(list(paste0(path, backgroundfile)))

# start GOrilla analysis
optionGObtn <- remDr$findElement(using = 'name', value = 'run_gogo_button')
optionGObtn$clickElement()

Sys.sleep(15)

# save GOrilla Excel export
optionXLS <- remDr$findElement(using = "xpath", '//a[contains(@href,"GO.xls")]')
optionXLS$clickElement()

# rename and move file to current directory
GO <- read.delim(paste0(downloadpath, "\\GO.xls"))
write.csv2(GO, paste0(getwd(), "\\GO\\GO_", filename, ".csv"), row.names = FALSE)
file.remove(paste0(downloadpath, "\\GO.xls"))

# forward results to ReViGo analysis
optionRevibtn <- remDr$findElement(using = "xpath", "//a[contains(@onclick,'document.revigoForm.submit();')]")
optionRevibtn$clickElement()

Sys.sleep(15)

# switch to ReViGo tab
remDr$switchToWindow(remDr$getWindowHandles()[[2]])

# accept cookies
remDr$findElement(using = "css selector", value = "button.ui-button:nth-child(1)")$clickElement()

# start ReViGo analysis
optionstartReViGo <- remDr$findElement(using = 'xpath', '//*[@id="ctl00_MasterContent_btnStart"]')
optionstartReViGo$clickElement()

Sys.sleep(15)

# export results as .tsv
optionTSV <- remDr$findElement(using = "xpath", '//a[contains(@href,"aTable")]')
optionTSV$clickElement()

# rename and move file to current directory
revigo <- read.delim(paste0(downloadpath, "\\Revigo.tsv"), header=TRUE)
write.csv2(revigo, paste0(getwd(), "\\GO\\Revigo_", filename, ".csv"), row.names = FALSE)
file.remove(paste0(downloadpath, "\\Revigo.tsv"))

remDr$closeWindow()
remDr$close()
remDr$closeServer()
