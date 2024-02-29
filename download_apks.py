import csv
import os
import sys
import subprocess
from multiprocessing import Pool
from shutil import which, rmtree
import find_classes  # find_classes.py


def download_apks(args):
    folder, apk_name, command = args
    apk_name_ext = apk_name + ".apk"
    cmd = command.split(" ")
    # check if this download has previously been done or is a re-run due to some failure on previous run
    if os.path.exists(folder + "failed_inserted_db"):
        print(f"re-running download job for {apk_name} as it previously failed")
    elif os.path.exists(folder + "done"):
        print(f"download job for {apk_name} already completed, skipping")
        return
    else:
        print(cmd)
    # create folder for download
    if not os.path.exists(folder):
        os.mkdir(folder)
    # download
    subprocess.run(cmd)
    # run apktool on apk
    subprocess.run(["java", "-jar", "../../../apktool.jar", "-f", "d", apk_name_ext], cwd=folder)

    # create all_classes.txt
    directory_path = f"{folder}/{apk_name}"
    classes = find_classes.list_smali_classes(directory_path)
    find_classes.write_file(classes, folder + "/all_classes.txt")

    # delete apk
    os.remove(folder + apk_name_ext)
    # delete apktool output
    try:
        rmtree(folder + apk_name)
    except Exception as e:
        print(f"Could not delete outputs: {e}")

    # if everything is ok, in reaching here we can delete failed_inserted_db if it exists
    if os.path.exists(folder + "failed_inserted_db"):
        os.remove(folder + "failed_inserted_db")

    # set flag in folder to show this was done in case we need to resume
    open(folder + "done", 'a').close()


def get_downloads(download_list, n_downloads, key):
    with open(download_list) as data:
        reader = csv.DictReader(data)
        counter = 0

        # for each row in the download list, return the curl command and the location of the download
        for row in reader:
            counter += 1
            if counter > n_downloads:
                return None

            yield f"./data_collection/downloads/{row['pkg_name']}/", f"{row['pkg_name']}", f"curl -o ./data_collection/downloads/{row['pkg_name']}/{row['pkg_name']}.apk -G -d apikey={key} -d sha256={row['sha256']} https://androzoo.uni.lu/api/download"


def main():
    if len(sys.argv) != 5:
        print("Usage: python download_apks.py <n concurrency> <n downloads> <path_to_download_list.csv> <api key>")
        sys.exit(1)

    pool_size = int(sys.argv[1])
    n_downloads = int(sys.argv[2])
    download_list = sys.argv[3]
    api_key = sys.argv[4]

    if not os.path.exists("data_collection/downloads/"):
        print("creating downloads folder")
        os.mkdir("data_collection/downloads/")

    if not os.path.exists(download_list):
        print("download list does not exist")
        sys.exit(1)

    if not os.path.exists("ClassyShark.jar"):
        print("ClassyShark.jar not found in root of repo")
        sys.exit(1)

    if not which("java"):
        print("java not found to run ClassyShark.jar")
        sys.exit(1)

    with Pool(processes=pool_size) as p:
        p.map(download_apks, get_downloads(download_list, n_downloads, api_key))


if __name__ == "__main__":
    main()
