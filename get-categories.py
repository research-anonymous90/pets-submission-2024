import csv
from google_play_scraper import app

with open('full_APKName_list.csv', 'r') as apk_f:
    unique_apk_list = csv.reader(apk_f)
    next(unique_apk_list)

    with open('app-categories.csv', mode='w', newline='', encoding='utf-8') as file:
        csv_writer = csv.writer(file)
        csv_writer.writerow(['APKName', 'Category'])

        for apk_name in unique_apk_list:
            print(apk_name[0])

            try:
                result = app(apk_name[0], lang='en', country='us')
                category = result['genre']
                print(f"Category for {apk_name[0]}: {category}")

            except Exception as e:
                print(f"Error fetching category for {apk_name[0]}: {e}")
                category = None

            csv_writer.writerow([apk_name[0], category])
