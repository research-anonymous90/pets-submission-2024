import seaborn as sns
import matplotlib.pyplot as plt
import pandas as pd

sdk_data = pd.read_csv('sdks_count.csv')

plt.figure(figsize=(10, 8))

sns.boxplot(x=sdk_data['C2'], color="lightblue", fliersize=0) 

# Calculate the IQR
Q1 = sdk_data['C2'].quantile(0.25)
Q3 = sdk_data['C2'].quantile(0.75)
IQR = Q3 - Q1
outlier_condition = (sdk_data['C2'] < (Q1 - 1.5 * IQR)) | (sdk_data['C2'] > (Q3 + 1.5 * IQR))
outliers = sdk_data[outlier_condition]

class_colors = {
    'Google': 'green',
    'Facebook': 'blue',
    'Unity': 'red',
    'AppLovin': 'purple'
}


legend_handles = []  
for class_name, color in class_colors.items():
    legend_handles.append(plt.plot([], [], marker='D', color=color, ls="", markersize=5, label=class_name)[0])

# Plot outliers
for idx, row in outliers.iterrows():
    plt.plot(row['C2'], 0, marker='D', color=class_colors.get(row['C3'], 'black'), markersize=5)

# Overlay data points for non-outliers
non_outliers = sdk_data[~outlier_condition]
sns.stripplot(x=non_outliers['C2'], color="grey", size=3, jitter=True)

plt.xlabel('Number of Apps SDKs Appear In', fontsize=15)
# plt.title('Box Plot of SDK Usage Count', fontsize=19)

plt.minorticks_on()
plt.grid(which='major', linestyle='-', linewidth='0.5', color='lightgray')
plt.grid(which='minor', linestyle=':', linewidth='0.35', color='lightgray')

plt.xticks(fontsize=15)

plt.legend(handles=legend_handles, title="SDK", fontsize=15)

plt.savefig("SDKCountsPlot.pdf", format="pdf", bbox_inches="tight")
plt.show()
