import pandas as pd
import matplotlib.pyplot as plt

data_path = 'sdks_count.csv'
data = pd.read_csv(data_path)

data_sorted = data.sort_values(by='C2', ascending=False)

plt.figure(figsize=(10, 6))

categories = data_sorted['C3'].unique()
colors = {'Google': 'blue', 'Facebook': 'red', 'Unity': 'green', 'AppLovin': 'purple', 'Other': 'gray'}

for category in categories:
    category_data = data_sorted[data_sorted['C3'] == category]

    plt.scatter(category_data.index, category_data['C2'], label=category, color=colors.get(category))

# plt.title('SDK Package Usage in APKs', fontsize=19)
plt.xlabel('SDK Package', fontsize=15)
plt.ylabel('Number of APKs Package Appears In', fontsize=15)
plt.grid(True)
plt.legend(title='SDK', fontsize=15)

plt.xticks([])

y_ticks = range(0, 650000, 50000) 
plt.yticks(y_ticks)
plt.yticks(fontsize=15)

plt.savefig("SDKCountsGraph.pdf", format="pdf", bbox_inches="tight")
plt.show()
