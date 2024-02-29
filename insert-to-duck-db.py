import os
import duckdb
import glob
import csv


def insert_into_db(csv_file, db_name="duck-monopolies.duckdb"):
    try:
        conn = duckdb.connect(db_name)
        cursor = conn.cursor()

        # Insert data into table
        cursor.execute(f"COPY apk_classes FROM '{csv_file}' WITH (FORMAT 'csv', HEADER 'false')")
        conn.commit()

    except duckdb.Error as e:
        print(f"Database error: {e}")
    finally:
        if conn:
            conn.close()


def get_downloads():
    for folder in glob.glob("data_collection/downloads/*"):
        apk_name = folder.split("data_collection/downloads/")[1]
        path_to_all_classes = folder + "/all_classes.txt"
        yield apk_name, folder, path_to_all_classes


def main():

    failures = []

    for apk, folder, classes in get_downloads():
        try:
            if os.path.exists(folder + "/inserted_duck_db"):
                print("Skipping " + apk + " because it already has been inserted to db")
                continue

            with open(classes, 'r') as file:
                classes = file.readlines()
                # store all lines for a bulk load
                all_lines = []
                for class_path in classes:
                    class_path = class_path.strip()
                    # ignore anything that isn't com. and make sure we remove duplicates with $
                    if "$" not in class_path or len(class_path) > 5 or "AndroidManifest.xml" in class_path or ".dex" not in class_path or class_path != "":
                        # store the tuple (apk name, class path) ready for DB insert
                        all_lines.append((apk, class_path))
                # create a csv rather than push directly into duckdb as it is faster
                new_csv = folder + "/classes.csv"
                with open(new_csv, 'w') as csv_file:
                    writer = csv.writer(csv_file)
                    writer.writerows(all_lines)

                # load the csv
                insert_into_db(new_csv)

            print(f"Data inserted successfully for {apk}")
            # place a flag in the folder to make sure it's not imported again
            open(folder + "/inserted_duck_db", 'a').close()

        except Exception as e:
            print(f"Error: {e}")
            # flag if insert failed
            open(folder + "/failed_inserted_duck_db", 'a').close()
            failures.append(apk)

    if failures:
        print("Failed to insert data for:")
        for fail in failures:
            print(fail)


if __name__ == "__main__":
    main()
