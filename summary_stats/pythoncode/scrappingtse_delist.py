from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import TimeoutException, WebDriverException
import time
import pandas as pd
import os


driver = webdriver.Chrome('/home/guolewen/chromedriver')
driver.get('https://www2.tse.or.jp/tseHpFront/JJK020030Action.do')
# delisted select
driver.find_element_by_name('jjHisiKbnChkbx').click()
driver.find_element_by_xpath('//*[@id="bodycontents"]/div[2]/form/div[1]/table/tbody/tr[6]/td/span/span/label[1]/input').click()
# check second section
driver.find_element_by_xpath('//*[@id="bodycontents"]/div[2]/form/div[1]/table/tbody/tr[6]/td/span/span/label[2]/input').click()
# click search
time.sleep(2)
driver.find_element_by_class_name('activeButton').click()

data_list = []
while True:
    detailed_total_num = len(driver.find_elements_by_name('detail_button'))
    for i in range(detailed_total_num):
        print(i)
        time.sleep(1)
        driver.find_elements_by_name('detail_button')[i].click()
        info_tr = driver.find_element_by_xpath('//*[@id="body_disclosure"]/div/table[1]/tbody/tr[2]')
        info_td = info_tr.find_elements_by_tag_name('td')
        data = [item.text for item in info_td]
        data_list.append(data)
        time.sleep(1)
        driver.back()
    try:
        driver.find_element_by_xpath('//*[@id="bodycontents"]/div[2]/form/div[1]/div[2]/a').click()
        print('Navigating to next page.')
    except (TimeoutException, WebDriverException) as e:
        print('Last Page')
        break

df = pd.DataFrame(data_list, columns=['Code', 'ISIN', 'DelistingDate', 'Industry'])
df.to_csv('/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/code_isin_delist.csv', index=False)