from selenium import webdriver
from selenium.webdriver.common.keys import Keys
from selenium.webdriver.support.ui import Select
from selenium.common.exceptions import TimeoutException, WebDriverException
import time
import pandas as pd
import os


driver = webdriver.Chrome('/home/guolewen/chromedriver')
driver.get('https://www2.tse.or.jp/tseHpFront/JJK020030Action.do')
# number displayed
select_number_display = Select(driver.find_element_by_name('dspSsuPd'))
select_number_display.select_by_value('10')
# check box delisted include
# driver.find_element_by_name('jjHisiKbnChkbx').click()
# check first section
driver.find_element_by_xpath('//*[@id="bodycontents"]/div[2]/form/div[1]/table/tbody/tr[6]/td/span/span/label[1]/input').click()
# check second section
driver.find_element_by_xpath('//*[@id="bodycontents"]/div[2]/form/div[1]/table/tbody/tr[6]/td/span/span/label[2]/input').click()
# click search
time.sleep(2)
# select industry
"""
industry_dict = {'Fishery, Agriculture & Forestry' : '0050',
                 'Mining': '1050',
                 'Construction': '2050',
                 'Foods': '3050',
                 'Textiles & Apparels': '3100',
                 'Pulp & Paper': '3150',
                 'Chemicals': '3200',
                 'Pharmaceutical': '3250',
                 'Oil & Coal Products': '3300',
                 'Rubber Products': '3350',
                 'Glass & Ceramics Products': '3400',
                 'Iron & Steel': '3450',
                 'Nonferrous Metals': '3500',
                 'Metal Products': '3550',
                 'Machinery': '3600',
                 'Electric Appliances': '3650',
                 'Transportation Equipment': '3700',
                 'Precision Instruments': '3750',
                 'Other Products': '3800',
                 'Electric Power & Gas': '4050',
                 'Land Transportation': '5050',
                 'Marine Transportation': '5100',
                 'Air Transportation': '5150',
                 'Warehousing & Harbor Transportation Services': '5200',
                 'Information & Communication': '5250',
                 'Wholesale Trade': '6050',
                 'Retail Trade': '6100',
                 'Banks': '7050',
                 'Securities & Commodity Futures': '7100',
                 'Insurance': '7150',
                 'Other Financing Business': '7200',
                 'Real Estate': '8050'}
"""
industry_dict = {
                 'Services': '9050'}

for k, v in industry_dict.items():
    select_industry_search = Select(driver.find_element_by_name('gyshKbnPd'))
    select_industry_search.select_by_value(v)
    driver.find_element_by_class_name('activeButton').click()
    data_list = []
    while True:
        detailed_total_num = len(driver.find_elements_by_name('detail_button'))
        for i in range(detailed_total_num):
            print(i)
            time.sleep(1)
            driver.find_elements_by_name('detail_button')[i].click()
            info_tr = driver.find_element_by_xpath('//*[@id="body_basicInformation"]/div/table[1]/tbody/tr[2]')
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

    df = pd.DataFrame(data_list, columns=['Code', 'ISIN', 'Market', 'Industry', 'BalaceSheetDate', 'TradingUnit'])
    file_p = os.path.join('/media/guolewen/regular_files/guolewen/Market_invariance/JAPAN/Code_ISIN/', k + '.csv')
    df.to_csv(file_p, index=False)
    time.sleep(100)
    driver.get('https://www2.tse.or.jp/tseHpFront/JJK020030Action.do')
    # number displayed
    select_number_display = Select(driver.find_element_by_name('dspSsuPd'))
    select_number_display.select_by_value('10')
    # check box delisted include
    # driver.find_element_by_name('jjHisiKbnChkbx').click()
    # check first section
    driver.find_element_by_xpath(
        '//*[@id="bodycontents"]/div[2]/form/div[1]/table/tbody/tr[6]/td/span/span/label[1]/input').click()
    # check second section
    driver.find_element_by_xpath(
        '//*[@id="bodycontents"]/div[2]/form/div[1]/table/tbody/tr[6]/td/span/span/label[2]/input').click()
