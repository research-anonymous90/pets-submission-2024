import glob
import csv

# script to convert all the all_classes.txt files into a pre-prepared classes.csv with the apk name in a column


def get_all_classes():
    for folder in glob.glob("data_collection/downloads/*"):
        apk_name = folder.split("data_collection/downloads/")[1]
        path_to_all_classes = folder + "/all_classes.txt"
        yield apk_name, folder, path_to_all_classes


def read_csv(path_to_all_classes):
    with open(path_to_all_classes) as f:
        reader = csv.reader(f)


def create_csv_file(apk, folder, path_to_all_classes):
    with open(path_to_all_classes, 'r') as file:
        classes = file.readlines()
        # store all lines for a bulk load
        all_lines = []
        for class_path in classes:
            class_path = class_path.strip()
            # ignore anything that isn't com. and make sure we remove duplicates with $
            if (class_path.startswith("com.") or class_path.startswith("net.") or class_path.startswith("org.")) and "$" not in class_path:
                # store the tuple (apk name, class path) ready for DB insert
                all_lines.append((apk, class_path))
        # create a csv rather than push directly into duckdb as it is faster
        new_csv = folder + "/classes.csv"
        with open(new_csv, 'w') as csv_file:
            writer = csv.writer(csv_file)
            writer.writerows(all_lines)


if __name__ == '__main__':
    pass
