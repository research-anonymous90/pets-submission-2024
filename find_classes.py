import os, sys

def list_smali_classes(directory):
    class_list = []

    for root, dirs, files in os.walk(directory):
        for file in files:
            if file.endswith(".smali"):
                class_name = os.path.join(root, file)[len(directory):].replace(os.sep, '.')
                class_name = class_name[:-6].lstrip('.')
                class_name = '.'.join(class_name.split('.')[1:])
                class_list.append(class_name)

    return class_list

def write_file(class_list, filename="all_classes.txt"):
    with open(filename, 'w') as file:
        for class_name in class_list:
            file.write(class_name + '\n')


if __name__ == "__main__":

    if len(sys.argv) != 2:
        print("Usage: python find_classes.py <path_to_decompile_dir>")
        sys.exit(1)

    directory_path = sys.argv[1]
    classes = list_smali_classes(directory_path)
    write_file(classes)
