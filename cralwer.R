#java -Dwebdriver.gecko.driver="geckodriver.exe" -jar selenium-server-standalone-3.9.1.jar -port 4445

#install.packages("rvest")
#install.packages("RSelenium")
#install.packages("httr")
#install.packages("stringr")

version
library(rvest)
library(RSelenium)
library(httr)
library(stringr)


fundGet <- function(frontPage, fundList){
  fundNames <- read_html(frontPage[[1]]) %>% html_nodes('.fund-grid-list') %>% html_nodes('.tooltip-help') %>% html_attr('title') #펀드 이름 추출하기
  
  fundInfos <- read_html(frontPage[[1]]) %>% html_nodes('.fund-grid-list') %>% html_nodes('.info-txt') %>% html_text() #펀드 기본정보 추출하기
  fundInfos <- gsub(" ","",fundInfos) #공백 공간 제거
  fundInfos <- gsub("\\\n"," ",fundInfos) #엔터 공간을 공백 공간으로 변환 
  fundInfos <- trimws(fundInfos) # 앞 뒤 공백 제거
  
  fundRates <- read_html(frontPage[[1]]) %>% html_nodes('.fund-grid-list') %>% html_nodes('.rate') %>% html_text() #펀드 수익률 추출하기
  fundRates <- gsub(" ","",fundRates) 
  fundRates <- gsub("\\\n"," ",fundRates) 
  
  fundRisk <- read_html(frontPage[[1]]) %>% html_nodes('.fund-grid-list') %>% html_nodes('.sort') %>% html_text() #펀드 위험도 추출하기
  fundRisk <- gsub(" ","",fundRisk)
  fundRisk <- gsub("\\\n"," ",fundRisk)
  fundRisk <- trimws(fundRisk)
  
  fundGrade <- read_html(frontPage[[1]]) %>% html_nodes('.fund-grid-list') %>% html_nodes('.grade') %>% html_text() #펀드 등급 추출하기
  fundGrade <- gsub(" ","",fundGrade)
  fundGrade <- gsub("\\\n"," ",fundGrade)
  fundGrade <- trimws(fundGrade)
  
  fundTemp <- data.frame(name=fundNames, type=fundInfos, risk=fundRisk, grade=fundGrade, rate=fundRates)
  
  fundList <- rbind(fundList, fundTemp)
  
  return(fundList)
}
getwd()

fundList <- data.frame(name=NA, type=NA, risk=NA, grade=NA, rate=NA)
fundList <- fundList[0,]

urls <- "http://www.fundsupermarket.co.kr/fmm/FMM1010301/main.do" #펀드 슈퍼마켓 사이트 검색결과 페이지

ch=wdman::chrome(port=4445L) #크롬드라이버를 포트 4567번에 배정
remDr=remoteDriver(port=4445L, browserName='chrome') #remort설정
remDr$open() #크롬 Open
remDr$navigate(urls) #설정 URL로 이동

webElem <- remDr$findElement("css", "body") #css의 body를 element로 찾아 지정
webElem$sendKeysToElement(list(key = "end")) #해당 화면의 끝(end)으로 이동

frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
fundList <- fundGet(frontPage, fundList)

for (i in 1:10) {
  if(i==1){
    for (j in 2:11) {
      webElemButton <- remDr$findElements(using = 'xpath',value = paste0('//*[@id="container"]/div[1]/div[1]/div[3]/div/span/a[',j,']')) #특정 번호의 xpath 위치 지정
      remDr$mouseMoveToLocation(webElement = webElemButton[[1]]) #해당 버튼으로 포인터 이동
      remDr$click() #마우스 클릭 액션
      
      Sys.sleep(6) #6초 대기
      
      webElem <- remDr$findElement("css", "body") #css의 body를 element로 찾아 지정
      webElem$sendKeysToElement(list(key = "end")) #해당 화면의 끝(end)으로 이동
      
      frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
      fundList <- fundGet(frontPage, fundList)
    }
  }else if(i==10){
    for (j in 4:8) {
      webElemButton <- remDr$findElements(using = 'xpath',value = paste0('//*[@id="container"]/div[1]/div[1]/div[3]/div/span/a[',j,']')) #특정 번호의 xpath 위치 지정
      remDr$mouseMoveToLocation(webElement = webElemButton[[1]]) #해당 버튼으로 포인터 이동
      remDr$click() #마우스 클릭 액션
      
      Sys.sleep(6) #6초 대기
      
      webElem <- remDr$findElement("css", "body") #css의 body를 element로 찾아 지정
      webElem$sendKeysToElement(list(key = "end")) #해당 화면의 끝(end)으로 이동
      
      frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
      fundList <- fundGet(frontPage, fundList)
    }
  }else{
    for (j in 4:13) {
      webElemButton <- remDr$findElements(using = 'xpath',value = paste0('//*[@id="container"]/div[1]/div[1]/div[3]/div/span/a[',j,']')) #특정 번호의 xpath 위치 지정
      remDr$mouseMoveToLocation(webElement = webElemButton[[1]]) #해당 버튼으로 포인터 이동
      remDr$click() #마우스 클릭 액션
      
      Sys.sleep(6) #6초 대기
      
      webElem <- remDr$findElement("css", "body") #css의 body를 element로 찾아 지정
      webElem$sendKeysToElement(list(key = "end")) #해당 화면의 끝(end)으로 이동
      
      frontPage <- remDr$getPageSource() #페이지 전체 소스 가져오기
      fundList <- fundGet(frontPage, fundList)
    }
  }
}

remDr$close() #크롬 Close

write.csv(fundList, "fundList.csv")